import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import {join} from 'node:path';
import {payload,verifyApplied,deploymentContext,project,repository,migrationName,
  migrationPath,activationPath,manifestPath,sha256} from './hallowed-contract.mjs';

const root=fileURLToPath(new URL('../../',import.meta.url));
const read=path=>readFileSync(join(root,path),'utf8');
const manifest=JSON.parse(read(manifestPath));
const expected=JSON.parse(read('tool/deploy/hallowed-reviewed-state.json'));
const plan=payload(read(migrationPath),read(activationPath),read('tool/backend_ci/catalog.sql'),manifest,expected);
async function response(url,options={}) {
  const result=await fetch(url,{...options,redirect:'error',signal:AbortSignal.timeout(60000)});
  if(!result.ok)throw Error(`Deployment HTTP ${result.status}; reconcile before retry`);
  return result;
}
try {
  assert.ok(process.argv.length===2||(process.argv.length===3&&process.argv[2]==='--check'),'Only offline --check is accepted');
  if(process.argv[2]==='--check') {
    console.log('Exact approved Halloween migration, activation and manifest verified offline.');
  } else {
    deploymentContext(process.env);
    const revision=process.env.GITHUB_SHA;
    const headers={Authorization:`Bearer ${process.env.GITHUB_TOKEN}`,Accept:'application/vnd.github+json'};
    const dev=await (await response(`https://api.github.com/repos/${repository}/branches/questwell-dev`,{headers})).json();
    assert.equal(dev.commit.sha,revision,'Deployment revision must equal current development head');
    const checks=await (await response(`https://api.github.com/repos/${repository}/commits/${revision}/check-runs?per_page=100`,{headers})).json();
    for(const name of ['quality / analyze','quality / Critical client coverage','quality / android / signing','quality / iOS unsigned release compile','Isolated application schema and smoke tests']) {
      const latest=checks.check_runs.filter(c=>c.name===name&&c.head_sha===revision&&c.app?.slug==='github-actions').sort((a,b)=>b.id-a.id)[0];
      assert.ok(latest?.status==='completed'&&latest.conclusion==='success',`Required check missing: ${name}`);
    }
    const live='https://funszdidiot.github.io/questwell-app/';
    const served=await (await response(live+'questwell-version.json')).json();
    assert.equal(served.revision,revision,'Reviewed development client is not served');
    // Verify the six shipped image bytes before exposing their catalog entries.
    for(const item of manifest.items) {
      const path=item.hearth.render?.asset_path??item.provenance.source_art_ref;
      const result=await response(live+'assets/'+path);
      const bytes=Buffer.from(await result.arrayBuffer());
      assert.equal(sha256(bytes),sha256(readFileSync(join(root,path))),`Served art differs: ${item.slug}`);
    }
    const token=process.env.QUESTWELL_HALLOWED_MIGRATION_TOKEN;
    const management=(endpoint,body)=>response(`https://api.supabase.com/v1/projects/${project}/database/${endpoint}`,{
      method:'POST',headers:{Authorization:`Bearer ${token}`,'Content-Type':'application/json'},body:JSON.stringify(body),
    });
    const state=async()=>{
      const rows=await (await management('query',{query:plan.query,read_only:true})).json();
      assert.ok(Array.isArray(rows)&&rows.length===1&&rows[0].state,'Unexpected metadata response');
      return rows[0].state;
    };
    const before=await state();
    if(before.records.length) {
      verifyApplied(before,plan.after,plan.sourceDigest);
      console.log('Halloween rollout already applied and verified; no write performed.');
    } else {
      assert.deepEqual(before,expected.before,'Live metadata drift; no change applied');
      // Exactly one atomic migration. Never retry an ambiguous write automatically.
      await management('migrations',{name:migrationName,query:plan.sql});
      verifyApplied(await state(),plan.after,plan.sourceDigest);
      console.log(JSON.stringify({revision,result:'Halloween catalog activated and permanent ownership preserved'}));
    }
  }
} catch(error) {
  console.error(error instanceof assert.AssertionError ? error.message.split('\n')[0] : 'Halloween deployment stopped; reconcile recorded state before retry.');
  process.exitCode=1;
}
