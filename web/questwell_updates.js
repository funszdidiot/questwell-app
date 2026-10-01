// Keep an already-open preview honest without interrupting unsaved work.
(() => {
  const revision = document.currentScript?.dataset.build;
  if (!/^[a-f0-9]{40}$/.test(revision || '')) return;
  const base = new URL('.', document.baseURI);
  let checking = false;
  let offered = null;
  let notice = null;

  // Retire only this app's legacy Flutter worker. Account storage is untouched.
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.getRegistrations().then(registrations => {
      for (const registration of registrations) {
        const worker = registration.active || registration.waiting || registration.installing;
        if (registration.scope === base.href && worker &&
            new URL(worker.scriptURL).pathname === base.pathname + 'flutter_service_worker.js') {
          registration.unregister().catch(() => {});
        }
      }
    }).catch(() => {});
  }

  function showUpdate(latest) {
    notice?.remove();
    notice = document.createElement('aside');
    notice.setAttribute('aria-label', 'Questwell update');
    notice.style.cssText = 'position:fixed;z-index:2147483647;left:12px;right:12px;bottom:max(12px,env(safe-area-inset-bottom));max-width:520px;margin:auto;padding:16px;background:#1a2c30;color:#f2e6c7;border:1px solid #c3a365;border-radius:12px;box-shadow:0 4px 20px #0008;font:16px/1.4 system-ui;';
    const message = document.createElement('p');
    message.setAttribute('role', 'status');
    message.textContent = 'A new Questwell update is ready. Finish any edits, then refresh.';
    message.style.cssText = 'margin:0 0 12px';
    const refresh = document.createElement('button');
    refresh.type = 'button';
    refresh.textContent = 'Refresh Questwell';
    refresh.style.cssText = 'font:inherit;font-weight:600;background:#e4c77e;color:#15252a;border:0;border-radius:7px;padding:10px 14px;margin-right:8px;cursor:pointer';
    refresh.addEventListener('click', () => {
      const url = new URL(window.location.href);
      url.searchParams.set('rev', latest);
      window.location.assign(url.href);
    });
    const later = document.createElement('button');
    later.type = 'button';
    later.textContent = 'Later';
    later.style.cssText = 'font:inherit;background:transparent;color:inherit;border:1px solid #9f967f;border-radius:7px;padding:10px 14px;cursor:pointer';
    later.addEventListener('click', () => notice.remove());
    notice.append(message, refresh, later);
    document.body.append(notice);
  }

  async function check() {
    if (checking || document.visibilityState === 'hidden') return;
    checking = true;
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 7000);
    try {
      const url = new URL('questwell-version.json', base);
      url.searchParams.set('check', Date.now());
      const response = await fetch(url, {cache: 'no-store', signal: controller.signal});
      if (!response.ok) return;
      const latest = (await response.json()).revision;
      if (/^[a-f0-9]{40}$/.test(latest || '') && latest !== revision && latest !== offered) {
        offered = latest;
        showUpdate(latest);
      }
    } catch (_) {
      // Offline and partial deployments must not interrupt play.
    } finally {
      clearTimeout(timeout);
      checking = false;
    }
  }
  document.addEventListener('visibilitychange', check);
  window.addEventListener('pageshow', check);
  setInterval(check, 60000);
  check();
})();
