// This harness is deliberately CI-only. It is not a general database client.
export function assertDisposableCi(env) {
  if (env.GITHUB_ACTIONS !== 'true' || env.RUNNER_ENVIRONMENT !== 'github-hosted') {
    throw new Error('Backend fixtures require a disposable GitHub-hosted runner');
  }
  for (const [key, value] of Object.entries(env)) {
    const forbidden = key.startsWith('SUPABASE_') && key !== 'SUPABASE_TELEMETRY_DISABLED';
    if (value && (forbidden || key === 'DATABASE_URL' || key.startsWith('PG'))) {
      throw new Error(`Remove remote credential/target override: ${key}`);
    }
  }
}

export function assertLocalStatus(status) {
  if (status?.API_URL !== 'http://127.0.0.1:54321') {
    throw new Error('Expected the fixed local API endpoint');
  }
  if (status.DB_URL !== 'postgresql://postgres:postgres@127.0.0.1:54322/postgres') {
    throw new Error('Expected the fixed local database endpoint');
  }
  if (!status.ANON_KEY || !status.SERVICE_ROLE_KEY) {
    throw new Error('CLI did not return the required local credentials');
  }
}

export async function localRequest(status, path, options = {}, transport = fetch) {
  assertLocalStatus(status);
  if (typeof path !== 'string' || !path.startsWith('/') || path.startsWith('//') || path.includes('\\')) {
    throw new Error('Expected a local path, not an external URL');
  }
  const url = new URL(path, status.API_URL);
  if (url.origin !== status.API_URL) throw new Error('Request escaped its local path');
  return transport(url.href, {
    ...options,
    // Never forward locally generated credentials through an HTTP redirect.
    redirect: 'error',
    signal: AbortSignal.timeout(10000),
  });
}
