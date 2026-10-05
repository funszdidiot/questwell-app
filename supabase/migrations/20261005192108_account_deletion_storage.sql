begin;

-- Metadata is read-only. Object bytes must be removed through the Storage API.
-- One bucket and at most 100 objects per page; repeat with no offset after removal.
create function public.account_deletion_objects(p_user_id uuid)
returns table (bucket_id text, name text, owner_id text)
language sql stable security invoker set search_path = ''
as $function$
  select o.bucket_id, o.name, o.owner_id
  from storage.objects o
  where o.owner_id = p_user_id::text
    and o.bucket_id = (
      select first_object.bucket_id from storage.objects first_object
      where first_object.owner_id = p_user_id::text
      order by first_object.bucket_id, first_object.name limit 1
    )
  order by o.name
  limit 100;
$function$;
revoke all on function public.account_deletion_objects(uuid) from public, anon, authenticated;
grant execute on function public.account_deletion_objects(uuid) to service_role;

-- Managed Storage tables prohibit application-created indexes. Keep their
-- ownership and privileges intact; assess inventory query cost before rollout.

-- Sign-out only revokes sessions, not already-issued JWTs. Check the session on
-- authenticated Storage operations so cleanup cannot be undone with an old JWT.
-- The private definer exposes only a boolean for the calling user's own session.
create function private.active_storage_session()
returns boolean language sql stable security definer set search_path = ''
as $function$
  select (select auth.uid()) is not null and exists (
    select 1 from auth.sessions s
    where s.id = nullif((select auth.jwt())->>'session_id', '')::uuid
      and s.user_id = (select auth.uid())
  );
$function$;
revoke all on function private.active_storage_session() from public, anon, authenticated, service_role;
grant execute on function private.active_storage_session() to authenticated;

-- Restrictive AND: preserves the existing bucket/path ownership policies.
create policy "questwell storage requires active session" on storage.objects
as restrictive for all to authenticated
using ((select private.active_storage_session()))
with check ((select private.active_storage_session()));

-- A durable fence also blocks fresh sessions opened while deletion is running.
-- Its identifier disappears with Auth; no deleted-account tombstone is retained.
create table private.account_deletion_fences (
  user_id uuid primary key references auth.users(id) on delete cascade
);
alter table private.account_deletion_fences enable row level security;
revoke all on private.account_deletion_fences from public, anon, authenticated;
grant usage on schema private to service_role;
grant select, insert on private.account_deletion_fences to service_role;

create function public.begin_account_deletion(p_user_id uuid)
returns void language plpgsql security invoker set search_path = ''
as $function$
begin
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_user_id::text, 24003));
  insert into private.account_deletion_fences(user_id) values (p_user_id)
    on conflict (user_id) do nothing;
end;
$function$;
revoke all on function public.begin_account_deletion(uuid) from public, anon, authenticated;
grant execute on function public.begin_account_deletion(uuid) to service_role;

-- Hold the caller's session row until each Storage write transaction commits.
-- Auth's session DELETE must wait for these locks before revocation completes;
-- cleanup therefore sees uploads that passed authorization before revocation.
-- A writer arriving after revocation cannot acquire a matching session row.
create function private.lock_storage_write_session()
returns trigger language plpgsql security definer set search_path = ''
as $function$
begin
  if (select auth.jwt())->>'role' = 'service_role' then return new; end if;
  if (select auth.uid()) is null then
    raise exception 'Active Storage session required' using errcode = '42501';
  end if;
  perform pg_catalog.pg_advisory_xact_lock_shared(
    pg_catalog.hashtextextended((select auth.uid())::text, 24003));
  if exists (select 1 from private.account_deletion_fences where user_id = (select auth.uid())) then
    raise exception 'Account deletion in progress' using errcode = '42501';
  end if;
  perform 1 from auth.sessions s
    where s.id = nullif((select auth.jwt())->>'session_id', '')::uuid
      and s.user_id = (select auth.uid())
    for key share;
  if not found then
    raise exception 'Active Storage session required' using errcode = '42501';
  end if;
  return new;
end;
$function$;
revoke all on function private.lock_storage_write_session() from public, anon, authenticated, service_role;
create trigger questwell_storage_write_session
before insert or update on storage.objects
for each row execute function private.lock_storage_write_session();

commit;
