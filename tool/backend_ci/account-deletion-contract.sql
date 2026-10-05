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
end;
$check$;
