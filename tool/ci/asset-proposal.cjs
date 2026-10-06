const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const {execFileSync} = require('node:child_process');
const outputs = {
  'issue6-polished-assets': ['assets/images/questwell/hearth/warding_lantern_v2.webp', 'assets/images/questwell/hearth/emerald_wayfarer_rug_v2.webp'],
  'neutral-woodland-repair': ['assets/images/questwell/avatar/woodland_scout_unified_neutral_v3.webp'],
};
function checkChanges(key, changed) {
  const allowed = outputs[key];
  if (!allowed) throw Error('Unknown asset proposal');
  if (changed.some(p => !allowed.includes(p))) throw Error('Unexpected generated changes');
  return allowed;
}
function run(key, root, destination) {
  const git = (...args) => execFileSync('git', args, {cwd:root, encoding:'utf8', maxBuffer:16*1024*1024});
  const changed = [...git('diff','--name-only','-z').split('\0'),
    ...git('diff','--cached','--name-only','-z').split('\0'),
    ...git('ls-files','--others','--exclude-standard','-z').split('\0')].filter(Boolean);
  const allowed = checkChanges(key, changed);
  for (const name of allowed) {
    if (!fs.lstatSync(path.join(root,name)).isFile()) throw Error('Missing or non-file output');
  }
  git('add','--',...allowed);
  fs.mkdirSync(destination,{recursive:true});
  fs.writeFileSync(path.join(destination,'proposal.patch'), git('diff','--cached','--binary','--',...allowed));
  const base = git('rev-parse','HEAD').trim();
  fs.writeFileSync(path.join(destination,'manifest.json'),JSON.stringify({base,proposal:key,
    files:allowed.map(name=>({path:name,sha256:crypto.createHash('sha256').update(fs.readFileSync(path.join(root,name))).digest('hex')}))},null,2)+'\n');
  fs.writeFileSync(path.join(destination,'REVIEW.md'),`# Asset review proposal\n\nBase: ${base}\n\nNo branch was pushed and no asset was published. Apply proposal.patch to a new isolated branch at this base, inspect the exact exports/composites and locked fit constraints, then open a PR. Required CI and AI review must run on that PR before any approved development merge. An artifact is not art approval. Never overwrite a locked asset without the separate required founder approval; version a replacement instead. Empty patch means the generator reproduced existing bytes.\n`);
}
if(require.main===module) {
  if(!process.env.RUNNER_TEMP) throw Error('RUNNER_TEMP required');
  run(process.argv[2],path.resolve(__dirname,'../..'),path.join(process.env.RUNNER_TEMP,'questwell-asset-proposal'));
}
module.exports={checkChanges,run};
