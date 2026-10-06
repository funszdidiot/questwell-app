-- C04: serialize completion within one battle, before locking individual steps.
-- Source proposal only. Hosted rollout and historical repair remain gated.
begin;
set local lock_timeout = '3s';
set local statement_timeout = '20s';

CREATE OR REPLACE FUNCTION private.complete_boss_step(p_step_id uuid)
 RETURNS TABLE(boss_completed boolean, xp_awarded integer, coins_awarded integer, total_xp integer, coin_balance integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
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

  -- Read the owned parent identity without locking the child first. Every
  -- completion for this battle then takes the same parent lock before any
  -- child mutation, preventing different final steps from missing each other.
  select s.boss_id into v_boss_id
  from public.boss_steps s
  where s.id = p_step_id and s.user_id = v_user_id;

  if v_boss_id is null then
    raise exception 'Boss step not found';
  end if;

  perform 1 from public.boss_battles b
  where b.id = v_boss_id and b.user_id = v_user_id
  for update;
  if not found then
    raise exception 'Boss step not found';
  end if;

  -- Re-read after waiting: a competing completion may have changed this step.
  select s.completed into v_step_completed
  from public.boss_steps s
  where s.id = p_step_id and s.boss_id = v_boss_id
    and s.user_id = v_user_id
  for update;
  if not found then
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
$function$;

-- CREATE OR REPLACE retains the existing owner, signature and ACL.
commit;
