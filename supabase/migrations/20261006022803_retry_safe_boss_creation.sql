begin;

-- Receipts outlive a boss, but not its account. No titles or step text retained.
create table private.boss_creation_requests (
  user_id uuid not null references auth.users(id) on delete cascade,
  request_id uuid not null,
  payload_hash text not null,
  boss_id uuid not null,
  primary key (user_id, request_id)
);
alter table private.boss_creation_requests enable row level security;
revoke all on private.boss_creation_requests from public, anon, authenticated, service_role;

create function private.create_boss_once(
  p_request_id uuid, p_expected_user_id uuid, p_title text, p_steps text[], p_boss_type text
) returns uuid language plpgsql security definer set search_path = ''
as $function$
declare
  v_uid uuid := auth.uid();
  v_hash text;
  v_receipt private.boss_creation_requests%rowtype;
  v_boss_id uuid;
begin
  if v_uid is null or p_expected_user_id is distinct from v_uid then
    raise exception 'Boss account changed' using errcode = '42501';
  end if;
  perform pg_catalog.pg_advisory_xact_lock_shared(pg_catalog.hashtextextended(v_uid::text, 24003));
  if exists (select 1 from private.account_deletion_fences where user_id = v_uid) then
    raise exception 'Account deletion in progress' using errcode = '42501';
  end if;
  perform 1 from auth.sessions s
    where s.user_id = v_uid and s.id = nullif(auth.jwt()->>'session_id', '')::uuid
    for key share;
  if not found then raise exception 'Active session required' using errcode = '42501'; end if;
  if p_request_id is null then
    raise exception 'Boss request required' using errcode = '22023';
  end if;
  v_hash := encode(sha256(convert_to(jsonb_build_array(btrim(p_title), p_steps, p_boss_type)::text, 'UTF8')), 'hex');

  -- The provisional ID is private and replaced before this transaction commits.
  -- The unique constraint waits for another transaction with the same request.
  insert into private.boss_creation_requests(user_id, request_id, payload_hash, boss_id)
    values (v_uid, p_request_id, v_hash, gen_random_uuid())
    on conflict (user_id, request_id) do nothing;
  if not found then
    select * into strict v_receipt from private.boss_creation_requests
      where user_id = v_uid and request_id = p_request_id;
    if v_receipt.payload_hash is distinct from v_hash then
      raise exception 'Request already used for another boss' using errcode = '22023';
    end if;
    return v_receipt.boss_id;
  end if;

  -- Preserve the established validation, level gates and server reward mapping.
  v_boss_id := private.create_boss_battle(p_title, p_steps, 25, 50, p_boss_type);
  update private.boss_creation_requests set boss_id = v_boss_id
    where user_id = v_uid and request_id = p_request_id;
  return v_boss_id;
end;
$function$;
revoke all on function private.create_boss_once(uuid,uuid,text,text[],text) from public, anon, authenticated, service_role;
grant execute on function private.create_boss_once(uuid,uuid,text,text[],text) to authenticated;

create function public.create_boss_once(
  p_request_id uuid, p_expected_user_id uuid, p_title text, p_steps text[], p_boss_type text
) returns uuid language sql security invoker set search_path = ''
as $function$
  select private.create_boss_once(p_request_id, p_expected_user_id, p_title, p_steps, p_boss_type);
$function$;
revoke all on function public.create_boss_once(uuid,uuid,text,text[],text) from public, anon, authenticated, service_role;
grant execute on function public.create_boss_once(uuid,uuid,text,text[],text) to authenticated;

-- Existing creation RPCs remain compatible; no existing data/grants are rewritten.
notify pgrst, 'reload schema';
commit;
