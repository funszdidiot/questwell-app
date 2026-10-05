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

commit;
