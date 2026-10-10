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
  return {
    async verifyUser(){const user=await json('/auth/v1/user');return user;},
    async collect(id){
      const tables={},complete={};let totalBytes=0;
      for(const [name,fields] of Object.entries(exportFields)) {
        const rows=[];let finished=false;let expected=null;
        for(let offset=0;offset<=10000;offset+=250) {
          const query=new URLSearchParams({select:fields.join(','),
            [name==='users'?'id':'user_id']:`eq.${id}`,
            order:name==='user_cosmetics'?'cosmetic_id.asc':'id.asc',limit:'250',offset:String(offset)});
          const response=await request(`/rest/v1/${name}?${query}`);
          const range=response.headers.get('content-range')??'';
          const count=/\/(\d+)$/.exec(range);
          if(!count)throw Error('Exact count required');
          const current=Number(count[1]);
          if(!Number.isSafeInteger(current)||current>10000 || (expected!==null&&current!==expected))throw Error('Inventory changed');
          expected=current;
          const page=JSON.parse(new TextDecoder().decode(await boundedBytes(response,2*1024*1024)));
          if(!Array.isArray(page)||page.length>250)throw Error('Invalid page');
          if(page.length!==Math.min(250,expected-offset))throw Error('Truncated page');
          totalBytes+=JSON.stringify(page).length;
          if(totalBytes>8*1024*1024 || rows.length+page.length>10000)throw Error('Record limit');
          rows.push(...page);
          if(rows.length===expected){finished=true;break;}
        }
        if(!finished)throw Error('Incomplete pagination');tables[name]=rows;complete[name]=true;
      }
      return {tables,complete,collectedAt:new Date().toISOString()};
    },
    async readAttachment(path,limit){
      return boundedBytes(await request('/storage/v1/object/authenticated/beta-feedback/'+path.split('/').map(encodeURIComponent).join('/')),limit);
    },
  };
}
