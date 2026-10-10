"""Replace only the approved synthetic fixture through the recovery S3 key."""
import hashlib
import json
import os
from recovery_owner_fixture import KEY, BUCKET, INITIAL, REPLACEMENT
from storage_backup import read_bounded
from recovery_preflight import TARGET


def replace(client):
    current = read_bounded(client.get_object(Bucket=BUCKET,Key=KEY),len(INITIAL))
    if current != INITIAL:
        raise RuntimeError('unexpected synthetic fixture state')
    client.put_object(Bucket=BUCKET,Key=KEY,Body=REPLACEMENT,ContentType='image/png')
    returned = read_bounded(client.get_object(Bucket=BUCKET,Key=KEY),len(REPLACEMENT))
    if returned != REPLACEMENT:
        raise RuntimeError('synthetic replacement mismatch')
    return {'synthetic_replacement_readback':'passed','private_files_restored':0,
            'sha256':hashlib.sha256(returned).hexdigest(),
            'ownership_verification':'requires independent SQL comparison'}


def main():
    try:
        import boto3
        from botocore.config import Config
        cfg=Config(signature_version='s3v4',connect_timeout=15,read_timeout=30,
          retries={'total_max_attempts':1},s3={'addressing_style':'path'},
          request_checksum_calculation='when_required',response_checksum_validation='when_required')
        client=boto3.client('s3',region_name='us-east-2',
          endpoint_url=f'https://{TARGET}.storage.supabase.co/storage/v1/s3',
          aws_access_key_id=os.environ['SUPABASE_RECOVERY_STORAGE_ACCESS_KEY_ID'],
          aws_secret_access_key=os.environ['SUPABASE_RECOVERY_STORAGE_SECRET_ACCESS_KEY'],config=cfg)
        print(json.dumps(replace(client),sort_keys=True))
        return 0
    except Exception:
        print('Synthetic replacement stopped; provider details withheld.')
        return 1

if __name__=='__main__': raise SystemExit(main())
