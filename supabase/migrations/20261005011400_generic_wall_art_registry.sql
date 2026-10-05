-- Generic wall-art registration.
-- Existing clients safely ignore these rows until the generic wall-art renderer ships.

alter table public.hearth_render_registry
  drop constraint hearth_render_registry_render_kind_check;

alter table public.hearth_render_registry
  add constraint hearth_render_registry_render_kind_check
  check (render_kind in ('static_sprite','floor_sprite','wall_art_sprite'));

insert into public.hearth_render_registry(
  cosmetic_id,render_kind,asset_source,asset_path,canvas_width,canvas_height,
  visible_base,shadow_profile,effect_profile,filter_mode,asset_revision
)
select id,'wall_art_sprite','bundle',
  case slug
    when 'moonlit-woodland' then 'assets/images/questwell/hearth/moonlit_woodland.webp'
    when 'fern-study' then 'assets/images/questwell/hearth/fern_study.webp'
    when 'celestial-study' then 'assets/images/questwell/hearth/celestial_study.webp'
  end,
  case slug
    when 'moonlit-woodland' then 1400
    when 'fern-study' then 957
    when 'celestial-study' then 954
  end,
  case slug
    when 'moonlit-woodland' then 1000
    when 'fern-study' then 1644
    when 'celestial-study' then 1648
  end,
  1,'none',null,'smooth',1
from public.cosmetics
where slug in ('moonlit-woodland','fern-study','celestial-study')
on conflict (cosmetic_id) do update set
  render_kind=excluded.render_kind,
  asset_source=excluded.asset_source,
  asset_path=excluded.asset_path,
  canvas_width=excluded.canvas_width,
  canvas_height=excluded.canvas_height,
  visible_base=excluded.visible_base,
  shadow_profile=excluded.shadow_profile,
  effect_profile=excluded.effect_profile,
  filter_mode=excluded.filter_mode,
  asset_revision=excluded.asset_revision;

do $$
begin
  if (
    select count(*)
    from public.hearth_render_registry r
    join public.cosmetics c on c.id=r.cosmetic_id
    where c.slug in ('moonlit-woodland','fern-study','celestial-study')
      and r.render_kind='wall_art_sprite'
  ) <> 3 then
    raise exception 'Expected three generic wall-art registrations';
  end if;
end $$;
