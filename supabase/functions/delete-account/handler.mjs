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
      // Drain in-flight writes and fence new sessions before cleanup starts.
      await backend.beginDeletion(user.id);
      // Revoke first. Storage's restrictive session policy then blocks old JWTs.
      await backend.revokeSessions(token);
      // Re-read the first remaining page: advancing an offset while deleting
      // would skip objects. Never walk an entire bucket or trust a name prefix.
      let empty = false;
      for (let batch = 0; batch <= 10; batch++) {
        const objects = await backend.listOwnedObjects(user.id);
        if (!Array.isArray(objects) || objects.length > 100 || objects.some(object =>
          !object || object.owner_id !== user.id || typeof object.bucket_id !== 'string' ||
          !object.bucket_id || typeof object.name !== 'string' || !object.name ||
          object.bucket_id !== objects[0].bucket_id)) throw Error('Invalid inventory');
        if (objects.length === 0) { empty = true; break; }
        if (batch === 10) break;
        await backend.removeOwnedObjects(user.id, objects[0].bucket_id, objects.map(object => object.name));
      }
      if (!empty) throw Error('Cleanup requires another request');
      // Storage API failures/timeouts leave Auth intact and never claim success.
      await backend.deleteUser(user.id);
      return reply(200, {deleted: true});
    } catch {
      return reply(503, {error: 'Deletion was not confirmed. Sign in again before retrying.'});
    }
  };
}
