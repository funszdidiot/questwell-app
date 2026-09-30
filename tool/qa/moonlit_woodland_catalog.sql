-- Wall art swaps independently of wearables and the four floor spots.
alter table public.cosmetics drop constraint cosmetics_category_check;
alter table public.cosmetics add constraint cosmetics_category_check check
(category in ('head','face','neck','chest','hands','legs','feet','back','familiar','room','effect','outfit','accessory','wall_art'));
insert into public.cosmetics(slug,name,category,rarity,description,price,premium,asset_key,active,required_archetype,unlock_method)
values ('moonlit-woodland','Moonlit Woodland','wall_art','uncommon',
 'A moonlit forest and a warmly lit cottage, framed in walnut and gold. Hang one wall piece at a time without moving your furniture.',
 120,false,'wall_art_moonlit_woodland',false,null,'shop')
on conflict(slug) do nothing;
