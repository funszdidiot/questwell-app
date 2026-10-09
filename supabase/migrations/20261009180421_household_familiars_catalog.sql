-- Approved permanent familiars. Staged until the matching client is served.
-- Data only: preserve economy functions, policies, balances and ownership.
begin;

insert into public.cosmetics(slug,name,category,rarity,description,price,premium,asset_key,required_archetype,unlock_method,edition_type,active) values
  ('boston-terrier','Boston Terrier','familiar','rare','A bright-eyed companion with a green bandana, perky ears and a wiggle for every small win.',180,false,'familiar_boston_terrier',null,'shop','standard',false),
  ('hearth-cat','Hearth Cat','familiar','rare','A moon-collared companion with golden eyes, slow blinks and a cozy place beside your adventurer.',180,false,'familiar_hearth_cat',null,'shop','standard',false);
commit;
