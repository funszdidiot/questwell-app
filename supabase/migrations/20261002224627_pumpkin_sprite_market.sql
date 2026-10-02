-- Stage until the development preview and catalog checks pass.
insert into public.cosmetics(slug,name,category,rarity,description,price,premium,asset_key,active,required_archetype,unlock_method)
values ('pumpkin-sprite','Pumpkin Sprite','familiar','rare',
'A bright-eyed little harvest spirit with curling vines and a warm amber glow. Your next small win has company.',
180,false,'familiar_pumpkin_sprite',false,null,'shop') on conflict(slug) do nothing;
