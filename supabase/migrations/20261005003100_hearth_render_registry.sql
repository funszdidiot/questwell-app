-- Generic Hearth render registry.
-- Ordinary decor should be registerable as data + approved art without adding
-- slug-specific Flutter branches. Special systems can remain explicit.
create table public.hearth_render_registry (
  cosmetic_id uuid primary key
    references public.cosmetics(id) on delete cascade,
  render_kind text not null check (render_kind in (
    'static_sprite',
    'floor_sprite'
  )),
  asset_source text not null default 'bundle'
    check (asset_source in ('bundle','network')),
  asset_path text not null,
  canvas_width integer not null check (canvas_width > 0),
  canvas_height integer not null check (canvas_height > 0),
  visible_base numeric(6,5) not null default 1
    check (visible_base > 0 and visible_base <= 1),
  shadow_profile text null check (shadow_profile in (
    'wide_plinth',
    'pedestal',
    'seating',
    'side_table',
    'plant',
    'none'
  )),
  effect_profile text null check (effect_profile in (
    'ward_glow',
    'warm_glow'
  )),
  filter_mode text not null default 'pixel'
    check (filter_mode in ('pixel','smooth')),
  asset_revision integer not null default 1 check (asset_revision > 0),
  min_client_build integer null check (min_client_build is null or min_client_build > 0)
);

alter table public.hearth_render_registry enable row level security;

create policy "Authenticated users can view Hearth render registry"
  on public.hearth_render_registry
  for select to authenticated
  using (true);

grant select on public.hearth_render_registry to authenticated;

insert into public.hearth_render_registry(
  cosmetic_id,render_kind,asset_path,canvas_width,canvas_height,visible_base,
  shadow_profile,effect_profile,filter_mode,asset_revision
)
select id,'static_sprite',
  case slug
    when 'walnut-bookshelf' then 'assets/images/questwell/hearth/walnut_bookshelf_front_v1.webp'
    when 'copper-potion-workbench' then 'assets/images/questwell/hearth/copper_potion_workbench_v1.webp'
    when 'harvest-apothecary-display' then 'assets/images/questwell/hearth/harvest_apothecary_display_v1.webp'
    when 'warding-lantern' then 'assets/images/questwell/hearth/warding_lantern_v3_64bit.webp'
    when 'burgundy-reading-chair' then 'assets/images/questwell/hearth/burgundy_reading_chair.webp'
    when 'hearth-fern' then 'assets/images/questwell/hearth/hearth_fern.webp'
    when 'walnut-reading-table' then 'assets/images/questwell/hearth/walnut_reading_table.webp'
  end,
  case slug
    when 'walnut-bookshelf' then 1225
    when 'copper-potion-workbench' then 1341
    when 'harvest-apothecary-display' then 1312
    when 'warding-lantern' then 960
    when 'burgundy-reading-chair' then 1312
    when 'hearth-fern' then 1244
    when 'walnut-reading-table' then 1213
  end,
  case slug
    when 'walnut-bookshelf' then 1284
    when 'copper-potion-workbench' then 1173
    when 'harvest-apothecary-display' then 1199
    when 'warding-lantern' then 1680
    when 'burgundy-reading-chair' then 1199
    when 'hearth-fern' then 1264
    when 'walnut-reading-table' then 1296
  end,
  case slug
    when 'walnut-bookshelf' then 1200::numeric/1284
    when 'copper-potion-workbench' then 1119::numeric/1173
    when 'harvest-apothecary-display' then 1095::numeric/1199
    when 'warding-lantern' then .965
    else 1
  end,
  case slug
    when 'walnut-bookshelf' then 'wide_plinth'
    when 'copper-potion-workbench' then 'wide_plinth'
    when 'harvest-apothecary-display' then 'wide_plinth'
    when 'warding-lantern' then 'pedestal'
    when 'burgundy-reading-chair' then 'seating'
    when 'hearth-fern' then 'plant'
    when 'walnut-reading-table' then 'side_table'
  end,
  case when slug='warding-lantern' then 'ward_glow' else null end,
  'pixel',
  1
from public.cosmetics
where slug in (
  'walnut-bookshelf',
  'copper-potion-workbench',
  'harvest-apothecary-display',
  'warding-lantern',
  'burgundy-reading-chair',
  'hearth-fern',
  'walnut-reading-table'
);

insert into public.hearth_render_registry(
  cosmetic_id,render_kind,asset_path,canvas_width,canvas_height,visible_base,
  shadow_profile,effect_profile,filter_mode,asset_revision
)
select id,'floor_sprite',
  'assets/images/questwell/hearth/emerald_wayfarer_rug_v3_64bit.webp',
  384,256,1,'none',null,'pixel',1
from public.cosmetics
where slug='emerald-wayfarer-rug';

do $$
begin
  if (select count(*) from public.hearth_render_registry) <> 8 then
    raise exception 'Expected 8 initial generic Hearth render registrations';
  end if;
end $$;
