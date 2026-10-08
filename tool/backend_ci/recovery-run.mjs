import {readFileSync} from 'node:fs';
import {assertDisposableCi} from './guard.mjs';
import {rehearseRecovery} from './recovery.mjs';

assertDisposableCi(process.env);
if (process.argv.length !== 2) throw new Error('No target or operation overrides are accepted');
await rehearseRecovery(JSON.parse(readFileSync(0, 'utf8')));
