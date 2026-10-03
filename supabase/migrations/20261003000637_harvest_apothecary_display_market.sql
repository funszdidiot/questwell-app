insert into public.cosmetics(slug,name,category,rarity,description,price,premium,asset_key,active,required_archetype,unlock_method)
values ('harvest-apothecary-display','Harvest Apothecary Display','room','uncommon',
'Autumn pumpkins, jewel-toned potions and a burgundy recipe book on a walnut stand. A little harvest warmth for either side of your Hearth.',
140,false,'room_harvest_apothecary_display',false,null,'shop') on conflict(slug) do nothing;
