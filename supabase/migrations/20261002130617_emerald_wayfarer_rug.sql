-- Dedicated floor slot. Stage the catalog item inactive until the client passes.
alter table public.user_cosmetics drop constraint user_cosmetics_room_slot_check;
alter table public.user_cosmetics add constraint user_cosmetics_room_slot_check
 check (room_slot in ('left','right','front','side','wall_left','wall_right','wall_center','mantel','bookshelf_top','window','floor'));

CREATE OR REPLACE FUNCTION private.place_hearth_cosmetic(p_cosmetic_id uuid, p_slot text, p_expected_occupant uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid := auth.uid(); v_occupant uuid; v_class text; v_required text; v_slug text; v_category text;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  if p_slot is null or p_slot not in ('left','right','front','side','wall_left','wall_right','wall_center','mantel','bookshelf_top','window','floor') then raise exception 'invalid room spot'; end if;
  -- Serialize placement with other profile operations, including concurrent devices.
  select adventurer_archetype into v_class from public.users where id=v_uid for update;
  if not found then raise exception 'profile missing'; end if;
  select c.required_archetype,c.slug,c.category into v_required,v_slug,v_category from public.cosmetics c
    join public.user_cosmetics uc on uc.cosmetic_id=c.id
    where uc.user_id=v_uid and c.id=p_cosmetic_id and c.active and c.category in ('room','wall_art');
  if not found then raise exception 'room item not owned or unavailable'; end if;
  if v_slug in ('first-journey-trophy','starlit-orrery') then
    if p_slot not in ('mantel','bookshelf_top') then raise exception 'choose a trophy surface'; end if;
    if p_slot='bookshelf_top' and not exists(
      select 1 from public.user_cosmetics uc join public.cosmetics c on c.id=uc.cosmetic_id
      where uc.user_id=v_uid and uc.equipped and c.slug='walnut-bookshelf' and uc.room_slot in ('left','right')
    ) then raise exception 'place the bookcase first'; end if;
  elsif v_slug in ('scholar-seal','scout-compass','alchemist-phial','guardian-crest','wanderer-star-map') then
    if p_slot not in ('left','right','front','mantel','bookshelf_top') then
      raise exception 'choose a relic surface or pedestal spot';
    end if;
    if p_slot='bookshelf_top' and not exists(
      select 1 from public.user_cosmetics uc join public.cosmetics c on c.id=uc.cosmetic_id
      where uc.user_id=v_uid and uc.equipped and c.active
        and c.slug='walnut-bookshelf' and uc.room_slot in ('left','right')
    ) then raise exception 'place the bookcase first'; end if;
  elsif v_slug='emerald-wayfarer-rug' then
    if p_slot<>'floor' then raise exception 'choose the floor beneath the adventurer'; end if;
  elsif v_slug='rainy-window' then
    if p_slot<>'window' then raise exception 'choose the window alcove'; end if;
  elsif v_category='wall_art' then
    if v_slug in ('fern-study','celestial-study') then
      if p_slot not in ('wall_left','wall_right') then raise exception 'item does not fit this wall spot'; end if;
    elsif p_slot<>'wall_center' then raise exception 'item does not fit this wall spot'; end if;
  else
    if p_slot in ('floor','window','wall_left','wall_right','wall_center','mantel','bookshelf_top') or
      ((p_slot='side') is distinct from (v_slug='walnut-reading-table')) then
      raise exception 'item does not fit this room spot';
    end if;
  end if;
  if v_required is not null and v_required<>v_class then raise exception 'class restricted'; end if;
  select cosmetic_id into v_occupant from public.user_cosmetics
    where user_id=v_uid and equipped and room_slot=p_slot;
  if v_occupant is distinct from p_expected_occupant and v_occupant is distinct from p_cosmetic_id then
    raise exception 'room spot changed; refresh and confirm replacement';
  end if;
  update public.user_cosmetics set equipped=false,room_slot=null
    where user_id=v_uid and equipped and room_slot=p_slot and cosmetic_id<>p_cosmetic_id;
  update public.user_cosmetics set equipped=true,room_slot=p_slot
    where user_id=v_uid and cosmetic_id=p_cosmetic_id;
end $function$
;

-- Preserve the existing private RPC and authenticated-only access.
revoke all on function private.place_hearth_cosmetic(uuid,text,uuid) from public,anon;
grant execute on function private.place_hearth_cosmetic(uuid,text,uuid) to authenticated;

insert into public.cosmetics(slug,name,category,rarity,description,price,premium,asset_key,active,required_archetype,unlock_method)
values ('emerald-wayfarer-rug','Emerald Wayfarer Rug','room','common',
 'Deep green threads, a woven gold border, and a compass rose. A soft place to begin your next adventure.',
 20,false,'room_emerald_wayfarer_rug',false,null,'shop')
on conflict(slug) do nothing;
