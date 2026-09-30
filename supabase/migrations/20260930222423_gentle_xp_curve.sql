-- 100 XP to level 2, then 15 additional XP per level.
-- Preserve earned totals, coins, earned levels and XP already in the current level.
lock table public.users in share row exclusive mode;

create function private.xp_at_level(p_level integer)
returns bigint language sql immutable security invoker set search_path = ''
as $$
  select 100::bigint * greatest(p_level - 1, 0)
    + 15::bigint * greatest(p_level - 1, 0) * greatest(p_level - 2, 0) / 2;
$$;
create function private.level_for_xp(p_xp bigint)
returns integer language plpgsql immutable security invoker set search_path = ''
as $$
declare
  v_xp bigint := greatest(coalesce(p_xp, 0), 0);
  v_level integer;
begin
  v_level := greatest(1, floor((sqrt(34225::numeric + 120::numeric * v_xp) - 185) / 30)::integer + 1);
  -- Exact integer checks protect the threshold from square-root rounding.
  while private.xp_at_level(v_level + 1) <= v_xp loop v_level := v_level + 1; end loop;
  while private.xp_at_level(v_level) > v_xp loop v_level := v_level - 1; end loop;
  return v_level;
end;
$$;
revoke all on function private.xp_at_level(integer), private.level_for_xp(bigint) from public, anon, authenticated;

do $$
begin
  if exists(select 1 from public.users
    where coalesce(level, 1) <> greatest(1, coalesce(total_xp, 0) / 100 + 1)
       or coalesce(total_xp, 0) < 0) then
    raise exception 'Existing progression needs review before curve migration';
  end if;
end;
$$;

alter table public.users add column level_xp_offset bigint not null default 0
  check (level_xp_offset >= 0);
comment on column public.users.level_xp_offset is
  'One-time legacy progression credit; excluded from lifetime earned XP and reward events.';
update public.users
set level_xp_offset = private.xp_at_level(coalesce(level, 1)) - 100::bigint * greatest(coalesce(level, 1) - 1, 0);

-- Profile clients must never be able to manufacture or modify legacy credit.
create function private.protect_level_xp_offset()
returns trigger language plpgsql security invoker set search_path = ''
as $$
begin
  if current_user in ('anon', 'authenticated') then
    if tg_op = 'INSERT' then
      if new.level_xp_offset <> 0 then
        raise exception 'Progression credit is server managed' using errcode = '42501';
      end if;
    elsif new.level_xp_offset is distinct from old.level_xp_offset then
      raise exception 'Progression credit is server managed' using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;
revoke all on function private.protect_level_xp_offset() from public, anon, authenticated;
create trigger protect_level_xp_offset before insert or update of level_xp_offset
  on public.users for each row execute function private.protect_level_xp_offset();

CREATE OR REPLACE FUNCTION private.complete_boss_step(p_step_id uuid)
 RETURNS TABLE(boss_completed boolean, xp_awarded integer, coins_awarded integer, total_xp integer, coin_balance integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare
  v_user_id uuid := auth.uid();
  v_boss_id uuid;
  v_step_completed boolean;
  v_reward_xp integer := 0;
  v_reward_coins integer := 0;
  v_remaining integer;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  select boss_id, completed
    into v_boss_id, v_step_completed
  from public.boss_steps
  where id = p_step_id
    and user_id = v_user_id
  for update;

  if v_boss_id is null then
    raise exception 'Boss step not found';
  end if;

  if v_step_completed then
    raise exception 'Boss step already completed';
  end if;

  update public.boss_steps
  set completed = true,
      completed_at = now()
  where id = p_step_id
    and user_id = v_user_id
    and completed = false;

  select count(*)
    into v_remaining
  from public.boss_steps
  where boss_id = v_boss_id
    and user_id = v_user_id
    and completed = false;

  if v_remaining = 0 then
    update public.boss_battles
    set status = 'completed',
        completed_at = now()
    where id = v_boss_id
      and user_id = v_user_id
      and status = 'open'
    returning reward_xp, reward_coins
      into v_reward_xp, v_reward_coins;

    if found then
      insert into public.reward_events(
        user_id,
        task_id,
        event_type,
        xp_amount,
        coin_amount
      )
      values (
        v_user_id,
        null,
        'boss_battle_completed',
        v_reward_xp,
        v_reward_coins
      );

      update public.users
      set total_xp = public.users.total_xp + v_reward_xp,
          coin_balance = public.users.coin_balance + v_reward_coins,
          level = private.level_for_xp(public.users.total_xp::bigint + v_reward_xp + public.users.level_xp_offset)
      where id = v_user_id;
    end if;
  end if;

  return query
  select
    (select status = 'completed'
       from public.boss_battles
      where id = v_boss_id),
    v_reward_xp,
    v_reward_coins,
    u.total_xp,
    u.coin_balance
  from public.users u
  where u.id = v_user_id;
end;
$function$
;
CREATE OR REPLACE FUNCTION private.complete_task(p_task_id uuid)
 RETURNS TABLE(task_id uuid, xp_awarded integer, coins_awarded integer, total_xp integer, coin_balance integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare
  v_uid uuid := auth.uid();
  v_task public.tasks%rowtype;
  v_total_xp integer;
  v_coin_balance integer;
begin
  if v_uid is null then
    raise exception 'authentication required';
  end if;

  select *
    into v_task
  from public.tasks
  where id = p_task_id
    and user_id = v_uid
    and status = 'open'
  for update;

  if not found then
    raise exception 'task not found, not owned by caller, or already completed';
  end if;

  update public.tasks
  set status = 'completed',
      completed_at = now()
  where id = p_task_id
    and user_id = v_uid
    and status = 'open';

  insert into public.reward_events (
    user_id,
    task_id,
    event_type,
    xp_amount,
    coin_amount
  )
  values (
    v_uid,
    p_task_id,
    'task_completed',
    coalesce(v_task.xp_value, 0),
    coalesce(v_task.coin_value, 0)
  );

  update public.users
  set total_xp = coalesce(public.users.total_xp, 0) + coalesce(v_task.xp_value, 0),
      coin_balance = coalesce(public.users.coin_balance, 0) + coalesce(v_task.coin_value, 0),
      level = private.level_for_xp(
        coalesce(public.users.total_xp, 0)::bigint + coalesce(v_task.xp_value, 0)
        + public.users.level_xp_offset
      )
  where id = v_uid
  returning public.users.total_xp, public.users.coin_balance
    into v_total_xp, v_coin_balance;

  return query
  select
    p_task_id,
    coalesce(v_task.xp_value, 0),
    coalesce(v_task.coin_value, 0),
    v_total_xp,
    v_coin_balance;
end;
$function$
;

notify pgrst, 'reload schema';
