-- Hearth scalability contract.
-- Slots and item-fit rules become data instead of slug-specific backend code.
-- Existing ownership, equipped state, pricing and room placements are preserved.

create table public.hearth_slots (
  slot_key text primary key,
  zone text not null check (zone in (
    'rear','foreground','side','wall','surface','window','floor','setting'
  )),
  default_label text not null,
  sort_order smallint not null default 0
);

create table public.hearth_layout_profiles (
  profile_key text primary key,
  family_key text not null,
  display_name text not null,
  layout_version smallint not null default 1 check (layout_version > 0)
);

create table public.hearth_profile_slots (
  profile_key text not null
    references public.hearth_layout_profiles(profile_key) on delete cascade,
  slot_key text not null
    references public.hearth_slots(slot_key) on delete restrict,
  placement_label text not null,
  sort_order smallint not null default 0,
  required_equipped_slug text null
    references public.cosmetics(slug) on delete restrict,
  primary key (profile_key, slot_key)
);

alter table public.hearth_slots enable row level security;
alter table public.hearth_layout_profiles enable row level security;
alter table public.hearth_profile_slots enable row level security;

create policy "Authenticated users can view Hearth slots"
  on public.hearth_slots for select to authenticated using (true);
create policy "Authenticated users can view Hearth layout profiles"
  on public.hearth_layout_profiles for select to authenticated using (true);
create policy "Authenticated users can view Hearth profile slots"
  on public.hearth_profile_slots for select to authenticated using (true);

grant select on public.hearth_slots to authenticated;
grant select on public.hearth_layout_profiles to authenticated;
grant select on public.hearth_profile_slots to authenticated;

insert into public.hearth_slots(slot_key,zone,default_label,sort_order) values
  ('left','rear','Back left',10),
  ('right','rear','Back right',20),
  ('front','foreground','Foreground',30),
  ('side','side','Beside the chair',40),
  ('wall_left','wall','Left wall',50),
  ('wall_center','wall','Center wall',60),
  ('wall_right','wall','Right wall',70),
  ('mantel','surface','Fireplace mantel',80),
  ('bookshelf_top','surface','On the bookcase',90),
  ('window','window','Window alcove',100),
  ('floor','floor','Beneath the adventurer',110),
  ('setting','setting','Hearth setting',120);

insert into public.hearth_layout_profiles(profile_key,family_key,display_name) values
  ('large_furniture','large_furniture','Large furniture'),
  ('pedestal_light','pedestal_light','Pedestal light'),
  ('seating','seating','Seating'),
  ('plant','plant','Plant'),
  ('side_table','side_table','Side table'),
  ('trophy_surface','surface_collectible','Trophy surface'),
  ('relic_display','relic_display','Class relic display'),
  ('floor_rug','floor_rug','Floor rug'),
  ('window_feature','window_feature','Window feature'),
  ('hearth_setting','hearth_setting','Hearth setting'),
  ('wall_art_side','wall_art','Side wall art'),
  ('wall_art_center','wall_art','Center wall art');

insert into public.hearth_profile_slots(
  profile_key,slot_key,placement_label,sort_order,required_equipped_slug
) values
  ('large_furniture','left','Back left',10,null),
  ('large_furniture','right','Back right',20,null),

  ('pedestal_light','left','Back left',10,null),
  ('pedestal_light','right','Back right',20,null),

  ('seating','front','Left floor',10,null),
  ('seating','right','Right floor',20,null),

  ('plant','left','Back left',10,null),
  ('plant','right','Back right',20,null),
  ('plant','front','Foreground',30,null),

  ('side_table','side','Beside the chair',10,null),

  ('trophy_surface','mantel','Fireplace mantel',10,null),
  ('trophy_surface','bookshelf_top','On the bookcase',20,'walnut-bookshelf'),

  ('relic_display','left','Back left pedestal',10,null),
  ('relic_display','right','Back right pedestal',20,null),
  ('relic_display','front','Front left pedestal',30,null),
  ('relic_display','mantel','On the fireplace mantel',40,null),
  ('relic_display','bookshelf_top','On the bookcase',50,'walnut-bookshelf'),

  ('floor_rug','floor','Beneath the adventurer',10,null),
  ('window_feature','window','Window alcove',10,null),
  ('hearth_setting','setting','Hearth setting',10,null),

  ('wall_art_side','wall_left','Left wall',10,null),
  ('wall_art_side','wall_right','Right wall',20,null),
  ('wall_art_center','wall_center','Center wall',10,null);

alter table public.cosmetics
  add column hearth_profile_key text null
  references public.hearth_layout_profiles(profile_key) on delete restrict;

update public.cosmetics
set hearth_profile_key = case
  when slug in ('walnut-bookshelf','copper-potion-workbench','harvest-apothecary-display')
    then 'large_furniture'
  when slug in ('autumn-ember-lantern','warding-lantern')
    then 'pedestal_light'
  when slug = 'burgundy-reading-chair' then 'seating'
  when slug = 'hearth-fern' then 'plant'
  when slug = 'walnut-reading-table' then 'side_table'
  when slug in ('first-journey-trophy','starlit-orrery') then 'trophy_surface'
  when slug in ('scholar-seal','scout-compass','alchemist-phial','guardian-crest','wanderer-star-map')
    then 'relic_display'
  when slug = 'emerald-wayfarer-rug' then 'floor_rug'
  when slug = 'rainy-window' then 'window_feature'
  when slug in (
    'woodland-cottage','midnight-harvest','enchanted-library',
    'midnight-observatory','alchemists-workshop','astral-sanctuary',
    'emberglass-conservatory'
  ) then 'hearth_setting'
  when slug in ('fern-study','celestial-study') then 'wall_art_side'
  when slug = 'moonlit-woodland' then 'wall_art_center'
  else hearth_profile_key
end
where category in ('room','wall_art');

do $$
begin
  if exists (
    select 1 from public.cosmetics
    where category in ('room','wall_art') and hearth_profile_key is null
  ) then
    raise exception 'Every Hearth cosmetic must have a hearth_profile_key';
  end if;
end $$;

alter table public.cosmetics
  add constraint cosmetics_hearth_profile_required
  check (
    category not in ('room','wall_art')
    or hearth_profile_key is not null
  );

-- Make room slots extensible through backend data instead of a schema CHECK.
alter table public.user_cosmetics
  drop constraint user_cosmetics_room_slot_check;

alter table public.user_cosmetics
  add constraint user_cosmetics_room_slot_fkey
  foreign key (room_slot)
  references public.hearth_slots(slot_key)
  on update cascade
  on delete restrict;

create or replace function private.place_hearth_cosmetic(
  p_cosmetic_id uuid,
  p_slot text,
  p_expected_occupant uuid default null::uuid
)
returns void
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_uid uuid := auth.uid();
  v_occupant uuid;
  v_class text;
  v_required text;
  v_profile text;
  v_required_equipped_slug text;
begin
  if v_uid is null then raise exception 'authentication required'; end if;

  if p_slot is null or not exists (
    select 1 from public.hearth_slots hs where hs.slot_key = p_slot
  ) then
    raise exception 'invalid room spot';
  end if;

  -- Serialize placement with other profile operations, including concurrent devices.
  select adventurer_archetype
    into v_class
    from public.users
    where id = v_uid
    for update;
  if not found then raise exception 'profile missing'; end if;

  select c.required_archetype, c.hearth_profile_key
    into v_required, v_profile
    from public.cosmetics c
    join public.user_cosmetics uc on uc.cosmetic_id = c.id
    where uc.user_id = v_uid
      and c.id = p_cosmetic_id
      and c.active
      and c.category in ('room','wall_art');
  if not found then raise exception 'room item not owned or unavailable'; end if;

  select hps.required_equipped_slug
    into v_required_equipped_slug
    from public.hearth_profile_slots hps
    where hps.profile_key = v_profile
      and hps.slot_key = p_slot;
  if not found then
    raise exception 'item does not fit this room spot';
  end if;

  if v_required_equipped_slug is not null and not exists (
    select 1
      from public.user_cosmetics uc
      join public.cosmetics c on c.id = uc.cosmetic_id
      where uc.user_id = v_uid
        and uc.equipped
        and c.active
        and c.slug = v_required_equipped_slug
  ) then
    raise exception 'required Hearth furniture is not placed';
  end if;

  if v_required is not null and v_required <> v_class then
    raise exception 'class restricted';
  end if;

  select cosmetic_id
    into v_occupant
    from public.user_cosmetics
    where user_id = v_uid
      and equipped
      and room_slot = p_slot;

  if v_occupant is distinct from p_expected_occupant
     and v_occupant is distinct from p_cosmetic_id then
    raise exception 'room spot changed; refresh and confirm replacement';
  end if;

  update public.user_cosmetics
    set equipped = false, room_slot = null
    where user_id = v_uid
      and equipped
      and room_slot = p_slot
      and cosmetic_id <> p_cosmetic_id;

  update public.user_cosmetics
    set equipped = true, room_slot = p_slot
    where user_id = v_uid
      and cosmetic_id = p_cosmetic_id;
end
$function$;

revoke all on function private.place_hearth_cosmetic(uuid,text,uuid)
  from public, anon;
grant execute on function private.place_hearth_cosmetic(uuid,text,uuid)
  to authenticated;
