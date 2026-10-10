import hashlib
import io
import unittest
import storage_backup as b
import recovery_restore as r
from test_recovery_preflight import SyntheticSource

class Missing(Exception):
    def __init__(self,code='NoSuchKey',status=500): self.response={'Error':{'Code':code},'ResponseMetadata':{'HTTPStatusCode':status}}
class Target:
    def __init__(self): self.objects,self.puts={r.FIXTURE_KEY:r.REPLACEMENT},[]; self.error='NoSuchKey'; self.status=500
    def get_object(self,**kw):
        if kw['Key'] not in self.objects: raise Missing(self.error,self.status)
        return {'Body':io.BytesIO(self.objects[kw['Key']])}
    def put_object(self,**kw):
        self.puts.append(kw['Key']); self.objects[kw['Key']]=kw['Body']
class Tests(unittest.TestCase):
    def setUp(self):
        self.payload,self.manifest,_=b.build_snapshot(SyntheticSource())
        self.expected={hashlib.sha256(f['key'].encode()).hexdigest():f for f in self.manifest['files'][:10]}
        self.t=Target()
    def run_restore(self): return r.restore_files(self.t,self.payload,self.manifest,self.expected)
    def test_ten_restored_newer_excluded(self):
        result=self.run_restore()
        self.assertEqual(result['uploaded_files'],10)
        self.assertEqual(len(self.t.puts),10)
        self.assertNotIn(self.manifest['files'][10]['key'],self.t.puts)
        self.assertEqual(self.run_restore()['uploaded_files'],0)
    def test_legacy_404_with_positive_controls(self):
        self.t.error='legacy'; self.t.status=404
        self.assertEqual(self.run_restore()['uploaded_files'],10)
    def test_failed_positive_control_never_writes(self):
        self.t.objects[r.FIXTURE_KEY]=b'wrong'
        with self.assertRaisesRegex(b.BackupError,'probe'): self.run_restore()
        self.assertEqual(self.t.puts,[])
    def test_access_denied_never_writes(self):
        self.t.error='AccessDenied'; self.t.status=403
        with self.assertRaisesRegex(b.BackupError,'absence'): self.run_restore()
        self.assertEqual(self.t.puts,[])
    def test_generic_error_not_missing_no_write(self):
        self.t.error='InternalError'
        with self.assertRaisesRegex(b.BackupError,'absence'): self.run_restore()
        self.assertEqual(self.t.puts,[])
    def test_different_existing_file_blocks_all_writes(self):
        self.t.objects[self.manifest['files'][9]['key']]=b'evil'
        with self.assertRaisesRegex(b.BackupError,'differ'): self.run_restore()
        self.assertEqual(self.t.puts,[])
    def test_wrong_count_blocks_all_writes(self):
        self.expected.pop(next(iter(self.expected)))
        with self.assertRaisesRegex(b.BackupError,'scope'): self.run_restore()
        self.assertEqual(self.t.puts,[])
    def test_corrupt_archive_blocks_all_writes(self):
        self.manifest['files'][0]['sha256']='0'*64
        with self.assertRaises(b.BackupError): self.run_restore()
        self.assertEqual(self.t.puts,[])
if __name__=='__main__': unittest.main()
