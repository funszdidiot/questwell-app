insert into public.cosmetics(slug,name,category,rarity,description,price,premium,asset_key,active,required_archetype,unlock_method)
values ('copper-potion-workbench','Copper Potion Workbench','room','uncommon',
'A walnut apothecary cabinet with a copper distiller, jewel-toned potions and herb drawers. Place on either side of your Hearth.',
120,false,'room_copper_potion_workbench',false,null,'shop') on conflict(slug) do nothing;
