-- Disposable harness only. This wrapper keeps the REAL RPC transaction open
-- after it returns, without changing its locks, count or reward implementation.
do $fixture$ begin
execute $ddl$create function public.ci_complete_boss_step_held(p_step_id uuid, p_marker integer)
returns table(boss_completed boolean, xp_awarded integer, coins_awarded integer,
  total_xp integer, coin_balance integer)
language plpgsql security invoker set search_path = '' as $$
begin
  perform pg_catalog.set_config('application_name', 'ci-boss-final-step', true);
  return query select * from public.complete_boss_step(p_step_id);
  perform pg_catalog.pg_advisory_xact_lock(73425, p_marker);
  perform pg_catalog.pg_sleep(3);
end $$ $ddl$;
execute 'revoke all on function public.ci_complete_boss_step_held(uuid,integer) from public, anon';
execute 'grant execute on function public.ci_complete_boss_step_held(uuid,integer) to authenticated';

execute $ddl$create function public.ci_boss_completion_activity() returns jsonb
language sql security definer set search_path = '' as $$
  select pg_catalog.jsonb_build_object(
    'returned', (select count(*) from pg_catalog.pg_locks
      where locktype='advisory' and classid=73425 and granted),
    'waiting', (select count(*) from pg_catalog.pg_stat_activity
      where application_name='ci-boss-final-step' and wait_event_type='Lock'));
$$ $ddl$;
execute 'revoke all on function public.ci_boss_completion_activity() from public, anon, authenticated';
execute 'grant execute on function public.ci_boss_completion_activity() to service_role';
perform pg_catalog.pg_notify('pgrst', 'reload schema');
end $fixture$;
