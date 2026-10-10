// Deterministic integration: unchanged handler + real hosted staging backend.
// Only the approved synthetic account's display_name is modified and restored.
import {randomUUID} from 'node:crypto';
import {setTimeout as delay} from 'node:timers/promises';
import {createBackend} from '../../supabase/functions/export-account/backend.mjs';
import {createExportHandler} from '../../supabase/functions/export-account/handler.mjs';
const url='https://hpjzfytwivlpsdhiupyd.supabase.co';
const publicKey='sb_publishable_XhQBsZ28qqCnZkLzo4WMOg_948v9PIz';
const owner='2e0c217b-950b-4122-8fc5-9e37fced985e';
let token, original, marker, changed=false, stage='credentials', failed=false;
async function api(path,{method='GET',body}={}) {
  const response=await fetch(url+path,{method,redirect:'error',signal:AbortSignal.timeout(25000),
    headers:{apikey:publicKey,...(token?{Authorization:'Bearer '+token}:{}),
      ...(body!==undefined?{'Content-Type':'application/json',Prefer:'return=representation'}:{})},
    ...(body!==undefined?{body:JSON.stringify(body)}:{})});
  if(!response.ok){await response.body?.cancel();throw Error('request failed');}
  const text=await response.text();return text?JSON.parse(text):null;
}
async function profile(){
 const rows=await api('/rest/v1/users?select=id,display_name&id=eq.'+owner);
 if(!Array.isArray(rows)||rows.length!==1||rows[0].id!==owner)throw Error('profile mismatch');
 return rows[0];
}
try {
 const email=process.env.STAGING_EXPORT_TEST_EMAIL,password=process.env.STAGING_EXPORT_TEST_PASSWORD;
 if(!email||!password)throw Error('missing credentials');
 stage='sign-in';
 const auth=await api('/auth/v1/token?grant_type=password',{method:'POST',body:{email,password}});
 token=auth.access_token;
 if(auth.user?.id!==owner||!token)throw Error('unexpected account');
 stage='baseline';original=(await profile()).display_name;
 marker='Export QA mutation '+randomUUID();
 // Prior hosted golden-path test consumes the legitimate 60-second start limit.
 stage='rate-interval';await delay(61000);
 stage='mutation-rejection';
 const backend=createBackend({url,publicKey,token});
 let reads=0,readAttachments=0,observedChange=false;
 const instrumented={...backend,
   async collect(id){
     const snapshot=await backend.collect(id);reads++;
     if(reads===1){
       if(snapshot.tables.users[0]?.display_name!==original)throw Error('baseline drift');
       changed=true; // A lost PATCH response must still trigger cleanup.
       const rows=await api('/rest/v1/users?id=eq.'+owner,{method:'PATCH',body:{display_name:marker}});
       if(rows?.length!==1||rows[0].id!==owner||rows[0].display_name!==marker)throw Error('mutation failed');
     } else if(reads===2){
       observedChange=snapshot.tables.users[0]?.display_name===marker;
     }
     return snapshot;
   },
   async readAttachment(...args){const bytes=await backend.readAttachment(...args);readAttachments++;return bytes;},
 };
 const handler=createExportHandler(()=>instrumented,{enabled:true,origins:[]});
 const response=await handler(new Request(url+'/functions/v1/export-account',{
   method:'POST',headers:{Authorization:'Bearer '+token}}));
 const body=await response.json();
 if(reads!==2||readAttachments<1||!observedChange||response.status!==503||
    JSON.stringify(body)!==JSON.stringify({error:'Export could not be completed. Please retry.'}))
   throw Error('mutation rejection not proven');
 console.log('PASS: real staging profile changed between snapshots; attachment read completed; unchanged handler rejected with HTTP 503 and no export payload.');
} catch {
 failed=true;console.log('FAIL: stage='+stage+'; no private response logged.');
} finally {
 if(changed&&token){
   try {
     const current=await profile();
     if(current.display_name===marker){
       const filter='&display_name=eq.'+encodeURIComponent(marker);
       const rows=await api('/rest/v1/users?id=eq.'+owner+filter,{method:'PATCH',body:{display_name:original}});
       if(rows?.length!==1)throw Error('cleanup conflict');
     } else if(current.display_name!==original)throw Error('unexpected concurrent change');
     if((await profile()).display_name!==original)throw Error('cleanup failed');
     console.log('PASS: original synthetic profile value restored and independently reread.');
   } catch {failed=true;console.log('FAIL: synthetic profile cleanup requires review; no values logged.');}
 }
 if(token){try{await api('/auth/v1/logout?scope=local',{method:'POST'});}catch{failed=true;console.log('FAIL: test-session logout requires review.');}}
}
process.exitCode=failed?1:0;
