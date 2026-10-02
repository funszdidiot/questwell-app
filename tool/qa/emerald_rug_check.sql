begin;
-- Synthetic accounts and all catalog/test writes are rolled back.
update public.cosmetics set active=true where slug='emerald-wayfarer-rug';
select set_config('qa.rug_uid',gen_random_uuid()::text,true);
select set_config('qa.rug_other',gen_random_uuid()::text,true);
insert into auth.users(id,email) values
 (current_setting('qa.rug_uid')::uuid,current_setting('qa.rug_uid')||'@rug.example.invalid'),
 (current_setting('qa.rug_other')::uuid,current_setting('qa.rug_other')||'@rug.example.invalid');
update public.users set coin_balance=100 where id=current_setting('qa.rug_uid')::uuid;
insert into public.user_cosmetics(user_id,cosmetic_id,source,equipped)
select current_setting('qa.rug_uid')::uuid,id,'qa',false from public.cosmetics
where slug in ('walnut-bookshelf','burgundy-reading-chair','walnut-reading-table');
set local role authenticated;
select set_config('request.jwt.claims',json_build_object(
 'sub',current_setting('qa.rug_uid'),'role','authenticated')::text,true);
do $$
declare uid uuid:=current_setting('qa.rug_uid')::uuid;
 rug uuid; shelf uuid; chair uuid; tbl uuid; denied bool; result record; slot text;
 old_xp int; old_level int;
begin
 select id into strict rug from public.cosmetics where slug='emerald-wayfarer-rug' and price=20 and unlock_method='shop';
 select id into strict shelf from public.cosmetics where slug='walnut-bookshelf';
 select id into strict chair from public.cosmetics where slug='burgundy-reading-chair';
 select id into strict tbl from public.cosmetics where slug='walnut-reading-table';
 select total_xp,level into old_xp,old_level from public.users where id=uid;
 -- Aborted server transaction must leave no partial debit or inventory.
 begin
   perform public.purchase_cosmetic(rug);
   raise exception using errcode='QW001',message='Simulated abort';
 exception when sqlstate 'QW001' then null;
 end;
 if (select coin_balance from public.users where id=uid)<>100
   or exists(select 1 from public.user_cosmetics where user_id=uid and cosmetic_id=rug)
 then raise exception 'Aborted purchase left partial state'; end if;
 -- Discard successful response, then retry the same purchase.
 perform public.purchase_cosmetic(rug);
 for i in 1..5 loop
   select * into result from public.purchase_cosmetic(rug);
   if not result.already_owned or result.remaining_coins<>80 then raise exception 'Retry charged twice'; end if;
 end loop;
 if (select count(*) from public.reward_events where user_id=uid and event_type='cosmetic_purchase')<>1
   or (select total_xp<>old_xp or level<>old_level from public.users where id=uid)
 then raise exception 'Purchase changed rewards incorrectly'; end if;
 perform public.place_hearth_cosmetic(shelf,'right',null);
 perform public.place_hearth_cosmetic(chair,'front',null);
 perform public.place_hearth_cosmetic(tbl,'side',null);
 perform public.place_hearth_cosmetic(rug,'floor',null);
 perform public.place_hearth_cosmetic(rug,'floor',null);
 if (select count(*) from public.user_cosmetics where user_id=uid and equipped and cosmetic_id in (rug,shelf,chair,tbl))<>4
   or not exists(select 1 from public.user_cosmetics where user_id=uid and cosmetic_id=rug and equipped and room_slot='floor')
 then raise exception 'Floor placement displaced furniture or failed to persist'; end if;
 foreach slot in array array['left','right','front','side','mantel','bookshelf_top','window','wall_left'] loop
   denied:=false;
   begin perform public.place_hearth_cosmetic(rug,slot,null);
   exception when others then
     if sqlerrm<>'choose the floor beneath the adventurer' then raise; end if;
     denied:=true;
   end;
   if not denied then raise exception 'Rug accepted wrong slot %',slot; end if;
 end loop;
 denied:=false;
 begin perform public.place_hearth_cosmetic(chair,'floor',rug);
 exception when others then
   if sqlerrm<>'item does not fit this room spot' then raise; end if;
   denied:=true;
 end;
 if not denied then raise exception 'Furniture accepted rug slot'; end if;
 perform public.unequip_cosmetic(rug);
 if not exists(select 1 from public.user_cosmetics where user_id=uid and cosmetic_id=rug and not equipped)
   or (select count(*) from public.user_cosmetics where user_id=uid and equipped and cosmetic_id in (rug,shelf,chair,tbl))<>3
   or (select coin_balance from public.users where id=uid)<>80
 then raise exception 'Removal changed ownership, furniture or coins'; end if;
 perform public.place_hearth_cosmetic(rug,'floor',null);
end $$;
-- A second caller cannot place a rug owned only by the first caller.
select set_config('request.jwt.claims',json_build_object(
 'sub',current_setting('qa.rug_other'),'role','authenticated')::text,true);
do $$
declare rug uuid; denied bool:=false;
begin
 select id into strict rug from public.cosmetics where slug='emerald-wayfarer-rug';
 begin perform public.place_hearth_cosmetic(rug,'floor',null);
 exception when others then
   if sqlerrm<>'room item not owned or unavailable' then raise; end if;
   denied:=true;
 end;
 if not denied then raise exception 'Cross-account placement allowed'; end if;
end $$;
reset role;
rollback;
select 'PASS: rug purchase abort/retry, one 20-coin debit, persisted floor slot, furniture coexistence, slot restrictions, removal, ownership isolation; rolled back' as verification;
