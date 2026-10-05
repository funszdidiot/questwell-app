-- Synthetic catalog and historical ownership, ONLY in the guarded CI stack.
-- db query --file accepts one prepared statement; keep the fixture atomic.
do $fixture$
begin
insert into public.cosmetics(id,slug,name,category,rarity,description,price,
  required_archetype,collection_key)
values
  ('10000000-0000-4000-8000-000000000001','woodland-scout-outfit','Woodland Scout Outfit',
   'chest','uncommon','Available for female and neutral Scout avatars.',120,'scout','woodland-scout'),
  ('10000000-0000-4000-8000-000000000002','everyday-adventurer-outfit','Everyday Adventurer Outfit',
   'chest','common','Synthetic Everyday fixture',40,null,null);
insert into auth.users(id,email)
values ('10000000-0000-4000-8000-000000000091','woodland-legacy-ci@example.test');
update public.users set adventurer_archetype='scout',avatar_body_type='neutral',coin_balance=380
where id='10000000-0000-4000-8000-000000000091';
insert into public.user_cosmetics(user_id,cosmetic_id,source,equipped)
values ('10000000-0000-4000-8000-000000000091','10000000-0000-4000-8000-000000000001','shop',true);
end;
$fixture$;
