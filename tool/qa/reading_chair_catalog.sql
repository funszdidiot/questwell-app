-- Approved room decoration; no account grant or coin change.
insert into public.cosmetics(slug,name,category,rarity,description,price,premium,asset_key,active,required_archetype,unlock_method)
values ('burgundy-reading-chair','Burgundy Reading Chair','room','uncommon',
 'Burgundy upholstery, walnut legs, and brass studs. Settle in with a good book.',
 120,false,'room_burgundy_reading_chair',true,null,'shop')
on conflict(slug) do nothing;
