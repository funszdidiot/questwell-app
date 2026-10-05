import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {assertDisposableCi, assertLocalStatus, localRequest} from './guard.mjs';

assertDisposableCi(process.env);
const status = JSON.parse(readFileSync(0, 'utf8'));
assertLocalStatus(status);
const request = async (path, token, method = 'GET', body, headers = {}) => {
  const r = await localRequest(status, path, {method,
    headers: {apikey:status.ANON_KEY,...(token?{authorization:`Bearer ${token}`} : {}),'content-type':'application/json',...headers},
    ...(body===undefined?{}:{body:typeof body==='string'?body:JSON.stringify(body)})});
  const text=await r.text();let data;try{data=text?JSON.parse(text):null;}catch{data=null;}
  return {status:r.status,data};
};
const endpoint='/functions/v1/delete-account-before-r03';
for(let attempt=0;;attempt++){
  try { if((await request(endpoint,null,'OPTIONS')).status===204)break; }catch{}
  if(attempt>=29)throw Error('Historical deletion Edge Function did not become ready');
  await new Promise(resolve=>setTimeout(resolve,1000));
}
const auth=await request('/auth/v1/signup',null,'POST',{email:`delete-baseline-${randomUUID()}@example.test`,password:`Ci-${randomUUID()}-9!`});
assert.equal(auth.status,200);
const {access_token:token,user}=auth.data;
const path=`${user.id}/before.png`;
assert.equal((await request(`/storage/v1/object/beta-feedback/${path}`,token,'POST','synthetic bytes',{'content-type':'image/png'})).status,200);
const deletion=await request(endpoint,token,'POST',{confirmation:'DELETE'});
assert.equal(deletion.status,503,'Historical deletion with an owned file must fail');
assert.equal((await request(`/auth/v1/admin/users/${user.id}`,status.SERVICE_ROLE_KEY)).status,200,'Auth user must remain after historical failure');
assert.equal((await request(`/storage/v1/object/authenticated/beta-feedback/${path}`,status.SERVICE_ROLE_KEY)).status,200,'Historical handler must leave object behind');
assert.equal((await request(`/storage/v1/object/beta-feedback/${user.id}/after-revocation.png`,token,'POST','synthetic bytes',{'content-type':'image/png'})).status,200,'Historical policy must expose the stale-token upload gap');
console.log('R03 negative control: historical handler failed HTTP 503 with an owned file; Auth and file remained; revoked access token still uploaded.');
