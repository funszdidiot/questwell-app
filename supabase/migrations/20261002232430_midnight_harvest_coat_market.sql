-- Stage until the development build and outfit fit review pass.
insert into public.cosmetics(slug,name,category,rarity,description,price,premium,asset_key,active,required_archetype,unlock_method)
values ('midnight-harvest-coat','Midnight Harvest Coat','chest','rare',
'Burgundy wool, moss-green lapels and copper oak-leaf clasps. An autumn layer for every adventurer.',
180,false,'chest_midnight_harvest_coat',false,null,'shop') on conflict(slug) do nothing;
