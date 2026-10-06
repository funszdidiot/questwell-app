const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {validate,files} = require('../ci/workflow-security.cjs');
const {checkChanges} = require('../ci/asset-proposal.cjs');
const root = path.resolve(__dirname,'../..');
const name = '.github/workflows/questwell-preview.yml';
const original = fs.readFileSync(path.join(root,name),'utf8');
const bad = text => assert.ok(validate(text,name).length > 0);
test('all actual workflow and local composite documents satisfy policy',()=> {
  for(const file of files(root)) assert.deepEqual(validate(fs.readFileSync(path.join(root,file),'utf8'),file),[]);
});
test('mutable action refs and unreviewed full SHA pins are rejected',()=> {
  bad(original.replace(/actions\/checkout@[a-f0-9]{40}/,'actions/checkout@v4'));
  bad(original.replace(/actions\/checkout@[a-f0-9]{40}/,'actions/checkout@'+'0'.repeat(40)));
});
test('persisted checkout credentials fail policy',()=>bad(original.replace('persist-credentials: false','persist-credentials: true')));
test('workflow-level write privilege fails policy',()=>bad(original.replace('contents: read','contents: write')));
test('deployment without trusted branch guard fails policy',()=>bad(original.replace("if: github.ref == 'refs/heads/questwell-dev'",'if: true')));
test('unreviewed job permissions fail policy',()=>bad(original.replace('pages: read','contents: write')));
test('direct pushes and unlocked installs fail policy',()=> {
  bad(original.replace('run: cp build/web/index.html build/web/404.html','run: git push origin HEAD:questwell-dev'));
  bad(original.replace('run: cp build/web/index.html build/web/404.html','run: npm install sharp'));
});
test('duplicate YAML keys fail closed',()=>bad(original+'\npermissions:\n  contents: read\n'));
test('Flutter nested mutable cache paths must stay disabled',()=> {
  const file='.github/actions/flutter/action.yml';
  const text=fs.readFileSync(path.join(root,file),'utf8').replace('cache: false','cache: true');
  assert.ok(validate(text,file).some(e=>e.includes('nested Flutter')));
});
test('asset proposal cannot become automatic',()=> {
  const file='.github/workflows/neutral-woodland-repair.yml';
  const text=fs.readFileSync(path.join(root,file),'utf8').replace('workflow_dispatch:','push:');
  assert.ok(validate(text,file).some(e=>e.includes('manual only')));
});
test('asset allowlist rejects unexpected or unknown outputs',()=> {
  assert.throws(()=>checkChanges('neutral-woodland-repair',['lib/main.dart']));
  assert.throws(()=>checkChanges('unknown',[]));
  assert.equal(checkChanges('neutral-woodland-repair',[]).length,1);
});
test('locked Sharp works without install scripts on this platform',async()=> {
  const sharp=require('../ci/node_modules/sharp');
  const bytes=await sharp({create:{width:2,height:2,channels:4,background:'#008000'}}).webp().toBuffer();
  const metadata=await sharp(bytes).metadata();
  assert.equal(metadata.width,2); assert.equal(metadata.height,2);
});
test('privileged triggers are rejected in mapping scalar and list syntax',()=> {
  for(const on of ['pull_request_target','[push, workflow_run]','\n  workflow_run:']) {
    bad(original.replace(/on:\n[\s\S]*?\npermissions:/,`on: ${on}\n\npermissions:`));
  }
});
test('proposal packages a binary patch and hashes without committing or pushing',()=> {
  const os=require('node:os');
  const {execFileSync}=require('node:child_process');
  const {run}=require('../ci/asset-proposal.cjs');
  const dir=fs.mkdtempSync(path.join(os.tmpdir(),'questwell-proposal-test-'));
  try {
    const repo=path.join(dir,'repo'), out=path.join(dir,'out');fs.mkdirSync(repo);
    const git=(...args)=>execFileSync('git',args,{cwd:repo,encoding:'utf8'}).trim();
    git('init','-q');git('config','user.name','Synthetic fixture');git('config','user.email','fixture@example.invalid');
    const file='assets/images/questwell/avatar/woodland_scout_unified_neutral_v3.webp';
    fs.mkdirSync(path.dirname(path.join(repo,file)),{recursive:true});
    fs.writeFileSync(path.join(repo,file),Buffer.from([0,1,2]));
    git('add','.');git('commit','-qm','fixture');const before=git('rev-parse','HEAD');
    fs.writeFileSync(path.join(repo,file),Buffer.from([0,3,4]));
    run('neutral-woodland-repair',repo,out);
    assert.equal(git('rev-parse','HEAD'),before);
    assert.match(fs.readFileSync(path.join(out,'proposal.patch'),'utf8'),/GIT binary patch/);
    const manifest=JSON.parse(fs.readFileSync(path.join(out,'manifest.json')));
    assert.equal(manifest.base,before);assert.equal(manifest.files[0].path,file);
    assert.match(manifest.files[0].sha256,/^[a-f0-9]{64}$/);
    fs.writeFileSync(path.join(repo,'unexpected.txt'),'must reject');
    assert.throws(()=>run('neutral-woodland-repair',repo,out),/Unexpected/);
  } finally {fs.rmSync(dir,{recursive:true,force:true});}
});
