import { createClient } from "npm:@supabase/supabase-js@2.57.4";
import { createDeleteAccountHandler } from "./handler.mjs";

const admin = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, {
  auth: { persistSession: false, autoRefreshToken: false },
});
Deno.serve(createDeleteAccountHandler({
  async verifyUser(token: string) {
    const { data, error } = await admin.auth.getUser(token);
    return error ? null : data.user;
  },
  async revokeSessions(token: string) {
    const { error } = await admin.auth.admin.signOut(token, "global");
    if (error) throw error;
  },
  async deleteUser(id: string) {
    const { error } = await admin.auth.admin.deleteUser(id, false);
    if (error) throw error;
  },
}));
