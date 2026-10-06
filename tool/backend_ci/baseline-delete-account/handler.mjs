const headers = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Content-Type': 'application/json',
  'Cache-Control': 'no-store',
};
const reply = (status, data) => new Response(JSON.stringify(data), {status, headers});

// No caller-supplied user ID. Identity always comes from Auth's verified user.
export function createDeleteAccountHandler(backend) {
  return async (req) => {
    if (req.method === 'OPTIONS') return new Response(null, {status: 204, headers});
    if (req.method !== 'POST') return reply(405, {error: 'Method not allowed'});
    const authorization = req.headers.get('authorization') || '';
    if (!/^Bearer [^ ]+$/i.test(authorization)) return reply(401, {error: 'Sign in required'});
    let body;
    try { body = await req.json(); } catch { return reply(400, {error: 'Confirmation required'}); }
    if (!body || body.confirmation !== 'DELETE' || Object.keys(body).some(key => key !== 'confirmation')) {
      return reply(400, {error: 'Confirmation required'});
    }
    const token = authorization.slice(7);
    try {
      const user = await backend.verifyUser(token);
      if (!user?.id) return reply(401, {error: 'Sign in required'});
      // Revoke refresh sessions before removal. Deletion cascades app-owned data.
      await backend.revokeSessions(token);
      await backend.deleteUser(user.id);
      return reply(200, {deleted: true});
    } catch {
      return reply(503, {error: 'Deletion was not confirmed. Sign in again before retrying.'});
    }
  };
}
