"""Restore only the ten approved recovery paths from a pinned verified archive."""
import hashlib
import io
import json
import os
import tarfile
import recovery_preflight as p
from recovery_owner_fixture import KEY as FIXTURE_KEY, REPLACEMENT
from storage_backup import BackupError, read_bounded, verify_archive

class InventoryWithoutFixture:
    def __init__(self, target): self.target=target
    def list_objects_v2(self, **kwargs):
        page=self.target.list_objects_v2(**kwargs)
        kept=[]
        for item in page.get('Contents',[]):
            if item['Key']==FIXTURE_KEY:
                if item['Size']!=len(REPLACEMENT) or item['ETag'].strip('"')!=hashlib.md5(REPLACEMENT).hexdigest():
                    raise BackupError('synthetic probe drift')
            else: kept.append(item)
        return {**page,'Contents':kept}


def restore_files(target, payload, manifest, expected):
    verify_archive(payload,manifest)
    selected=[f for f in manifest['files'] if hashlib.sha256(f['key'].encode()).hexdigest() in expected]
    if len(selected)!=10 or len({f['key'] for f in selected})!=10:
        raise BackupError('unexpected restoration scope')
    # Positive control with the same privileged key and private bucket.
    if read_bounded(target.get_object(Bucket=p.BUCKET,Key=FIXTURE_KEY),len(REPLACEMENT)) != REPLACEMENT:
        raise BackupError('recovery access control probe failed')
    pending=[]
    # Prove absence or exact existing bytes for every selected file before writes.
    for item in selected:
        try:
            value=read_bounded(target.get_object(Bucket=p.BUCKET,Key=item['key']),item['size'])
        except Exception as exc:
            code=getattr(exc,'response',{}).get('Error',{}).get('Code')
            status=getattr(exc,'response',{}).get('ResponseMetadata',{}).get('HTTPStatusCode')
            # A metadata-only restored object can return a legacy/unparsed 404.
            # Exact inventory was verified by run(); the same full-access S3 key
            # must read the owned private fixture both before and after these reads.
            if code!='NoSuchKey' and status!=404:
                raise BackupError('target absence not established') from None
            pending.append(item)
        else:
            if len(value)!=item['size'] or hashlib.sha256(value).hexdigest()!=item['sha256']:
                raise BackupError('existing target bytes differ')
    if read_bounded(target.get_object(Bucket=p.BUCKET,Key=FIXTURE_KEY),len(REPLACEMENT)) != REPLACEMENT:
        raise BackupError('recovery access control probe failed')
    with tarfile.open(fileobj=io.BytesIO(payload),mode='r:gz') as archive:
        for item in pending:
            value=archive.extractfile(item['member']).read(item['size']+1)
            if len(value)!=item['size'] or hashlib.sha256(value).hexdigest()!=item['sha256']:
                raise BackupError('archive member changed')
            kwargs={'Bucket':p.BUCKET,'Key':item['key'],'Body':value,
                    'ContentType':item['content_type'],'Metadata':item.get('metadata',{})}
            if item.get('cache_control'): kwargs['CacheControl']=item['cache_control']
            target.put_object(**kwargs)
            result=read_bounded(target.get_object(Bucket=p.BUCKET,Key=item['key']),item['size'])
            if len(result)!=item['size'] or hashlib.sha256(result).hexdigest()!=item['sha256']:
                raise BackupError('restored file checksum mismatch')
    return {'selected_files':10,'uploaded_files':len(pending),'already_verified_files':10-len(pending),
            'file_checksums':'passed','excluded_newer_files':1,
            'ownership_verification':'requires independent SQL comparison'}


def run(b2,target):
    p.check(b2,InventoryWithoutFixture(target))
    payload=read_bounded(b2.get_object(Bucket=p.B2_BUCKET,Key=p.BASE+'.tar.gz'),p.ARCHIVE_SIZE)
    if len(payload)!=p.ARCHIVE_SIZE or hashlib.sha256(payload).hexdigest()!=p.ARCHIVE_SHA:
        raise BackupError('pinned archive changed')
    with tarfile.open(fileobj=io.BytesIO(payload),mode='r:gz') as archive:
        manifest=json.load(archive.extractfile('manifest.json'))
    with open(os.path.join(os.path.dirname(__file__),'recovery_expected.json')) as handle:
        expected=json.load(handle)
    return restore_files(target,payload,manifest,expected)


def main():
    try:
        if os.environ.get('QUESTWELL_RECOVERY_TEN_FILES_APPROVED')!='true':
            raise BackupError('restore gate closed')
        import boto3
        from botocore.config import Config
        cfg=Config(signature_version='s3v4',connect_timeout=15,read_timeout=60,
          retries={'total_max_attempts':1},s3={'addressing_style':'path'},
          request_checksum_calculation='when_required',response_checksum_validation='when_required')
        b2=boto3.client('s3',region_name='us-east-005',endpoint_url='https://s3.us-east-005.backblazeb2.com',
            aws_access_key_id=os.environ['B2_KEY_ID'],aws_secret_access_key=os.environ['B2_APPLICATION_KEY'],config=cfg)
        target=boto3.client('s3',region_name='us-east-2',endpoint_url=f'https://{p.TARGET}.storage.supabase.co/storage/v1/s3',
            aws_access_key_id=os.environ['SUPABASE_RECOVERY_STORAGE_ACCESS_KEY_ID'],
            aws_secret_access_key=os.environ['SUPABASE_RECOVERY_STORAGE_SECRET_ACCESS_KEY'],config=cfg)
        print(json.dumps(run(b2,target),sort_keys=True))
        return 0
    except BackupError as exc:
        print('Recovery stopped: '+str(exc))
        return 1
    except Exception:
        print('Recovery stopped: provider details withheld.')
        return 1

if __name__=='__main__': raise SystemExit(main())
