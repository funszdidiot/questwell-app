-- Add a dedicated table spot without moving existing furniture or changing ownership.
alter table public.user_cosmetics drop constraint user_cosmetics_room_slot_check;
alter table public.user_cosmetics add constraint user_cosmetics_room_slot_check
 check (room_slot in ('left','right','front','side'));
create or replace function private.place_hearth_cosmetic(p_cosmetic_id uuid, p_slot text, p_expected_occupant uuid default null)
returns void language plpgsql security definer set search_path='' as $$
declare v_uid uuid := auth.uid(); v_occupant uuid; v_class text; v_required text; v_slug text;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  if p_slot is null or p_slot not in ('left','right','front','side') then raise exception 'invalid room spot'; end if;
  -- Serialize placement with other profile operations, including concurrent devices.
  select adventurer_archetype into v_class from public.users where id=v_uid for update;
  if not found then raise exception 'profile missing'; end if;
  select c.required_archetype,c.slug into v_required,v_slug from public.cosmetics c
    join public.user_cosmetics uc on uc.cosmetic_id=c.id
    where uc.user_id=v_uid and c.id=p_cosmetic_id and c.active and c.category='room';
  if not found then raise exception 'room item not owned or unavailable'; end if;
  if (p_slot='side') is distinct from (v_slug='walnut-reading-table') then raise exception 'item does not fit this room spot'; end if;
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
-- Activate only after the supporting development client has passed checks.
insert into public.cosmetics(slug,name,category,rarity,description,price,premium,asset_key,active,required_archetype,unlock_method)
values ('walnut-reading-table','Walnut Reading Table','room','uncommon',
 'Worn books, warm walnut, and candlelight. A quiet companion for your reading chair.',
 120,false,'room_walnut_reading_table',false,null,'shop')
on conflict(slug) do nothing;
