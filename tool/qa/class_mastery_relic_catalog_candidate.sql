-- APPLIED 2026-10-01 with explicit founder approval to bdzcazkyypopbanbjnud.
-- Migration: activate_class_mastery_hearth_relics. Retained here as the reviewed SQL.
-- Applies catalog and placement rules together in one transaction.
-- No ownership, reward requirements, item IDs, XP, or coin values change.
begin;

-- Existing hand/effect relics return to inventory before changing their slot type.
update public.user_cosmetics uc set equipped=false, room_slot=null
from public.cosmetics c
where uc.cosmetic_id=c.id and c.unlock_method='class_mastery'
  and c.slug in ('scholar-seal','scout-compass','alchemist-phial','guardian-crest','wanderer-star-map')
  and c.category <> 'room' and (uc.equipped or uc.room_slot is not null);

update public.cosmetics set category='room',
  description=case slug
    when 'scholar-seal' then 'A gilt archive seal, earned through Scholar mastery. Display it on a surface or walnut pedestal in your Hearth.'
    when 'scout-compass' then 'A brass compass with a jade dial, earned through Scout mastery. A keepsake for your Hearth.'
    when 'alchemist-phial' then 'An emerald phial in a brass holder, earned through Alchemist mastery. Display it in your Hearth.'
    when 'guardian-crest' then 'A burgundy and gold crest, earned through Guardian mastery. A place of honor in your Hearth.'
    when 'wanderer-star-map' then 'A framed constellation map, earned through Wanderer mastery. Display the paths you have made.'
  end
where unlock_method='class_mastery'
  and slug in ('scholar-seal','scout-compass','alchemist-phial','guardian-crest','wanderer-star-map');

-- Preserve the existing RPC's owner checks, class restrictions, row lock,
-- replacement check, security mode, search path, and function privileges.
-- The only added branch recognizes the five class relics and their four spots.
CREATE OR REPLACE FUNCTION private.place_hearth_cosmetic(p_cosmetic_id uuid, p_slot text, p_expected_occupant uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid := auth.uid(); v_occupant uuid; v_class text; v_required text; v_slug text; v_category text;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  if p_slot is null or p_slot not in ('left','right','front','side','wall_left','wall_right','wall_center','mantel','bookshelf_top','window') then raise exception 'invalid room spot'; end if;
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
    if p_slot not in ('left','right','mantel','bookshelf_top') then
      raise exception 'choose a relic surface or side-wall pedestal';
    end if;
    if p_slot='bookshelf_top' and not exists(
      select 1 from public.user_cosmetics uc join public.cosmetics c on c.id=uc.cosmetic_id
      where uc.user_id=v_uid and uc.equipped and c.active
        and c.slug='walnut-bookshelf' and uc.room_slot in ('left','right')
    ) then raise exception 'place the bookcase first'; end if;
  elsif v_slug='rainy-window' then
    if p_slot<>'window' then raise exception 'choose the window alcove'; end if;
  elsif v_category='wall_art' then
    if v_slug in ('fern-study','celestial-study') then
      if p_slot not in ('wall_left','wall_right') then raise exception 'item does not fit this wall spot'; end if;
    elsif p_slot<>'wall_center' then raise exception 'item does not fit this wall spot'; end if;
  else
    if p_slot in ('window','wall_left','wall_right','wall_center','mantel','bookshelf_top') or
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

commit;
