-- First Journey is earned once at level 5, never purchased.
alter table public.cosmetics drop constraint cosmetics_unlock_method_check;
alter table public.cosmetics add constraint cosmetics_unlock_method_check
 check (unlock_method in ('shop','class_mastery','level_milestone'));
alter table public.user_cosmetics drop constraint user_cosmetics_room_slot_check;
alter table public.user_cosmetics add constraint user_cosmetics_room_slot_check
 check (room_slot in ('left','right','front','side','wall_left','wall_right','wall_center','mantel','bookshelf_top'));

insert into public.cosmetics(slug,name,category,rarity,description,price,premium,asset_key,active,required_archetype,unlock_method)
values ('first-journey-trophy','First Journey','room','uncommon',
 'An aged-bronze compass on a walnut stand. Earned at level 5. Display on the fireplace mantel or on your bookcase.',
 0,false,'room_first_journey_trophy',false,null,'level_milestone');

-- Called only as a trigger on server-managed levels. Invoker inherits the
-- existing reward transaction's privileges; no public award endpoint is added.
create function private.award_first_journey()
returns trigger language plpgsql security invoker set search_path='' as $$
begin
 if new.level >= 5 then
  insert into public.user_cosmetics(user_id,cosmetic_id,source,equipped)
   select new.id,c.id,'level_milestone',false from public.cosmetics c
   where c.slug='first-journey-trophy'
   on conflict(user_id,cosmetic_id) do nothing;
 end if;
 return new;
end $$;
revoke all on function private.award_first_journey() from public,anon,authenticated;
create trigger award_first_journey after insert or update of level on public.users
 for each row execute function private.award_first_journey();

-- Also cover players who have already passed the milestone.
insert into public.user_cosmetics(user_id,cosmetic_id,source,equipped)
 select u.id,c.id,'level_milestone',false from public.users u cross join public.cosmetics c
 where u.level>=5 and c.slug='first-journey-trophy'
 on conflict(user_id,cosmetic_id) do nothing;

CREATE OR REPLACE FUNCTION private.place_hearth_cosmetic(p_cosmetic_id uuid, p_slot text, p_expected_occupant uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid := auth.uid(); v_occupant uuid; v_class text; v_required text; v_slug text; v_category text;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  if p_slot is null or p_slot not in ('left','right','front','side','wall_left','wall_right','wall_center','mantel','bookshelf_top') then raise exception 'invalid room spot'; end if;
  -- Serialize placement with other profile operations, including concurrent devices.
  select adventurer_archetype into v_class from public.users where id=v_uid for update;
  if not found then raise exception 'profile missing'; end if;
  select c.required_archetype,c.slug,c.category into v_required,v_slug,v_category from public.cosmetics c
    join public.user_cosmetics uc on uc.cosmetic_id=c.id
    where uc.user_id=v_uid and c.id=p_cosmetic_id and c.active and c.category in ('room','wall_art');
  if not found then raise exception 'room item not owned or unavailable'; end if;
  if v_slug='first-journey-trophy' then
    if p_slot not in ('mantel','bookshelf_top') then raise exception 'choose a trophy surface'; end if;
    if p_slot='bookshelf_top' and not exists(
      select 1 from public.user_cosmetics uc join public.cosmetics c on c.id=uc.cosmetic_id
      where uc.user_id=v_uid and uc.equipped and c.slug='walnut-bookshelf' and uc.room_slot in ('left','right')
    ) then raise exception 'place the bookcase first'; end if;
  elsif v_category='wall_art' then
    if v_slug in ('fern-study','celestial-study') then
      if p_slot not in ('wall_left','wall_right') then raise exception 'item does not fit this wall spot'; end if;
    elsif p_slot<>'wall_center' then raise exception 'item does not fit this wall spot'; end if;
  else
    if p_slot in ('wall_left','wall_right','wall_center','mantel','bookshelf_top') or
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

-- Moving the bookcase retains the trophy. Removing/replacing it puts the
-- supported trophy safely back in inventory, preserving ownership.
create function private.return_unsupported_trophy()
returns trigger language plpgsql security invoker set search_path='' as $$
begin
 if old.equipped and exists(select 1 from public.cosmetics where id=old.cosmetic_id and slug='walnut-bookshelf') then
  if tg_op='DELETE' or not new.equipped or new.room_slot is null or new.room_slot not in ('left','right') then
   update public.user_cosmetics uc set equipped=false,room_slot=null
    from public.cosmetics c where uc.cosmetic_id=c.id and uc.user_id=old.user_id
      and c.slug='first-journey-trophy' and uc.equipped and uc.room_slot='bookshelf_top';
  end if;
 end if;
 return null;
end $$;
revoke all on function private.return_unsupported_trophy() from public,anon,authenticated;
create trigger return_unsupported_trophy after update or delete on public.user_cosmetics
 for each row execute function private.return_unsupported_trophy();

notify pgrst, 'reload schema';
