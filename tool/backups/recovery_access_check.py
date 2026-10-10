"""Authenticated synthetic owner access and cross-owner isolation; no writes."""
import hashlib
import json
import os
import urllib.error
from recovery_owner_fixture import BASE, USER, EMAIL, KEY, BUCKET, REPLACEMENT, request
from storage_backup import inventory
from recovery_preflight import TARGET


def check(client,password,public_key,call=request):
    if not password or not public_key: raise RuntimeError('missing credentials')
    session=json.loads(call('/auth/v1/token?grant_type=password','POST',
        {'apikey':public_key,'Content-Type':'application/json'},
        json.dumps({'email':EMAIL,'password':password}).encode()))
    if session.get('user',{}).get('id')!=USER: raise RuntimeError('unexpected account')
    headers={'apikey':public_key,'Authorization':'Bearer '+session['access_token']}
    if call('/storage/v1/object/authenticated/'+BUCKET+'/'+KEY,'GET',headers)!=REPLACEMENT:
        raise RuntimeError('owner positive control failed')
    with open(os.path.join(os.path.dirname(__file__),'recovery_expected.json')) as f: expected=json.load(f)
    listing,_=inventory(client,BUCKET)
    selected=[key for key in listing if hashlib.sha256(key.encode()).hexdigest() in expected]
    if len(selected)!=10: raise RuntimeError('scope mismatch')
    import urllib.parse
    for key in selected:
        path='/storage/v1/object/authenticated/'+BUCKET+'/'+urllib.parse.quote(key,safe='/')
        try: call(path,'GET',headers)
        except urllib.error.HTTPError as error:
            # Require a concrete authorization/masked-not-found result, never a 5xx.
            try:
                body=error.read(4097)
                response=json.loads(body) if len(body)<=4096 else {}
            finally: error.close()
            code=response.get('code',response.get('error'))
            if error.code not in (400,403,404) or code not in ('NoSuchKey','not_found','Not Found','AccessDenied','Unauthorized','unauthorized'):
                raise RuntimeError('unexpected cross-owner error') from None
        else: raise RuntimeError('cross-owner download unexpectedly allowed')
    if call('/storage/v1/object/authenticated/'+BUCKET+'/'+KEY,'GET',headers)!=REPLACEMENT:
        raise RuntimeError('owner final control failed')
    return {'synthetic_sign_in':'passed','own_replaced_fixture_read':'passed',
            'cross_owner_private_files_denied':10,'real_recovered_owner_sign_in_verified':False,
            'storage_writes':0}


def main():
    try:
        import boto3
        from botocore.config import Config
        client=boto3.client('s3',region_name='us-east-2',endpoint_url=f'https://{TARGET}.storage.supabase.co/storage/v1/s3',
            aws_access_key_id=os.environ['SUPABASE_RECOVERY_STORAGE_ACCESS_KEY_ID'],
            aws_secret_access_key=os.environ['SUPABASE_RECOVERY_STORAGE_SECRET_ACCESS_KEY'],
            config=Config(signature_version='s3v4',connect_timeout=15,read_timeout=30,
              retries={'total_max_attempts':1},s3={'addressing_style':'path'}))
        print(json.dumps(check(client,os.environ['SUPABASE_RECOVERY_PROBE_PASSWORD'],
                               os.environ['SUPABASE_RECOVERY_PUBLIC_KEY']),sort_keys=True))
        return 0
    except Exception:
        print('Recovery access verification stopped; private details withheld.')
        return 1
if __name__=='__main__': raise SystemExit(main())
