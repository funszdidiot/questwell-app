-- Only loaded by the disposable CI harness. Fixed clocks never reach release SQL.
do $test$
<<hollow_harvest_contract>>
declare
  original text := pg_get_functiondef('private.create_boss_battle(text,text[],integer,integer,text)'::regprocedure);
  owner_id uuid := gen_random_uuid();
  session_id uuid := gen_random_uuid();
  request_id uuid := gen_random_uuid();
  boss_id uuid;
  returned_id uuid;
  step_id uuid;
  xp_before integer;
  coins_before integer;
  boundary timestamptz;
  allowed boolean;
begin
  insert into auth.users(id,email,aud,role) values(owner_id,'harvest-ci-'||owner_id||'@example.test','authenticated','authenticated');
  insert into auth.sessions(id,user_id) values(session_id,owner_id);
  perform set_config('request.jwt.claim.sub',owner_id::text,true);
  perform set_config('request.jwt.claims',json_build_object('sub',owner_id,'role','authenticated','session_id',session_id)::text,true);
  foreach boundary in array array[
    timestamptz '2026-10-08T03:36:53.444480Z',
    timestamptz '2026-10-08T03:36:53.444481Z',
    timestamptz '2026-11-09T05:59:59.999999Z',
    timestamptz '2026-11-09T06:00:00Z'] loop
    execute replace(original,'statement_timestamp()',format('%L::timestamptz',boundary));
    allowed := boundary >= timestamptz '2026-10-08T03:36:53.444481Z' and boundary < timestamptz '2026-11-09T06:00:00Z';
    set local role authenticated;
    begin
      returned_id := public.create_boss_battle('Season boundary',array['One','Two'],9999,9999,'hollow_harvest');
      if not allowed then raise exception 'Closed season accepted' using errcode='XX000'; end if;
      if not exists(select 1 from public.boss_battles where id=returned_id and reward_xp=25 and reward_coins=50) then
        raise exception 'Harvest rewards were not fixed' using errcode='XX000';
      end if;
    exception when raise_exception then
      if allowed or sqlerrm <> 'The Hollow Harvest is outside the Halloween season.' then raise; end if;
    end;
    reset role;
  end loop;
  execute replace(original,'statement_timestamp()',$clock$timestamptz '2026-10-31T12:00:00Z'$clock$);
  set local role authenticated;
  boss_id := public.create_boss_once(request_id,owner_id,'Harvest retry',array['One','Two'],'hollow_harvest');
  reset role;
  execute replace(original,'statement_timestamp()',$clock$timestamptz '2026-11-09T06:00:00Z'$clock$);
  set local role authenticated;
  returned_id := public.create_boss_once(request_id,owner_id,'Harvest retry',array['One','Two'],'hollow_harvest');
  if returned_id <> boss_id then raise exception 'Closed-season receipt lost'; end if;
  begin
    perform public.create_boss_once(gen_random_uuid(),owner_id,'New closed battle',array['One','Two'],'hollow_harvest');
    raise exception 'Closed fresh request accepted' using errcode='XX000';
  exception when raise_exception then
    if sqlerrm <> 'The Hollow Harvest is outside the Halloween season.' then raise; end if;
  end;
  select total_xp,coin_balance into xp_before,coins_before from public.users where id=owner_id;
  for step_id in select s.id from public.boss_steps s where s.boss_id=hollow_harvest_contract.boss_id loop
    perform public.complete_boss_step(step_id);
    perform public.complete_boss_step(step_id);
  end loop;
  if not exists(select 1 from public.boss_battles where id=hollow_harvest_contract.boss_id and status='completed') then
    raise exception 'Saved Harvest battle cannot complete after close';
  end if;
  if not exists(select 1 from public.users where id=owner_id and total_xp=xp_before+25 and coin_balance=coins_before+50) then
    raise exception 'Harvest victory reward was not paid exactly once';
  end if;
  perform public.create_boss_battle('Regular boss after close',array['One','Two'],25,50,'inbox_hydra');
  begin
    perform public.create_boss_battle('Locked regular boss',array['One','Two'],25,50,'update_dragon');
    raise exception 'Regular level gate bypassed' using errcode='XX000';
  exception when raise_exception then
    if sqlerrm <> 'This boss unlocks at level 20.' then raise; end if;
  end;
  reset role;
  execute original;
end;
$test$;
