import datetime as dt
import hashlib
import io
import json
import unittest
from unittest.mock import patch, mock_open
import recovery_preflight as r
import storage_backup as b

class SyntheticSource:
    def list_buckets(self):
        return {'Buckets': [{'Name': b.SOURCE_BUCKET}]}
    def list_objects_v2(self, **kwargs):
        return {'Contents': [{'Key': f'synthetic/{i}', 'Size': 4, 'ETag': '"test"',
          'LastModified': dt.datetime(2026,10,9,tzinfo=dt.timezone.utc)} for i in range(11)]}
    def get_object(self, **kwargs):
        return {'Body': io.BytesIO(b'data'), 'ETag': '"test"'}

class ReadOnlyB2:
    def __init__(self, payload, marker):
        self.payload, self.marker = payload, marker
    def get_object(self, **kw):
        assert kw['Bucket'] == r.B2_BUCKET
        assert kw['Key'] in (r.BASE+'.verified.json', r.BASE+'.tar.gz')
        return {'Body': io.BytesIO(json.dumps(self.marker).encode() if kw['Key'].endswith('.json') else self.payload)}

class Target:
    def __init__(self):
        self.items = SyntheticSource().list_objects_v2()['Contents'][:10]
    def list_objects_v2(self, **kw):
        assert kw['Bucket'] == r.BUCKET
        return {'Contents': self.items}

class RecoveryTests(unittest.TestCase):
    def setUp(self):
        self.payload, self.manifest, _ = b.build_snapshot(SyntheticSource())
        self.sha = hashlib.sha256(self.payload).hexdigest()
        self.marker = {'sha256': self.sha, 'storage_round_trip':'passed'}
        self.target = Target()
        self.expected = {hashlib.sha256(f['key'].encode()).hexdigest(): {'size':f['size'],'etag':f['etag']} for f in self.manifest['files'] if f['key'] in {item['Key'] for item in self.target.items}}
        for ctx in (patch.object(r, 'ARCHIVE_SHA', self.sha), patch.object(r, 'ARCHIVE_SIZE', len(self.payload)),
                    patch('builtins.open', mock_open(read_data=json.dumps(self.expected)))):
            ctx.start()
            self.addCleanup(ctx.stop)
    def check(self):
        return r.check(ReadOnlyB2(self.payload,self.marker),self.target)
    def test_exact_ten_selected_and_newer_excluded_without_writes(self):
        result = self.check()
        self.assertEqual(result['matched_files'],10)
        self.assertEqual(result['excluded_newer_files'],1)
        self.assertFalse(result['file_restore_executed'])
        self.assertNotIn('synthetic/',json.dumps(result))
    def test_corrupt_archive_rejected(self):
        self.payload = b'X'+self.payload[1:]
        with self.assertRaisesRegex(b.BackupError,'pinned archive'): self.check()
    def test_unverified_marker_rejected(self):
        self.marker['storage_round_trip']='failed'
        with self.assertRaisesRegex(b.BackupError,'marker'): self.check()
    def test_extra_target_file_rejected(self):
        self.target.items = SyntheticSource().list_objects_v2()['Contents']
        with self.assertRaisesRegex(b.BackupError,'inventory drift'): self.check()
    def test_changed_target_metadata_rejected(self):
        self.target.items[0]['Size']=5
        with self.assertRaisesRegex(b.BackupError,'metadata'): self.check()
    def test_wrong_target_path_rejected(self):
        self.target.items[0]['Key']='unexpected/file'
        with self.assertRaisesRegex(b.BackupError,'inventory drift'): self.check()

if __name__ == '__main__': unittest.main()
