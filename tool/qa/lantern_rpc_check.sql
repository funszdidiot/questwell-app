-- Synthetic fixtures only. No real account, purchase, or balance changes.
begin;
insert into auth.users(id,email) values
 ('c7416ed6-d535-4ca9-ad46-b601c2a89101','questwell-lantern-a@example.invalid'),
 ('c7416ed6-d535-4ca9-ad46-b601c2a89102','questwell-lantern-b@example.invalid');
insert into public.cosmetics(slug,name,category,price,active) values
 ('qa-lantern-hands','Temporary lantern fixture','hands',60,true),
 ('qa-other-hands','Temporary other hands fixture','hands',60,true);
insert into public.user_cosmetics(user_id,cosmetic_id,source,equipped)
 select 'c7416ed6-d535-4ca9-ad46-b601c2a89101',id,'shop',false
 from public.cosmetics where slug in
 ('qa-lantern-hands','qa-other-hands','leather-satchel','emerald-scholar-scarf');
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"c7416ed6-d535-4ca9-ad46-b601c2a89101","role":"authenticated"}',true);
do $$
declare lantern uuid; other_hand uuid; accessory uuid; denied boolean; kind text;
begin
 select id into strict lantern from public.cosmetics where slug='qa-lantern-hands';
 select id into strict other_hand from public.cosmetics where slug='qa-other-hands';
 for accessory in select id from public.cosmetics where slug in ('leather-satchel','emerald-scholar-scarf') loop
  perform public.equip_cosmetic(accessory);
 end loop;
 perform public.equip_cosmetic(other_hand);
 perform public.equip_cosmetic(lantern);
 if exists(select 1 from public.user_cosmetics where cosmetic_id=other_hand and equipped) then
  raise exception 'Hands slot did not replace previous item';
 end if;
 foreach kind in array array['scholar','scout','alchemist','guardian','wanderer'] loop
  perform public.set_adventurer_archetype(kind);
  if not exists(select 1 from public.user_cosmetics where cosmetic_id=lantern and equipped) then
   raise exception 'Universal lantern lost on class change';
  end if;
 end loop;
 perform public.unequip_cosmetic(lantern);
 if exists(select 1 from public.user_cosmetics where cosmetic_id=lantern and equipped) then
  raise exception 'Lantern did not unequip';
 end if;
 if not exists(select 1 from public.user_cosmetics where cosmetic_id=lantern) then
  raise exception 'Unequip removed ownership';
 end if;
 if (select count(*) from public.user_cosmetics uc join public.cosmetics c on c.id=uc.cosmetic_id
     where c.slug in ('leather-satchel','emerald-scholar-scarf') and uc.equipped) <> 2 then
  raise exception 'Unrelated accessories changed';
 end if;
 perform public.equip_cosmetic(lantern);
 perform set_config('request.jwt.claims','{"sub":"c7416ed6-d535-4ca9-ad46-b601c2a89102","role":"authenticated"}',true);
 if exists(select 1 from public.user_cosmetics where cosmetic_id=lantern) then
  raise exception 'Cross-account ownership visible';
 end if;
 denied := false;
 begin perform public.equip_cosmetic(lantern);
 exception when others then
  if sqlerrm <> 'cosmetic not owned' then raise; end if;
  denied := true;
 end;
 if not denied then raise exception 'Unowned equip allowed'; end if;
 perform set_config('request.jwt.claims','{"sub":"c7416ed6-d535-4ca9-ad46-b601c2a89101","role":"authenticated"}',true);
 if not exists(select 1 from public.user_cosmetics where cosmetic_id=lantern and equipped) then
  raise exception 'Saved equipment missing on identity reload';
 end if;
end $$;
rollback;
select 'PASS: hands replacement, class changes, unequip retains ownership, other accessories preserved, RLS and saved state; all fixtures rolled back' as result;
