begin;
-- Synthetic accounts and rewards only; every fixture is rolled back.
do $$
declare n integer; threshold bigint;
begin
  for n in 2..10000 loop
    threshold := private.xp_at_level(n);
    if private.level_for_xp(threshold) <> n or private.level_for_xp(threshold - 1) <> n - 1 then
      raise exception 'Threshold mismatch at level %', n;
    end if;
  end loop;
  if private.level_for_xp(-1) <> 1 or private.level_for_xp(0) <> 1 then
    raise exception 'Level-one floor mismatch';
  end if;
end $$;

select set_config('qa.xp_user', gen_random_uuid()::text, true);
select set_config('qa.xp_legacy', gen_random_uuid()::text, true);
insert into auth.users(id,email) values
 (current_setting('qa.xp_user')::uuid, current_setting('qa.xp_user') || '@example.invalid'),
 (current_setting('qa.xp_legacy')::uuid, current_setting('qa.xp_legacy') || '@example.invalid');
update public.users set total_xp=99, level=1, coin_balance=0
 where id=current_setting('qa.xp_user')::uuid;
update public.users set total_xp=355, level=4, coin_balance=79, level_xp_offset=45
 where id=current_setting('qa.xp_legacy')::uuid;
insert into public.tasks(user_id,title,status,xp_value,coin_value)
values
 (current_setting('qa.xp_user')::uuid,'xp-qa-exact-100','open',1,2),
 (current_setting('qa.xp_user')::uuid,'xp-qa-below-215','open',114,3),
 (current_setting('qa.xp_user')::uuid,'xp-qa-exact-215','open',1,1),
 (current_setting('qa.xp_user')::uuid,'xp-qa-carryover','open',235,4),
 (current_setting('qa.xp_user')::uuid,'xp-qa-multilevel','open',1000,5),
 (current_setting('qa.xp_legacy')::uuid,'xp-qa-legacy-490','open',90,7);

set local role authenticated;
select set_config('request.jwt.claims', json_build_object('sub',current_setting('qa.xp_user'),'role','authenticated')::text,true);
do $$
declare t uuid; boss uuid; step_id uuid; reward record; denied boolean;
begin
  select id into strict t from public.tasks where title='xp-qa-exact-100';
  select * into reward from public.complete_task(t);
  if reward.xp_awarded <> 1 or reward.coins_awarded <> 2 or reward.total_xp <> 100
     or (select level from public.users where id=auth.uid()) <> 2 then raise exception 'First boundary/reward mismatch'; end if;
  denied := false;
  begin perform public.complete_task(t);
  exception when others then
    if sqlerrm not like '%already completed%' then raise; end if;
    denied := true;
  end;
  if not denied then raise exception 'Repeated task awarded twice'; end if;
  perform public.complete_task((select id from public.tasks where title='xp-qa-below-215'));
  if (select level from public.users where id=auth.uid()) <> 2 then raise exception 'Premature level 3'; end if;
  perform public.complete_task((select id from public.tasks where title='xp-qa-exact-215'));
  if (select level from public.users where id=auth.uid()) <> 3 then raise exception 'Exact level 3 missing'; end if;
  perform public.complete_task((select id from public.tasks where title='xp-qa-carryover'));
  if not exists(select 1 from public.users where id=auth.uid() and total_xp=450 and level=4 and coin_balance=10 and level_xp_offset=0) then
    raise exception 'Quest carryover/coin reward mismatch';
  end if;
  boss := public.create_boss_battle('xp-qa-boss', array['one','two']);
  select id into strict step_id from public.boss_steps where boss_id=boss and position=0;
  select * into reward from public.complete_boss_step(step_id);
  if reward.boss_completed or reward.xp_awarded <> 0 or reward.coins_awarded <> 0 then raise exception 'Early boss reward'; end if;
  select id into strict step_id from public.boss_steps where boss_id=boss and position=1;
  select * into reward from public.complete_boss_step(step_id);
  if not reward.boss_completed or reward.xp_awarded <> 100 or reward.coins_awarded <> 50 or reward.total_xp <> 550
    or (select level from public.users where id=auth.uid()) <> 5 then raise exception 'Boss level-up mismatch'; end if;
  denied := false;
  begin perform public.complete_boss_step(step_id);
  exception when others then
    if sqlerrm <> 'Boss step already completed' then raise; end if;
    denied := true;
  end;
  if not denied then raise exception 'Repeated boss reward'; end if;
  perform public.complete_task((select id from public.tasks where title='xp-qa-multilevel'));
  if not exists(select 1 from public.users where id=auth.uid() and total_xp=1550 and level=10 and coin_balance=65) then
    raise exception 'Multi-level carryover mismatch';
  end if;
  denied := false;
  begin update public.users set level_xp_offset=100 where id=auth.uid();
  exception when insufficient_privilege then denied := true; end;
  if not denied then raise exception 'Client modified legacy credit'; end if;
  denied := false;
  begin insert into public.users(id,level_xp_offset) values(auth.uid(),100);
  exception when insufficient_privilege then denied := true; end;
  if not denied then raise exception 'Client inserted legacy credit'; end if;
  if exists(select 1 from public.users where id=current_setting('qa.xp_legacy')::uuid) then
    raise exception 'Cross-account profile exposed';
  end if;
end $$;
select set_config('request.jwt.claims', json_build_object('sub',current_setting('qa.xp_legacy'),'role','authenticated')::text,true);
do $$
declare reward record;
begin
  select * into reward from public.complete_task((select id from public.tasks where title='xp-qa-legacy-490'));
  if reward.total_xp <> 445 or reward.coin_balance <> 86
    or not exists(select 1 from public.users where id=auth.uid() and level=5 and level_xp_offset=45) then
    raise exception 'Legacy level-up changed earned total, coins, or progression credit';
  end if;
end $$;
reset role;
rollback;
select 'PASS: 10,000 level boundaries, quest/boss awards, carryover, multiple levels, duplicate protection, legacy progress and RLS; fixtures rolled back' as result;
