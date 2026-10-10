"""Read-only recovery preflight. No upload/delete methods are called."""
import hashlib
import io
import json
import os
import tarfile

from storage_backup import BackupError, inventory, read_bounded, verify_archive

TARGET = 'czubumijsibtgjwekdpt'
BUCKET = 'beta-feedback'
B2_BUCKET = 'questwell-backups-20261009'
BASE = 'questwell/file-backups/live/20261010T024417Z-9129f3e518c846bbb307b3588b94c56b'
ARCHIVE_SHA = '5eaf712e79f55b4c44c2ad6268d2a00bc7ca9fdd0504d6417e962519815a2f3b'
ARCHIVE_SIZE = 9881367


def check(b2, target):
    marker = json.loads(read_bounded(b2.get_object(Bucket=B2_BUCKET, Key=BASE+'.verified.json'), 4096))
    if marker.get('sha256') != ARCHIVE_SHA or marker.get('storage_round_trip') != 'passed':
        raise BackupError('verified marker mismatch')
    payload = read_bounded(b2.get_object(Bucket=B2_BUCKET, Key=BASE+'.tar.gz'), ARCHIVE_SIZE)
    if len(payload) != ARCHIVE_SIZE or hashlib.sha256(payload).hexdigest() != ARCHIVE_SHA:
        raise BackupError('pinned archive mismatch')
    with tarfile.open(fileobj=io.BytesIO(payload), mode='r:gz') as archive:
        member = archive.getmember('manifest.json')
        if member.size > 1024*1024:
            raise BackupError('manifest too large')
        manifest = json.load(archive.extractfile(member))
    if manifest.get('source_project') != 'bdzcazkyypopbanbjnud' or manifest.get('bucket') != BUCKET:
        raise BackupError('wrong backup source')
    verify_archive(payload, manifest)
    if len(manifest['files']) != 11:
        raise BackupError('unexpected archive count')
    expected = json.load(open(os.path.join(os.path.dirname(__file__), 'recovery_expected.json')))
    listing, _ = inventory(target, BUCKET)
    observed = {hashlib.sha256(k.encode()).hexdigest(): v for k,v in listing.items()}
    if set(observed) != set(expected):
        raise BackupError('recovery target inventory drift')
    by_hash = {hashlib.sha256(f['key'].encode()).hexdigest(): f for f in manifest['files']}
    if len(by_hash) != 11 or not set(expected).issubset(by_hash):
        raise BackupError('archive path mismatch')
    for key, exp in expected.items():
        for meta in (observed[key], by_hash[key]):
            if meta['size'] != exp['size'] or meta['etag'].strip('"') != exp['etag'].strip('"'):
                raise BackupError('metadata does not match selected recovery point')
    # No file contents or names are returned to logs; no target GET is used to
    # infer missing bytes from a generic provider failure.
    return {'archive_integrity':'passed','matched_files':10,'excluded_newer_files':1,
            'target_inventory':'passed','file_restore_executed':False,
            'ownership_upload_behavior_verified':False}


def main():
    try:
        import boto3
        from botocore.config import Config
        cfg = Config(signature_version='s3v4',connect_timeout=15,read_timeout=60,
                     retries={'total_max_attempts':1},s3={'addressing_style':'path'},
                     request_checksum_calculation='when_required',response_checksum_validation='when_required')
        b2 = boto3.client('s3',region_name='us-east-005',endpoint_url='https://s3.us-east-005.backblazeb2.com',
            aws_access_key_id=os.environ['B2_KEY_ID'],aws_secret_access_key=os.environ['B2_APPLICATION_KEY'],config=cfg)
        target = boto3.client('s3',region_name='us-east-2',endpoint_url=f'https://{TARGET}.storage.supabase.co/storage/v1/s3',
            aws_access_key_id=os.environ['SUPABASE_RECOVERY_STORAGE_ACCESS_KEY_ID'],
            aws_secret_access_key=os.environ['SUPABASE_RECOVERY_STORAGE_SECRET_ACCESS_KEY'],config=cfg)
        result = check(b2,target)
        print(json.dumps(result,sort_keys=True))
        return 0
    except Exception:
        print('Recovery preflight failed; provider details withheld to protect private paths.')
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
