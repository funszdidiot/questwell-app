do $test$
declare p record; r text;
begin
  select * into strict p from pg_proc where oid = 'public.chronicle_totals(timestamptz)'::regprocedure;
  if p.prosecdef or p.provolatile <> 's' or p.proconfig <> array['search_path=""'] then
    raise exception 'Chronicle must be stable, invoker rights, empty search path';
  end if;
  foreach r in array array['anon','service_role'] loop
    if has_function_privilege(r,'public.chronicle_totals(timestamptz)','EXECUTE') then
      raise exception 'Unexpected Chronicle execution by %', r;
    end if;
  end loop;
  if not has_function_privilege('authenticated','public.chronicle_totals(timestamptz)','EXECUTE') then
    raise exception 'Authenticated Chronicle execution missing';
  end if;
  if exists (select 1 from aclexplode(p.proacl) where grantee=0) then
    raise exception 'PUBLIC Chronicle grant';
  end if;
end;
$test$;
