begin;
update public.cosmetics set active=true where slug in ('enchanted-library','midnight-harvest');
select set_config('qa.setting_uid',gen_random_uuid()::text,true);
select set_config('qa.setting_other',gen_random_uuid()::text,true);
insert into auth.users(id,email) values
(current_setting('qa.setting_uid')::uuid,current_setting('qa.setting_uid')||'@setting.example.invalid'),
(current_setting('qa.setting_other')::uuid,current_setting('qa.setting_other')||'@setting.example.invalid');
update public.users set coin_balance=500 where id=current_setting('qa.setting_uid')::uuid;
insert into public.user_cosmetics(user_id,cosmetic_id,source,equipped)
select current_setting('qa.setting_uid')::uuid,id,'qa',false from public.cosmetics where slug='walnut-bookshelf';
set local role authenticated;
select set_config('request.jwt.claims',json_build_object('sub',current_setting('qa.setting_uid'),'role','authenticated')::text,true);
do $$
declare a uuid; b uuid; shelf uuid; denied bool; reward record;
begin
 select id into strict a from public.cosmetics where slug='enchanted-library' and price=120;
 select id into strict b from public.cosmetics where slug='midnight-harvest' and price=120;
 select id into strict shelf from public.cosmetics where slug='walnut-bookshelf';
 perform public.purchase_cosmetic(a);
 perform public.purchase_cosmetic(b);
 for i in 1..3 loop
  select * into reward from public.purchase_cosmetic(a);
  if not reward.already_owned or reward.remaining_coins<>260 then raise exception 'Retry debited coins'; end if;
 end loop;
 perform public.place_hearth_cosmetic(shelf,'right',null);
 perform public.place_hearth_cosmetic(a,'setting',null);
 denied:=false;
 begin perform public.place_hearth_cosmetic(b,'setting',null);
 exception when others then
  if sqlerrm<>'room spot changed; refresh and confirm replacement' then raise; end if;
  denied:=true;
 end;
 if not denied then raise exception 'Replacement skipped confirmation'; end if;
 perform public.place_hearth_cosmetic(b,'setting',a);
 if not exists(select 1 from public.user_cosmetics where user_id=auth.uid() and cosmetic_id=b and equipped and room_slot='setting')
 or exists(select 1 from public.user_cosmetics where user_id=auth.uid() and cosmetic_id=a and equipped)
 or not exists(select 1 from public.user_cosmetics where user_id=auth.uid() and cosmetic_id=shelf and equipped and room_slot='right')
 then raise exception 'Setting replacement displaced furniture or failed'; end if;
 denied:=false;
 begin perform public.place_hearth_cosmetic(a,'right',shelf);
 exception when others then
  if sqlerrm<>'choose the Hearth setting slot' then raise; end if;
  denied:=true;
 end;
 if not denied then raise exception 'Setting accepted furniture slot'; end if;
 denied:=false;
 begin perform public.place_hearth_cosmetic(shelf,'setting',b);
 exception when others then
  if sqlerrm<>'item does not fit this room spot' then raise; end if;
  denied:=true;
 end;
 if not denied then raise exception 'Furniture accepted setting slot'; end if;
 perform public.unequip_cosmetic(b);
 if exists(select 1 from public.user_cosmetics where user_id=auth.uid() and equipped and room_slot='setting') then raise exception 'Setting removal failed'; end if;
 perform public.place_hearth_cosmetic(a,'setting',null);
 if (select coin_balance from public.users where id=auth.uid())<>260
 or (select count(*) from public.reward_events where user_id=auth.uid() and event_type='cosmetic_purchase')<>2
 or (select count(*) from public.user_cosmetics where user_id=auth.uid() and cosmetic_id in (a,b))<>2
 then raise exception 'Ownership/balance/event mismatch'; end if;
end $$;
select set_config('request.jwt.claims',json_build_object('sub',current_setting('qa.setting_other'),'role','authenticated')::text,true);
do $$
declare a uuid; denied bool:=false;
begin
 select id into strict a from public.cosmetics where slug='enchanted-library';
 begin perform public.place_hearth_cosmetic(a,'setting',null);
 exception when others then
  if sqlerrm<>'room item not owned or unavailable' then raise; end if;
  denied:=true;
 end;
 if not denied then raise exception 'Cross-account setting equip allowed'; end if;
end $$;
reset role;
rollback;
select 'PASS: two 120-coin purchases, retry safety, setting persistence, confirmed replacement, furniture coexistence, wrong-slot rejection, removal, ownership isolation; fixtures rolled back' as result;
