-- Synthetic-only fixture, invoked in the disposable CI transaction and rolled back.
do $test$
declare
  owner_id uuid := gen_random_uuid(); other_id uuid := gen_random_uuid();
  furniture uuid := gen_random_uuid(); chair uuid := gen_random_uuid(); setting uuid := gen_random_uuid();
  relic uuid := gen_random_uuid(); outfit uuid := gen_random_uuid();
  state jsonb; original jsonb; target jsonb; saved jsonb;
begin
  insert into auth.users(id,email) values(owner_id,'decorator-a@example.test'),(other_id,'decorator-b@example.test');
  insert into public.cosmetics(id,slug,name,category,rarity,description,price,hearth_profile_key)
    values(furniture,'decorator-fixture-cabinet','Cabinet','room','common','fixture',0,'large_furniture'),
      (chair,'decorator-fixture-chair','Chair','room','common','fixture',0,'seating'),
      (setting,'decorator-fixture-room','Room','room','common','fixture',0,'hearth_setting'),
      (relic,'decorator-fixture-relic','Relic','room','common','fixture',0,'relic_display'),
      (outfit,'decorator-fixture-outfit','Outfit','chest','common','fixture',0,null);
  insert into public.user_cosmetics(user_id,cosmetic_id,source,equipped)
    values(owner_id,furniture,'shop',false),(owner_id,chair,'shop',false),(owner_id,setting,'shop',false),
      (owner_id,relic,'shop',false),(owner_id,outfit,'shop',false);
  perform set_config('questwell.test_owner',owner_id::text,true);
  perform set_config('request.jwt.claim.sub',owner_id::text,true);
  state := public.read_hearth_layouts();
  original := jsonb_build_object('right',furniture::text,'front',chair::text);
  saved := public.save_hearth_layout(state->'current',0,original);
  if saved->'current' <> original or (saved->>'revision')::int <> 1 then raise exception 'save failed'; end if;
  target := jsonb_build_object('setting',setting::text,'left',furniture::text);
  saved := public.save_hearth_layout(original,1,jsonb_build_object('setting',upper(setting::text),'left',furniture::text));
  if saved->'current' <> target then raise exception 'UUID normalization failed'; end if;
  if saved->'rooms'->'original' <> original then raise exception 'original layout lost'; end if;
  saved := public.save_hearth_layout(target,2,saved->'rooms'->'original');
  if saved->'current' <> original or saved->'rooms'->setting::text <> target then raise exception 'room recall failed'; end if;
  -- Stale clients, unowned items, illegal slots and crowding leave all state intact.
  begin
    perform public.save_hearth_layout(original,1,'{}');
    raise exception 'stale save accepted';
  exception when others then if sqlerrm <> 'room changed; reopen the decorator' then raise; end if; end;
  begin
    perform public.save_hearth_layout('{}',3,original);
    raise exception 'stale current accepted';
  exception when others then if sqlerrm <> 'room changed; reopen the decorator' then raise; end if; end;
  begin
    perform public.save_hearth_layout(original,3,jsonb_build_object('left',furniture::text,'right',furniture::text));
    raise exception 'duplicate accepted';
  exception when others then if sqlerrm <> 'an item can occupy only one spot' then raise; end if; end;
  begin
    perform public.save_hearth_layout(original,3,jsonb_build_object('left',furniture::text,'right',upper(furniture::text)));
    raise exception 'mixed-case duplicate accepted';
  exception when others then if sqlerrm <> 'an item can occupy only one spot' then raise; end if; end;
  begin
    perform public.save_hearth_layout(original,3,jsonb_build_object('right',gen_random_uuid()::text));
    raise exception 'unowned save accepted';
  exception when others then if sqlerrm <> 'decoration not owned' then raise; end if; end;
  begin
    perform public.save_hearth_layout(original,3,jsonb_build_object('wall_center',furniture::text));
    raise exception 'invalid spot accepted';
  exception when others then if sqlerrm <> 'decoration does not fit this spot or class' then raise; end if; end;
  begin
    perform public.save_hearth_layout(original,3,jsonb_build_object('left',furniture::text,'front',chair::text));
    raise exception 'crowding accepted';
  exception when others then if sqlerrm <> 'left chair and large furniture overlap' then raise; end if; end;
  if public.read_hearth_layouts() <> saved then raise exception 'failure partially changed layout'; end if;
  begin
    perform public.save_hearth_layout(original,3,jsonb_build_object('bookshelf_top',relic::text));
    raise exception 'dependency bypassed';
  exception when others then if sqlerrm <> 'required Hearth furniture is not placed' then raise; end if; end;
  begin
    perform public.save_hearth_layout(original,3,jsonb_build_object('right',outfit::text));
    raise exception 'outfit placed';
  exception when others then if sqlerrm <> 'decoration not owned' then raise; end if; end;
  update public.cosmetics set required_archetype='guardian' where id=furniture;
  begin
    perform public.save_hearth_layout(original,3,jsonb_build_object('left',furniture::text));
    raise exception 'class restriction bypassed';
  exception when others then if sqlerrm <> 'decoration does not fit this spot or class' then raise; end if; end;
  update public.cosmetics set required_archetype=null,active=false where id=furniture;
  begin
    perform public.save_hearth_layout(original,3,jsonb_build_object('left',furniture::text));
    raise exception 'retired moved';
  exception when others then if sqlerrm <> 'decoration does not fit this spot or class' then raise; end if; end;
  saved := public.save_hearth_layout(original,3,original);
  if saved->'current' <> original then raise exception 'retired placement lost'; end if;
  perform set_config('request.jwt.claim.sub',other_id::text,true);
  state := public.read_hearth_layouts();
  if state->'current' <> '{}' or state->'rooms' <> '{}' then raise exception 'cross-owner read'; end if;
  begin
    perform public.save_hearth_layout('{}',0,original);
    raise exception 'cross-owner write';
  exception when others then if sqlerrm <> 'decoration not owned' then raise; end if; end;
  if has_function_privilege('anon','public.read_hearth_layouts()','execute')
    or has_function_privilege('anon','public.save_hearth_layout(jsonb,bigint,jsonb)','execute')
    or has_function_privilege('anon','private.read_hearth_layouts()','execute')
    or has_function_privilege('anon','private.save_hearth_layout(jsonb,bigint,jsonb)','execute')
    or has_table_privilege('authenticated','private.hearth_saved_layouts','select,insert,update,delete') then
    raise exception 'unexpected layout privileges';
  end if;
  if not (select relrowsecurity from pg_class where oid='private.hearth_saved_layouts'::regclass) then
    raise exception 'missing RLS';
  end if;
  perform set_config('request.jwt.claim.sub','',true);
  begin
    perform public.read_hearth_layouts();
    raise exception 'anonymous read';
  exception when others then if sqlerrm <> 'authentication required' then raise; end if; end;
end $test$;
-- Exercise the public wrappers with the actual client database role.
set local role authenticated;
select set_config('request.jwt.claim.sub', current_setting('questwell.test_owner'), true);
do $client$
declare state jsonb; saved jsonb;
begin
  state := public.read_hearth_layouts();
  saved := public.save_hearth_layout(state->'current', (state->>'revision')::bigint, state->'current');
  if saved->'current' <> state->'current'
    or (saved->>'revision')::bigint <> (state->>'revision')::bigint + 1 then
    raise exception 'authenticated wrapper contract failed';
  end if;
end $client$;
reset role;
rollback;
