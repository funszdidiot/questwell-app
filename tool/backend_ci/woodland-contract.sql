-- No remote target: executed only by the guarded disposable CI runner.
do $test$
declare body_type text;
begin
  foreach body_type in array array['female','neutral','male'] loop
    if not private.cosmetic_supports_body('woodland-scout-outfit',body_type)
      or not private.cosmetic_supports_body('everyday-adventurer-outfit',body_type) then
      raise exception 'Approved fit unavailable for %',body_type;
    end if;
  end loop;
  if private.cosmetic_supports_body('woodland-scout-outfit',null)
    or private.cosmetic_supports_body('woodland-scout-outfit','invalid') then
    raise exception 'Invalid body gained a Woodland fit';
  end if;
  if has_function_privilege('anon','private.cosmetic_supports_body(text,text)','EXECUTE')
    or has_function_privilege('authenticated','private.cosmetic_supports_body(text,text)','EXECUTE') then
    raise exception 'Private fit predicate exposed to clients';
  end if;
  if exists (select 1 from pg_proc
      where oid='private.cosmetic_supports_body(text,text)'::regprocedure
      and (prosecdef or provolatile<>'i' or proconfig<>array['search_path=""'])) then
    raise exception 'Fit predicate must stay immutable, invoker-only and search-path constrained';
  end if;
  if exists(select 1 from pg_class where oid in
      ('public.users'::regclass,'public.cosmetics'::regclass,'public.user_cosmetics'::regclass)
      and not relrowsecurity) then
    raise exception 'Wardrobe RLS disabled';
  end if;
  if not exists(select 1 from public.cosmetics where slug='woodland-scout-outfit'
      and price=120 and required_archetype='scout' and collection_key='woodland-scout'
      and active and not premium and unlock_method='shop' and edition_type='standard'
      and description like '%female, neutral and male Scout%') then
    raise exception 'Woodland catalog contract changed';
  end if;
  if not exists(select 1 from public.user_cosmetics
      where user_id='10000000-0000-4000-8000-000000000091'
      and cosmetic_id='10000000-0000-4000-8000-000000000001' and equipped and source='shop') then
    raise exception 'Existing neutral ownership/equipment lost';
  end if;
end;
$test$;
