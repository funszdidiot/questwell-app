import {createBackend} from './backend.mjs';
import {createExportHandler} from './handler.mjs';

// Disabled by default. Staging authorization/session, load and privacy review
// must pass before anyone enables this on a live project.
Deno.serve(createExportHandler(token=>createBackend({
  url:Deno.env.get('SUPABASE_URL')!,
  publicKey:Deno.env.get('SUPABASE_ANON_KEY')!, token,
}), {
  enabled:Deno.env.get('QUESTWELL_EXPORT_ENABLED')==='true',
  origins:(Deno.env.get('QUESTWELL_EXPORT_ORIGINS')??'').split(',').map(s=>s.trim()).filter(Boolean),
}));
