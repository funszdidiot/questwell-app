-- Founder-approved activation, 2026-10-01. New battles only.
-- Existing battles, saved rewards, and earned XP are preserved.
begin;
set local lock_timeout='3s';
set local statement_timeout='20s';
do $patch$
declare
  d text;
begin
  d := pg_get_functiondef('public.create_boss_battle(text,text[],integer,integer,text)'::regprocedure);
  if position('least(greatest(coalesce(p_reward_xp,100),0),100)' in d)=0 then
    raise exception 'Public reward wrapper changed; review candidate';
  end if;
  d := replace(d,'p_reward_xp integer DEFAULT 100','p_reward_xp integer DEFAULT 25');
  d := replace(d,'least(greatest(coalesce(p_reward_xp,100),0),100)',
    'least(greatest(coalesce(p_reward_xp,25),0),25)');
  execute d;
  d := pg_get_functiondef('private.create_boss_battle(text,text[],integer,integer,text)'::regprocedure);
  if position('greatest(coalesce(p_reward_xp,100),0)' in d)=0 then
    raise exception 'Private reward creation changed; review candidate';
  end if;
  d := replace(d,'p_reward_xp integer DEFAULT 100','p_reward_xp integer DEFAULT 25');
  d := replace(d,'greatest(coalesce(p_reward_xp,100),0)',
    'least(greatest(coalesce(p_reward_xp,25),0),25)');
  execute d;
end;
$patch$;
do $patch$
declare
  definition text := pg_get_functiondef('private.create_boss_battle(text,text[],integer,integer,text)'::regprocedure);
  anchor text := '  insert into public.boss_battles(';
  gate text := $gate$
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

$gate$;
begin
  if position('questwell_boss_unlock_gate_v1' in definition) > 0 then
    raise exception 'Candidate already present; review rather than overwrite';
  end if;
  if position(anchor in definition) = 0 then
    raise exception 'Creation function changed; review candidate before proceeding';
  end if;
  execute replace(definition, anchor, gate || anchor);
end;
$patch$;

commit;
