-- Guarded disposable CI only. Exercise the private boundary as authenticated,
-- not as a superuser. This does not imply that private is exposed through REST.
do $test$
declare
  owner_id uuid := gen_random_uuid();
  boss_id uuid;
  requested integer;
  xp integer;
  coins integer;
  role_name text;
  table_name text;
  privilege_name text;
begin
  insert into auth.users(id,email,aud,role)
    values(owner_id, 'boss-sql-ci-' || owner_id || '@example.test', 'authenticated', 'authenticated');
  perform set_config('request.jwt.claim.sub', owner_id::text, true);
  perform set_config('request.jwt.claims', json_build_object('sub',owner_id,'role','authenticated')::text, true);
  set local role authenticated;
  foreach requested in array array[2147483647, -10, 0, 10, null, 25] loop
    boss_id := private.create_boss_battle('Private boundary fixture', array['One','Two'], requested, requested, 'inbox_hydra');
    select reward_xp, reward_coins into xp, coins from public.boss_battles where id = boss_id;
    if xp is distinct from 25 or coins is distinct from 50 then
      raise exception 'Private caller controlled saved rewards: XP %, coins %', xp, coins;
    end if;
  end loop;
  reset role;
  delete from auth.users where id = owner_id;

  foreach role_name in array array['anon','authenticated'] loop
    foreach table_name in array array['boss_battles','boss_steps'] loop
      foreach privilege_name in array array['INSERT','UPDATE','DELETE','TRUNCATE','TRIGGER','REFERENCES','MAINTAIN'] loop
        if has_table_privilege(role_name, 'public.' || table_name, privilege_name) then
          raise exception 'Unsafe direct boss privilege remains: % % %', role_name, table_name, privilege_name;
        end if;
      end loop;
    end loop;
  end loop;
  if not has_table_privilege('authenticated','public.boss_battles','SELECT')
    or not has_table_privilege('authenticated','public.boss_steps','SELECT') then
    raise exception 'Existing owner reads lost access';
  end if;
  if exists(select 1 from pg_class where oid in
    ('public.boss_battles'::regclass,'public.boss_steps'::regclass) and not relrowsecurity) then
    raise exception 'Boss RLS disabled';
  end if;
  if has_function_privilege('anon','private.create_boss_battle(text,text[],integer,integer,text)','EXECUTE')
    or has_function_privilege('anon','public.create_boss_battle(text,text[],integer,integer,text)','EXECUTE')
    or has_function_privilege('anon','private.complete_boss_step(uuid)','EXECUTE')
    or has_function_privilege('anon','public.complete_boss_step(uuid)','EXECUTE') then
    raise exception 'Anonymous boss function access';
  end if;
end;
$test$;
