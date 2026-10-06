do $test$
declare p record; r text; v_index text; v_plan json;
begin
  foreach r in array array['tasks','boss_battles'] loop
    v_index := case r when 'tasks' then 'tasks_chronicle_owner_idx' else 'bosses_chronicle_owner_idx' end;
    if not exists (
      select 1 from pg_index i join pg_class c on c.oid=i.indexrelid
      where i.indrelid = ('public.' || r)::regclass
        and c.relname = v_index
        and i.indisvalid and i.indisready
        and pg_get_expr(i.indpred,i.indrelid) = '(status = ''completed''::text)'
        and pg_get_indexdef(i.indexrelid,1,true) = 'user_id'
    ) then raise exception 'Missing valid completed-owner index for %',r; end if;
    -- Index usability proof, not a production latency/load claim. Discourage a
    -- sequential scan so tiny empty fixtures do not mask an unusable predicate.
    perform set_config('enable_seqscan','off',true);
    execute format('explain (format json) select * from public.%I where user_id = %L::uuid and status = ''completed''',r,'00000000-0000-4000-8000-000000000001') into v_plan;
    if v_plan::text not like ('%' || v_index || '%') then
      raise exception 'Chronicle owner predicate cannot use its index for %',r;
    end if;
  end loop;
  perform set_config('enable_seqscan','on',true);
  select * into strict p from pg_proc where oid = 'public.chronicle_totals(timestamptz)'::regprocedure;
  if p.prosecdef or p.provolatile <> 's' or p.proconfig is distinct from array['search_path=""'] then
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
