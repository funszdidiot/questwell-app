do $test$
declare r text;
begin
  if not (select relrowsecurity from pg_class where oid = 'private.boss_creation_requests'::regclass) then
    raise exception 'Boss receipts require RLS';
  end if;
  foreach r in array array['anon','authenticated','service_role'] loop
    if has_table_privilege(r, 'private.boss_creation_requests', 'SELECT,INSERT,UPDATE,DELETE,TRUNCATE') then
      raise exception 'Boss receipts exposed to %', r;
    end if;
  end loop;
  if has_function_privilege('anon','public.create_boss_once(uuid,uuid,text,text[],text)','EXECUTE')
    or has_function_privilege('anon','private.create_boss_once(uuid,uuid,text,text[],text)','EXECUTE') then
    raise exception 'Anonymous boss creation allowed';
  end if;
  if not has_function_privilege('authenticated','public.create_boss_once(uuid,uuid,text,text[],text)','EXECUTE') then
    raise exception 'Authenticated boss creation missing';
  end if;
  if has_table_privilege('authenticated','public.boss_battles','INSERT,UPDATE,DELETE,TRUNCATE')
    or has_table_privilege('authenticated','public.boss_steps','INSERT,UPDATE,DELETE,TRUNCATE') then
    raise exception 'Direct boss write grants regressed';
  end if;
end;
$test$;
