do $check$
declare caller text;
begin
  foreach caller in array array['anon', 'authenticated'] loop
    if has_function_privilege(caller, 'public.account_deletion_objects(uuid)', 'execute') then
      raise exception 'Client can enumerate deletion inventory: %', caller;
    end if;
  end loop;
  if not has_function_privilege('service_role', 'public.account_deletion_objects(uuid)', 'execute') then
    raise exception 'Deletion backend cannot read inventory';
  end if;
  if (select prosecdef from pg_proc where oid = 'public.account_deletion_objects(uuid)'::regprocedure) then
    raise exception 'Inventory must remain invoker-rights';
  end if;
  if has_function_privilege('anon', 'private.active_storage_session()', 'execute') then
    raise exception 'Anonymous caller can execute private session helper';
  end if;
  if not exists (select 1 from pg_policy where polrelid = 'storage.objects'::regclass
      and polname = 'questwell storage requires active session' and not polpermissive and polcmd = '*') then
    raise exception 'Restrictive Storage session policy is missing';
  end if;
  if (select count(*) from pg_policy where polrelid = 'storage.objects'::regclass and polpermissive) <> 3 then
    raise exception 'Existing Storage ownership policies changed';
  end if;
  if not exists (select 1 from pg_trigger where tgrelid = 'storage.objects'::regclass
      and tgname = 'questwell_storage_write_session' and tgenabled = 'O') then
    raise exception 'Storage write/session coordination is missing';
  end if;
-- Failure injection on app-owned rows only, in the disposable fixture only.
-- A test clears the flag through REST and retries after the real Auth failure.
execute $ddl$
create function public.ci_account_delete_failure() returns trigger
language plpgsql set search_path = '' as $function$
begin
  if old.total_xp = 987654 then raise exception 'Synthetic Auth cascade failure'; end if;
  return old;
end;
$function$;
$ddl$;
execute 'revoke all on function public.ci_account_delete_failure() from public, anon, authenticated';
execute $ddl$
create trigger ci_account_delete_failure before delete on public.users
for each row execute function public.ci_account_delete_failure();
$ddl$;

-- A second synthetic bucket proves cleanup is owner-based across buckets, not
-- hard-coded to beta-feedback or a user's path prefix. Never applied to hosted DBs.
execute $ddl$
create policy ci_secondary_upload on storage.objects as permissive for insert to authenticated
with check (bucket_id = 'ci-deletion-secondary' and owner_id = (select auth.uid())::text);
$ddl$;

-- Hold one real Storage API transaction open after its INSERT. The advisory
-- marker is visible before commit, so the HTTP test never guesses when to race.
execute $ddl$
create function public.ci_pause_storage_upload() returns trigger
language plpgsql set search_path = '' as $function$
begin
  if (new.name like '%/race-inflight-probe.png' and new.version = '1')
      or (new.name like '%/race-inflight-commit.png' and new.version <> '1') then
    perform pg_catalog.pg_advisory_xact_lock(73424, 1);
    perform pg_catalog.pg_sleep(3);
  end if;
  return new;
end;
$function$;
$ddl$;
execute 'revoke all on function public.ci_pause_storage_upload() from public, anon, authenticated';
execute $ddl$
create trigger ci_pause_storage_upload after insert on storage.objects
for each row execute function public.ci_pause_storage_upload();
$ddl$;
execute $ddl$
create function public.ci_storage_upload_paused() returns boolean
language sql volatile security invoker set search_path = '' as $function$
  select exists (select 1 from pg_catalog.pg_locks
    where locktype = 'advisory' and classid = 73424 and objid = 1 and granted);
$function$;
$ddl$;
execute 'revoke all on function public.ci_storage_upload_paused() from public, anon, authenticated';
execute 'grant execute on function public.ci_storage_upload_paused() to service_role';
end;
$check$;
