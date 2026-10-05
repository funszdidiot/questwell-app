const fs = require('node:fs');
const path = require('node:path');

const args = process.argv.slice(2);
const structureOnly = args.includes('--structure-only');
const fileArg = args.find((arg) => !arg.startsWith('--'));

if (!fileArg) {
  console.error('Usage: node tool/validate_seasonal_release_manifest.cjs <manifest.json> [--structure-only]');
  process.exit(2);
}

const root = path.resolve(__dirname, '..');
const manifestPath = path.resolve(process.cwd(), fileArg);
const errors = [];
const warnings = [];

const allowed = {
  releaseType: new Set(['seasonal', 'limited', 'event_reward', 'founder_beta']),
  availability: new Set(['planned', 'scheduled', 'available', 'archived']),
  brief: new Set(['draft', 'approved']),
  visual: new Set(['candidate', 'approved', 'locked', 'superseded', 'retired']),
  economy: new Set(['not_required', 'pending', 'approved']),
  activation: new Set(['not_authorized', 'authorized', 'launched', 'archived']),
  category: new Set(['head','face','neck','chest','hands','legs','feet','back','familiar','room','effect','outfit','accessory','wall_art']),
  rarity: new Set(['common','uncommon','rare','epic','legendary']),
  archetype: new Set([null,'scholar','scout','alchemist','guardian','wanderer']),
  unlock: new Set(['shop','class_mastery','level_milestone']),
  hearthProfile: new Set(['large_furniture','pedestal_light','seating','plant','side_table','trophy_surface','relic_display','floor_rug','window_feature','hearth_setting','wall_art_side','wall_art_center']),
  renderKind: new Set(['static_sprite','floor_sprite']),
  assetSource: new Set(['bundle','network']),
  shadow: new Set([null,'wide_plinth','pedestal','seating','side_table','plant','none']),
  effect: new Set([null,'ward_glow','warm_glow']),
  filter: new Set(['pixel','smooth']),
  assetState: new Set(['candidate','approved','locked','superseded','retired']),
  qa: new Set(['not_run','pass','fail'])
};

function fail(message) {
  errors.push(message);
}

function warn(message) {
  warnings.push(message);
}

function object(value) {
  return value && typeof value === 'object' && !Array.isArray(value);
}

function isoDate(value) {
  if (value === null || value === undefined) return null;
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
}

function checkImageHeader(absPath) {
  const fd = fs.openSync(absPath, 'r');
  try {
    const header = Buffer.alloc(16);
    fs.readSync(fd, header, 0, header.length, 0);
    const png = header.slice(0, 8).equals(Buffer.from([0x89,0x50,0x4e,0x47,0x0d,0x0a,0x1a,0x0a]));
    const webp = header.slice(0, 4).toString('ascii') === 'RIFF' &&
      header.slice(8, 12).toString('ascii') === 'WEBP';
    return png || webp;
  } finally {
    fs.closeSync(fd);
  }
}

let manifest;
try {
  manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
} catch (error) {
  console.error('Manifest is not valid JSON: ' + error.message);
  process.exit(1);
}

if (manifest.schema_version !== 'questwell.seasonal-release/v1') {
  fail('schema_version must be questwell.seasonal-release/v1');
}
if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(manifest.release_id || '')) {
  fail('release_id must be a lowercase kebab-case key');
}
if (!allowed.releaseType.has(manifest.release_type)) {
  fail('release_type is unsupported: ' + manifest.release_type);
}
if (!object(manifest.availability)) {
  fail('availability object is required');
} else {
  if (!allowed.availability.has(manifest.availability.status)) {
    fail('availability.status is unsupported: ' + manifest.availability.status);
  }
  if (manifest.availability.ownership_persists_after_archive !== true) {
    fail('ownership_persists_after_archive must be true');
  }
  const start = isoDate(manifest.availability.starts_at);
  const end = isoDate(manifest.availability.ends_at);
  if (manifest.availability.starts_at !== null && !start) {
    fail('availability.starts_at is not a valid date-time');
  }
  if (manifest.availability.ends_at !== null && !end) {
    fail('availability.ends_at is not a valid date-time');
  }
  if (start && end && end <= start) {
    fail('availability.ends_at must be after starts_at');
  }
}

if (!object(manifest.approval)) {
  fail('approval object is required');
} else {
  const a = manifest.approval;
  if (!allowed.brief.has(a.brief_status)) fail('approval.brief_status is invalid');
  if (!allowed.visual.has(a.visual_status)) fail('approval.visual_status is invalid');
  if (!allowed.economy.has(a.economy_status)) fail('approval.economy_status is invalid');
  if (!allowed.activation.has(a.activation_status)) fail('approval.activation_status is invalid');

  const activationRequested = a.activation_status === 'authorized' || a.activation_status === 'launched';
  if (activationRequested && a.brief_status !== 'approved') {
    fail('activation cannot be authorized/launched before brief approval');
  }
  if (activationRequested && !['approved','locked'].includes(a.visual_status)) {
    fail('activation cannot be authorized/launched before visual approval');
  }
  if (activationRequested && !['approved','not_required'].includes(a.economy_status)) {
    fail('activation cannot be authorized/launched before economy approval/not_required');
  }
  if (a.activation_status === 'launched' && manifest.availability && manifest.availability.status !== 'available') {
    fail('launched releases must have availability.status=available');
  }
}

if (!Array.isArray(manifest.items) || manifest.items.length === 0) {
  fail('items must contain at least one release item');
}

const slugs = new Set();
for (const [index, item] of (manifest.items || []).entries()) {
  const prefix = 'items[' + index + ']';
  if (!object(item)) {
    fail(prefix + ' must be an object');
    continue;
  }

  if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(item.slug || '')) {
    fail(prefix + '.slug must be lowercase kebab-case');
  } else if (slugs.has(item.slug)) {
    fail('duplicate item slug: ' + item.slug);
  } else {
    slugs.add(item.slug);
  }

  if (!allowed.category.has(item.category)) fail(prefix + '.category is invalid');
  if (!allowed.rarity.has(item.rarity)) fail(prefix + '.rarity is invalid');
  if (!allowed.archetype.has(item.required_archetype ?? null)) fail(prefix + '.required_archetype is invalid');
  if (!allowed.unlock.has(item.unlock_method)) fail(prefix + '.unlock_method is invalid');
  if (!allowed.assetState.has(item.asset_state)) fail(prefix + '.asset_state is invalid');

  if (item.unlock_method === 'level_milestone' &&
      (!Number.isInteger(item.milestone_level) || item.milestone_level < 2)) {
    fail(prefix + '.milestone_level must be >= 2 for level_milestone');
  }

  const economyApproved = manifest.approval &&
    ['approved','not_required'].includes(manifest.approval.economy_status);
  if (economyApproved && item.unlock_method === 'shop' &&
      (!Number.isInteger(item.price) || item.price < 0)) {
    fail(prefix + '.price must be a non-negative integer before an approved shop launch');
  }

  const hearthItem = item.category === 'room' || item.category === 'wall_art';
  if (hearthItem) {
    if (!object(item.hearth)) {
      fail(prefix + '.hearth is required for room/wall_art items');
    } else {
      if (!allowed.hearthProfile.has(item.hearth.profile_key)) {
        fail(prefix + '.hearth.profile_key is invalid');
      }

      const render = item.hearth.render;
      if (render) {
        if (!allowed.renderKind.has(render.render_kind)) fail(prefix + '.hearth.render.render_kind is invalid');
        if (!allowed.assetSource.has(render.asset_source)) fail(prefix + '.hearth.render.asset_source is invalid');
        if (!allowed.shadow.has(render.shadow_profile ?? null)) fail(prefix + '.hearth.render.shadow_profile is invalid');
        if (!allowed.effect.has(render.effect_profile ?? null)) fail(prefix + '.hearth.render.effect_profile is invalid');
        if (!allowed.filter.has(render.filter_mode)) fail(prefix + '.hearth.render.filter_mode is invalid');
        if (!Number.isInteger(render.canvas_width) || render.canvas_width < 1) fail(prefix + '.hearth.render.canvas_width must be > 0');
        if (!Number.isInteger(render.canvas_height) || render.canvas_height < 1) fail(prefix + '.hearth.render.canvas_height must be > 0');
        if (typeof render.visible_base !== 'number' || render.visible_base <= 0 || render.visible_base > 1) fail(prefix + '.hearth.render.visible_base must be in (0,1]');
        if (!Number.isInteger(render.asset_revision) || render.asset_revision < 1) fail(prefix + '.hearth.render.asset_revision must be >= 1');

        if (render.render_kind === 'floor_sprite' && item.hearth.profile_key !== 'floor_rug') {
          warn(prefix + ' uses floor_sprite outside floor_rug profile');
        }
        if (item.hearth.profile_key === 'floor_rug' && render.render_kind !== 'floor_sprite') {
          fail(prefix + ' floor_rug items must use floor_sprite');
        }
        if (render.filter_mode !== 'pixel' && ['static_sprite','floor_sprite'].includes(render.render_kind)) {
          warn(prefix + ' uses smooth filtering for a 64-bit sprite render kind');
        }

        if (!structureOnly && render.asset_source === 'bundle') {
          const abs = path.resolve(root, render.asset_path || '');
          if (!abs.startsWith(root + path.sep)) {
            fail(prefix + '.hearth.render.asset_path escapes repository root');
          } else if (!fs.existsSync(abs)) {
            fail(prefix + '.hearth.render.asset_path does not exist: ' + render.asset_path);
          } else if (!checkImageHeader(abs)) {
            fail(prefix + '.hearth.render.asset_path is not a decodable PNG/WebP header: ' + render.asset_path);
          }
        }
      }
    }
  }

  if (!object(item.provenance)) {
    fail(prefix + '.provenance is required');
  } else if (!Number.isInteger(item.provenance.version) || item.provenance.version < 1) {
    fail(prefix + '.provenance.version must be >= 1');
  }

  if (item.qa && object(item.qa)) {
    for (const key of ['preflight','runtime','visual']) {
      if (item.qa[key] !== undefined && !allowed.qa.has(item.qa[key])) {
        fail(prefix + '.qa.' + key + ' is invalid');
      }
    }
  }
}

if (manifest.approval &&
    manifest.approval.activation_status === 'not_authorized' &&
    manifest.availability &&
    manifest.availability.status === 'available') {
  warn('release is marked available while activation is not_authorized');
}

if (warnings.length) {
  console.log('Warnings:');
  for (const message of warnings) console.log('  - ' + message);
}

if (errors.length) {
  console.error('Seasonal release manifest FAILED preflight:');
  for (const message of errors) console.error('  - ' + message);
  process.exit(1);
}

console.log('Seasonal release manifest PASS: ' + manifest.release_id);
console.log('Items: ' + manifest.items.length);
console.log('Mode: ' + (structureOnly ? 'structure-only' : 'full'));
