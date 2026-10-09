-- Scoped forward release; never replay the historical migration chain.
-- Changes only the supported type constraint and creation function.
begin;
set local lock_timeout = '3s';
set local statement_timeout = '20s';
do $release$
declare source text;
begin
  select pg_get_functiondef('private.create_boss_battle(text,text[],integer,integer,text)'::regprocedure) into source;
  if md5(source) <> 'f355abc49be4e5890aa89157b7b32cb8' then
    raise exception 'Harvest creation function drift';
  end if;
  if (select pg_get_constraintdef(oid) from pg_constraint where
      conrelid='public.boss_battles'::regclass and conname='boss_battles_boss_type_check')
      is distinct from $constraint$CHECK ((boss_type = ANY (ARRAY['inbox_hydra'::text, 'meeting_mimic'::text, 'spreadsheet_slime'::text, 'calendar_kraken'::text, 'printer_poltergeist'::text, 'notification_swarm'::text, 'ticket_troll'::text, 'update_dragon'::text])))$constraint$ then
    raise exception 'Harvest boss constraint drift';
  end if;
  if not exists(select 1 from public.cosmetics where slug='hallowed-hearth'
    and active and collection_key='midnight-harvest' and edition_type='seasonal'
    and availability_start=timestamptz '2026-10-08T03:36:53.444481Z'
    and availability_end=timestamptz '2026-11-09T06:00:00Z') then
    raise exception 'Harvest collection window drift';
  end if;
  source := replace(source,
    '''ticket_troll'',''update_dragon''',
    '''ticket_troll'',''update_dragon'',''hollow_harvest''');
  source := replace(source,
    'when ''inbox_hydra'' then 1 when ''meeting_mimic'' then 3',
    'when ''hollow_harvest'' then 1 when ''inbox_hydra'' then 1 when ''meeting_mimic'' then 3');
  source := replace(source, '  -- questwell_boss_unlock_gate_v1:', $gate$
  -- questwell_hollow_harvest_2026: creation only; retries and saved battles survive close.
  if p_boss_type = 'hollow_harvest' and not (
    statement_timestamp() >= timestamptz '2026-10-08T03:36:53.444481Z'
    and statement_timestamp() < timestamptz '2026-11-09T06:00:00Z'
  ) then
    raise exception 'The Hollow Harvest is outside the Halloween season.' using errcode='P0001';
  end if;

  -- questwell_boss_unlock_gate_v1:$gate$);
  alter table public.boss_battles drop constraint boss_battles_boss_type_check;
  alter table public.boss_battles add constraint boss_battles_boss_type_check check (
    boss_type in ('inbox_hydra','meeting_mimic','spreadsheet_slime','calendar_kraken',
      'printer_poltergeist','notification_swarm','ticket_troll','update_dragon','hollow_harvest'));
  execute source;
end;
$release$;
commit;
