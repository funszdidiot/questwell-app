begin;
-- Synthetic account and all purchases are rolled back; no founder data changes.
select set_config('qa.purchase_uid',gen_random_uuid()::text,true);
insert into auth.users(id,email)
values (current_setting('qa.purchase_uid')::uuid,
  current_setting('qa.purchase_uid')||'@purchase-check.example.invalid');
update public.users set coin_balance=1000
where id=current_setting('qa.purchase_uid')::uuid;
set local role authenticated;
select set_config('request.jwt.claims',json_build_object(
  'sub',current_setting('qa.purchase_uid'),'role','authenticated')::text,true);
do $$
declare
  uid uuid := current_setting('qa.purchase_uid')::uuid;
  item uuid; price int; before_coins int; before_events int;
  old_xp int; old_level int; result record; n int;
begin
  select id,c.price into item,price from public.cosmetics c
    where c.slug='round-scholar-glasses' and active and unlock_method='shop';
  if item is null then raise exception 'Missing test catalog item'; end if;
  select coin_balance,total_xp,level into before_coins,old_xp,old_level
    from public.users where id=uid;
  select count(*) into before_events from public.reward_events
    where user_id=uid and event_type='cosmetic_purchase';

  -- A server transaction aborted after mutation cannot leave a partial charge.
  begin
    perform public.purchase_cosmetic(item);
    raise exception using errcode='QW001', message='Simulated transaction abort';
  exception when sqlstate 'QW001' then null;
  end;
  if (select coin_balance from public.users where id=uid)<>before_coins
    or exists(select 1 from public.user_cosmetics where user_id=uid and cosmetic_id=item)
    or (select count(*) from public.reward_events where user_id=uid and event_type='cosmetic_purchase')<>before_events
  then raise exception 'Aborted purchase left partial state'; end if;

  -- Discard the successful response, as if the connection dropped after commit.
  perform public.purchase_cosmetic(item);
  for n in 1..5 loop
    select * into result from public.purchase_cosmetic(item);
    if not result.already_owned or result.remaining_coins<>before_coins-price then
      raise exception 'Retry was not idempotent';
    end if;
  end loop;
  if (select count(*) from public.user_cosmetics where user_id=uid and cosmetic_id=item)<>1
    or (select coin_balance from public.users where id=uid)<>before_coins-price
    or (select count(*) from public.reward_events where user_id=uid and event_type='cosmetic_purchase')<>before_events+1
  then raise exception 'Wrong ownership, balance, or event count after retry'; end if;
  if (select total_xp<>old_xp or level<>old_level from public.users where id=uid) then
    raise exception 'Purchase changed XP or level';
  end if;
end $$;
reset role;
-- Insufficient balance must not grant another item or record a charge.
update public.users set coin_balance=0 where id=current_setting('qa.purchase_uid')::uuid;
set local role authenticated;
do $$
declare item uuid; denied bool:=false; uid uuid:=current_setting('qa.purchase_uid')::uuid;
begin
  select id into item from public.cosmetics where slug='leather-satchel';
  begin perform public.purchase_cosmetic(item);
  exception when others then
    if sqlerrm<>'not enough coins' then raise; end if;
    denied:=true;
  end;
  if not denied or exists(select 1 from public.user_cosmetics where user_id=uid and cosmetic_id=item)
    or (select coin_balance from public.users where id=uid)<>0
    or (select count(*) from public.reward_events where user_id=uid and event_type='cosmetic_purchase')<>1
  then raise exception 'Insufficient funds changed purchase state'; end if;
end $$;
select 'PASS: transaction abort, lost-response retries, one debit/item/event, unchanged XP, insufficient funds' as verification;
rollback;
