begin;

-- Keep receipts after task deletion to prevent late retries resurrecting work.
-- Auth deletion removes these records; no task text is retained in the receipt.
create table private.task_creation_requests (
  user_id uuid not null references auth.users(id) on delete cascade,
  request_id uuid not null,
  payload_hash text not null,
  task_id uuid not null,
  primary key (user_id, request_id)
);
alter table private.task_creation_requests enable row level security;
revoke all on private.task_creation_requests from public, anon, authenticated, service_role;

-- A private definer is needed for the inaccessible receipt and server-owned ID.
-- Both the public wrapper and this boundary enforce the authenticated owner.
create function private.create_task_once(
  p_request_id uuid, p_expected_user_id uuid, p_title text, p_friction integer
) returns uuid language plpgsql security definer set search_path = ''
as $function$
declare
  v_uid uuid := auth.uid();
  v_hash text;
  v_receipt private.task_creation_requests%rowtype;
  v_task_id uuid := gen_random_uuid();
  v_xp integer;
  v_coins integer;
begin
  if v_uid is null or p_expected_user_id is distinct from v_uid then
    raise exception 'Quest account changed' using errcode = '42501';
  end if;
  -- Coordinate with the existing account-deletion fence and session revocation.
  perform pg_catalog.pg_advisory_xact_lock_shared(pg_catalog.hashtextextended(v_uid::text, 24003));
  if exists (select 1 from private.account_deletion_fences where user_id = v_uid) then
    raise exception 'Account deletion in progress' using errcode = '42501';
  end if;
  perform 1 from auth.sessions s
    where s.user_id = v_uid and s.id = nullif(auth.jwt()->>'session_id', '')::uuid
    for key share;
  if not found then raise exception 'Active session required' using errcode = '42501'; end if;
  if p_request_id is null or p_title is null or btrim(p_title) = '' then
    raise exception 'Quest request and title required' using errcode = '22023';
  end if;
  select v.xp, v.coins into v_xp, v_coins from private.task_reward_values(p_friction) v;
  v_hash := encode(sha256(convert_to(jsonb_build_array(btrim(p_title), p_friction)::text, 'UTF8')), 'hex');

  insert into private.task_creation_requests(user_id, request_id, payload_hash, task_id)
    values (v_uid, p_request_id, v_hash, v_task_id)
    on conflict (user_id, request_id) do nothing;
  if not found then
    select * into strict v_receipt from private.task_creation_requests
      where user_id = v_uid and request_id = p_request_id;
    if v_receipt.payload_hash is distinct from v_hash then
      raise exception 'Request already used for another quest' using errcode = '22023';
    end if;
    return v_receipt.task_id;
  end if;
  insert into public.tasks(id, user_id, title, status, friction_level, xp_value, coin_value)
    values (v_task_id, v_uid, btrim(p_title), 'open', p_friction, v_xp, v_coins);
  return v_task_id;
end;
$function$;
revoke all on function private.create_task_once(uuid, uuid, text, integer) from public, anon, authenticated, service_role;
grant execute on function private.create_task_once(uuid, uuid, text, integer) to authenticated;

create function public.create_task_once(
  p_request_id uuid, p_expected_user_id uuid, p_title text, p_friction integer
) returns uuid language sql security invoker set search_path = ''
as $function$
  select private.create_task_once(p_request_id, p_expected_user_id, p_title, p_friction);
$function$;
revoke all on function public.create_task_once(uuid, uuid, text, integer) from public, anon, authenticated, service_role;
grant execute on function public.create_task_once(uuid, uuid, text, integer) to authenticated;

-- Legacy INSERT grants and server-derived rewards are intentionally unchanged.
notify pgrst, 'reload schema';
commit;
