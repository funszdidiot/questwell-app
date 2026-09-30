begin;
-- Run after the migration; all synthetic accounts, grants and placements roll back.
select set_config('qa.journey',gen_random_uuid()::text,true);
select set_config('qa.journey_boss',gen_random_uuid()::text,true);
insert into auth.users(id,email) values
 (current_setting('qa.journey')::uuid,current_setting('qa.journey')||'@example.invalid'),
 (current_setting('qa.journey_boss')::uuid,current_setting('qa.journey_boss')||'@example.invalid');
update public.users set level=4,total_xp=489,coin_balance=79
 where id in (current_setting('qa.journey')::uuid,current_setting('qa.journey_boss')::uuid);
update public.cosmetics set active=true where slug='first-journey-trophy';
insert into public.tasks(user_id,title,status,xp_value,coin_value) values
 (current_setting('qa.journey')::uuid,'journey-exact-five','open',1,2),
 (current_setting('qa.journey')::uuid,'journey-later','open',1000,3);
insert into public.user_cosmetics(user_id,cosmetic_id,source)
 select current_setting('qa.journey')::uuid,id,'qa' from public.cosmetics
 where slug in ('walnut-bookshelf','hearth-fern');
set local role authenticated;
select set_config('request.jwt.claims',json_build_object('sub',current_setting('qa.journey'),'role','authenticated')::text,true);
do $$
declare trophy uuid; shelf uuid; fern uuid; denied boolean; reward record;
begin
 select id into strict trophy from public.cosmetics where slug='first-journey-trophy';
 select id into strict shelf from public.cosmetics where slug='walnut-bookshelf';
 select id into strict fern from public.cosmetics where slug='hearth-fern';
 if exists(select 1 from public.user_cosmetics where user_id=auth.uid() and cosmetic_id=trophy) then raise exception 'Early trophy'; end if;
 denied:=false;
 begin perform public.purchase_cosmetic(trophy);
 exception when others then if sqlerrm<>'cosmetic is not purchasable' then raise; end if; denied:=true; end;
 if not denied then raise exception 'Milestone purchase allowed'; end if;
 denied:=false;
 begin perform public.place_hearth_cosmetic(trophy,'mantel',null);
 exception when others then if sqlerrm<>'room item not owned or unavailable' then raise; end if; denied:=true; end;
 if not denied then raise exception 'Early equip'; end if;
 denied:=false;
 begin update public.users set level=5 where id=auth.uid();
 exception when insufficient_privilege then denied:=true; end;
 if not denied then raise exception 'Client changed level'; end if;
 select * into reward from public.complete_task((select id from public.tasks where title='journey-exact-five'));
 if reward.total_xp<>490 or reward.coin_balance<>81 then raise exception 'Reward changed XP or coins'; end if;
 if not exists(select 1 from public.user_cosmetics where user_id=auth.uid() and cosmetic_id=trophy and not equipped and source='level_milestone') then raise exception 'Level 5 trophy missing or auto-equipped'; end if;
 perform public.place_hearth_cosmetic(trophy,'mantel',null);
 denied:=false;
 begin perform public.place_hearth_cosmetic(trophy,'bookshelf_top',null);
 exception when others then if sqlerrm<>'place the bookcase first' then raise; end if; denied:=true; end;
 if not denied then raise exception 'Unsupported trophy'; end if;
 denied:=false;
 begin perform public.place_hearth_cosmetic(trophy,'right',null);
 exception when others then if sqlerrm<>'choose a trophy surface' then raise; end if; denied:=true; end;
 if not denied then raise exception 'Trophy on floor'; end if;
 denied:=false;
 begin perform public.place_hearth_cosmetic(fern,'mantel',trophy);
 exception when others then if sqlerrm<>'item does not fit this room spot' then raise; end if; denied:=true; end;
 if not denied then raise exception 'Fern on trophy surface'; end if;
 perform public.place_hearth_cosmetic(shelf,'left',null);
 perform public.place_hearth_cosmetic(trophy,'bookshelf_top',null);
 perform public.place_hearth_cosmetic(shelf,'right',null);
 if not exists(select 1 from public.user_cosmetics where user_id=auth.uid() and cosmetic_id=trophy and equipped and room_slot='bookshelf_top') then raise exception 'Moving shelf lost trophy'; end if;
 perform public.unequip_cosmetic(shelf);
 if not exists(select 1 from public.user_cosmetics where user_id=auth.uid() and cosmetic_id=trophy and not equipped and room_slot is null) then raise exception 'Removing shelf left floating trophy'; end if;
 perform public.place_hearth_cosmetic(shelf,'left',null);
 perform public.place_hearth_cosmetic(trophy,'bookshelf_top',null);
 perform public.place_hearth_cosmetic(fern,'left',shelf);
 if exists(select 1 from public.user_cosmetics where user_id=auth.uid() and cosmetic_id=trophy and equipped) then raise exception 'Replacement left floating trophy'; end if;
 perform public.place_hearth_cosmetic(trophy,'mantel',null);
 perform public.place_hearth_cosmetic(shelf,'right',null);
 perform public.unequip_cosmetic(shelf);
 if not exists(select 1 from public.user_cosmetics where user_id=auth.uid() and cosmetic_id=trophy and equipped and room_slot='mantel') then raise exception 'Removing shelf removed mantel trophy'; end if;
 perform public.complete_task((select id from public.tasks where title='journey-later'));
 if (select count(*) from public.user_cosmetics where user_id=auth.uid() and cosmetic_id=trophy)<>1 then raise exception 'Duplicate trophy'; end if;
 if not exists(select 1 from public.user_cosmetics where user_id=auth.uid() and cosmetic_id=trophy and equipped and room_slot='mantel') then raise exception 'Repeated award reset placement'; end if;
 if has_function_privilege('authenticated','private.award_first_journey()','execute') or has_function_privilege('anon','private.award_first_journey()','execute') then raise exception 'Award endpoint exposed'; end if;
end $$;
select set_config('request.jwt.claims',json_build_object('sub',current_setting('qa.journey_boss'),'role','authenticated')::text,true);
do $$
declare boss uuid; step_id uuid;
begin
 boss:=public.create_boss_battle('journey-boss',array['one','two']);
 for step_id in select id from public.boss_steps where boss_id=boss order by position loop
  perform public.complete_boss_step(step_id);
 end loop;
 if not exists(select 1 from public.user_cosmetics uc join public.cosmetics c on c.id=uc.cosmetic_id where uc.user_id=auth.uid() and c.slug='first-journey-trophy' and not uc.equipped) then raise exception 'Boss did not award trophy'; end if;
end $$;
reset role;
-- Administrative deletion of support must also return the trophy to inventory.
update public.user_cosmetics set equipped=true,room_slot='right' where user_id=current_setting('qa.journey')::uuid and cosmetic_id=(select id from public.cosmetics where slug='walnut-bookshelf');
update public.user_cosmetics set room_slot='bookshelf_top' where user_id=current_setting('qa.journey')::uuid and cosmetic_id=(select id from public.cosmetics where slug='first-journey-trophy');
delete from public.user_cosmetics where user_id=current_setting('qa.journey')::uuid and cosmetic_id=(select id from public.cosmetics where slug='walnut-bookshelf');
do $$ begin
 if exists(select 1 from public.user_cosmetics uc join public.cosmetics c on c.id=uc.cosmetic_id where uc.user_id=current_setting('qa.journey')::uuid and c.slug='first-journey-trophy' and uc.equipped) then raise exception 'Deleted support left trophy floating'; end if;
end $$;
rollback;
select 'PASS: level-5 task and boss unlocks, ownership/coin safety, duplicate protection, both supported surfaces, removal/replacement/deletion and client restrictions; fixtures rolled back' as result;
