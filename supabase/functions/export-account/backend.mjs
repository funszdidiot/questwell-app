import {exportFields} from '../_shared/data_policy.mjs';
export async function boundedBytes(response,limit) {
  if(!response.ok || !response.body) throw Error('Upstream request failed');
  const announced=response.headers.get('content-length');
  if(announced!==null && (!/^\d+$/.test(announced)||Number(announced)>limit)) {
    await response.body.cancel(); throw Error('Response exceeds limit');
  }
  const reader=response.body.getReader(); const chunks=[]; let size=0;
  try {
    for(;;) {
      const {done,value}=await reader.read();if(done)break;
      size+=value.length;if(size>limit)throw Error('Response exceeds limit');chunks.push(value);
    }
  } finally {await reader.cancel();}
  const out=new Uint8Array(size);let offset=0;
  for(const chunk of chunks){out.set(chunk,offset);offset+=chunk.length;}
  return out;
}
// Public project key + the requester's token only. No service-role access.
export function createBackend({url,publicKey,token,fetcher=fetch}) {
  const base=new URL(url);
  if(base.protocol!=='https:' || base.pathname!=='/' || base.search || base.hash)throw Error('Invalid project URL');
  const signal=AbortSignal.timeout(25000);
  const request=async (path)=>fetcher(new URL(path,base),{method:'GET',redirect:'error',signal,
    headers:{apikey:publicKey,Authorization:`Bearer ${token}`,Prefer:'count=exact'}});
  const json=async path=>JSON.parse(new TextDecoder().decode(await boundedBytes(await request(path),2*1024*1024)));
  const rpc=async (name,limit=1024)=>{
    const response=await fetcher(new URL('/rest/v1/rpc/'+name,base),{method:'POST',redirect:'error',signal,
      headers:{apikey:publicKey,Authorization:`Bearer ${token}`,'Content-Type':'application/json'},body:'{}'});
    return JSON.parse(new TextDecoder().decode(await boundedBytes(response,limit)));
  };
  return {
    sessionAllowed:async()=>await rpc('account_export_session_allowed')===true,
    claimExport:async()=>await rpc('claim_account_export')===true,
    async verifyUser(){const user=await json('/auth/v1/user');return user;},
    async collect(_id){
      const snapshot=await rpc('account_export_snapshot',8*1024*1024);
      if(!snapshot || !snapshot.tables || !Array.isArray(snapshot.objects))throw Error('Invalid snapshot');
      for(const name of Object.keys(exportFields)) {
        if(!Array.isArray(snapshot.tables[name]) || snapshot.tables[name].length>10000)throw Error('Incomplete snapshot');
      }
      if(snapshot.objects.length>100)throw Error('Object limit');
      return {...snapshot,complete:Object.fromEntries(Object.keys(exportFields).map(name=>[name,true]))};
    },
    async readAttachment(path,limit,expected){
      const response=await request('/storage/v1/object/authenticated/beta-feedback/'+path.split('/').map(encodeURIComponent).join('/'));
      const etag=response.headers.get('etag');
      if(!etag || etag.replace(/^"|"$/g,'')!==expected.etag.replace(/^"|"$/g,'')) {
        await response.body?.cancel();throw Error('Attachment version changed');
      }
      const bytes=await boundedBytes(response,limit);
      if(bytes.length!==expected.size)throw Error('Attachment size changed');
      return bytes;
    },
  };
}
