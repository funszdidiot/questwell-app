import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {assertDisposableCi,assertLocalStatus,localRequest} from './guard.mjs';

assertDisposableCi(process.env);
const status=JSON.parse(readFileSync(0,'utf8'));
assertLocalStatus(status);
const request=async(path,token,method='GET',body,contentType='application/json')=>{
  const r=await localRequest(status,path,{method,
    headers:{apikey:status.ANON_KEY,...(token?{authorization:`Bearer ${token}`}:{}) ,'content-type':contentType},
    ...(body===undefined?{}:{body:typeof body==='string'?body:JSON.stringify(body)})});
  const text=await r.text();let data;try{data=JSON.parse(text);}catch{data=null;}
  return {status:r.status,data,text};
};
const endpoint='/functions/v1/delete-account';
for(let i=0;;i++){
  try{if((await request(endpoint,null,'OPTIONS')).status===204)break;}catch{}
  if(i>=29)throw Error('Reviewed Edge Function did not become ready');
  await new Promise(r=>setTimeout(r,1000));
}
const missing=await request('/rest/v1/rpc/begin_account_deletion',status.SERVICE_ROLE_KEY,'POST',{p_user_id:randomUUID()});
assert.equal(missing.status,404,'Edge-first interval requires the absent R03 RPC');
const auth=await request('/auth/v1/signup',null,'POST',{
  email:`edge-first-${randomUUID()}@example.test`,password:`Ci-${randomUUID()}-9!`});
assert.equal(auth.status,200);
const {access_token:token,refresh_token:refresh,user}=auth.data;
const path=`${user.id}/edge-first.png`;
const bytes='synthetic bytes preserved through failed deletion';
assert.equal((await request(`/storage/v1/object/beta-feedback/${path}`,token,'POST',bytes,'image/png')).status,200);
const result=await request(endpoint,token,'POST',{confirmation:'DELETE'});
assert.equal(result.status,503);
assert.equal(result.data.deleted,undefined);
assert.equal((await request(`/auth/v1/admin/users/${user.id}`,status.SERVICE_ROLE_KEY)).status,200);
const file=await request(`/storage/v1/object/authenticated/beta-feedback/${path}`,token);
assert.equal(file.status,200);assert.equal(file.text,bytes);
const session=await request('/auth/v1/token?grant_type=refresh_token',null,'POST',{refresh_token:refresh});
assert.equal(session.status,200,'Failed preparation must not revoke the original session');
assert.equal(session.data.user.id,user.id);
console.log('PASS Edge-first: missing deletion RPC returns 503; original account, object bytes and refreshable session survive.');
