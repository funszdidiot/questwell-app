-- R02: fixed rewards for new battles, without rewriting grandfathered battles.
-- Source proposal only; hosted rollout requires reviewed migration history/grants.
begin;
set local lock_timeout = '3s';
set local statement_timeout = '20s';

CREATE OR REPLACE FUNCTION private.create_boss_battle(p_title text, p_steps text[], p_reward_xp integer DEFAULT 25, p_reward_coins integer DEFAULT 50, p_boss_type text DEFAULT 'inbox_hydra'::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid := auth.uid();
  v_boss_id uuid;
  v_step text;
  v_position integer := 0;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  if p_title is null or char_length(trim(p_title)) = 0 then
    raise exception 'Boss title is required';
  end if;

  if p_steps is null or array_length(p_steps, 1) is null or array_length(p_steps, 1) < 2 then
    raise exception 'A Boss Battle requires at least two steps';
  end if;

  if p_boss_type not in (
    'inbox_hydra','meeting_mimic','spreadsheet_slime','calendar_kraken',
    'printer_poltergeist','notification_swarm','ticket_troll','update_dragon'
  ) then
    raise exception 'Unsupported boss type';
  end if;


  -- questwell_boss_unlock_gate_v1: creation only; saved battles remain playable.
  declare
    required_level integer := case p_boss_type
      when 'inbox_hydra' then 1 when 'meeting_mimic' then 3
      when 'spreadsheet_slime' then 5 when 'calendar_kraken' then 7
      when 'printer_poltergeist' then 10 when 'notification_swarm' then 13
      when 'ticket_troll' then 16 when 'update_dragon' then 20
      else null end;
    earned_level integer;
  begin
    if required_level is null then
      raise exception 'Unsupported boss type';
    end if;
    select coalesce(u.level, 1) into earned_level
      from public.users u where u.id = v_user_id;
    if earned_level is null then
      raise exception 'Profile required';
    end if;
    if earned_level < required_level then
      raise exception using message = format('This boss unlocks at level %s.', required_level),
        errcode = 'P0001';
    end if;
  end;

  -- Reward arguments remain for API compatibility; the server owns new rewards.
  insert into public.boss_battles(
    user_id, title, reward_xp, reward_coins, boss_type
  )
  values (
    v_user_id,
    trim(p_title),
    25,
    50,
    p_boss_type
  )
  returning id into v_boss_id;

  foreach v_step in array p_steps loop
    if v_step is not null and char_length(trim(v_step)) > 0 then
      insert into public.boss_steps(boss_id, user_id, title, position)
      values (v_boss_id, v_user_id, trim(v_step), v_position);
      v_position := v_position + 1;
    end if;
  end loop;

  if v_position < 2 then
    delete from public.boss_battles where id = v_boss_id;
    raise exception 'A Boss Battle requires at least two non-empty steps';
  end if;

  return v_boss_id;
end;
$function$;

revoke all on function private.create_boss_battle(text,text[],integer,integer,text)
  from public, anon;
grant execute on function private.create_boss_battle(text,text[],integer,integer,text)
  to authenticated;

-- Clients already write through RPCs. Keep owner SELECT/RLS and remove broad
-- table privileges (including TRUNCATE, which is not protected by RLS).
revoke all on table public.boss_battles, public.boss_steps
  from public, anon, authenticated;
grant select on table public.boss_battles, public.boss_steps to authenticated;

commit;
