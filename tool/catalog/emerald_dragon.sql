-- Repeatable catalog seed. User-specific inventory grants are separate.
insert into public.cosmetics
  (slug,name,category,rarity,description,price,premium,asset_key,active,required_archetype,unlock_method)
values
  ('emerald-dragon','Emerald Dragon','familiar','epic',
   'A small emerald companion with golden horns and a talent for guarding your next small win.',
   320,false,'familiar_emerald_dragon',true,null,'shop')
on conflict (slug) do update set
  name=excluded.name,category=excluded.category,rarity=excluded.rarity,
  description=excluded.description,price=excluded.price,premium=excluded.premium,
  asset_key=excluded.asset_key,active=excluded.active,
  required_archetype=excluded.required_archetype,unlock_method=excluded.unlock_method;
