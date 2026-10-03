begin;
update public.cosmetics set active=true where slug in ('woodland-scout-outfit','everyday-adventurer-outfit');
select set_config('qa.wardrobe_uid',gen_random_uuid()::text,true);
insert into auth.users(id,email) values(current_setting('qa.wardrobe_uid')::uuid,current_setting('qa.wardrobe_uid')||'@wardrobe.example.invalid');
update public.users set coin_balance=500,avatar_body_type='female',adventurer_archetype='scout' where id=current_setting('qa.wardrobe_uid')::uuid;
set local role authenticated;
select set_config('request.jwt.claims',json_build_object('sub',current_setting('qa.wardrobe_uid'),'role','authenticated')::text,true);
do $$ declare item uuid; v_slug text; result record; begin
 for v_slug in select unnest(array['woodland-scout-outfit','everyday-adventurer-outfit']) loop
  select c.id into strict item from public.cosmetics c where c.slug=v_slug;
  perform public.purchase_cosmetic(item);
  select * into result from public.purchase_cosmetic(item);
  if not result.already_owned then raise exception 'Retry lost ownership'; end if;
  perform public.equip_cosmetic(item);
  if (select count(*) from public.user_cosmetics uc join public.cosmetics c on c.id=uc.cosmetic_id where uc.user_id=auth.uid() and uc.equipped and c.category='chest')<>1 then raise exception 'Outfit slot conflict'; end if;
  perform public.set_avatar_body_type('male');
  if exists(select 1 from public.user_cosmetics where user_id=auth.uid() and cosmetic_id=item and equipped) then raise exception 'Body switch retained unsupported fit'; end if;
  begin
   perform public.equip_cosmetic(item);
   raise exception 'Unsupported equip accepted';
  exception when raise_exception then
   if sqlerrm<>'outfit requires female body' then raise; end if;
  end;
  begin
   perform public.purchase_cosmetic(item);
   raise exception 'Unsupported purchase accepted';
  exception when raise_exception then
   if sqlerrm<>'outfit requires female body' then raise; end if;
  end;
  perform public.set_avatar_body_type('female');
  perform public.equip_cosmetic(item);
  perform public.unequip_cosmetic(item);
  if not exists(select 1 from public.user_cosmetics where user_id=auth.uid() and cosmetic_id=item and not equipped) then raise exception 'Ownership lost'; end if;
 end loop;
 if (select coin_balance from public.users where id=auth.uid())<>340 then raise exception 'Purchase balance mismatch'; end if;
 if (select count(*) from public.reward_events where user_id=auth.uid() and event_type='cosmetic_purchase')<>2 then raise exception 'Duplicate purchase event'; end if;
end $$;
reset role;
rollback;
select 'PASS: both outfits purchase/equip/remove, retry debit protection and body-switch restrictions; fixtures rolled back' as result;
