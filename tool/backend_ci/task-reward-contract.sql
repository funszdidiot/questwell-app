-- Runs only after the proposed migration in the guarded disposable CI database.
do $test$
declare
  r record;
  role_name text;
  column_name text;
begin
  for r in select * from (values (1,10,5),(2,20,10),(3,35,18),(4,60,30))
    as expected(friction,xp,coins)
  loop
    if not exists (select 1 from private.task_reward_values(r.friction) v
      where v.xp = r.xp and v.coins = r.coins) then
      raise exception 'Approved reward mapping changed';
    end if;
  end loop;
  begin
    perform private.task_reward_values(null);
    raise exception 'Null difficulty was accepted';
  exception when invalid_parameter_value then null;
  end;

  if has_table_privilege('authenticated','public.tasks','INSERT')
    or has_table_privilege('authenticated','public.tasks','UPDATE') then
    raise exception 'Broad task column access remains';
  end if;
  foreach column_name in array array['id','created_at','completed_at'] loop
    if has_column_privilege('authenticated','public.tasks',column_name,'INSERT')
      or has_column_privilege('authenticated','public.tasks',column_name,'UPDATE') then
      raise exception 'Client can forge server-managed column %', column_name;
    end if;
  end loop;
  if has_column_privilege('authenticated','public.tasks','user_id','UPDATE') then
    raise exception 'Client can reassign task ownership';
  end if;
  foreach role_name in array array['anon','authenticated'] loop
    if has_table_privilege(role_name,'public.tasks','TRUNCATE')
      or has_table_privilege(role_name,'public.tasks','TRIGGER')
      or has_table_privilege(role_name,'public.reward_events','TRUNCATE')
      or has_table_privilege(role_name,'public.reward_events','INSERT')
      or has_table_privilege(role_name,'public.reward_events','UPDATE')
      or has_table_privilege(role_name,'public.reward_events','DELETE') then
      raise exception 'Unsafe task/ledger privilege remains for %', role_name;
    end if;
  end loop;
  if has_function_privilege('anon','private.task_reward_values(integer)','EXECUTE')
    or has_function_privilege('anon','private.complete_task(uuid)','EXECUTE') then
    raise exception 'Anonymous access to private reward functions';
  end if;
  if not has_column_privilege('authenticated','public.tasks','pinned_at','UPDATE')
    or not has_column_privilege('authenticated','public.tasks','friction_level','UPDATE')
    or not has_column_privilege('authenticated','public.tasks','title','INSERT')
    or not has_table_privilege('authenticated','public.tasks','DELETE') then
    raise exception 'Legitimate existing task operations lost access';
  end if;
  if exists(select 1 from pg_class where oid in
      ('public.tasks'::regclass,'public.reward_events'::regclass,'public.users'::regclass)
      and not relrowsecurity) then
    raise exception 'Application RLS disabled';
  end if;
  if exists(select 1 from pg_proc where oid in
      ('private.guard_task_write()'::regprocedure,'private.task_reward_values(integer)'::regprocedure)
      and prosecdef) then
    raise exception 'Pure mapping or invoker guard gained definer privileges';
  end if;
end;
$test$;
