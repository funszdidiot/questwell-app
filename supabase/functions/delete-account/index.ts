import { createClient } from "npm:@supabase/supabase-js@2.57.4";
import { createDeleteAccountHandler } from "./handler.mjs";

Deno.serve(async (req) => {
  // One request budget, below the app's 12-second write timeout. No automatic
  // mutation retries. An uncertain response must never be reported as success.
  const signal = AbortSignal.timeout(9_000);
  const admin = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, {
    auth: { persistSession: false, autoRefreshToken: false },
    global: { fetch: (input, init) => fetch(input, { ...init, signal, redirect: "error" }) },
  });
  return await createDeleteAccountHandler({
    async verifyUser(token: string) {
      const { data, error } = await admin.auth.getUser(token);
      return error ? null : data.user;
    },
    async revokeSessions(token: string) {
      const { error } = await admin.auth.admin.signOut(token, "global");
      if (error) throw error;
    },
    async listOwnedObjects(id: string) {
      const { data, error } = await admin.rpc("account_deletion_objects", { p_user_id: id });
      if (error) throw error;
      return data;
    },
    async removeOwnedObjects(_id: string, bucket: string, paths: string[]) {
      const { error } = await admin.storage.from(bucket).remove(paths);
      if (error) throw error;
    },
    async deleteUser(id: string) {
      const { error } = await admin.auth.admin.deleteUser(id, false);
      if (error) throw error;
    },
  })(req);
});
