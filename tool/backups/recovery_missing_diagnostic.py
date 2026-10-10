"""Read-only error classification for one approved recovery path; no writes."""
import collections
import re
import hashlib
import json
import os
import boto3
from botocore.config import Config
import recovery_preflight as p
from storage_backup import inventory, read_bounded
cfg=Config(signature_version='s3v4',connect_timeout=15,read_timeout=30,
    retries={'total_max_attempts':1},s3={'addressing_style':'path'},
    request_checksum_calculation='when_required',response_checksum_validation='when_required')
client=boto3.client('s3',region_name='us-east-2',endpoint_url=f'https://{p.TARGET}.storage.supabase.co/storage/v1/s3',
    aws_access_key_id=os.environ['SUPABASE_RECOVERY_STORAGE_ACCESS_KEY_ID'],
    aws_secret_access_key=os.environ['SUPABASE_RECOVERY_STORAGE_SECRET_ACCESS_KEY'],config=cfg)
expected=json.load(open('tool/backups/recovery_expected.json'))
listing,_=inventory(client,p.BUCKET)
for key,meta in listing.items():
    if hashlib.sha256(key.encode()).hexdigest() not in expected: continue
    try:
        value=read_bounded(client.get_object(Bucket=p.BUCKET,Key=key),meta['size'])
        print(json.dumps({'result':'bytes_received','size':len(value)}))
    except Exception as exc:
        response=getattr(exc,'response',{})
        code=response.get('Error',{}).get('Code','unknown')
        allowed={'NoSuchKey','NoSuchBucket','AccessDenied','InternalError','InvalidAccessKeyId','SignatureDoesNotMatch','404','403','500','NoSuchObject'}
        status=response.get('ResponseMetadata',{}).get('HTTPStatusCode')
        print(json.dumps({'result':'error','code':code if isinstance(code,str) and re.fullmatch(r'[A-Za-z_]{1,48}',code) else 'other',
            'http_status':status if isinstance(status,int) else None,
            'exception_type':type(exc).__name__ if type(exc).__name__ in {'ClientError','ReadTimeoutError','SSLError','EndpointConnectionError'} else 'other'}))
    break
