-- Disposable CI database only. All synthetic users and purchases roll back.
begin;
do $test$
declare
  uid uuid := '70000000-0000-4000-8000-000000000091';
  item record; result record; body text; archetype text; balance integer;
begin
  insert into auth.users(id,email) values(uid,'costumes-ci@example.test');
  perform set_config('request.jwt.claim.sub',uid::text,true);
  update public.users set coin_balance=2000,adventurer_archetype='scout',avatar_body_type='female' where id=uid;
  for item in select * from public.cosmetics where slug in ('midnight-masquerade','pumpkin-court') order by slug loop
    if item.price<>180 or item.category<>'chest' or item.premium or not item.active or item.required_archetype is not null then
      raise exception 'Costume catalog mismatch';
    end if;
    update public.cosmetics set availability_start=statement_timestamp(),availability_end=statement_timestamp()+interval '1 day' where id=item.id;
    select * into strict result from public.purchase_cosmetic(item.id);
    balance := result.remaining_coins;
    if result.already_owned then raise exception 'Unexpected ownership'; end if;
    update public.cosmetics set availability_end=statement_timestamp() where id=item.id;
    select * into strict result from public.purchase_cosmetic(item.id);
    if not result.already_owned or result.remaining_coins<>balance then raise exception 'Duplicate charge after expiry'; end if;
    foreach body in array array['female','neutral','male'] loop
      foreach archetype in array array['scout','scholar','guardian','wanderer','alchemist'] loop
        update public.users set avatar_body_type=body,adventurer_archetype=archetype where id=uid;
        perform public.equip_cosmetic(item.id);
        if not exists(select 1 from public.user_cosmetics where user_id=uid and cosmetic_id=item.id and equipped) then raise exception 'Equipment not persisted'; end if;
        perform public.unequip_cosmetic(item.id);
        if exists(select 1 from public.user_cosmetics where user_id=uid and cosmetic_id=item.id and equipped) then raise exception 'Unequip not persisted'; end if;
        perform public.equip_cosmetic(item.id);
      end loop;
    end loop;
  end loop;
  if (select coin_balance from public.users where id=uid)<>1640 then raise exception 'Expected exactly 360 coins charged'; end if;
  if (select count(*) from public.user_cosmetics where user_id=uid and equipped)<>1 then raise exception 'Chest replacement failed'; end if;
  if (select count(*) from public.user_cosmetics where user_id=uid)<>2 then raise exception 'Ownership lost'; end if;
end;
$test$;
rollback;
