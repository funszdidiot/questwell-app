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
 where uc.cosmetic_id=c.id and uc.user_id=v_uid and (c.category=v_category
   or (v_slug in ('moss-green-cloak','hearthguard-mantle') and c.category='hands')
   or (v_category='hands' and c.slug in ('moss-green-cloak','hearthguard-mantle')));
 update public.user_cosmetics set equipped=true where user_id=v_uid and cosmetic_id=p_cosmetic_id;
end $$;
revoke all on function private.equip_cosmetic(uuid) from public,anon;
grant execute on function private.equip_cosmetic(uuid) to authenticated;


-- Confirm the conflicting item has not changed on another device before swapping.
create or replace function private.equip_cosmetic_loadout(p_cosmetic_id uuid,p_expected_conflict uuid default null)
returns void language plpgsql security definer set search_path='' as $$
declare v_uid uuid:=auth.uid(); v_slug text; v_category text; v_conflict uuid;
begin
 if v_uid is null then raise exception 'authentication required'; end if;
 perform 1 from public.users where id=v_uid for update;
 if not found then raise exception 'profile missing'; end if;
 select c.slug,c.category into v_slug,v_category from public.cosmetics c
 join public.user_cosmetics uc on uc.cosmetic_id=c.id
 where uc.user_id=v_uid and c.id=p_cosmetic_id;
 if v_slug is null then raise exception 'cosmetic not owned'; end if;
 select uc.cosmetic_id into v_conflict from public.user_cosmetics uc
 join public.cosmetics c on c.id=uc.cosmetic_id
 where uc.user_id=v_uid and uc.equipped and
 ((v_slug in ('moss-green-cloak','hearthguard-mantle') and c.category='hands')
 or (v_category='hands' and c.slug in ('moss-green-cloak','hearthguard-mantle')));
 if v_conflict is distinct from p_expected_conflict then
   raise exception 'equipment changed; refresh and confirm the swap';
 end if;
 perform private.equip_cosmetic(p_cosmetic_id);
end $$;
revoke all on function private.equip_cosmetic_loadout(uuid,uuid) from public,anon;
grant execute on function private.equip_cosmetic_loadout(uuid,uuid) to authenticated;
create or replace function public.equip_cosmetic_loadout(p_cosmetic_id uuid,p_expected_conflict uuid default null)
returns void language sql security invoker set search_path='' as $$
 select private.equip_cosmetic_loadout(p_cosmetic_id,p_expected_conflict);
$$;
revoke all on function public.equip_cosmetic_loadout(uuid,uuid) from public,anon;
grant execute on function public.equip_cosmetic_loadout(uuid,uuid) to authenticated;
