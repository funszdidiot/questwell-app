begin;

-- Recovery checks include completed/deleted quest history; existing partial
-- open-task indexes cannot serve these owner lookups.
create index tasks_onboarding_owner_idx on public.tasks(user_id);
create index reward_events_onboarding_owner_idx on public.reward_events(user_id);

-- One durable onboarding decision per account, including skip. Retain the
-- receipt if its quest is deleted; remove it when its Auth owner is deleted.
create table private.onboarding_results (
  user_id uuid primary key references auth.users(id) on delete cascade,
  task_id uuid
);
alter table private.onboarding_results enable row level security;
revoke all on private.onboarding_results from public, anon, authenticated, service_role;

create function private.finish_onboarding_once(p_expected_user_id uuid, p_starter_key text)
returns jsonb language plpgsql security definer set search_path = ''
as $function$
declare
  v_uid uuid := auth.uid();
  v_completed boolean;
  v_task_id uuid;
  v_title text;
  v_friction integer;
  v_xp integer;
  v_coins integer;
begin
  if v_uid is null or p_expected_user_id is distinct from v_uid then
    raise exception 'Setup account changed' using errcode = '42501';
  end if;
  perform pg_catalog.pg_advisory_xact_lock_shared(pg_catalog.hashtextextended(v_uid::text, 24003));
  if exists (select 1 from private.account_deletion_fences where user_id = v_uid) then
    raise exception 'Account deletion in progress' using errcode = '42501';
  end if;
  perform 1 from auth.sessions s
    where s.user_id = v_uid and s.id = nullif(auth.jwt()->>'session_id', '')::uuid
    for key share;
  if not found then raise exception 'Active session required' using errcode = '42501'; end if;
  if p_starter_key is not null and p_starter_key not in ('email','files','avoided') then
    raise exception 'Unknown starter quest' using errcode = '22023';
  end if;

  -- Serialize every starter choice and skip against this same account row.
  select onboarding_completed into v_completed from public.users
    where id = v_uid for update;
  if not found then raise exception 'Account profile unavailable' using errcode = '42501'; end if;

  select task_id into v_task_id from private.onboarding_results where user_id = v_uid;
  if found then
    -- A stale older client may reset its writable flag; it cannot reset the
    -- private outcome or cause this RPC to issue another starter.
    update public.users set onboarding_completed = true where id = v_uid;
    return jsonb_build_object('status','completed','task_id',v_task_id);
  end if;

  if not v_completed and p_starter_key is not null then
    -- Legacy starters have no reliable origin marker. Never classify, delete,
    -- or rewrite personal quests by title. Ask the owner to finish explicitly
    -- with their existing progress instead of adding a potentially duplicate.
    if exists (select 1 from public.tasks where user_id = v_uid)
      or exists (select 1 from public.reward_events where user_id = v_uid) then
      return jsonb_build_object('status','needs_confirmation','task_id',null);
    end if;
    v_title := case p_starter_key
      when 'email' then 'Reply to one email'
      when 'files' then 'Clear five desktop files'
      when 'avoided' then 'Do the thing I keep avoiding' end;
    v_friction := case when p_starter_key = 'avoided' then 3 else 1 end;
    select v.xp, v.coins into v_xp, v_coins from private.task_reward_values(v_friction) v;
    insert into public.tasks(user_id, title, status, friction_level, xp_value, coin_value)
      values (v_uid, v_title, 'open', v_friction, v_xp, v_coins) returning id into v_task_id;
  end if;
  insert into private.onboarding_results(user_id, task_id) values (v_uid, v_task_id);
  update public.users set onboarding_completed = true where id = v_uid;
  return jsonb_build_object('status','completed','task_id',v_task_id);
end;
$function$;
alter function private.finish_onboarding_once(uuid,text) owner to postgres;
revoke all on function private.finish_onboarding_once(uuid,text) from public, anon, authenticated, service_role;
grant execute on function private.finish_onboarding_once(uuid,text) to authenticated;

create function public.finish_onboarding_once(p_expected_user_id uuid, p_starter_key text)
returns jsonb language sql security invoker set search_path = ''
as $function$
  select private.finish_onboarding_once(p_expected_user_id, p_starter_key);
$function$;
revoke all on function public.finish_onboarding_once(uuid,text) from public, anon, authenticated, service_role;
grant execute on function public.finish_onboarding_once(uuid,text) to authenticated;

-- Existing client grants remain unchanged; only updated clients use this atomic
-- boundary. Deployment must account for older clients still doing two writes.
notify pgrst, 'reload schema';
commit;
