-- Additive development change. Existing placed bookshelf keeps its right-hand spot.
alter table public.user_cosmetics add column if not exists room_slot text
  check (room_slot in ('left','right','front'));
update public.user_cosmetics uc set room_slot='right'
from public.cosmetics c where c.id=uc.cosmetic_id and c.category='room' and uc.equipped and uc.room_slot is null;
create unique index if not exists user_cosmetics_placed_room_slot
on public.user_cosmetics(user_id,room_slot) where equipped and room_slot is not null;

create or replace function private.place_hearth_cosmetic(p_cosmetic_id uuid, p_slot text, p_expected_occupant uuid default null)
returns void language plpgsql security definer set search_path='' as $$
declare v_uid uuid := auth.uid(); v_occupant uuid; v_class text; v_required text;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  if p_slot is null or p_slot not in ('left','right','front') then raise exception 'invalid room spot'; end if;
  -- Serialize placement with other profile operations, including concurrent devices.
  select adventurer_archetype into v_class from public.users where id=v_uid for update;
  if not found then raise exception 'profile missing'; end if;
  select c.required_archetype into v_required from public.cosmetics c
    join public.user_cosmetics uc on uc.cosmetic_id=c.id
    where uc.user_id=v_uid and c.id=p_cosmetic_id and c.active and c.category='room';
  if not found then raise exception 'room item not owned or unavailable'; end if;
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
create or replace function public.place_hearth_cosmetic(p_cosmetic_id uuid,p_slot text,p_expected_occupant uuid default null)
returns void language sql security invoker set search_path='' as $$
select private.place_hearth_cosmetic(p_cosmetic_id,p_slot,p_expected_occupant); $$;
revoke all on function public.place_hearth_cosmetic(uuid,text,uuid) from public,anon;
grant execute on function public.place_hearth_cosmetic(uuid,text,uuid) to authenticated;

-- Old clients may place only into an empty right spot, never replace all room decor.
create or replace function private.equip_cosmetic(p_cosmetic_id uuid)
returns void language plpgsql security definer set search_path='' as $$
declare v_uid uuid:=auth.uid(); v_category text; v_required text; v_class text;
begin
 if v_uid is null then raise exception 'authentication required'; end if;
 select adventurer_archetype into v_class from public.users where id=v_uid for update;
 select c.category,c.required_archetype into v_category,v_required
 from public.user_cosmetics uc join public.cosmetics c on c.id=uc.cosmetic_id
 where uc.user_id=v_uid and c.id=p_cosmetic_id;
 if v_category is null then raise exception 'cosmetic not owned'; end if;
 if v_required is not null and v_required<>v_class then raise exception 'cosmetic restricted'; end if;
 if v_category='room' then
   perform private.place_hearth_cosmetic(p_cosmetic_id,'right',null); return;
 end if;
 update public.user_cosmetics uc set equipped=false from public.cosmetics c
 where uc.cosmetic_id=c.id and uc.user_id=v_uid and c.category=v_category;
 update public.user_cosmetics set equipped=true where user_id=v_uid and cosmetic_id=p_cosmetic_id;
end $$;
insert into public.cosmetics(slug,name,category,rarity,description,price,premium,asset_key,active,required_archetype,unlock_method)
values ('hearth-fern','Hearth Fern','room','uncommon','Lush green fronds in an aged brass planter. A little life for your Hearth.',120,false,'room_hearth_fern',true,null,'shop')
on conflict(slug) do nothing;
