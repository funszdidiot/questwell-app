begin;
-- Five synthetic profiles; everything, including purchases, rolls back.
select set_config('qa.market_prefix',gen_random_uuid()::text,true);
insert into auth.users(id,email)
select gen_random_uuid(),current_setting('qa.market_prefix')||'-'||c||'@example.invalid'
from unnest(array['scholar','scout','alchemist','guardian','wanderer']) c;
update public.users u set coin_balance=10000,adventurer_archetype=split_part(split_part(a.email,'@',1),'-',6)
from auth.users a where a.id=u.id and a.email like current_setting('qa.market_prefix')||'-%';
select set_config('qa.market_ids',(select json_agg(u.id)::text from public.users u join auth.users a on a.id=u.id where a.email like current_setting('qa.market_prefix')||'-%'),true);
set local role authenticated;
do $$
declare uid uuid; item record; klass text; before_coins int; after_coins int; old_xp int; old_level int;
 was_owned bool; slot text; occupant uuid; denied bool; checked int:=0;
begin
 for uid in select json_array_elements_text(current_setting('qa.market_ids')::json)::uuid loop
  perform set_config('request.jwt.claims',json_build_object('sub',uid,'role','authenticated')::text,true);
  select adventurer_archetype,total_xp,level into klass,old_xp,old_level from public.users where id=uid;
  for item in select * from public.cosmetics where active and unlock_method='shop' order by price,slug loop
   if item.required_archetype is not null and item.required_archetype<>klass then
    denied:=false;
    begin perform public.purchase_cosmetic(item.id);exception when others then
      if sqlerrm not like 'cosmetic restricted%' then raise; end if; denied:=true;end;
    if not denied then raise exception 'Wrong class bought %',item.slug;end if;
    continue;
   end if;
   select coin_balance into before_coins from public.users where id=uid;
   select exists(select 1 from public.user_cosmetics where user_id=uid and cosmetic_id=item.id) into was_owned;
   perform public.purchase_cosmetic(item.id);
   select coin_balance into after_coins from public.users where id=uid;
   if after_coins<>before_coins-(case when was_owned then 0 else item.price end) then raise exception 'Wrong charge %',item.slug;end if;
   perform public.purchase_cosmetic(item.id);
   if (select coin_balance from public.users where id=uid)<>after_coins then raise exception 'Repeat charge %',item.slug;end if;
   if item.category in ('room','wall_art') then
    slot:=case when item.slug='rainy-window' then 'window' when item.slug='walnut-reading-table' then 'side'
      when item.slug='moonlit-woodland' then 'wall_center' when item.category='wall_art' then 'wall_left' else 'right' end;
    select cosmetic_id into occupant from public.user_cosmetics where user_id=uid and equipped and room_slot=slot;
    perform public.place_hearth_cosmetic(item.id,slot,occupant);
    if not exists(select 1 from public.user_cosmetics where user_id=uid and cosmetic_id=item.id and equipped and room_slot=slot) then raise exception 'Placement not saved %',item.slug;end if;
   else
    perform public.equip_cosmetic(item.id);
    if (select count(*) from public.user_cosmetics uc join public.cosmetics c on c.id=uc.cosmetic_id where uc.user_id=uid and uc.equipped and c.category=item.category)<>1 then raise exception 'Equipment slot conflict %',item.slug;end if;
   end if;
   if not exists(select 1 from public.user_cosmetics where user_id=uid and cosmetic_id=item.id and equipped) then raise exception 'Equipment not saved %',item.slug;end if;
   perform public.unequip_cosmetic(item.id);
   if not exists(select 1 from public.user_cosmetics where user_id=uid and cosmetic_id=item.id and not equipped) then raise exception 'Unequip lost item %',item.slug;end if;
   checked:=checked+1;
  end loop;
  denied:=false;
  begin perform public.place_hearth_cosmetic((select id from public.cosmetics where slug='rainy-window'),'right',null);
   exception when others then if sqlerrm<>'choose the window alcove' then raise;end if;denied:=true;end;
  if not denied then raise exception 'Window on floor';end if;
  if (select total_xp<>old_xp or level<>old_level from public.users where id=uid) then raise exception 'Purchase changed progression';end if;
 end loop;
 if checked<>105 then raise exception 'Expected 105 class-eligible purchase/equip cases, got %',checked;end if;
end $$;
select '105 purchase/equip/unequip cases, repeat purchases, class restrictions and window placement passed' as verification;
rollback;
