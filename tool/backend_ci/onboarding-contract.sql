do $test$
declare r text;
begin
  if not (select relrowsecurity from pg_class where oid = 'private.onboarding_results'::regclass) then
    raise exception 'Onboarding receipts require RLS';
  end if;
  foreach r in array array['anon','authenticated','service_role'] loop
    if has_table_privilege(r,'private.onboarding_results','SELECT,INSERT,UPDATE,DELETE,TRUNCATE') then
      raise exception 'Onboarding receipts exposed to %',r;
    end if;
  end loop;
  if has_function_privilege('anon','public.finish_onboarding_once(uuid,text)','EXECUTE')
    or has_function_privilege('anon','private.finish_onboarding_once(uuid,text)','EXECUTE') then
    raise exception 'Anonymous onboarding allowed';
  end if;
  if not has_function_privilege('authenticated','public.finish_onboarding_once(uuid,text)','EXECUTE') then
    raise exception 'Authenticated onboarding missing';
  end if;
  if has_column_privilege('authenticated','public.tasks','id','INSERT') then
    raise exception 'Task ID recreation grant regressed';
  end if;
end;
$test$;
