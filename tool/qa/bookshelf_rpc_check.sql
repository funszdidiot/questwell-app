-- Synthetic fixtures only. No real account, purchase, or balance changes.
begin;
insert into auth.users(id,email) values
 ('e9625ff1-d535-4ca9-ad46-b601c2a89101','questwell-bookshelf-a@example.invalid'),
 ('e9625ff1-d535-4ca9-ad46-b601c2a89102','questwell-bookshelf-b@example.invalid');
insert into public.cosmetics(slug,name,category,price,active) values
 ('qa-bookshelf-accessory','Temporary bookshelf fixture','room',60,true),
 ('qa-other-accessory','Temporary other accessory fixture','room',60,true);
insert into public.user_cosmetics(user_id,cosmetic_id,source,equipped)
 select 'e9625ff1-d535-4ca9-ad46-b601c2a89101',id,'shop',false
 from public.cosmetics where slug in
 ('qa-bookshelf-accessory','qa-other-accessory','leather-satchel','emerald-scholar-scarf','brass-lantern','moonstone-brooch');
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"e9625ff1-d535-4ca9-ad46-b601c2a89101","role":"authenticated"}',true);
do $$
declare bookshelf uuid; other_hand uuid; accessory uuid; denied boolean; kind text;
begin
 select id into strict bookshelf from public.cosmetics where slug='qa-bookshelf-accessory';
 select id into strict other_hand from public.cosmetics where slug='qa-other-accessory';
 for accessory in select id from public.cosmetics where slug in ('leather-satchel','emerald-scholar-scarf','brass-lantern','moonstone-brooch') loop
  perform public.equip_cosmetic(accessory);
 end loop;
 perform public.equip_cosmetic(other_hand);
 perform public.equip_cosmetic(bookshelf);
 if exists(select 1 from public.user_cosmetics where cosmetic_id=other_hand and equipped) then
  raise exception 'Accessory slot did not replace previous item';
 end if;
 foreach kind in array array['scholar','scout','alchemist','guardian','wanderer'] loop
  perform public.set_adventurer_archetype(kind);
  if not exists(select 1 from public.user_cosmetics where cosmetic_id=bookshelf and equipped) then
   raise exception 'Universal bookshelf lost on class change';
  end if;
 end loop;
 perform public.unequip_cosmetic(bookshelf);
 if exists(select 1 from public.user_cosmetics where cosmetic_id=bookshelf and equipped) then
  raise exception 'Lantern did not unequip';
 end if;
 if not exists(select 1 from public.user_cosmetics where cosmetic_id=bookshelf) then
  raise exception 'Unequip removed ownership';
 end if;
 if (select count(*) from public.user_cosmetics uc join public.cosmetics c on c.id=uc.cosmetic_id
     where c.slug in ('leather-satchel','emerald-scholar-scarf','brass-lantern','moonstone-brooch') and uc.equipped) <> 4 then
  raise exception 'Unrelated accessories changed';
 end if;
 perform public.equip_cosmetic(bookshelf);
 perform set_config('request.jwt.claims','{"sub":"e9625ff1-d535-4ca9-ad46-b601c2a89102","role":"authenticated"}',true);
 if exists(select 1 from public.user_cosmetics where cosmetic_id=bookshelf) then
  raise exception 'Cross-account ownership visible';
 end if;
 denied := false;
 begin perform public.equip_cosmetic(bookshelf);
 exception when others then
  if sqlerrm <> 'cosmetic not owned' then raise; end if;
  denied := true;
 end;
 if not denied then raise exception 'Unowned equip allowed'; end if;
 perform set_config('request.jwt.claims','{"sub":"e9625ff1-d535-4ca9-ad46-b601c2a89101","role":"authenticated"}',true);
 if not exists(select 1 from public.user_cosmetics where cosmetic_id=bookshelf and equipped) then
  raise exception 'Saved equipment missing on identity reload';
 end if;
end $$;
rollback;
select 'PASS: accessory replacement, class changes, unequip retains ownership, other accessories preserved, RLS and saved state; all fixtures rolled back' as result;

