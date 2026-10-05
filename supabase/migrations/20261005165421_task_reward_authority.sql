-- R01: server-authoritative task rewards. Source proposal; live rollout requires
-- migration-history reconciliation and Tanya's separate exact-scope approval.
begin;

-- Keep the existing four approved reward tiers in one server-owned mapping.
create function private.task_reward_values(p_friction integer)
returns table(xp integer, coins integer)
language plpgsql immutable security invoker set search_path = ''
as $function$
begin
  if p_friction is null or p_friction not between 1 and 4 then
    raise exception 'Choose a valid quest difficulty' using errcode = '22023';
  end if;
  return query select
    case p_friction when 1 then 10 when 2 then 20 when 3 then 35 when 4 then 60 end,
    case p_friction when 1 then 5 when 2 then 10 when 3 then 18 when 4 then 30 end;
end;
$function$;
alter function private.task_reward_values(integer) owner to postgres;
revoke all on function private.task_reward_values(integer) from public, anon, authenticated, service_role;
grant execute on function private.task_reward_values(integer) to authenticated, service_role;

-- Invoker security is intentional: a completion RPC runs as its existing private
-- definer; direct REST writes run as authenticated and cannot forge that role.
create function private.guard_task_write()
returns trigger language plpgsql security invoker set search_path = ''
as $function$
begin
  if current_user not in ('anon', 'authenticated') then return new; end if;
  if tg_op = 'INSERT' then
    if new.status is distinct from 'open' then
      raise exception 'New quests must be open' using errcode = '42501';
    end if;
  else
    if old.status is null or old.status not in ('open', 'set_aside') then
      raise exception 'Completed quest history is server managed' using errcode = '42501';
    end if;
    if new.status is null or new.status not in ('open', 'set_aside') then
      raise exception 'Complete quests through complete_task' using errcode = '42501';
    end if;
  end if;
  select v.xp, v.coins into new.xp_value, new.coin_value
    from private.task_reward_values(new.friction_level) v;
  return new;
end;
$function$;
alter function private.guard_task_write() owner to postgres;
revoke all on function private.guard_task_write() from public, anon, authenticated, service_role;
create trigger task_write_guard before insert or update on public.tasks
for each row execute function private.guard_task_write();

-- Preserve request compatibility for old clients that send display reward values.
-- The trigger ignores those values. IDs/timestamps are exclusively server-owned.
revoke insert, update, delete, truncate, references, trigger, maintain
  on public.tasks from public, anon, authenticated;
grant insert (user_id, title, notes, status, due_date, friction_level, xp_value, coin_value)
  on public.tasks to authenticated;
grant update (title, notes, status, due_date, friction_level, xp_value, coin_value, pinned_at)
  on public.tasks to authenticated;
grant delete on public.tasks to authenticated;
alter table public.tasks alter column status set default 'open';

-- Task IDs cannot be recreated by clients after deletion. Ledger rows remain
-- readable through the unchanged owner RLS policy, but only the server writes.
revoke insert, update, delete, truncate, references, trigger, maintain
  on public.reward_events from public, anon, authenticated;
create index reward_events_task_completion_idx on public.reward_events(task_id)
  where event_type = 'task_completed' and task_id is not null;

create or replace function private.complete_task(p_task_id uuid)
returns table(task_id uuid, xp_awarded integer, coins_awarded integer, total_xp integer, coin_balance integer)
language plpgsql security definer set search_path = ''
as $function$
declare
  v_uid uuid := auth.uid();
  v_task public.tasks%rowtype;
  v_xp integer;
  v_coins integer;
  v_total_xp integer;
  v_coin_balance integer;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  select * into v_task from public.tasks
    where id = p_task_id and user_id = v_uid and status = 'open' for update;
  if not found then
    raise exception 'task not found, not owned by caller, or already completed';
  end if;
  -- Also deny historical rows that were reopened before this hardening change.
  if exists (select 1 from public.reward_events e
    where e.task_id = p_task_id and e.event_type = 'task_completed') then
    raise exception 'task already completed';
  end if;
  select v.xp, v.coins into v_xp, v_coins
    from private.task_reward_values(v_task.friction_level) v;
  update public.tasks set status = 'completed', completed_at = now(),
    xp_value = v_xp, coin_value = v_coins where id = p_task_id;
  insert into public.reward_events(user_id, task_id, event_type, xp_amount, coin_amount)
    values(v_uid, p_task_id, 'task_completed', v_xp, v_coins);
  update public.users set
    total_xp = coalesce(public.users.total_xp, 0) + v_xp,
    coin_balance = coalesce(public.users.coin_balance, 0) + v_coins,
    level = private.level_for_xp(coalesce(public.users.total_xp, 0)::bigint + v_xp + public.users.level_xp_offset)
    where id = v_uid
    returning public.users.total_xp, public.users.coin_balance into v_total_xp, v_coin_balance;
  if not found then raise exception 'account profile unavailable'; end if;
  return query select p_task_id, v_xp, v_coins, v_total_xp, v_coin_balance;
end;
$function$;

-- CREATE OR REPLACE preserves the established owner/EXECUTE grants and the
-- public invoker wrapper. No new public RPC or response shape is introduced.
notify pgrst, 'reload schema';
commit;
