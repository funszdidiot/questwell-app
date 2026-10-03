-- Female wardrobe catalog; activation follows successful development verification.
insert into public.cosmetics(slug,name,category,rarity,description,price,premium,asset_key,active,required_archetype,unlock_method)
values
('woodland-scout-outfit','Woodland Scout Outfit','chest','uncommon','Moss leather, an ivory rolled-sleeve shirt, reinforced trousers and travel boots. Available for the female body; every class.',120,false,'chest_woodland_scout_outfit',false,null,'shop'),
('everyday-adventurer-outfit','Everyday Adventurer Outfit','chest','common','A simple ivory shirt, brown trousers and sturdy boots. Available for the female body; every class.',40,false,'chest_everyday_adventurer_outfit',false,null,'shop')
on conflict(slug) do nothing;

CREATE OR REPLACE FUNCTION private.equip_cosmetic(p_cosmetic_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=auth.uid(); v_category text; v_required text; v_class text; v_slug text; v_occupant uuid;
begin
 if v_uid is null then raise exception 'authentication required'; end if;
 select adventurer_archetype into v_class from public.users where id=v_uid for update;
 select c.category,c.required_archetype,c.slug into v_category,v_required,v_slug
 from public.user_cosmetics uc join public.cosmetics c on c.id=uc.cosmetic_id
 where uc.user_id=v_uid and c.id=p_cosmetic_id;
 if v_category is null then raise exception 'cosmetic not owned'; end if;
 if v_required is not null and v_required<>v_class then raise exception 'cosmetic restricted'; end if;
 if v_slug in ('woodland-scout-outfit','everyday-adventurer-outfit')
   and not exists(select 1 from public.users u where u.id=v_uid and u.avatar_body_type='female') then
   raise exception 'outfit requires female body';
 end if;
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
end $function$;


CREATE OR REPLACE FUNCTION private.purchase_cosmetic(p_cosmetic_id uuid)
 RETURNS TABLE(cosmetic_id uuid, remaining_coins integer, already_owned boolean)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_price integer;
  v_balance integer;
  v_required_archetype text;
  v_user_archetype text;
  v_unlock_method text;
begin
  if v_uid is null then raise exception 'authentication required'; end if;

  -- Serialize coin, class, and ownership decisions across devices and retries.
  select u.coin_balance,u.adventurer_archetype into v_balance,v_user_archetype
    from public.users u where u.id=v_uid for update;
  if not found then raise exception 'profile not found'; end if;

  select c.price,c.required_archetype,c.unlock_method
    into v_price,v_required_archetype,v_unlock_method
    from public.cosmetics c where c.id=p_cosmetic_id and c.active for share;
  if v_price is null then raise exception 'cosmetic not found'; end if;
  if exists(select 1 from public.cosmetics c where c.id=p_cosmetic_id
      and c.slug in ('woodland-scout-outfit','everyday-adventurer-outfit'))
    and not exists(select 1 from public.users u where u.id=v_uid and u.avatar_body_type='female') then
    raise exception 'outfit requires female body';
  end if;
  if v_unlock_method<>'shop' then raise exception 'cosmetic is not purchasable'; end if;
  if v_required_archetype is not null and v_required_archetype<>v_user_archetype then
    raise exception 'cosmetic restricted to % archetype',v_required_archetype;
  end if;

  if exists(select 1 from public.user_cosmetics uc
    where uc.user_id=v_uid and uc.cosmetic_id=p_cosmetic_id) then
    return query select p_cosmetic_id,v_balance,true;
    return;
  end if;
  if v_balance<v_price then raise exception 'not enough coins'; end if;

  update public.users u set coin_balance=u.coin_balance-v_price
    where u.id=v_uid returning u.coin_balance into v_balance;
  insert into public.user_cosmetics(user_id,cosmetic_id,source)
    values(v_uid,p_cosmetic_id,'shop');
  insert into public.reward_events(user_id,task_id,event_type,xp_amount,coin_amount)
    values(v_uid,null,'cosmetic_purchase',0,-v_price);
  return query select p_cosmetic_id,v_balance,false;
end;
$function$;


CREATE OR REPLACE FUNCTION private.set_avatar_body_type(p_body_type text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if p_body_type not in ('male','female','neutral') then
    raise exception 'Unsupported avatar body type';
  end if;

  update public.users
  set avatar_body_type = p_body_type
  where id = auth.uid();
  -- Keep ownership, but return unsupported fits to inventory on a body change.
  if p_body_type <> 'female' then
    update public.user_cosmetics uc set equipped=false
    from public.cosmetics c
    where uc.cosmetic_id=c.id and uc.user_id=auth.uid() and uc.equipped
      and c.slug in ('woodland-scout-outfit','everyday-adventurer-outfit');
  end if;
end;
$function$;
