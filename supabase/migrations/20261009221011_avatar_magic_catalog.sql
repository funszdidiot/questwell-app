-- Approved permanent avatar effects. Staged until matching client is served.
-- Data only; preserve account balances, ownership and all existing functions.
begin;

insert into public.cosmetics(slug,name,category,rarity,description,price,premium,asset_key,required_archetype,unlock_method,edition_type,active) values
  ('starlight-aura','Starlight Aura','effect','rare','Gold and lavender stars drift quietly beside your adventurer.',150,false,'effect_starlight_aura',null,'shop','standard',false),
  ('enchanted-leaves','Enchanted Leaves','effect','rare','A gentle emerald orbit brings a little woodland magic to your steps.',150,false,'effect_enchanted_leaves',null,'shop','standard',false);
commit;
