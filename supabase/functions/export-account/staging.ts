import {createBackend} from './backend.mjs';
import {createExportHandler} from './handler.mjs';
const url=Deno.env.get('SUPABASE_URL')!;
// Synthetic staging only. This entrypoint cannot enable another project.
Deno.serve(createExportHandler(token=>createBackend({url,publicKey:Deno.env.get('SUPABASE_ANON_KEY')!,token}),{
 enabled:url==='https://hpjzfytwivlpsdhiupyd.supabase.co',
 origins:['https://funszdidiot.github.io'],
}));

