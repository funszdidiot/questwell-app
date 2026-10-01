-- Candidate only. No shared-database rollout is authorized by this file.
-- This dry run always rolls back. Promote through an approved migration later.
begin;
set local lock_timeout = '3s';
set local statement_timeout = '20s';

do $patch$
declare
  definition text := pg_get_functiondef('private.create_boss_battle(text,text[],integer,integer,text)'::regprocedure);
  anchor text := '  insert into public.boss_battles(';
  gate text := $gate$
  -- questwell_boss_unlock_gate_v1: creation only; saved battles remain playable.
  declare
    required_level integer := case p_boss_type
      when 'inbox_hydra' then 1 when 'meeting_mimic' then 3
      when 'spreadsheet_slime' then 5 when 'calendar_kraken' then 7
      when 'printer_poltergeist' then 10 when 'notification_swarm' then 13
      when 'ticket_troll' then 16 when 'update_dragon' then 20
      else null end;
    earned_level integer;
  begin
    if required_level is null then
      raise exception 'Unsupported boss type';
    end if;
    select coalesce(u.level, 1) into earned_level
      from public.users u where u.id = v_user_id;
    if earned_level is null then
      raise exception 'Profile required';
    end if;
    if earned_level < required_level then
      raise exception using message = format('This boss unlocks at level %s.', required_level),
        errcode = 'P0001';
    end if;
  end;

$gate$;
begin
  if position('questwell_boss_unlock_gate_v1' in definition) > 0 then
    raise exception 'Candidate already present; review rather than overwrite';
  end if;
  if position(anchor in definition) = 0 then
    raise exception 'Creation function changed; review candidate before proceeding';
  end if;
  execute replace(definition, anchor, gate || anchor);
end;
$patch$;

do $test$
declare
  fixture uuid := gen_random_uuid();
  item record;
  boss_id uuid;
  rejected boolean;
  expected_xp integer;
begin
  -- Fictional fixture and all function/data changes are transaction-local.
  insert into auth.users(id, email, aud, role)
    values (fixture, 'questwell-boss-gate-test-' || fixture || '@example.invalid', 'authenticated', 'authenticated');
  insert into public.users(id, level, total_xp, level_xp_offset)
    values (fixture, 1, 0, 0) on conflict (id) do nothing;
  perform set_config('request.jwt.claim.sub', fixture::text, true);
  perform set_config('request.jwt.claims', json_build_object('sub', fixture, 'role', 'authenticated')::text, true);

  for item in select * from (values
    ('inbox_hydra',1),('meeting_mimic',3),('spreadsheet_slime',5),('calendar_kraken',7),
    ('printer_poltergeist',10),('notification_swarm',13),('ticket_troll',16),('update_dragon',20)
  ) as gates(kind,required_level) loop
    if item.required_level > 1 then
      expected_xp := 100*(item.required_level-2) + 15*(item.required_level-2)*(item.required_level-3)/2;
      update public.users set level=item.required_level-1, total_xp=expected_xp where id=fixture;
      rejected := false;
      begin
        perform public.create_boss_battle('Locked fixture', array['First step','Second step'],100,50,item.kind);
      exception when raise_exception then
        if sqlerrm = format('This boss unlocks at level %s.',item.required_level) then
          rejected := true;
        else raise;
        end if;
      end;
      if not rejected then raise exception 'Under-level gate failed for %',item.kind; end if;
    end if;
    expected_xp := 100*(item.required_level-1) + 15*(item.required_level-1)*(item.required_level-2)/2;
    update public.users set level=item.required_level,total_xp=expected_xp where id=fixture;
    boss_id := public.create_boss_battle('Unlocked fixture',array['First step','Second step'],100,50,item.kind);
    if not exists(select 1 from public.boss_battles where id=boss_id and user_id=fixture and boss_type=item.kind) then
      raise exception 'Exact-level gate failed for %',item.kind;
    end if;
  end loop;
  if (select count(*) from public.boss_battles where user_id=fixture) <> 8 then
    raise exception 'Unexpected battle count after gate checks';
  end if;
  perform set_config('request.jwt.claim.sub', '', true);
  perform set_config('request.jwt.claims', '{}', true);
  rejected := false;
  begin
    perform public.create_boss_battle('Anonymous fixture',array['First','Second'],100,50,'inbox_hydra');
  exception when raise_exception then
    if sqlerrm = 'Not authenticated' then rejected := true; else raise; end if;
  end;
  if not rejected then raise exception 'Anonymous creation was not rejected'; end if;
end;
$test$;
select '8 exact-level passes, 7 under-level rejections, anonymous rejection; all changes rolled back' as result;
rollback;
