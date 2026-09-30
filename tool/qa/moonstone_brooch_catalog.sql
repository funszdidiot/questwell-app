-- Approved universal cosmetic. Idempotent; no purchases or ownership changes.
insert into public.cosmetics
 (slug,name,category,rarity,description,price,premium,asset_key,active,required_archetype,unlock_method)
values ('moonstone-brooch','Moonstone Brooch','accessory','uncommon',
 'A little moonlight for the road ahead. Icy blue stone framed in antique gold.',
 60,false,'accessory_moonstone_brooch',true,null,'shop')
on conflict (slug) do nothing;
