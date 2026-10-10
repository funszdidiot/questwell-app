import hashlib
import io
import json
import unittest
import urllib.error
from unittest.mock import patch,mock_open
import recovery_access_check as r
class Tests(unittest.TestCase):
    def test_owner_allowed_other_owner_denied(self): self.run_check(False)
    def test_cross_owner_leak_fails(self):
        with self.assertRaisesRegex(RuntimeError,'unexpectedly allowed'): self.run_check(True)
    def run_check(self,leak):
        keys=['synthetic-other/'+str(i) for i in range(10)]
        expected={hashlib.sha256(k.encode()).hexdigest():{} for k in keys}
        def call(path,method,headers,data=None):
            if path.startswith('/auth/'): return json.dumps({'user':{'id':r.USER},'access_token':'test'}).encode()
            if path.endswith(r.KEY): return r.REPLACEMENT
            if leak: return b'not allowed'
            raise urllib.error.HTTPError('https://synthetic.invalid',404,'Not Found',{},io.BytesIO(b'{"code":"NoSuchKey"}'))
        with patch('builtins.open',mock_open(read_data=json.dumps(expected))),patch.object(r,'inventory',return_value=({k:{} for k in keys},0)):
            result=r.check(object(),'test','public',call)
        self.assertEqual(result['cross_owner_private_files_denied'],10)
        self.assertFalse(result['real_recovered_owner_sign_in_verified'])
if __name__=='__main__': unittest.main()
