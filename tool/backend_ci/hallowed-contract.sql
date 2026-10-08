-- Disposable application database only; all synthetic changes roll back.
do $test$
declare
  v_uid uuid := '60000000-0000-4000-8000-000000000091';
  item record; result record; v_balance integer; v_count integer;
  expected_prices jsonb := '{"hallowed-hearth":220,"velvet-batwing-chair":140,"moonbrew-side-table":100,"witchlight-bookcase":160,"moonweb-rug":60,"midnight-visitors-print":60}';
begin
  begin
    select count(*) into v_count from public.cosmetics where slug in (select jsonb_object_keys(expected_prices));
    if v_count<>6 then raise exception 'Expected exactly six Halloween rows'; end if;
    if exists(select 1 from public.cosmetics where slug in (select jsonb_object_keys(expected_prices))
      and (active or price<>(expected_prices->>slug)::int or premium or required_archetype is not null
        or collection_key<>'midnight-harvest' or edition_type<>'seasonal'
        or availability_start is not null or availability_end is distinct from '2026-11-09T06:00:00Z'::timestamptz)) then
      raise exception 'Unapproved catalog price, activation or availability';
    end if;
    if (select count(*) from public.hearth_render_registry r join public.cosmetics c on c.id=r.cosmetic_id
      where c.slug in (select jsonb_object_keys(expected_prices)))<>5 then
      raise exception 'Expected five generic furnishings';
    end if;
    insert into auth.users(id,email) values(v_uid,'hallowed-ci@example.test');
    update public.users set coin_balance=2000,adventurer_archetype='wanderer',avatar_body_type='neutral' where id=v_uid;
    perform set_config('request.jwt.claim.sub',v_uid::text,true);
    for item in select * from public.cosmetics where slug in (select jsonb_object_keys(expected_prices)) order by slug loop
      -- Inactive catalog staging must never sell, even with direct RPC calls.
      begin
        perform public.purchase_cosmetic(item.id);
        raise exception 'Inactive item was purchasable';
      exception when others then
        if sqlerrm<>'cosmetic not found' then raise; end if;
      end;
      update public.cosmetics set active=true,availability_start=statement_timestamp()+interval '1 hour',
        availability_end=statement_timestamp()+interval '2 hours' where id=item.id;
      begin
        perform public.purchase_cosmetic(item.id);
        raise exception 'Future item was purchasable';
      exception when others then
        if sqlerrm<>'cosmetic outside purchase availability' then raise; end if;
      end;
      -- Equality at end is closed, equality at start is open.
      update public.cosmetics set availability_start=null,availability_end=statement_timestamp() where id=item.id;
      begin
        perform public.purchase_cosmetic(item.id);
        raise exception 'Expired item was purchasable';
      exception when others then
        if sqlerrm<>'cosmetic outside purchase availability' then raise; end if;
      end;
      update public.cosmetics set availability_start=statement_timestamp(),availability_end=null where id=item.id;
      select * into strict result from public.purchase_cosmetic(item.id);
      if result.already_owned then raise exception 'Unexpected previous ownership'; end if;
      v_balance := result.remaining_coins;
      update public.cosmetics set availability_end=statement_timestamp() where id=item.id;
      -- Lost-response retry after cutoff neither charges twice nor fails.
      select * into strict result from public.purchase_cosmetic(item.id);
      if not result.already_owned or result.remaining_coins<>v_balance then raise exception 'Retry after cutoff changed balance'; end if;
      -- Ownership still permits place, unplace and restoration after cutoff.
      perform public.place_hearth_cosmetic(item.id,case item.hearth_profile_key
        when 'hearth_setting' then 'setting' when 'seating' then 'front'
        when 'side_table' then 'side' when 'large_furniture' then 'right'
        when 'floor_rug' then 'floor' when 'wall_art_side' then 'wall_left' end,null);
      perform public.unequip_cosmetic(item.id);
      perform public.place_hearth_cosmetic(item.id,case item.hearth_profile_key
        when 'hearth_setting' then 'setting' when 'seating' then 'front'
        when 'side_table' then 'side' when 'large_furniture' then 'right'
        when 'floor_rug' then 'floor' when 'wall_art_side' then 'wall_left' end,null);
    end loop;
    if (select coin_balance from public.users where id=v_uid)<>1260 then raise exception 'Expected exactly 740 coins charged'; end if;
    if (select count(*) from public.user_cosmetics where user_id=v_uid and equipped)<>6 then raise exception 'Ownership/placement not restored'; end if;
    if (select count(*) from public.reward_events where user_id=v_uid and event_type='cosmetic_purchase')<>6 then raise exception 'Duplicate purchase events'; end if;
    raise exception using errcode='ZX001',message='Rollback passed Halloween scenarios';
  exception when sqlstate 'ZX001' then null;
  end;
  if exists(select 1 from auth.users where id=v_uid) then raise exception 'Synthetic fixture leaked'; end if;
end;
$test$;
