begin;
select set_config('qa.roadmap_user',gen_random_uuid()::text,true);
select set_config('qa.roadmap_boss',gen_random_uuid()::text,true);
select set_config('qa.roadmap_preview',gen_random_uuid()::text,true);
insert into auth.users(id,email) values
 (current_setting('qa.roadmap_user')::uuid,current_setting('qa.roadmap_user')||'@example.invalid'),
 (current_setting('qa.roadmap_boss')::uuid,current_setting('qa.roadmap_boss')||'@example.invalid'),
 (current_setting('qa.roadmap_preview')::uuid,current_setting('qa.roadmap_preview')||'@example.invalid');
update public.users set level=4,total_xp=489,coin_balance=79 where id in
 (current_setting('qa.roadmap_user')::uuid,current_setting('qa.roadmap_boss')::uuid,current_setting('qa.roadmap_preview')::uuid);
-- Remove only setup transitions for these disposable fixtures.
delete from public.progression_events where user_id in
 (current_setting('qa.roadmap_user')::uuid,current_setting('qa.roadmap_boss')::uuid,current_setting('qa.roadmap_preview')::uuid);
insert into public.user_cosmetics(user_id,cosmetic_id,source,unlocked_at)
 select current_setting('qa.roadmap_preview')::uuid,id,'founder_testing_grant','2026-09-29T12:00:00Z' from public.cosmetics where slug='first-journey-trophy';
insert into public.tasks(user_id,title,status,xp_value,coin_value) values
 (current_setting('qa.roadmap_user')::uuid,'roadmap-five','open',1,2),
 (current_setting('qa.roadmap_user')::uuid,'roadmap-ten','open',1000,3),
 (current_setting('qa.roadmap_preview')::uuid,'roadmap-preview-five','open',1,2);
set local role authenticated;
select set_config('request.jwt.claims',json_build_object('sub',current_setting('qa.roadmap_user'),'role','authenticated')::text,true);
do $$
declare reward record; denied boolean; target uuid;
begin
 if exists(select 1 from public.progression_events) then raise exception 'Cross-user journal exposed'; end if;
 select id into strict target from public.tasks where title='roadmap-five';
 select * into reward from public.complete_task(target);
 if reward.total_xp<>490 or reward.coin_balance<>81 then raise exception 'Journal changed rewards'; end if;
 if (select count(*) from public.progression_events where kind='level_up' and level=5)<>1 then raise exception 'Missing level 5 event'; end if;
 if (select count(*) from public.progression_events where kind='milestone_reward' and cosmetic_slug='first-journey-trophy' and source='level_milestone')<>1 then raise exception 'Missing trophy event'; end if;
 denied:=false;
 begin perform public.complete_task(target); exception when others then
  if sqlerrm not like '%already completed%' then raise; end if; denied:=true; end;
 if not denied or (select count(*) from public.progression_events)<>2 then raise exception 'Duplicate completion journaled twice'; end if;
 perform public.complete_task((select id from public.tasks where title='roadmap-ten'));
 if (select array_agg(level order by level) from public.progression_events where kind='level_up')<>array[5,6,7,8,9,10] then raise exception 'Skipped levels missing'; end if;
 if (select count(*) from public.progression_events where kind='milestone_reward')<>1 then raise exception 'Duplicate trophy event'; end if;
 denied:=false;
 begin insert into public.progression_events(user_id,kind,event_key,title,level,source)
 values(auth.uid(),'level_up','100','Fake',100,'progression'); exception when insufficient_privilege then denied:=true; end;
 if not denied then raise exception 'Client could forge journal'; end if;
 denied:=false;
 begin update public.progression_events set title='Fake' where user_id=auth.uid(); exception when insufficient_privilege then denied:=true; end;
 if not denied then raise exception 'Client could rewrite journal'; end if;
 denied:=false;
 begin delete from public.progression_events where user_id=auth.uid(); exception when insufficient_privilege then denied:=true; end;
 if not denied then raise exception 'Client could erase journal'; end if;
 if has_function_privilege('authenticated','private.record_level_milestones()','execute') or has_function_privilege('anon','private.record_milestone_reward()','execute') then raise exception 'Journal trigger exposed'; end if;
end $$;
select set_config('request.jwt.claims',json_build_object('sub',current_setting('qa.roadmap_preview'),'role','authenticated')::text,true);
do $$ begin
 if not exists(select 1 from public.progression_events where source='founder_testing_grant' and occurred_at='2026-09-29T12:00:00Z' and kind='milestone_reward') then raise exception 'Preview date/source lost'; end if;
 if exists(select 1 from public.progression_events where kind='level_up') then raise exception 'Preview grant invented level-up'; end if;
 perform public.complete_task((select id from public.tasks where title='roadmap-preview-five'));
 if (select count(*) from public.progression_events)<>2 then raise exception 'Early copy duplicates or missing later earned level'; end if;
end $$;
select set_config('request.jwt.claims',json_build_object('sub',current_setting('qa.roadmap_boss'),'role','authenticated')::text,true);
do $$ declare boss uuid; step_id uuid;
begin
 boss:=public.create_boss_battle('roadmap-boss',array['one','two']);
 for step_id in select id from public.boss_steps where boss_id=boss order by position loop
  perform public.complete_boss_step(step_id);
 end loop;
 if (select count(*) from public.progression_events where kind='level_up' and level=5)<>1 or
  (select count(*) from public.progression_events where kind='milestone_reward')<>1 then raise exception 'Boss progression not journaled'; end if;
end $$;
reset role;
update public.users set level=level where id=current_setting('qa.roadmap_user')::uuid;
do $$ begin
 if (select count(*) from public.progression_events where user_id=current_setting('qa.roadmap_user')::uuid)<>7 then raise exception 'Unchanged level repeated journal'; end if;
 if has_table_privilege('anon','public.progression_events','select') then raise exception 'Anonymous journal read'; end if;
end $$;
rollback;
select 'PASS: task/boss level-ups, multi-level jumps, unique rewards, preview provenance, real dates, unchanged economy, owner-only reads and no client writes; fixtures rolled back' as result;
