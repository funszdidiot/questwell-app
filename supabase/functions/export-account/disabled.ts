import {disabledExportHandler} from './disabled.mjs';

// Keep gateway JWT verification enabled when deploying this entrypoint.
Deno.serve(disabledExportHandler);
