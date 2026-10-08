-- Approved Halloween catalog, initially hidden until the reviewed client is served.
-- Forward-only: no ownership writes, existing harvest edits or history repair.
-- Keep active=true after launch; availability_end closes purchases, not ownership.
begin;

-- Only replace the observed purchase definition; stop on concurrent drift.
do $guard$
declare current_definition text;
begin
  select pg_get_functiondef('private.purchase_cosmetic(uuid)'::regprocedure)
    into current_definition;
  if btrim(current_definition,E' \n\r\t')=btrim($after$CREATE OR REPLACE FUNCTION private.purchase_cosmetic(p_cosmetic_id uuid)
 RETURNS TABLE(cosmetic_id uuid, remaining_coins integer, already_owned boolean)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_price integer; v_balance integer;
  v_required_archetype text; v_user_archetype text; v_unlock_method text;
  v_body text; v_slug text;
  v_start timestamptz; v_end timestamptz;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  -- Preserve serialization across devices/retries and the existing catalog authority.
  select u.coin_balance,u.adventurer_archetype,u.avatar_body_type
    into v_balance,v_user_archetype,v_body
    from public.users u where u.id=v_uid for update;
  if not found then raise exception 'profile not found'; end if;
  select c.price,c.required_archetype,c.unlock_method,c.slug,c.availability_start,c.availability_end
    into v_price,v_required_archetype,v_unlock_method,v_slug,v_start,v_end
    from public.cosmetics c where c.id=p_cosmetic_id and c.active for share;
  if v_price is null then raise exception 'cosmetic not found'; end if;
  if not private.cosmetic_supports_body(v_slug,v_body) then
    raise exception 'outfit unavailable for selected body';
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
  -- Owned retries above remain idempotent after the purchase window closes.
  if (v_start is not null and statement_timestamp()<v_start)
    or (v_end is not null and statement_timestamp()>=v_end) then
    raise exception 'cosmetic outside purchase availability';
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
$function$$after$) then
    null; -- Safe replay.
  elsif btrim(current_definition,E' \n\r\t')=btrim($before$CREATE OR REPLACE FUNCTION private.purchase_cosmetic(p_cosmetic_id uuid)
 RETURNS TABLE(cosmetic_id uuid, remaining_coins integer, already_owned boolean)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_price integer; v_balance integer;
  v_required_archetype text; v_user_archetype text; v_unlock_method text;
  v_body text; v_slug text;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  -- Preserve serialization across devices/retries and the existing catalog authority.
  select u.coin_balance,u.adventurer_archetype,u.avatar_body_type
    into v_balance,v_user_archetype,v_body
    from public.users u where u.id=v_uid for update;
  if not found then raise exception 'profile not found'; end if;
  select c.price,c.required_archetype,c.unlock_method,c.slug
    into v_price,v_required_archetype,v_unlock_method,v_slug
    from public.cosmetics c where c.id=p_cosmetic_id and c.active for share;
  if v_price is null then raise exception 'cosmetic not found'; end if;
  if not private.cosmetic_supports_body(v_slug,v_body) then
    raise exception 'outfit unavailable for selected body';
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
$function$$before$) then
    execute $after$CREATE OR REPLACE FUNCTION private.purchase_cosmetic(p_cosmetic_id uuid)
 RETURNS TABLE(cosmetic_id uuid, remaining_coins integer, already_owned boolean)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_price integer; v_balance integer;
  v_required_archetype text; v_user_archetype text; v_unlock_method text;
  v_body text; v_slug text;
  v_start timestamptz; v_end timestamptz;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  -- Preserve serialization across devices/retries and the existing catalog authority.
  select u.coin_balance,u.adventurer_archetype,u.avatar_body_type
    into v_balance,v_user_archetype,v_body
    from public.users u where u.id=v_uid for update;
  if not found then raise exception 'profile not found'; end if;
  select c.price,c.required_archetype,c.unlock_method,c.slug,c.availability_start,c.availability_end
    into v_price,v_required_archetype,v_unlock_method,v_slug,v_start,v_end
    from public.cosmetics c where c.id=p_cosmetic_id and c.active for share;
  if v_price is null then raise exception 'cosmetic not found'; end if;
  if not private.cosmetic_supports_body(v_slug,v_body) then
    raise exception 'outfit unavailable for selected body';
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
  -- Owned retries above remain idempotent after the purchase window closes.
  if (v_start is not null and statement_timestamp()<v_start)
    or (v_end is not null and statement_timestamp()>=v_end) then
    raise exception 'cosmetic outside purchase availability';
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
$function$$after$;
  else
    raise exception 'Purchase definition drift; review before deploying Halloween';
  end if;
end;
$guard$;

create temporary table hallowed_expected on commit drop as
select * from (values
  ('hallowed-hearth','The Hallowed Hearth','room','rare','Approved Halloween room with two gently descending spiders.',220,false,false,null,'shop','midnight-harvest','seasonal',null,'2026-11-09T06:00:00Z','hearth_setting'),
  ('velvet-batwing-chair','Velvet Batwing Chair','room','uncommon','Plum velvet, walnut feet and a crescent cushion.',140,false,false,null,'shop','midnight-harvest','seasonal',null,'2026-11-09T06:00:00Z','seating'),
  ('moonbrew-side-table','Moonbrew Side Table','room','uncommon','A copper cup and spellbook on a carved walnut table.',100,false,false,null,'shop','midnight-harvest','seasonal',null,'2026-11-09T06:00:00Z','side_table'),
  ('witchlight-bookcase','Witchlight Bookcase','room','uncommon','Old books and softly glowing amber bottles.',160,false,false,null,'shop','midnight-harvest','seasonal',null,'2026-11-09T06:00:00Z','large_furniture'),
  ('moonweb-rug','Moonweb Rug','room','uncommon','Plum wool, copper fringe and a woven moon-and-web motif.',60,false,false,null,'shop','midnight-harvest','seasonal',null,'2026-11-09T06:00:00Z','floor_rug'),
  ('midnight-visitors-print','Midnight Visitors Print','wall_art','uncommon','A moonlit cottage and three bats in a walnut frame.',60,false,false,null,'shop','midnight-harvest','seasonal',null,'2026-11-09T06:00:00Z','wall_art_side')
) as items(slug,name,category,rarity,description,price,premium,active,
  required_archetype,unlock_method,collection_key,edition_type,
  availability_start,availability_end,hearth_profile_key);

insert into public.cosmetics(slug,name,category,rarity,description,price,premium,
  active,required_archetype,unlock_method,collection_key,edition_type,
  availability_start,availability_end,hearth_profile_key)
select slug,name,category,rarity,description,price,premium,active,
  required_archetype,unlock_method,collection_key,edition_type,
  availability_start::timestamptz,availability_end::timestamptz,hearth_profile_key
from hallowed_expected
on conflict (slug) do nothing;

-- Never overwrite an existing slug, ID, ownership, activation or start date.
do $guard$
begin
  if exists (
    select 1 from hallowed_expected e join public.cosmetics c using(slug)
    where (c.name,c.category,c.rarity,c.description,c.price,c.premium,
      c.required_archetype,c.unlock_method,c.collection_key,c.edition_type,
      c.availability_end,c.hearth_profile_key)
    is distinct from
      (e.name,e.category,e.rarity,e.description,e.price,e.premium,
      e.required_archetype,e.unlock_method,e.collection_key,e.edition_type,
      e.availability_end::timestamptz,e.hearth_profile_key)
  ) then raise exception 'Halloween catalog drift'; end if;
end;
$guard$;

create temporary table hallowed_renders on commit drop as
select * from (values
  ('velvet-batwing-chair','static_sprite','bundle','assets/images/questwell/hearth/velvet_batwing_chair_v1.webp',1312,1199,1.0,'seating',null,'pixel',1),
  ('moonbrew-side-table','static_sprite','bundle','assets/images/questwell/hearth/moonbrew_side_table_v1.webp',1225,1284,1.0,'side_table',null,'pixel',1),
  ('witchlight-bookcase','static_sprite','bundle','assets/images/questwell/hearth/witchlight_bookcase_v1.webp',1024,1536,1.0,'wide_plinth',null,'pixel',1),
  ('moonweb-rug','floor_sprite','bundle','assets/images/questwell/hearth/moonweb_rug_v1.webp',1774,887,1.0,'none',null,'pixel',1),
  ('midnight-visitors-print','wall_art_sprite','bundle','assets/images/questwell/hearth/midnight_visitors_print_v1.webp',1095,1437,1.0,'none',null,'pixel',1)
) as specs(slug,render_kind,asset_source,asset_path,canvas_width,canvas_height,
  visible_base,shadow_profile,effect_profile,filter_mode,asset_revision);

insert into public.hearth_render_registry(cosmetic_id,render_kind,asset_source,
  asset_path,canvas_width,canvas_height,visible_base,shadow_profile,effect_profile,
  filter_mode,asset_revision)
select c.id,r.render_kind,r.asset_source,r.asset_path,r.canvas_width,r.canvas_height,
  r.visible_base,r.shadow_profile,r.effect_profile,r.filter_mode,r.asset_revision
from hallowed_renders r join public.cosmetics c using(slug)
on conflict (cosmetic_id) do nothing;

do $guard$
begin
  if exists (
    select 1 from hallowed_renders e join public.cosmetics c using(slug)
    join public.hearth_render_registry r on r.cosmetic_id=c.id
    where (r.render_kind,r.asset_source,r.asset_path,r.canvas_width,r.canvas_height,
      r.visible_base,r.shadow_profile,r.effect_profile,r.filter_mode,r.asset_revision,r.min_client_build)
    is distinct from
      (e.render_kind,e.asset_source,e.asset_path,e.canvas_width,e.canvas_height,
      e.visible_base,e.shadow_profile,e.effect_profile,e.filter_mode,e.asset_revision,null::integer)
  ) then raise exception 'Halloween renderer drift'; end if;
end;
$guard$;
commit;
