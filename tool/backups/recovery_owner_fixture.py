"""Create one approved synthetic owned PNG in the recovery project only."""
import hashlib
import json
import os
import struct
import urllib.request
import zlib

BASE = 'https://czubumijsibtgjwekdpt.supabase.co'
USER = 'cced3e06-f196-4b32-a16f-69e661240cda'
EMAIL = 'questwell-recovery-probe-20261010@example.invalid'
KEY = USER + '/recovery-owner-probe-20261010.png'
BUCKET = 'beta-feedback'


def png(rgb):
    def chunk(kind, data):
        return struct.pack('>I', len(data)) + kind + data + struct.pack('>I', zlib.crc32(kind+data))
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB',1,1,8,2,0,0,0))
            + chunk(b'IDAT', zlib.compress(b'\0'+bytes(rgb))) + chunk(b'IEND',b''))

INITIAL = png((40,90,60))
REPLACEMENT = png((60,110,80))

class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        raise RuntimeError('redirect refused')


def request(path, method, headers, data=None):
    if not path.startswith('/') or path.startswith('//'):
        raise RuntimeError('invalid path')
    req = urllib.request.Request(BASE+path, method=method, headers=headers, data=data)
    with urllib.request.build_opener(NoRedirect).open(req, timeout=30) as response:
        body = response.read(65537)
        if len(body)>65536:
            raise RuntimeError('response too large')
        return body


def create(password, public_key, call=request):
    if not password or not public_key:
        raise RuntimeError('missing fixture credentials')
    session = json.loads(call('/auth/v1/token?grant_type=password','POST',
        {'apikey':public_key,'Content-Type':'application/json'},
        json.dumps({'email':EMAIL,'password':password}).encode()))
    if session.get('user',{}).get('id') != USER or not session.get('access_token'):
        raise RuntimeError('unexpected signed-in account')
    headers = {'apikey':public_key,'Authorization':'Bearer '+session['access_token']}
    # No upsert: an existing fixture is never overwritten during creation.
    call('/storage/v1/object/'+BUCKET+'/'+KEY,'POST',
         {**headers,'Content-Type':'image/png','x-upsert':'false'},INITIAL)
    returned = call('/storage/v1/object/authenticated/'+BUCKET+'/'+KEY,'GET',headers)
    if returned != INITIAL:
        raise RuntimeError('fixture readback mismatch')
    return {'synthetic_fixture_created':True,'authenticated_readback':'passed',
            'fixture_sha256':hashlib.sha256(INITIAL).hexdigest(),
            'fixture_bytes':len(INITIAL),'private_files_restored':0,
            'ownership_preservation_verified':False}


def main():
    try:
        print(json.dumps(create(os.environ.get('SUPABASE_RECOVERY_PROBE_PASSWORD'),
                                os.environ.get('SUPABASE_RECOVERY_PUBLIC_KEY')),sort_keys=True))
        return 0
    except Exception:
        print('Synthetic fixture check stopped; credential and provider details withheld.')
        return 1

if __name__ == '__main__':
    raise SystemExit(main())
