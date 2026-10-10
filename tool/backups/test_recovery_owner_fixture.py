import json
import unittest
import recovery_owner_fixture as f

class Tests(unittest.TestCase):
    def test_only_pinned_synthetic_upload_and_authenticated_read(self):
        calls=[]
        def call(path, method, headers, data=None):
            calls.append((path,method,headers,data))
            if len(calls)==1: return json.dumps({'user':{'id':f.USER},'access_token':'synthetic-token'}).encode()
            if method=='POST':
                self.assertEqual(path,'/storage/v1/object/beta-feedback/'+f.KEY)
                self.assertEqual(headers['x-upsert'],'false')
                self.assertEqual(data,f.INITIAL)
                return b'{}'
            return f.INITIAL
        result=f.create('synthetic-password','public-key',call)
        self.assertEqual(len(calls),3)
        self.assertEqual(result['private_files_restored'],0)
        self.assertFalse(result['ownership_preservation_verified'])
        self.assertNotIn('synthetic-token',json.dumps(result))
    def test_wrong_user_never_uploads(self):
        calls=[]
        def call(*args):
            calls.append(args)
            return b'{"user":{"id":"wrong"},"access_token":"test"}'
        with self.assertRaisesRegex(RuntimeError,'unexpected'): f.create('pass','pub',call)
        self.assertEqual(len(calls),1)
    def test_missing_password_never_connects(self):
        def call(*args): self.fail('network called')
        with self.assertRaisesRegex(RuntimeError,'missing'): f.create('','pub',call)

if __name__=='__main__': unittest.main()
