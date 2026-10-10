const fs = require('node:fs');
const path = require('node:path');
const yaml = require('./node_modules/yaml');
const pins = require('./action-pins.json');

function validate(text, name) {
  const errors = [];
  let doc;
  try { doc = yaml.parse(text, { uniqueKeys: true, maxAliasCount: 0 }); }
  catch (e) { return [`${name}: invalid YAML: ${e.message}`]; }
  if (!doc || typeof doc !== 'object') return [`${name}: missing document`];
  const checkSteps = (steps = []) => {
    for (const step of steps) {
      if (step.uses) {
        if (step.uses.startsWith('./')) {
          if (step.uses !== './.github/actions/flutter') errors.push('unreviewed local action');
        } else {
          const match = /^([^@]+)@([a-f0-9]{40})$/.exec(step.uses);
          if (!match || pins[match[1]]?.sha !== match[2]) errors.push(`unreviewed action pin: ${step.uses}`);
          if (match?.[1] === 'actions/checkout' && step.with?.['persist-credentials'] !== false) errors.push('checkout persists credentials');
        }
      }
      if (step.run) {
        if (/git\s+push\b/.test(step.run)) errors.push('direct git push in workflow');
        if (/\$\{\{\s*github\.event\./.test(step.run)) errors.push('event data interpolated into shell');
        if (/\b(?:npm\s+install|npx|pip\s+install)\b/.test(step.run)) errors.push('unlocked runtime dependency install');
      }
    }
  };
  if (doc.runs) {
    if (name !== '.github/actions/flutter/action.yml' || doc.runs.using !== 'composite') errors.push('unreviewed local composite');
    checkSteps(doc.runs.steps);
  } else {
    if (JSON.stringify(doc.permissions) !== JSON.stringify({contents: 'read'})) errors.push('workflow token must default to contents:read only');
    const triggers = typeof doc.on === 'string' ? [doc.on] : Array.isArray(doc.on) ? doc.on : Object.keys(doc.on || {});
    if (triggers.some(t => ['pull_request_target', 'workflow_run'].includes(t))) errors.push('privileged external trigger');
    for (const [id, job] of Object.entries(doc.jobs || {})) {
      if (job.uses && job.uses !== './.github/workflows/questwell-flutter-check.yml' &&
          job.uses !== './.github/workflows/questwell-android-signing.yml') errors.push('unreviewed reusable workflow');
      if (job.permissions) {
        const allowed = name.endsWith('/questwell-preview.yml') && id === 'deploy'
          ? {contents:'read', pages:'write', 'id-token':'write'}
          : name.endsWith('/questwell-preview.yml') && id === 'build'
          ? {contents:'read', pages:'read'}
          : (name.endsWith('/questwell-woodland-forward.yml') || name.endsWith('/questwell-hallowed-forward.yml') || name.endsWith('/questwell-content-forward.yml') || name.endsWith('/questwell-autumn-forward.yml') || name.endsWith('/questwell-household-forward.yml') || name.endsWith('/questwell-magic-forward.yml')) && id === 'apply'
          ? {contents:'read', checks:'read'} : {contents:'read'};
        if (JSON.stringify(job.permissions) !== JSON.stringify(allowed)) errors.push(`excess permissions for ${id}`);
      }
      if (name.endsWith('/questwell-preview.yml') && id === 'deploy' &&
          job.if !== "github.ref == 'refs/heads/questwell-dev'") errors.push('preview deployment not branch-guarded');
      if (name.endsWith('/questwell-hallowed-forward.yml') && id === 'apply' &&
          job.if !== "github.event_name == 'push' && github.ref == 'refs/heads/deploy/hallowed-hearth-approved'") errors.push('Halloween deployment not branch-guarded');
      if (name.endsWith('/questwell-magic-forward.yml') && id === 'apply' &&
          job.if !== "github.event_name == 'push' && github.ref == 'refs/heads/deploy/avatar-magic-approved'") errors.push('Magic deployment not branch-guarded');
      if (name.endsWith('/questwell-household-forward.yml') && id === 'apply' &&
          job.if !== "github.event_name == 'push' && github.ref == 'refs/heads/deploy/household-familiars-approved'") errors.push('Household deployment not branch-guarded');
      if (name.endsWith('/questwell-autumn-forward.yml') && id === 'apply' &&
          job.if !== "github.event_name == 'push' && github.ref == 'refs/heads/deploy/autumn-hearth-approved'") errors.push('Autumn deployment not branch-guarded');
      if (name.endsWith('/questwell-content-forward.yml') && id === 'apply' &&
          job.if !== "github.event_name == 'push' && github.ref == 'refs/heads/deploy/content-limits-approved'") errors.push('Content deployment not branch-guarded');
      checkSteps(job.steps);
    }
    if (/\/(issue6-polished-assets|neutral-woodland-repair)\.yml$/.test(name)) {
      if (Object.keys(doc.on || {}).join() !== 'workflow_dispatch') errors.push('asset proposal must be manual only');
      if (doc.jobs?.propose?.if !== "github.ref == 'refs/heads/questwell-dev'") errors.push('asset proposal not trusted-branch guarded');
      if (!doc.jobs?.propose?.steps?.some(s => s.run?.startsWith('node tool/ci/asset-proposal.cjs '))) errors.push('asset proposal lacks output allowlist');
    }
  }
  return errors.map(e => `${name}: ${e}`);
}

function files(root) {
  return [...fs.readdirSync(path.join(root, '.github/workflows')).filter(n => /\.ya?ml$/.test(n)).map(n => `.github/workflows/${n}`), '.github/actions/flutter/action.yml'];
}
if (require.main === module) {
  const root = path.resolve(__dirname, '../..');
  const errors = files(root).flatMap(n => validate(fs.readFileSync(path.join(root, n), 'utf8'), n));
  if (errors.length) { console.error(errors.join('\n')); process.exitCode = 1; }
  else console.log('Workflow pins, token scopes, checkout isolation and asset proposal boundaries passed.');
}
module.exports = { validate, files };
