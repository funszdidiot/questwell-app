insert into public.cosmetics(slug,name,category,rarity,description,price,premium,asset_key,active,required_archetype,unlock_method)
values ('autumn-ember-lantern','Autumn Ember Lantern','room','rare',
'A copper lantern with flickering amber light and swirling autumn leaves. A warm welcome for either side of your Hearth.',
240,false,'room_autumn_ember_lantern',false,null,'shop') on conflict(slug) do nothing;
