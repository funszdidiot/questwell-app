import io
import unittest
import recovery_owner_replace as r
class Fake:
    def __init__(self, data=r.INITIAL): self.data,self.puts=data,[]
    def get_object(self,**kw):
        assert kw == {'Bucket':r.BUCKET,'Key':r.KEY}
        return {'Body':io.BytesIO(self.data)}
    def put_object(self,**kw):
        assert kw['Bucket']==r.BUCKET and kw['Key']==r.KEY
        self.puts.append(kw)
        self.data=kw['Body']
class Tests(unittest.TestCase):
    def test_exact_synthetic_replace(self):
        f=Fake(); result=r.replace(f)
        self.assertEqual(len(f.puts),1)
        self.assertEqual(result['private_files_restored'],0)
    def test_unexpected_bytes_never_write(self):
        f=Fake(b'wrong')
        with self.assertRaises(RuntimeError): r.replace(f)
        self.assertEqual(f.puts,[])
if __name__=='__main__': unittest.main()
