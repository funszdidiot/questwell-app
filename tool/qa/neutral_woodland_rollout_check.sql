-- Run after neutral_woodland_approved_rollout. Only synthetic accounts are touched.
-- Every fixture, purchase, coin change and equipment change is rolled back.
begin;
select set_config('qa.wardrobe_ids',jsonb_build_object(
  'female',gen_random_uuid(),'neutral',gen_random_uuid(),
  'male',gen_random_uuid(),'outsider',gen_random_uuid(),'legacy',gen_random_uuid())::text,true);
insert into auth.users(id,email)
select value::uuid,value||'@approved-wardrobe-check.example.invalid'
from jsonb_each_text(current_setting('qa.wardrobe_ids')::jsonb);
update public.users u
set coin_balance=case when fixture.key='legacy' then 2000 else 500 end,
    avatar_body_type=case when fixture.key='outsider' then 'neutral' when fixture.key='legacy' then 'female' else fixture.key end,
    adventurer_archetype=case when fixture.key='outsider' then 'scholar' else 'scout' end
from jsonb_each_text(current_setting('qa.wardrobe_ids')::jsonb) fixture
where u.id=fixture.value::uuid;

-- Public RPC authorization remains unchanged; the new predicate is private.
do $$
declare rpc text;
begin
  foreach rpc in array array[
    'public.purchase_cosmetic(uuid)','public.equip_cosmetic(uuid)',
    'public.set_avatar_body_type(text)'] loop
    if has_function_privilege('anon',rpc,'EXECUTE')
      or not has_function_privilege('authenticated',rpc,'EXECUTE') then
      raise exception 'RPC authorization drift: %',rpc;
    end if;
  end loop;
  if has_function_privilege('authenticated','private.cosmetic_supports_body(text,text)','EXECUTE')
    or has_function_privilege('anon','private.cosmetic_supports_body(text,text)','EXECUTE') then
    raise exception 'Internal body predicate exposed';
  end if;
end $$;

set local role authenticated;
do $$
declare
  initial_body text; next_body text; v_uid uuid; item uuid;
  everyday uuid; woodland uuid; everyday_price integer; woodland_price integer;
  original_xp integer; original_level integer; result record; legacy_item record; before_coins integer; denied boolean; was_owned boolean;
begin
  select id,price into strict everyday,everyday_price from public.cosmetics
    where slug='everyday-adventurer-outfit' and active and unlock_method='shop'
      and required_archetype is null;
  select id,price into strict woodland,woodland_price from public.cosmetics
    where slug='woodland-scout-outfit' and active and unlock_method='shop'
      and required_archetype='scout' and collection_key='woodland-scout';

  -- Even an authenticated database role needs a genuine identity claim.
  perform set_config('request.jwt.claims','{}',true);
  denied := false;
  begin perform public.purchase_cosmetic(everyday);
  exception when raise_exception then
    if sqlerrm<>'authentication required' then raise; end if;
    denied := true;
  end;
  if not denied then raise exception 'Identity-free purchase accepted'; end if;
  denied := false;
  begin perform public.equip_cosmetic(everyday);
  exception when raise_exception then
    if sqlerrm<>'authentication required' then raise; end if;
    denied := true;
  end;
  if not denied then raise exception 'Identity-free equipment accepted'; end if;
  denied := false;
  begin perform public.set_avatar_body_type('neutral');
  exception when raise_exception then
    if sqlerrm<>'Authentication required' then raise; end if;
    denied := true;
  end;
  if not denied then raise exception 'Identity-free body change accepted'; end if;

  foreach initial_body in array array['female','neutral','male'] loop
    v_uid := (current_setting('qa.wardrobe_ids')::jsonb->>initial_body)::uuid;
    perform set_config('request.jwt.claims',jsonb_build_object(
      'sub',v_uid,'role','authenticated')::text,true);
    select total_xp,level into original_xp,original_level from public.users where id=v_uid;

    -- A first purchase (not just a retry) succeeds on each integrated body.
    select * into result from public.purchase_cosmetic(everyday);
    if result.already_owned or result.remaining_coins<>500-everyday_price then
      raise exception 'Everyday first purchase failed for %',initial_body;
    end if;
    select * into result from public.purchase_cosmetic(everyday);
    if not result.already_owned or result.remaining_coins<>500-everyday_price then
      raise exception 'Everyday retry charged twice for %',initial_body;
    end if;
    perform public.equip_cosmetic(everyday);
    foreach next_body in array array['female','neutral','male'] loop
      perform public.set_avatar_body_type(next_body);
      if not exists(select 1 from public.users where id=v_uid and avatar_body_type=next_body)
        or not exists(select 1 from public.user_cosmetics
          where user_id=v_uid and cosmetic_id=everyday and equipped) then
        raise exception 'Everyday persistence failed during % -> %',initial_body,next_body;
      end if;
    end loop;
    perform public.set_avatar_body_type(initial_body);
    perform public.equip_cosmetic(everyday);
    foreach next_body in array array['scout','scholar','alchemist','guardian','wanderer'] loop
      perform public.set_adventurer_archetype(next_body);
      if not exists(select 1 from public.user_cosmetics where user_id=v_uid
          and cosmetic_id=everyday and equipped) then
        raise exception 'Everyday class persistence failed: %',next_body;
      end if;
    end loop;
    perform public.set_adventurer_archetype('scout');
    perform public.unequip_cosmetic(everyday);
    if not exists(select 1 from public.user_cosmetics
        where user_id=v_uid and cosmetic_id=everyday and not equipped) then
      raise exception 'Everyday removal lost ownership';
    end if;

    -- Unsupported male purchases leave no item or debit.
    perform public.set_avatar_body_type('male');
    denied := false;
    begin perform public.purchase_cosmetic(woodland);
    exception when raise_exception then
      if sqlerrm<>'outfit unavailable for selected body' then raise; end if;
      denied := true;
    end;
    if not denied or exists(select 1 from public.user_cosmetics
        where user_id=v_uid and cosmetic_id=woodland)
      or (select coin_balance from public.users where id=v_uid)<>500-everyday_price then
      raise exception 'Unsupported Woodland purchase changed state';
    end if;

    -- Approved neutral Woodland purchases and equips through public RPCs.
    perform public.set_avatar_body_type('neutral');
    select * into result from public.purchase_cosmetic(woodland);
    if result.already_owned or result.remaining_coins<>500-everyday_price-woodland_price then
      raise exception 'Woodland initial purchase failed';
    end if;
    select * into result from public.purchase_cosmetic(woodland);
    if not result.already_owned or result.remaining_coins<>500-everyday_price-woodland_price then
      raise exception 'Woodland retry charged twice';
    end if;
    perform public.equip_cosmetic(everyday);
    perform public.equip_cosmetic(woodland);
    if (select count(*) from public.user_cosmetics uc
        join public.cosmetics c on c.id=uc.cosmetic_id
        where uc.user_id=v_uid and uc.equipped and c.category='chest')<>1 then
      raise exception 'Chest equipment exclusivity failed';
    end if;
    foreach next_body in array array['female','neutral'] loop
      perform public.set_avatar_body_type(next_body);
      if not exists(select 1 from public.user_cosmetics
          where user_id=v_uid and cosmetic_id=woodland and equipped) then
        raise exception 'Supported Woodland body switch lost equipment';
      end if;
    end loop;
    foreach next_body in array array['male'] loop
      perform public.set_avatar_body_type('female');
      perform public.equip_cosmetic(woodland);
      perform public.set_avatar_body_type(next_body);
      if not exists(select 1 from public.user_cosmetics
          where user_id=v_uid and cosmetic_id=woodland and not equipped) then
        raise exception 'Unsupported body switch lost ownership or retained equipment';
      end if;
      denied := false;
      begin perform public.equip_cosmetic(woodland);
      exception when raise_exception then
        if sqlerrm<>'outfit unavailable for selected body' then raise; end if;
        denied := true;
      end;
      if not denied then raise exception 'Unsupported Woodland equip accepted: %',next_body; end if;
      denied := false;
      begin perform public.purchase_cosmetic(woodland);
      exception when raise_exception then
        if sqlerrm<>'outfit unavailable for selected body' then raise; end if;
        denied := true;
      end;
      if not denied then raise exception 'Unsupported owned Woodland purchase accepted: %',next_body; end if;
    end loop;

    -- Class changes still enforce the catalog's Scout requirement.
    perform public.set_avatar_body_type('female');
    perform public.equip_cosmetic(woodland);
    perform public.set_adventurer_archetype('scholar');
    if not exists(select 1 from public.user_cosmetics
        where user_id=v_uid and cosmetic_id=woodland and not equipped) then
      raise exception 'Class switch lost ownership or retained restricted outfit';
    end if;
    denied := false;
    begin perform public.equip_cosmetic(woodland);
    exception when raise_exception then
      if sqlerrm<>'cosmetic restricted' then raise; end if;
      denied := true;
    end;
    if not denied then raise exception 'Non-Scout Woodland equip accepted'; end if;
    perform public.equip_cosmetic(everyday);
    if not exists(select 1 from public.user_cosmetics
        where user_id=v_uid and cosmetic_id=everyday and equipped) then
      raise exception 'Everyday all-class equipment failed';
    end if;
    perform public.set_adventurer_archetype('scout');
    perform public.equip_cosmetic(woodland);

    -- Invalid body input cannot partially change profile or equipment.
    foreach next_body in array array['invalid',null] loop
      denied := false;
      begin perform public.set_avatar_body_type(next_body);
      exception when raise_exception then
        if sqlerrm<>'Unsupported avatar body type' then raise; end if;
        denied := true;
      end;
      if not denied or not exists(select 1 from public.users
          where id=v_uid and avatar_body_type='female')
        or not exists(select 1 from public.user_cosmetics
          where user_id=v_uid and cosmetic_id=woodland and equipped) then
        raise exception 'Invalid body input changed state';
      end if;
    end loop;
    if (select coin_balance from public.users where id=v_uid)<>500-everyday_price-woodland_price
      or (select count(*) from public.reward_events
          where user_id=v_uid and event_type='cosmetic_purchase')<>2
      or (select sum(coin_amount) from public.reward_events
          where user_id=v_uid and event_type='cosmetic_purchase')<>-everyday_price-woodland_price
      or (select total_xp<>original_xp or level<>original_level from public.users where id=v_uid)
      or (select count(*) from public.user_cosmetics
          where user_id=v_uid and cosmetic_id in (everyday,woodland))<>2 then
      raise exception 'Economy, progression or ownership changed unexpectedly';
    end if;
  end loop;

  -- Legacy male chest availability and ownership remain intact on v3.
  v_uid := (current_setting('qa.wardrobe_ids')::jsonb->>'legacy')::uuid;
  perform set_config('request.jwt.claims',jsonb_build_object(
    'sub',v_uid,'role','authenticated')::text,true);
  for legacy_item in select id,slug,price,required_archetype from public.cosmetics
      where slug in ('starter-business-suit','midnight-harvest-coat','moss-green-cloak','hearthguard-mantle') loop
    perform public.set_avatar_body_type('male');
    perform public.set_adventurer_archetype(coalesce(legacy_item.required_archetype,'scout'));
    select coin_balance into before_coins from public.users where id=v_uid;
    select exists(select 1 from public.user_cosmetics where user_id=v_uid
      and cosmetic_id=legacy_item.id) into was_owned;
    select * into result from public.purchase_cosmetic(legacy_item.id);
    if result.already_owned is distinct from was_owned
      or result.remaining_coins<>before_coins-(case when was_owned then 0 else legacy_item.price end) then
      raise exception 'Legacy male first purchase failed: %',legacy_item.slug;
    end if;
    select * into result from public.purchase_cosmetic(legacy_item.id);
    if not result.already_owned or result.remaining_coins<>before_coins-legacy_item.price then
      raise exception 'Legacy male retry charged twice: %',legacy_item.slug;
    end if;
    perform public.equip_cosmetic(legacy_item.id);
    foreach next_body in array array['female','neutral','male'] loop
      perform public.set_avatar_body_type(next_body);
      if not exists(select 1 from public.user_cosmetics where user_id=v_uid
          and cosmetic_id=legacy_item.id and equipped) then
        raise exception 'Legacy supported body switch changed equipment: %/%',legacy_item.slug,next_body;
      end if;
    end loop;
    perform public.unequip_cosmetic(legacy_item.id);
    if not exists(select 1 from public.user_cosmetics where user_id=v_uid
        and cosmetic_id=legacy_item.id and not equipped) then
      raise exception 'Legacy unequip lost ownership: %',legacy_item.slug;
    end if;
  end loop;

  -- A separate unowned, non-Scout identity cannot borrow another user's item.
  v_uid := (current_setting('qa.wardrobe_ids')::jsonb->>'outsider')::uuid;
  perform set_config('request.jwt.claims',jsonb_build_object(
    'sub',v_uid,'role','authenticated')::text,true);
  perform public.set_avatar_body_type('female');
  denied := false;
  begin perform public.equip_cosmetic(everyday);
  exception when raise_exception then
    if sqlerrm<>'cosmetic not owned' then raise; end if;
    denied := true;
  end;
  if not denied then raise exception 'Unowned equipment accepted'; end if;
  denied := false;
  begin perform public.purchase_cosmetic(woodland);
  exception when raise_exception then
    if sqlerrm<>'cosmetic restricted to scout archetype' then raise; end if;
    denied := true;
  end;
  if not denied or exists(select 1 from public.user_cosmetics
      where user_id=v_uid and cosmetic_id in (everyday,woodland))
    or (select coin_balance from public.users where id=v_uid)<>500
    or exists(select 1 from public.reward_events
      where user_id=v_uid and event_type='cosmetic_purchase') then
    raise exception 'Unowned/class-restricted operation changed state';
  end if;
  if exists(select 1 from public.user_cosmetics where user_id<>v_uid) then
    raise exception 'Inventory RLS leaked another account';
  end if;
end $$;
reset role;
rollback;
select 'PASS: Everyday on all three bodies; all five classes; female and neutral Scout Woodland enabled; four legacy male items remain purchasable/equippable with ownership intact; equip/unequip and body/class persistence; one-charge retries; RLS/ACLs preserved; fixtures rolled back' as result;
