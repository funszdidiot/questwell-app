-- Temporary synthetic fixtures only. No real account is impersonated or changed.
-- All fixture writes roll back; assertions exercise the authenticated role.
begin;
insert into auth.users (id,email) values
 ('16c39f61-b3f7-4a59-8f72-64257bb252a1','questwell-equipment-a@example.invalid'),
 ('16c39f61-b3f7-4a59-8f72-64257bb252a2','questwell-equipment-b@example.invalid');
insert into public.user_cosmetics(user_id,cosmetic_id,source,equipped)
 select '16c39f61-b3f7-4a59-8f72-64257bb252a1',id,'shop',false from public.cosmetics
 where slug='round-scholar-glasses' or required_archetype='scholar';
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"16c39f61-b3f7-4a59-8f72-64257bb252a1","role":"authenticated"}',true);
do $$
declare glasses uuid; restricted uuid; denied boolean := false;
begin
 select id into strict glasses from public.cosmetics where slug='round-scholar-glasses';
 select id into restricted from public.cosmetics where required_archetype='scholar' limit 1;
 if restricted is null then raise exception 'Missing restriction fixture'; end if;
 begin perform public.equip_cosmetic(restricted);
 exception when others then
  if sqlerrm not like 'cosmetic restricted%' then raise; end if;
  denied := true;
 end;
 if not denied then raise exception 'Class restriction failed'; end if;
 perform public.equip_cosmetic(glasses);
 if not exists(select 1 from public.user_cosmetics where cosmetic_id=glasses and equipped) then
  raise exception 'Equip did not persist'; end if;
 perform public.set_adventurer_archetype('alchemist');
 if not exists(select 1 from public.user_cosmetics where cosmetic_id=glasses and equipped) then
  raise exception 'Universal glasses lost on class change'; end if;
 perform set_config('request.jwt.claims','{"sub":"16c39f61-b3f7-4a59-8f72-64257bb252a2","role":"authenticated"}',true);
 if exists(select 1 from public.user_cosmetics where cosmetic_id=glasses) then
  raise exception 'Cross-account read visible'; end if;
 denied := false;
 begin perform public.equip_cosmetic(glasses);
 exception when others then
  if sqlerrm <> 'cosmetic not owned' then raise; end if;
  denied := true;
 end;
 if not denied then raise exception 'Ownership restriction failed'; end if;
 denied := false;
 begin perform public.unequip_cosmetic(glasses);
 exception when others then
  if sqlerrm <> 'Cosmetic is not currently equipped' then raise; end if;
  denied := true;
 end;
 if not denied then raise exception 'Cross-account unequip allowed'; end if;
 perform set_config('request.jwt.claims','{"sub":"16c39f61-b3f7-4a59-8f72-64257bb252a1","role":"authenticated"}',true);
 if not exists(select 1 from public.user_cosmetics where cosmetic_id=glasses and equipped) then
  raise exception 'Equipment missing after identity reload'; end if;
 perform public.unequip_cosmetic(glasses);
 if exists(select 1 from public.user_cosmetics where cosmetic_id=glasses and equipped) then
  raise exception 'Unequip did not persist'; end if;
end $$;
rollback;
select 'PASS: equip, unequip, ownership, class restriction, class change, RLS isolation, identity reload; all fixtures rolled back' as result;
