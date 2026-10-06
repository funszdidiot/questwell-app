do $test$
declare r text;
begin
  if not (select relrowsecurity from pg_class where oid = 'private.task_creation_requests'::regclass) then
    raise exception 'Creation receipts require RLS';
  end if;
  foreach r in array array['anon','authenticated','service_role'] loop
    if has_table_privilege(r, 'private.task_creation_requests', 'SELECT,INSERT,UPDATE,DELETE,TRUNCATE') then
      raise exception 'Creation receipts exposed to %', r;
    end if;
  end loop;
  if has_function_privilege('anon','public.create_task_once(uuid,uuid,text,integer)','EXECUTE')
    or has_function_privilege('anon','private.create_task_once(uuid,uuid,text,integer)','EXECUTE') then
    raise exception 'Anonymous creation allowed';
  end if;
  if not has_function_privilege('authenticated','public.create_task_once(uuid,uuid,text,integer)','EXECUTE') then
    raise exception 'Authenticated creation missing';
  end if;
  if has_column_privilege('authenticated','public.tasks','id','INSERT') then
    raise exception 'Task ID recreation grant regressed';
  end if;
end;
$test$;
