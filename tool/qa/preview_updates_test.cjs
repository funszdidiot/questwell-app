const {test} = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const source = fs.readFileSync('web/questwell_updates.js', 'utf8');
const current = 'a'.repeat(40);
const latest = 'b'.repeat(40);

function harness({revision = latest, offline = false} = {}) {
  const notices = [], requests = [], removed = [], navigations = [];
  const events = {};
  function element() {
    return {style: {}, children: [], events: {}, setAttribute() {},
      append(...children) { this.children.push(...children); },
      addEventListener(name, callback) { this.events[name] = callback; },
      remove() { this.removed = true; }};
  }
  const scope = 'https://example.test/questwell-app/';
  const registrations = [
    [scope, scope + 'flutter_service_worker.js'],
    ['https://example.test/other-app/', 'https://example.test/other-app/flutter_service_worker.js'],
    [scope, scope + 'other-worker.js'],
  ].map(([scope, scriptURL], index) => ({scope, active: {scriptURL},
    unregister: async () => removed.push(index)}));
  const document = {currentScript: {dataset: {build: current}}, baseURI: scope,
    visibilityState: 'visible', createElement: element,
    body: {append: notice => notices.push(notice)},
    addEventListener: (name, callback) => events[name] = callback};
  vm.runInNewContext(source, {document, URL, AbortController, Date,
    navigator: {serviceWorker: {getRegistrations: async () => registrations}},
    window: {location: {href: scope + '?review=cloaks&rev=old#hearth',
      assign: url => navigations.push(url)},
      addEventListener: (name, callback) => events[name] = callback},
    fetch: async (url, options) => {
      requests.push({url, options});
      if (offline) throw Error('offline');
      return {ok: true, json: async () => ({revision})};
    },
    setTimeout: () => 1, clearTimeout() {},
    setInterval: callback => events.interval = callback,
  });
  return {notices, requests, removed, navigations, events, document};
}
const settle = () => new Promise(resolve => setImmediate(resolve));

test('new deployment offers explicit refresh, preserves route, and never auto-navigates', async () => {
  const h = harness(); await settle();
  assert.equal(h.notices.length, 1);
  assert.deepEqual(h.navigations, []);
  assert.equal(h.requests[0].options.cache, 'no-store');
  assert.equal(h.requests[0].url.pathname, '/questwell-app/questwell-version.json');
  h.notices[0].children[1].events.click();
  const url = new URL(h.navigations[0]);
  assert.equal(url.searchParams.get('rev'), latest);
  assert.equal(url.searchParams.get('review'), 'cloaks');
  assert.equal(url.hash, '#hearth');
  assert.deepEqual(h.removed, [0], 'Only this app legacy Flutter worker is retired');
});
test('Later suppresses repeated notices for that deployment', async () => {
  const h = harness(); await settle();
  h.notices[0].children[2].events.click();
  assert.equal(h.notices[0].removed, true);
  await h.events.interval();
  assert.equal(h.notices.length, 1);
  assert.deepEqual(h.navigations, []);
});
test('current version, invalid manifest, and offline state stay quiet', async () => {
  for (const options of [{revision: current}, {revision: '<invalid>'}, {offline: true}]) {
    const h = harness(options); await settle();
    assert.equal(h.notices.length, 0);
    assert.deepEqual(h.navigations, []);
  }
});
test('hidden tabs pause checks and returning to app checks for updates', async () => {
  const h = harness({revision: current}); await settle();
  h.document.visibilityState = 'hidden';
  await h.events.interval();
  assert.equal(h.requests.length, 1);
  h.document.visibilityState = 'visible';
  await h.events.visibilitychange();
  assert.equal(h.requests.length, 2);
});
