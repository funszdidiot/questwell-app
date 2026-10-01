begin;
set local lock_timeout='3s';
set local statement_timeout='20s';
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
do $test$
declare
  fixture uuid := gen_random_uuid();
  item record;
  boss_id uuid;
  rejected boolean;
  expected_xp integer;
begin
  -- Fictional fixture and all function/data changes are transaction-local.
  insert into auth.users(id, email, aud, role)
    values (fixture, 'questwell-boss-gate-test-' || fixture || '@example.invalid', 'authenticated', 'authenticated');
  insert into public.users(id, level, total_xp, level_xp_offset)
    values (fixture, 1, 0, 0) on conflict (id) do nothing;
  perform set_config('request.jwt.claim.sub', fixture::text, true);
  perform set_config('request.jwt.claims', json_build_object('sub', fixture, 'role', 'authenticated')::text, true);

  for item in select * from (values
    ('inbox_hydra',1),('meeting_mimic',3),('spreadsheet_slime',5),('calendar_kraken',7),
    ('printer_poltergeist',10),('notification_swarm',13),('ticket_troll',16),('update_dragon',20)
  ) as gates(kind,required_level) loop
    if item.required_level > 1 then
      expected_xp := 100*(item.required_level-2) + 15*(item.required_level-2)*(item.required_level-3)/2;
      update public.users set level=item.required_level-1, total_xp=expected_xp where id=fixture;
      rejected := false;
      begin
        perform public.create_boss_battle('Locked fixture', array['First step','Second step'],100,50,item.kind);
      exception when raise_exception then
        if sqlerrm = format('This boss unlocks at level %s.',item.required_level) then
          rejected := true;
        else raise;
        end if;
      end;
      if not rejected then raise exception 'Under-level gate failed for %',item.kind; end if;
    end if;
    expected_xp := 100*(item.required_level-1) + 15*(item.required_level-1)*(item.required_level-2)/2;
    update public.users set level=item.required_level,total_xp=expected_xp where id=fixture;
    boss_id := public.create_boss_battle('Unlocked fixture',array['First step','Second step'],100,50,item.kind);
    if not exists(select 1 from public.boss_battles where id=boss_id and user_id=fixture and boss_type=item.kind) then
      raise exception 'Exact-level gate failed for %',item.kind;
    end if;
  end loop;
  if (select count(*) from public.boss_battles where user_id=fixture) <> 8 then
    raise exception 'Unexpected battle count after gate checks';
  end if;
  perform set_config('request.jwt.claim.sub', '', true);
  perform set_config('request.jwt.claims', '{}', true);
  rejected := false;
  begin
    perform public.create_boss_battle('Anonymous fixture',array['First','Second'],100,50,'inbox_hydra');
  exception when raise_exception then
    if sqlerrm = 'Not authenticated' then rejected := true; else raise; end if;
  end;
  if not rejected then raise exception 'Anonymous creation was not rejected'; end if;
end;
$test$;
rollback;
select 'PASS: live 25-XP cap, 8 exact-level unlocks, 7 under-level rejections, 2/5/20-step rewards paid once, reward edge cases, duplicate and anonymous rejection. Test fixtures rolled back.' as result;