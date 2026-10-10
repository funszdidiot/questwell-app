// Preparation and synthetic rehearsal only. No network, credentials or deletion.
import {createHash, randomBytes} from 'node:crypto';
import {accountExport, feedbackRetentionPlan} from './data_policy.mjs';
const hash = value => createHash('sha256').update(value).digest('hex');
const refs = row => [...new Set([row.attachment_path, ...(row.attachment_paths ?? [])].filter(x=>x!==null && x!==undefined))];
const validPath = (path, owner) => typeof path==='string' && path.startsWith(owner+'/') &&
  path.split('/').every(p=>p!=='' && p!=='.' && p!=='..') && !/[\\\x00-\x1f]/.test(path);
const requireComplete = value => {if(value!==true)throw Error('Complete inventory required');};
function objectMap(objects) {
  const found=new Map();
  for(const object of objects) {
    if(!object || object.bucket!=='beta-feedback' || !validPath(object.path,object.owner_id) ||
       !Number.isSafeInteger(object.size) || object.size<0 || object.size>5*1024*1024 ||
       typeof object.version!=='string' || !object.version || !/^[a-f0-9]{64}$/.test(object.sha256) ||
       found.has(object.path)) throw Error('Invalid Storage inventory');
    found.set(object.path,object);
  }
  return found;
}
export async function preparePrivateExport({snapshot,objects,inventoryComplete,readObject}) {
  requireComplete(inventoryComplete);
  const records=accountExport(snapshot); // allowlist, owner and relationship validation
  const lookup=objectMap(objects);
  const paths=[...new Set(records.tables.beta_feedback.flatMap(refs))];
  if(paths.length>100)throw Error('Export attachment limit exceeded');
  let total=0;const attachments=[], selected=[];
  for(const path of paths) {
    if(!validPath(path,snapshot.verifiedOwnerId))throw Error('Cross-owner attachment reference');
    const object=lookup.get(path);
    if(!object || object.owner_id!==snapshot.verifiedOwnerId)throw Error('Missing owned attachment');
    total+=object.size;if(total>25*1024*1024)throw Error('Export byte limit exceeded');
    selected.push(object);
  }
  for(const object of selected) {
    const path=object.path;
    // Adapter must perform conditional reads at this exact immutable version.
    const response=await readObject({...object});
    if(!response || response.version!==object.version || !Buffer.isBuffer(response.bytes) ||
       response.bytes.length!==object.size || hash(response.bytes)!==object.sha256)throw Error('Attachment integrity mismatch');
    attachments.push({path,size:object.size,sha256:object.sha256,encoding:'base64',data:response.bytes.toString('base64')});
  }
  records.scope='Allowlisted application records and verified feedback attachment bytes; Auth secrets and internal support notes excluded.';
  const bytes=Buffer.from(JSON.stringify({...records,attachments}));
  return {ownerId:snapshot.verifiedOwnerId,bytes,sha256:hash(bytes),attachmentCount:attachments.length};
}
// Synthetic in-memory delivery model. A deployed service needs a durable private
// store and an atomic consume transaction, plus server-verified session identity.
export class SyntheticPrivateDelivery {
  #tickets=new Map();
  constructor(now=()=>Date.now()){this.now=now;}
  issue(bundle){
    const token=randomBytes(32).toString('hex');
    this.#tickets.set(hash(token),{owner:bundle.ownerId,bytes:Buffer.from(bundle.bytes),expires:this.now()+15*60*1000});
    return {token,expiresAt:new Date(this.now()+15*60*1000).toISOString()};
  }
  redeem({token,authenticatedOwnerId}) {
    const key=hash(token ?? '');const ticket=this.#tickets.get(key);
    if(!ticket || ticket.expires<=this.now()) {this.#tickets.delete(key);throw Error('Export unavailable');}
    if(!authenticatedOwnerId || ticket.owner!==authenticatedOwnerId)throw Error('Export unavailable');
    this.#tickets.delete(key);
    return Buffer.from(ticket.bytes);
  }
}
export function reviewedRetentionPlan({now,reports,reportsComplete,objects,objectsComplete,backupDispositionVerified=false}) {
  requireComplete(reportsComplete);requireComplete(objectsComplete);
  const initial=feedbackRetentionPlan({now,reports});
  const lookup=objectMap(objects);const dueIds=new Set(initial.due.map(x=>x.report_id));
  const references=new Map();
  for(const row of reports) {
    if(!Object.hasOwn(row,'attachment_path') || !Array.isArray(row.attachment_paths))throw Error('Complete attachment references required');
    for(const path of refs(row)) {
      if(!validPath(path,row.user_id))throw Error('Invalid report attachment owner');
      if(!references.has(path))references.set(path,[]);
      references.get(path).push(row.id);
    }
  }
  const candidates=initial.due.map(item=>{
    const row=reports.find(r=>r.id===item.report_id);const blocks=[];const files=[];
    for(const path of refs(row)) {
      const object=lookup.get(path);
      if(!object || object.owner_id!==row.user_id){blocks.push('missing-or-mismatched-object');continue;}
      if(references.get(path).some(id=>!dueIds.has(id))){blocks.push('referenced-by-retained-report');continue;}
      files.push({...object});
    }
    if(!backupDispositionVerified)blocks.push('backup-disposition-unverified');
    return {...item,files,blocks:[...new Set(blocks)]};
  });
  const manifest={version:1,cutoff:initial.cutoff,candidates};
  return {...manifest,manifestSha256:hash(JSON.stringify(manifest)),dryRun:true,deletionAuthorized:false};
}
export function assertUnchangedRetentionPlan(reviewed,current) {
  if(reviewed.manifestSha256!==current.manifestSha256)throw Error('Retention inventory changed; review again');
  if(current.candidates.some(c=>c.blocks.length))throw Error('Retention blockers remain');
  return {reviewMatches:true,deletionAuthorized:false};
}
