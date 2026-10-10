begin;
create table private.account_export_limits (
  user_id uuid primary key references auth.users(id) on delete cascade,
  next_allowed_at timestamptz not null
);
alter table private.account_export_limits enable row level security;
revoke all on private.account_export_limits from public, anon, authenticated;

-- Private definer is narrowly required for auth.sessions and the private fence.
-- It returns only a boolean for the caller, and never accepts a user/session ID.
create function private.export_session_allowed()
returns boolean language sql stable security definer set search_path = '' as $$
  select (select auth.uid()) is not null
    and coalesce((select auth.jwt())->>'is_anonymous','false') = 'false'
    and exists (select 1 from auth.sessions s
      where s.id::text = (select auth.jwt())->>'session_id'
        and s.user_id = (select auth.uid())
        and (s.not_after is null or s.not_after > statement_timestamp()))
    and not exists (select 1 from private.account_deletion_fences f
      where f.user_id = (select auth.uid()));
$$;
revoke all on function private.export_session_allowed() from public, anon, authenticated;
grant execute on function private.export_session_allowed() to authenticated;

create function private.claim_account_export()
returns boolean language plpgsql security definer set search_path = '' as $$
begin
  if not private.export_session_allowed() then return false; end if;
  -- Atomic upsert serializes concurrent requests. One start per 60 seconds.
  insert into private.account_export_limits(user_id,next_allowed_at)
    values ((select auth.uid()),clock_timestamp()+interval '60 seconds')
    on conflict(user_id) do update set next_allowed_at=excluded.next_allowed_at
    where private.account_export_limits.next_allowed_at<=clock_timestamp();
  return found;
end;
$$;
revoke all on function private.claim_account_export() from public, anon, authenticated;
grant execute on function private.claim_account_export() to authenticated;

create function public.account_export_session_allowed()
returns boolean language sql stable security invoker set search_path = '' as $$
  select private.export_session_allowed();
$$;
create function public.claim_account_export()
returns boolean language sql volatile security invoker set search_path = '' as $$
  select private.claim_account_export();
$$;
revoke all on function public.account_export_session_allowed() from public, anon;
revoke all on function public.claim_account_export() from public, anon;
grant execute on function public.account_export_session_allowed() to authenticated;
grant execute on function public.claim_account_export() to authenticated;
commit;
