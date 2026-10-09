-- Disposable CI only. The enclosing transaction rolls back every synthetic write.
do $test$
declare
  owner_id uuid := gen_random_uuid();
  item record; bought record; state jsonb; target jsonb := '{}'; saved jsonb;
  expected_prices jsonb := '{"amberfall-window":120,"maple-hearth-rug":60,"mooncap-grove":120,"harvest-lanterns":240,"sages-rest":120}';
  slot text; replacement uuid := gen_random_uuid(); window_id uuid;
begin
  if (select count(*) from public.cosmetics where slug in (select jsonb_object_keys(expected_prices))
      and active and not premium and required_archetype is null and price=(expected_prices->>slug)::int
      and availability_end is null and collection_key='autumn-hearth')<>5 then
    raise exception 'Autumn pricing or eligibility differs';
  end if;
  insert into auth.users(id,email) values(owner_id,'autumn-ci@example.test');
  update public.users set coin_balance=2000,adventurer_archetype='wanderer',avatar_body_type='neutral' where id=owner_id;
  perform set_config('request.jwt.claim.sub',owner_id::text,true);
  for item in select * from public.cosmetics where slug in (select jsonb_object_keys(expected_prices)) loop
    select * into strict bought from public.purchase_cosmetic(item.id);
    if bought.already_owned then raise exception 'Unexpected ownership'; end if;
    select * into strict bought from public.purchase_cosmetic(item.id);
    if not bought.already_owned then raise exception 'Purchase retry is not idempotent'; end if;
    slot := case item.hearth_profile_key when 'window_feature' then 'window' when 'floor_rug' then 'floor'
      when 'plant' then 'right' when 'pedestal_light' then 'left' when 'seating' then 'front' end;
    perform public.place_hearth_cosmetic(item.id,slot,null);
    perform public.unequip_cosmetic(item.id);
    perform public.place_hearth_cosmetic(item.id,slot,null);
    target := target || jsonb_build_object(slot,item.id::text);
  end loop;
  if (select coin_balance from public.users where id=owner_id)<>1340 then raise exception 'Expected exactly 660 coins charged'; end if;
  if (select count(*) from public.reward_events where user_id=owner_id and event_type='cosmetic_purchase')<>5 then raise exception 'Duplicate purchase events'; end if;
  if (select count(*) from public.user_cosmetics where user_id=owner_id and equipped)<>5 then raise exception 'Five placements not restored'; end if;
  state := public.read_hearth_layouts();
  if state->'current'<>target then raise exception 'Placement reload differs'; end if;
  saved := public.save_hearth_layout(state->'current',(state->>'revision')::bigint,'{}');
  saved := public.save_hearth_layout(saved->'current',(saved->>'revision')::bigint,target);
  if public.read_hearth_layouts()->'current'<>target then raise exception 'Decorator persistence differs'; end if;
  -- Slot replacement preserves the first item's ownership.
  insert into public.cosmetics(id,slug,name,category,rarity,price,hearth_profile_key)
    values(replacement,'autumn-ci-rain','Synthetic rain','room','common',0,'window_feature');
  insert into public.user_cosmetics(user_id,cosmetic_id,source) values(owner_id,replacement,'shop');
  select id into window_id from public.cosmetics where slug='amberfall-window';
  perform public.place_hearth_cosmetic(replacement,'window',window_id);
  if not exists(select 1 from public.user_cosmetics where user_id=owner_id and cosmetic_id=window_id and not equipped) then
    raise exception 'Window replacement lost ownership';
  end if;
  perform public.place_hearth_cosmetic(window_id,'window',replacement);
  if public.read_hearth_layouts()->'current'<>target then raise exception 'Window restore failed'; end if;
end;
$test$;
