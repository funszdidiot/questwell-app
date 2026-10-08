// Offline support helpers. No network, credentials, deletion or automatic delivery.
const fields = Object.freeze({
  users: ['id','created_at','email','display_name','level','total_xp','coin_balance','current_energy_mode','onboarding_completed','adventurer_archetype','avatar_body_type','level_xp_offset'],
  tasks: ['id','user_id','created_at','title','notes','status','due_date','xp_value','coin_value','completed_at','friction_level','pinned_at'],
  boss_battles: ['id','user_id','title','status','reward_xp','reward_coins','created_at','completed_at','boss_type'],
  boss_steps: ['id','user_id','boss_id','title','position','completed','completed_at','created_at'],
  user_cosmetics: ['user_id','cosmetic_id','unlocked_at','source','equipped','room_slot'],
  progression_events: ['id','user_id','kind','event_key','title','level','cosmetic_slug','source','occurred_at'],
  reward_events: ['id','user_id','task_id','event_type','xp_amount','coin_amount','created_at'],
  beta_feedback: ['id','user_id','created_at','category','goal','message','expected','steps','reply_email','device','screen','build','platform','status','attachment_path','attachment_paths'],
});
const uuid = value => typeof value === 'string' && /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value);
const instant = value => {
  const m = typeof value === 'string' && /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(?:\.\d{1,6})?(Z|[+-]\d{2}:\d{2})$/.exec(value);
  if (!m) throw Error('Timezone-qualified timestamp required');
  const [year,month,day,hour,minute,second] = m.slice(1,7).map(Number);
  const leap = year%4===0 && (year%100!==0 || year%400===0);
  const days = [31,leap?29:28,31,30,31,30,31,31,30,31,30,31];
  const zone = m[7];
  if (month<1 || month>12 || day<1 || day>days[month-1] || hour>23 || minute>59 || second>59 ||
      (zone!=='Z' && (Number(zone.slice(1,3))>23 || Number(zone.slice(4))>59))) throw Error('Invalid timestamp');
  const ms=Date.parse(value);if(!Number.isFinite(ms))throw Error('Invalid timestamp');return ms;
};
const numericFields = new Set(['level','total_xp','coin_balance','level_xp_offset','xp_value','coin_value','friction_level','reward_xp','reward_coins','position','xp_amount','coin_amount']);
const booleanFields = new Set(['onboarding_completed','completed','equipped']);
const idFields = new Set(['id','user_id','boss_id','task_id','cosmetic_id']);
function validateValue(key,value) {
  if (value === null) return;
  if (key === 'attachment_paths') {
    if (!Array.isArray(value) || value.some(path=>typeof path!=='string')) throw Error('Invalid export field type');
  } else if (numericFields.has(key)) {
    if (!Number.isSafeInteger(value)) throw Error('Invalid export number');
  } else if (booleanFields.has(key)) {
    if (typeof value!=='boolean') throw Error('Invalid export boolean');
  } else {
    if (typeof value!=='string') throw Error('Invalid export field type');
    if (idFields.has(key) && !uuid(value)) throw Error('Invalid export identifier');
    if (key.endsWith('_at') || key==='due_date') instant(value);
  }
}
export const policy = Object.freeze({version:1, feedbackDays:90, recoveryPointHours:24, recoveryTimeHours:8});

export function accountExport({verifiedOwnerId, collectedAt, tables, complete}) {
  if(!uuid(verifiedOwnerId))throw Error('Verified requester identity required');
  instant(collectedAt);
  // Retrieval must paginate every table and finish successfully. Empty is not an error fallback.
  if(!tables || !complete || Object.keys(fields).some(name=>complete[name]!==true || !Array.isArray(tables[name])))throw Error('Complete account snapshot required');
  if(tables.users.length!==1)throw Error('Exactly one owner profile required');
  const result={};
  for(const [name,allowed] of Object.entries(fields)) {
    const seen = new Set();
    result[name]=tables[name].map(row=> {
      if(!row || typeof row!=='object' || Array.isArray(row) || row[name==='users'?'id':'user_id']!==verifiedOwnerId)throw Error('Cross-account row rejected');
      for (const key of allowed) {
        if (!Object.hasOwn(row,key)) throw Error('Missing export field');
        validateValue(key,row[key]);
      }
      const keyFields = name==='user_cosmetics'?['user_id','cosmetic_id']:['id'];
      if (keyFields.some(key=>!uuid(row[key]))) throw Error('Missing export primary key');
      const primaryKey=keyFields.map(key=>row[key]).join('/');
      if (seen.has(primaryKey)) throw Error('Duplicate export row');
      seen.add(primaryKey);
      return Object.fromEntries(allowed.map(key=>[key,Array.isArray(row[key])?[...row[key]]:row[key]]));
    });
  }
  const bossIds=new Set(result.boss_battles.map(row=>row.id));
  if(result.boss_steps.some(row=>!bossIds.has(row.boss_id)))throw Error('Incomplete boss snapshot');
  const taskIds=new Set(result.tasks.map(row=>row.id));
  if(result.reward_events.some(row=>row.task_id!==null && !taskIds.has(row.task_id)))throw Error('Incomplete reward snapshot');
  return {format:'questwell-account-export',version:1,collected_at:collectedAt,
    scope:'Application records only. Attachment paths are references, not downloaded files. Auth secrets and internal support notes excluded.',tables:result};
}

export function feedbackRetentionPlan({now, reports}) {
  const cutoff=instant(now)-policy.feedbackDays*86400000;
  if(!Array.isArray(reports))throw Error('Report inventory required');
  const seen=new Set();
  const due=reports.filter(row=> {
    if(!row || !uuid(row.id) || !uuid(row.user_id) || seen.has(row.id))throw Error('Invalid report inventory');
    seen.add(row.id);
    return instant(row.created_at)<=cutoff;
  }).map(row=>({report_id:row.id,owner_id:row.user_id}));
  // Never accept paths from mail/body as deletion authority. A separate reviewed
  // operation must verify Storage ownership, shared references and backup expiry.
  return {dry_run:true,policy_version:1,cutoff:new Date(cutoff).toISOString(),due,
    deletion_authorized:false,attachments_resolved:false};
}
