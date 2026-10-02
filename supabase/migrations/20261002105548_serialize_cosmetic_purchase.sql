-- Ownership must be read after the profile lock: overlapping retries then see
-- the first request's committed item instead of a stale pre-lock ownership flag.
create or replace function private.purchase_cosmetic(p_cosmetic_id uuid)
returns table(cosmetic_id uuid, remaining_coins integer, already_owned boolean)
language plpgsql security definer set search_path = ''
as $function$
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
-- Existing wrapper and grants are preserved. No new API or client privilege.
