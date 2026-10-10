import {accountExport} from '../_shared/data_policy.mjs';
import {createHash} from 'node:crypto';
import {Buffer} from 'node:buffer';
const digest = bytes => createHash('sha256').update(bytes).digest('hex');
const headers = {'Content-Type':'application/json', 'Cache-Control':'no-store, private',
  'X-Content-Type-Options':'nosniff', 'Vary':'Origin'};
const validPath = (path, id) => typeof path === 'string' && path.startsWith(id+'/') &&
  path.split('/').every(p=>p && p!=='.' && p!=='..') && !/[\\\x00-\x1f]/.test(path);

// Direct response to the authenticated requester. No durable ticket or public URL.
export function createExportHandler(makeBackend, {enabled=false, origins=[]}={}) {
  return async req => {
    const origin=req.headers.get('origin');
    const h={...headers};
    const reply=(status,data)=>new Response(JSON.stringify(data),{status,headers:h});
    if(origin && !origins.includes(origin)) return reply(403,{error:'Origin denied'});
    if(origin) Object.assign(h, {'Access-Control-Allow-Origin':origin,
      'Access-Control-Allow-Headers':'authorization, apikey, content-type, x-client-info',
      'Access-Control-Allow-Methods':'POST, OPTIONS'});
    if(req.method==='OPTIONS') return new Response(null,{status:204,headers:h});
    if(req.method!=='POST') return reply(405,{error:'Method not allowed'});
    if(!enabled) return reply(503,{error:'Export is not enabled'});
    if(new URL(req.url).search) return reply(400,{error:'No query parameters accepted'});
    const authorization=req.headers.get('authorization')??'';
    if(!/^Bearer [A-Za-z0-9._~-]+$/i.test(authorization))return reply(401,{error:'Sign in required'});
    // Empty body only: no supplied owner, destination, attachment path or token URL.
    if(req.body) {
      const reader=req.body.getReader();
      const first=await reader.read(); await reader.cancel();
      if(!first.done) return reply(400,{error:'Request body must be empty'});
    }
    try {
      const backend=makeBackend(authorization.slice(7));
      const user=await backend.verifyUser();
      if(!user?.id || user.is_anonymous) return reply(401,{error:'Sign in required'});
      if(!await backend.sessionAllowed()) return reply(401,{error:'Sign in again'});
      if(!await backend.claimExport()) return reply(429,{error:'Please wait before requesting another export'});
      const snapshot=await backend.collect(user.id);
      const records=accountExport({...snapshot,verifiedOwnerId:user.id});
      const paths=[...new Set(records.tables.beta_feedback.flatMap(row=>
        [row.attachment_path,...(row.attachment_paths??[])].filter(p=>p!==null)))];
      if(paths.length>100 || paths.some(p=>!validPath(p,user.id))) throw Error('Invalid attachment inventory');
      const attachments=[];let total=0;
      for(const path of paths) {
        const bytes=await backend.readAttachment(path,Math.min(5*1024*1024,25*1024*1024-total));
        total+=bytes.length;
        if(total>25*1024*1024) throw Error('Attachment limit');
        attachments.push({path,size:bytes.length,sha256:digest(bytes),encoding:'base64',data:Buffer.from(bytes).toString('base64')});
      }
      // Detect visible edits during collection. This is not a transactional snapshot.
      const again=accountExport({...await backend.collect(user.id),verifiedOwnerId:user.id});
      if(JSON.stringify(records.tables)!==JSON.stringify(again.tables)) throw Error('Account changed');
      const finalUser=await backend.verifyUser();
      if(finalUser?.id!==user.id || finalUser.is_anonymous) throw Error('Authentication changed');
      if(!await backend.sessionAllowed()) throw Error('Session ended');
      records.scope='Account-owned public application records and referenced feedback attachments. Shared catalog definitions, device-local settings, Auth records and internal support fields are excluded.';
      return new Response(JSON.stringify({...records,attachments}),{status:200,headers:{...h,
        'Content-Disposition':'attachment; filename="questwell-account-export.json"'}});
    } catch {
      return reply(503,{error:'Export could not be completed. Please retry.'});
    }
  };
}
