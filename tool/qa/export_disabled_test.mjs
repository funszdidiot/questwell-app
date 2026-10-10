import test from 'node:test';
import assert from 'node:assert/strict';
import {disabledExportHandler as handler} from '../../supabase/functions/export-account/disabled.mjs';

test('disabled production returns no export for authenticated-looking and empty requests',async()=>{
 for(const headers of [{},{authorization:'Bearer synthetic-token'}]){
  const response=await handler(new Request('https://example.invalid/export-account',{method:'POST',headers}));
  assert.equal(response.status,503);
  assert.deepEqual(await response.json(),{error:'Export is not enabled'});
  assert.match(response.headers.get('cache-control'),/no-store/);
  assert.equal(response.headers.get('content-disposition'),null);
 }
});
test('disabled production does not echo supplied private content',async()=>{
 const response=await handler(new Request('https://example.invalid/export-account?owner=synthetic-private-marker',{
  method:'POST',headers:{authorization:'Bearer synthetic-token'},body:'synthetic-private-marker'}));
 assert.equal(response.status,503);
 assert.equal((await response.text()).includes('synthetic-private-marker'),false);
});
test('disabled production denies every browser origin without CORS grants',async()=>{
 for(const method of ['POST','OPTIONS']){
  const response=await handler(new Request('https://example.invalid/export-account',{method,headers:{origin:'https://example.invalid'}}));
  assert.equal(response.status,403);
  assert.equal(response.headers.get('access-control-allow-origin'),null);
 }
});
test('disabled production rejects unsupported methods',async()=>{
 const response=await handler(new Request('https://example.invalid/export-account',{method:'GET'}));
 assert.equal(response.status,405);
 assert.deepEqual(await response.json(),{error:'Method not allowed'});
});
