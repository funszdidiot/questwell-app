-- Synthetic fixtures only; every write rolls back.
begin;
insert into auth.users(id,email) values
 ('26c39f61-b3f7-4a59-8f72-64257bb252a1','questwell-cloak-check@example.invalid');
update public.users set adventurer_archetype='guardian' where id='26c39f61-b3f7-4a59-8f72-64257bb252a1';
insert into public.user_cosmetics(user_id,cosmetic_id,source,equipped)
 select '26c39f61-b3f7-4a59-8f72-64257bb252a1',id,'shop',false from public.cosmetics
 where slug in ('moss-green-cloak','hearthguard-mantle','brass-lantern','round-scholar-glasses');
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"26c39f61-b3f7-4a59-8f72-64257bb252a1","role":"authenticated"}',true);
do $$
declare cloak uuid; lantern uuid; glasses uuid; denied boolean; before_coins integer; before_owned integer;
begin
 select coin_balance into before_coins from public.users where id=auth.uid();
 select count(*) into before_owned from public.user_cosmetics where user_id=auth.uid();
 select id into strict lantern from public.cosmetics where slug='brass-lantern';
 select id into strict glasses from public.cosmetics where slug='round-scholar-glasses';
 perform public.equip_cosmetic_loadout(glasses,null);
 for cloak in select id from public.cosmetics where slug in ('moss-green-cloak','hearthguard-mantle') loop
   perform public.equip_cosmetic(lantern);
   denied:=false;
   begin perform public.equip_cosmetic_loadout(cloak,null);
   exception when others then
    if sqlerrm not like 'equipment changed%' then raise; end if; denied:=true;
   end;
   if not denied then raise exception 'Unconfirmed swap succeeded';end if;
   perform public.equip_cosmetic_loadout(cloak,lantern);
   if not exists(select 1 from public.user_cosmetics where cosmetic_id=cloak and equipped)
     or exists(select 1 from public.user_cosmetics where cosmetic_id=lantern and equipped) then
      raise exception 'Cloak did not replace held item';end if;
   denied:=false;
   begin perform public.equip_cosmetic_loadout(lantern,glasses);
   exception when others then
    if sqlerrm not like 'equipment changed%' then raise; end if; denied:=true;
   end;
   if not denied then raise exception 'Stale confirmation succeeded';end if;
   perform public.equip_cosmetic_loadout(lantern,cloak);
   if exists(select 1 from public.user_cosmetics where cosmetic_id=cloak and equipped)
     or not exists(select 1 from public.user_cosmetics where cosmetic_id=lantern and equipped) then
      raise exception 'Held item did not replace cloak';end if;
   perform public.equip_cosmetic(cloak);
   if exists(select 1 from public.user_cosmetics where cosmetic_id=lantern and equipped) then
     raise exception 'Legacy RPC allowed incompatible loadout';end if;
   perform public.unequip_cosmetic(cloak);
 end loop;
 if not exists(select 1 from public.user_cosmetics where cosmetic_id=glasses and equipped) then
   raise exception 'Unrelated equipment changed';end if;
 if (select coin_balance from public.users where id=auth.uid())<>before_coins or
    (select count(*) from public.user_cosmetics where user_id=auth.uid())<>before_owned then
   raise exception 'Coins or ownership changed';end if;
end $$;
rollback;
select 'PASS: both cloak swaps, reverse swap, stale confirmation, legacy enforcement, unrelated equipment, balance/ownership; fixtures rolled back' as result;
