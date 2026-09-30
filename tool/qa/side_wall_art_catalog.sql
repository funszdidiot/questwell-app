-- Add a dedicated table spot without moving existing furniture or changing ownership.
alter table public.user_cosmetics drop constraint user_cosmetics_room_slot_check;
alter table public.user_cosmetics add constraint user_cosmetics_room_slot_check
 check (room_slot in ('left','right','front','side','wall_left','wall_right','wall_center'));
create or replace function private.place_hearth_cosmetic(p_cosmetic_id uuid, p_slot text, p_expected_occupant uuid default null)
returns void language plpgsql security definer set search_path='' as $$
declare v_uid uuid := auth.uid(); v_occupant uuid; v_class text; v_required text; v_slug text; v_category text;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  if p_slot is null or p_slot not in ('left','right','front','side','wall_left','wall_right','wall_center') then raise exception 'invalid room spot'; end if;
  -- Serialize placement with other profile operations, including concurrent devices.
  select adventurer_archetype into v_class from public.users where id=v_uid for update;
  if not found then raise exception 'profile missing'; end if;
  select c.required_archetype,c.slug,c.category into v_required,v_slug,v_category from public.cosmetics c
    join public.user_cosmetics uc on uc.cosmetic_id=c.id
    where uc.user_id=v_uid and c.id=p_cosmetic_id and c.active and c.category in ('room','wall_art');
  if not found then raise exception 'room item not owned or unavailable'; end if;
  if v_category='wall_art' then
    if v_slug in ('fern-study','celestial-study') then
      if p_slot not in ('wall_left','wall_right') then raise exception 'item does not fit this wall spot'; end if;
    elsif p_slot<>'wall_center' then raise exception 'item does not fit this wall spot'; end if;
  else
    if p_slot in ('wall_left','wall_right','wall_center') or
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
end $$;

revoke all on function private.place_hearth_cosmetic(uuid,text,uuid) from public,anon;
grant execute on function private.place_hearth_cosmetic(uuid,text,uuid) to authenticated;

-- Preserve existing center paintings and their ownership.
update public.user_cosmetics uc set room_slot='wall_center'
from public.cosmetics c where uc.cosmetic_id=c.id and c.category='wall_art' and uc.room_slot is null;

-- Center art can still use the simple Hang control and older clients.
-- Side art requires the placement picker so replacing another piece is explicit.
create or replace function private.equip_cosmetic(p_cosmetic_id uuid)
returns void language plpgsql security definer set search_path='' as $$
declare v_uid uuid:=auth.uid(); v_category text; v_required text; v_class text; v_slug text; v_occupant uuid;
begin
 if v_uid is null then raise exception 'authentication required'; end if;
 select adventurer_archetype into v_class from public.users where id=v_uid for update;
 select c.category,c.required_archetype,c.slug into v_category,v_required,v_slug
 from public.user_cosmetics uc join public.cosmetics c on c.id=uc.cosmetic_id
 where uc.user_id=v_uid and c.id=p_cosmetic_id;
 if v_category is null then raise exception 'cosmetic not owned'; end if;
 if v_required is not null and v_required<>v_class then raise exception 'cosmetic restricted'; end if;
 if v_category='room' then
   perform private.place_hearth_cosmetic(p_cosmetic_id,'right',null); return;
 end if;
 if v_category='wall_art' then
   if v_slug in ('fern-study','celestial-study') then raise exception 'choose a wall spot'; end if;
   select cosmetic_id into v_occupant from public.user_cosmetics where user_id=v_uid and equipped and room_slot='wall_center';
   perform private.place_hearth_cosmetic(p_cosmetic_id,'wall_center',v_occupant); return;
 end if;
 update public.user_cosmetics uc set equipped=false from public.cosmetics c
 where uc.cosmetic_id=c.id and uc.user_id=v_uid and c.category=v_category;
 update public.user_cosmetics set equipped=true where user_id=v_uid and cosmetic_id=p_cosmetic_id;
end $$;
revoke all on function private.equip_cosmetic(uuid) from public,anon;
grant execute on function private.equip_cosmetic(uuid) to authenticated;

-- Activate after the updated development client passes checks.
insert into public.cosmetics(slug,name,category,rarity,description,price,premium,asset_key,active,required_archetype,unlock_method)
values
 ('fern-study','Fern Study','wall_art','uncommon','A green fern on warm parchment, framed in walnut and gold. Hang on the left or right wall.',120,false,'wall_art_fern_study',false,null,'shop'),
 ('celestial-study','Celestial Study','wall_art','uncommon','A golden crescent and constellations against midnight blue. Hang on the left or right wall.',120,false,'wall_art_celestial_study',false,null,'shop')
on conflict(slug) do nothing;

update public.cosmetics set description='A moonlit forest and a warmly lit cottage, framed in walnut and gold. Hang in the center, with room for smaller paintings on either side.' where slug='moonlit-woodland';
