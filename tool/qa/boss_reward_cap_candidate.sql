-- Candidate only: no shared-database rollout. Every change below rolls back.
-- New battles cap at 25 XP. Existing saved rewards and earned XP are preserved.
begin;
set local lock_timeout = '3s';
set local statement_timeout = '20s';
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
do $test$
declare
  fixture uuid := gen_random_uuid();
  boss uuid;
  step_row record;
  result record;
  count_steps integer;
  requested integer;
  expected integer;
  prior_xp integer;
  last_step uuid;
  rejected boolean;
begin
  insert into auth.users(id,email,aud,role) values
    (fixture,'questwell-xp-test-'||fixture||'@example.invalid','authenticated','authenticated');
  insert into public.users(id,level,total_xp,level_xp_offset)
    values(fixture,1,0,0) on conflict(id) do nothing;
  perform set_config('request.jwt.claim.sub',fixture::text,true);
  perform set_config('request.jwt.claims',json_build_object('sub',fixture,'role','authenticated')::text,true);
  foreach count_steps in array array[2,5,20] loop
    select total_xp into prior_xp from public.users where id=fixture;
    boss := public.create_boss_battle('XP fixture',
      array(select 'Step '||i from generate_series(1,count_steps) as i),999999,50,'inbox_hydra');
    if (select reward_xp from public.boss_battles where id=boss) <> 25 then
      raise exception 'Over-request was not capped';
    end if;
    for step_row in select id,position from public.boss_steps where boss_id=boss order by position loop
      select * into result from public.complete_boss_step(step_row.id);
      if step_row.position < count_steps-1 and result.xp_awarded <> 0 then
        raise exception 'Intermediate step awarded XP';
      end if;
      last_step := step_row.id;
    end loop;
    if result.xp_awarded <> 25 or result.coins_awarded <> 50 or result.total_xp <> prior_xp+25 then
      raise exception 'Final reward mismatch';
    end if;
    rejected := false;
    begin perform public.complete_boss_step(last_step);
    exception when raise_exception then
      if sqlerrm='Boss step already completed' then rejected:=true; else raise; end if;
    end;
    if not rejected then raise exception 'Duplicate completion not rejected'; end if;
  end loop;
  foreach requested in array array[-10,0,10,25,100] loop
    expected := least(greatest(requested,0),25);
    boss := private.create_boss_battle('Direct guard fixture',array['One','Two'],requested,50,'inbox_hydra');
    if (select reward_xp from public.boss_battles where id=boss) <> expected then
      raise exception 'Private creation cap mismatch';
    end if;
  end loop;
  boss := public.create_boss_battle('Default fixture',array['One','Two']);
  if (select reward_xp from public.boss_battles where id=boss) <> 25 then
    raise exception 'Default reward mismatch';
  end if;
  boss := public.create_boss_battle('Null fixture',array['One','Two'],null,50,'inbox_hydra');
  if (select reward_xp from public.boss_battles where id=boss) <> 25 then
    raise exception 'Null reward mismatch';
  end if;
  if (select count(*) from public.reward_events where user_id=fixture and event_type='boss_battle_completed') <> 3 then
    raise exception 'Duplicate reward event';
  end if;
  if (select total_xp from public.users where id=fixture) <> 75 then
    raise exception 'Unexpected XP total';
  end if;
  perform set_config('request.jwt.claim.sub','',true);
  perform set_config('request.jwt.claims','{}',true);
  rejected := false;
  begin perform public.create_boss_battle('Anonymous',array['One','Two']);
  exception when raise_exception then
    if sqlerrm='Not authenticated' then rejected:=true; else raise; end if;
  end;
  if not rejected then raise exception 'Anonymous creation accepted'; end if;
end;
$test$;
select 'PASS: 2/5/20 steps award 25 XP once; coins 50; over-request/default/null/negative guards; duplicate and anonymous rejection. Rolled back.' as result;
rollback;
