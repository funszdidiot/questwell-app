import {createExportHandler} from './handler.mjs';

// Production holding state: no environment variable can enable delivery.
// The backend is deliberately unavailable in this entrypoint.
export const disabledExportHandler=createExportHandler(()=>{
  throw Error('Export backend is disabled');
},{enabled:false,origins:[]});
