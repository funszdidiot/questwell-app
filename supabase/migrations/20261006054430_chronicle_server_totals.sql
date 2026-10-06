-- C11b proposal. G3: separate exact-scope approval before live deployment.
-- Retained completed-history totals, not wallet balances or a lifetime ledger.
begin;
set local lock_timeout = '3s';
set local statement_timeout = '20s';

-- Bound reads to one owner's completed history, including when other accounts
-- accumulate large histories. Additive partial indexes; no reward/data rewrite.
create index tasks_chronicle_owner_idx on public.tasks (user_id)
  where status = 'completed';
create index bosses_chronicle_owner_idx on public.boss_battles (user_id)
  where status = 'completed';

create function public.chronicle_totals(p_week_start timestamptz)
returns jsonb
language plpgsql stable security invoker set search_path = ''
as $function$
declare
  v_owner uuid := auth.uid();
  v_result jsonb;
  v_invalid boolean;
begin
  if v_owner is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  -- Client sends its local Monday midnight as an absolute timestamp. No server
  -- timezone assumption or artificial upper bound changes existing week semantics.
  if p_week_start is null or not pg_catalog.isfinite(p_week_start) then
    raise exception 'A finite week boundary is required' using errcode = '22023';
  end if;
  -- Both sources and every total share one statement snapshot. Explicit owner
  -- predicates supplement unchanged RLS; this function never bypasses RLS.
  with activities as (
    select t.xp_value as xp, t.coin_value as coins, t.completed_at, false as boss
      from public.tasks t where t.user_id = v_owner and t.status = 'completed'
    union all
    select b.reward_xp, b.reward_coins, b.completed_at, true
      from public.boss_battles b where b.user_id = v_owner and b.status = 'completed'
  )
  select pg_catalog.jsonb_build_object(
    'owner_id', v_owner,
    'week_start', p_week_start,
    -- Decimal strings preserve exact aggregates in browser JSON decoders.
    'total_xp_earned', coalesce(sum(xp), 0)::text,
    'total_coins_earned', coalesce(sum(coins), 0)::text,
    'week_wins', count(*) filter (where completed_at >= p_week_start)::text,
    'bosses_defeated', count(*) filter (where boss)::text
  ), coalesce(bool_or(completed_at is null or not pg_catalog.isfinite(completed_at)), false)
  into v_result, v_invalid from activities;
  if v_invalid then
    raise exception 'Completed history has an invalid timestamp' using errcode = '22023';
  end if;
  return v_result;
end;
$function$;
alter function public.chronicle_totals(timestamptz) owner to postgres;
revoke all on function public.chronicle_totals(timestamptz) from public, anon, authenticated, service_role;
grant execute on function public.chronicle_totals(timestamptz) to authenticated;
comment on function public.chronicle_totals(timestamptz) is
  'Owner-only retained completed-history totals in one statement snapshot; decimal strings; local-week boundary supplied by caller.';
notify pgrst, 'reload schema';
commit;
