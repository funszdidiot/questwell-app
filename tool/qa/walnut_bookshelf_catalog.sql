-- Approved Hearth decoration. No user ownership or balance changes.
insert into public.cosmetics
 (slug,name,category,rarity,description,price,premium,asset_key,active,required_archetype,unlock_method)
values ('walnut-bookshelf','Walnut Bookshelf','room','uncommon',
 'Warm walnut, worn jewel-toned books, and brass details. A quiet corner for your Hearth.',
 120,false,'room_walnut_bookshelf',true,null,'shop')
on conflict (slug) do nothing;
