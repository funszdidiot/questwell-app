-- Disposable CI only; the enclosing transaction restores all synthetic state.
do $evergreen$
declare
  owner_id uuid := gen_random_uuid();
  other_id uuid := gen_random_uuid();
  item record; bought record; slot text; occupant uuid; guardian_id uuid;
  lab_id uuid; keep_id uuid; denied boolean; state jsonb; saved jsonb;
  gallery jsonb; layout jsonb; body text;
begin
  if (select count(*) from public.cosmetics where collection_key='evergreen-hearth'
      and not active and not premium and edition_type='standard'
      and availability_start is null and availability_end is null
      and unlock_method='shop' and milestone_level is null) <> 5 then
    raise exception 'Expected five inactive permanent shop candidates';
  end if;
  if (select count(*) from public.hearth_profile_slots where profile_key='wall_textile'
      and slot_key in ('wall_left','wall_center','wall_right')) <> 3 then
    raise exception 'All three wall slots required';
  end if;
  insert into auth.users(id,email) values(owner_id,'evergreen-owner@example.test'),
    (other_id,'evergreen-other@example.test');
  update public.users set coin_balance=2000,adventurer_archetype='guardian',
    avatar_body_type='neutral' where id in (owner_id,other_id);
  perform set_config('request.jwt.claim.sub',owner_id::text,true);
  for item in select * from public.cosmetics where collection_key='evergreen-hearth' loop
    denied := false;
    begin perform public.purchase_cosmetic(item.id);
    exception when others then
      if sqlerrm <> 'cosmetic not found' then raise; end if;
      denied := true;
    end;
    if not denied then raise exception 'Inactive item purchased'; end if;
    if item.price <> (case when item.category='wall_art' then 120 else 300 end)
      or item.required_archetype is distinct from
        (case when item.slug='guardians-oath-tapestry' then 'guardian'::text else null::text end) then
      raise exception 'Candidate pricing or eligibility changed';
    end if;
    foreach body in array array['female','neutral','male'] loop
      if not private.cosmetic_supports_body(item.slug,body) then
        raise exception 'Hearth decor must support every body';
      end if;
    end loop;
  end loop;
  -- Activation is synthetic and rolled back; this is not a release script.
  update public.cosmetics set active=true where collection_key='evergreen-hearth';
  select id into guardian_id from public.cosmetics where slug='guardians-oath-tapestry';
  select id into lab_id from public.cosmetics where slug='mad-alchemists-lab';
  select id into keep_id from public.cosmetics where slug='guardians-keep';
  update public.users set adventurer_archetype='wanderer' where id=owner_id;
  denied := false;
  begin perform public.purchase_cosmetic(guardian_id);
  exception when others then
    if sqlerrm <> 'cosmetic restricted to guardian archetype' then raise; end if;
    denied := true;
  end;
  if not denied then raise exception 'Non-Guardian purchase succeeded'; end if;
  update public.users set adventurer_archetype='guardian' where id=owner_id;
  for item in select * from public.cosmetics where collection_key='evergreen-hearth' order by slug loop
    select * into strict bought from public.purchase_cosmetic(item.id);
    if bought.already_owned then raise exception 'Unexpected initial ownership'; end if;
    select * into strict bought from public.purchase_cosmetic(item.id);
    if not bought.already_owned then raise exception 'Purchase retry double charged'; end if;
    if item.category='wall_art' then
      foreach slot in array array['wall_left','wall_center','wall_right'] loop
        select cosmetic_id into occupant from public.user_cosmetics
          where user_id=owner_id and equipped and room_slot=slot;
        perform public.place_hearth_cosmetic(item.id,slot,occupant);
        perform public.unequip_cosmetic(item.id);
      end loop;
      denied := false;
      begin perform public.place_hearth_cosmetic(item.id,'floor',null);
      exception when others then
        if sqlerrm <> 'item does not fit this room spot' then raise; end if;
        denied := true;
      end;
      if not denied then raise exception 'Textile placed on floor'; end if;
    end if;
  end loop;
  if (select coin_balance from public.users where id=owner_id) <> 1040
    or (select count(*) from public.reward_events where user_id=owner_id and event_type='cosmetic_purchase') <> 5 then
    raise exception 'Expected five purchases totaling 960 coins';
  end if;
  select jsonb_build_object('wall_left',min(id::text) filter(where slug='hearthwoven-macrame'),
    'wall_center',min(id::text) filter(where slug='guardians-oath-tapestry'),
    'wall_right',min(id::text) filter(where slug='woodland-path-tapestry')) into gallery
    from public.cosmetics where collection_key='evergreen-hearth';
  state := public.read_hearth_layouts();
  saved := public.save_hearth_layout(state->'current',(state->>'revision')::bigint,gallery);
  foreach occupant in array array[lab_id,keep_id] loop
    layout := gallery || jsonb_build_object('setting',occupant::text);
    saved := public.save_hearth_layout(saved->'current',(saved->>'revision')::bigint,layout);
    if public.read_hearth_layouts()->'current' <> layout then raise exception 'Room gallery reload differs'; end if;
  end loop;
  layout := saved->'rooms'->(lab_id::text);
  saved := public.save_hearth_layout(saved->'current',(saved->>'revision')::bigint,layout);
  if saved->'current' <> (gallery || jsonb_build_object('setting',lab_id::text)) then
    raise exception 'Lab gallery recall differs';
  end if;
  -- Class change must not allow either placement API to re-equip Guardian art.
  update public.users set adventurer_archetype='wanderer' where id=owner_id;
  state := public.read_hearth_layouts();
  denied := false;
  begin perform public.place_hearth_cosmetic(guardian_id,'wall_center',guardian_id);
  exception when others then
    if sqlerrm <> 'class restricted' then raise; end if;
    denied := true;
  end;
  if not denied then raise exception 'Non-Guardian equipped tapestry'; end if;
  denied := false;
  begin perform public.save_hearth_layout(state->'current',(state->>'revision')::bigint,gallery);
  exception when others then
    if sqlerrm <> 'decoration does not fit this spot or class' then raise; end if;
    denied := true;
  end;
  if not denied or public.read_hearth_layouts() <> state then
    raise exception 'Rejected class save mutated state';
  end if;
  if (select count(*) from public.user_cosmetics where user_id=owner_id) <> 5 then
    raise exception 'Class or room change lost ownership';
  end if;
  perform set_config('request.jwt.claim.sub',other_id::text,true);
  if public.read_hearth_layouts()->'current' <> '{}'::jsonb then raise exception 'Layout leaked across users'; end if;
  denied := false;
  begin perform public.place_hearth_cosmetic(guardian_id,'wall_center',null);
  exception when others then
    if sqlerrm <> 'room item not owned or unavailable' then raise; end if;
    denied := true;
  end;
  if not denied then raise exception 'Unowned tapestry equipped'; end if;
end;
$evergreen$;
