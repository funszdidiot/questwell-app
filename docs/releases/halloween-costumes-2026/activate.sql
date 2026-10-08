-- Tanya authorized both costumes under the existing Halloween collection rules.
-- Catalog-only forward change. No schema, existing catalog, or ownership edits.
begin;
do $guard$
begin
  if statement_timestamp() >= timestamptz '2026-11-09T06:00:00Z' then
    raise exception 'Halloween purchase window has already closed';
  end if;
  if not exists(select 1 from public.cosmetics where slug='hallowed-hearth'
      and active and collection_key='midnight-harvest' and edition_type='seasonal'
      and availability_end=timestamptz '2026-11-09T06:00:00Z') then
    raise exception 'Halloween collection rules have drifted';
  end if;
end;
$guard$;
create temporary table halloween_costumes_expected on commit drop as
select * from (values
 ('midnight-masquerade','Midnight Masquerade','Plum velvet robe, smoky-plum blouse, copper-trimmed bat mask, trousers and boots. One complete Halloween outfit.'),
 ('pumpkin-court','Pumpkin Court','Burnt-orange robe, cream blouse with green trim, copper-and-green leaf mask, trousers and boots. One complete Halloween outfit.')
) as x(slug,name,description);
insert into public.cosmetics(slug,name,description,category,rarity,price,premium,
 active,required_archetype,unlock_method,collection_key,edition_type,
 availability_start,availability_end)
select e.slug,e.name,e.description,'chest','rare',180,false,true,null,'shop',
 'midnight-harvest','seasonal',h.availability_start,h.availability_end
from halloween_costumes_expected e cross join public.cosmetics h
where h.slug='hallowed-hearth'
on conflict (slug) do nothing;
do $guard$
begin
  if (select count(*) from public.cosmetics where slug in
      ('midnight-masquerade','pumpkin-court'))<>2 or exists(
    select 1 from halloween_costumes_expected e join public.cosmetics c using(slug)
    cross join public.cosmetics h
    where h.slug='hallowed-hearth' and
      (c.name,c.description,c.category,c.rarity,c.price,c.premium,c.active,
       c.required_archetype,c.unlock_method,c.collection_key,c.edition_type,
       c.availability_start,c.availability_end,c.hearth_profile_key)
      is distinct from
      (e.name,e.description,'chest','rare',180,false,true,null::text,'shop',
       'midnight-harvest','seasonal',h.availability_start,h.availability_end,null::text)
  ) then raise exception 'Halloween costume metadata mismatch'; end if;
end;
$guard$;
commit;
