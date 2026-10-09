-- Disposable CI only. The enclosing transaction rolls back synthetic accounts.
do $test$
declare
  uid uuid := gen_random_uuid();
  item record; bought record; body text; archetype text;
begin
  if (select count(*) from public.cosmetics where slug in ('boston-terrier','hearth-cat')
    and category='familiar' and active and rarity='rare' and price=180
    and not premium and required_archetype is null and unlock_method='shop'
    and edition_type='standard' and availability_end is null)<>2 then
    raise exception 'Household familiar price or eligibility differs';
  end if;
  insert into auth.users(id,email) values(uid,'household-ci@example.test');
  update public.users set coin_balance=1000,adventurer_archetype='scout',avatar_body_type='female' where id=uid;
  perform set_config('request.jwt.claim.sub',uid::text,true);
  for item in select * from public.cosmetics where slug in ('boston-terrier','hearth-cat') order by slug loop
    set local role authenticated;
    select * into strict bought from public.purchase_cosmetic(item.id);
    if bought.already_owned then raise exception 'Unexpected ownership'; end if;
    select * into strict bought from public.purchase_cosmetic(item.id);
    if not bought.already_owned then raise exception 'Purchase retry duplicated'; end if;
    reset role;
    foreach body in array array['female','neutral','male'] loop
      foreach archetype in array array['scout','scholar','guardian','wanderer','alchemist'] loop
        update public.users set avatar_body_type=body,adventurer_archetype=archetype where id=uid;
        set local role authenticated;
        perform public.equip_cosmetic(item.id);
        if not exists(select 1 from public.user_cosmetics where user_id=uid and cosmetic_id=item.id and equipped) then
          raise exception 'Equipment not persisted';
        end if;
        perform public.unequip_cosmetic(item.id);
        if exists(select 1 from public.user_cosmetics where user_id=uid and cosmetic_id=item.id and equipped) then
          raise exception 'Unequip not persisted';
        end if;
        perform public.equip_cosmetic(item.id);
        reset role;
      end loop;
    end loop;
  end loop;
  set local role authenticated;
  if (select coin_balance from public.users where id=uid)<>640 then raise exception 'Expected exactly 360 coins charged'; end if;
  if (select count(*) from public.user_cosmetics where user_id=uid)<>2 then raise exception 'Ownership lost'; end if;
  if (select count(*) from public.user_cosmetics where user_id=uid and equipped)<>1 then raise exception 'Familiar replacement failed'; end if;
  reset role;
  if (select count(*) from public.reward_events where user_id=uid and event_type='cosmetic_purchase')<>2 then
    raise exception 'Duplicate purchase events';
  end if;
end;
$test$;
