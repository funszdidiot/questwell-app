-- Candidate forward change. Do not replay the root migration history.
create table private.hearth_saved_layouts (
  user_id uuid primary key references public.users(id) on delete cascade,
  rooms jsonb not null default '{}'::jsonb check (jsonb_typeof(rooms) = 'object'),
  revision bigint not null default 0 check (revision >= 0)
);
alter table private.hearth_saved_layouts enable row level security;
revoke all on private.hearth_saved_layouts from public, anon, authenticated, service_role;

create function private.read_hearth_layouts() returns jsonb
language plpgsql security definer set search_path = '' as $$
declare v_uid uuid := auth.uid(); v_result jsonb;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  select jsonb_build_object(
    'current', coalesce((select jsonb_object_agg(
      coalesce(uc.room_slot, case when c.category = 'wall_art' then 'wall_center' else 'right' end),
      uc.cosmetic_id::text)
      from public.user_cosmetics uc join public.cosmetics c on c.id = uc.cosmetic_id
      where uc.user_id = v_uid and uc.equipped and c.category in ('room','wall_art')), '{}'::jsonb),
    'rooms', coalesce((select s.rooms from private.hearth_saved_layouts s where s.user_id = v_uid), '{}'::jsonb),
    'revision', coalesce((select s.revision from private.hearth_saved_layouts s where s.user_id = v_uid), 0))
    into v_result;
  return v_result;
end $$;

create function private.save_hearth_layout(
  p_expected_current jsonb, p_expected_revision bigint, p_layout jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_uid uuid := auth.uid(); v_state jsonb; v_current jsonb; v_rooms jsonb;
  v_entry record; v_id uuid; v_revision bigint; v_source text; v_target text;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  if p_layout is null or jsonb_typeof(p_layout) <> 'object'
    or p_expected_current is null or jsonb_typeof(p_expected_current) <> 'object'
    or p_expected_revision is null then raise exception 'invalid layout'; end if;
  if (select count(*) from jsonb_each(p_layout)) > 12 then raise exception 'invalid layout'; end if;
  -- Existing profile mutations take this lock. Also lock inventory rows so
  -- legacy unequip operations cannot interleave with the compare-and-save.
  perform 1 from public.users where id = v_uid for update;
  if not found then raise exception 'profile missing'; end if;
  perform 1 from public.user_cosmetics where user_id = v_uid order by cosmetic_id for update;
  v_state := private.read_hearth_layouts();
  v_current := v_state->'current';
  v_revision := (v_state->>'revision')::bigint;
  if v_current is distinct from p_expected_current or v_revision <> p_expected_revision then
    raise exception 'room changed; reopen the decorator';
  end if;
  if (select count(*) from jsonb_each_text(p_layout)) <>
     (select count(distinct value) from jsonb_each_text(p_layout)) then
    raise exception 'an item can occupy only one spot';
  end if;
  -- Validate the complete target before mutating anything. Existing retired
  -- placements may stay untouched; they cannot be newly placed or moved.
  for v_entry in select key, value from jsonb_each(p_layout) loop
    if jsonb_typeof(v_entry.value) <> 'string' then raise exception 'invalid item'; end if;
    v_id := (v_entry.value #>> '{}')::uuid;
    if not exists (select 1 from public.user_cosmetics uc join public.cosmetics c
      on c.id = uc.cosmetic_id where uc.user_id = v_uid and c.id = v_id
      and c.category in ('room','wall_art')) then raise exception 'decoration not owned'; end if;
    if v_current->v_entry.key is not distinct from v_entry.value then continue; end if;
    if not exists (select 1 from public.cosmetics c
      join public.hearth_profile_slots ps on ps.profile_key = c.hearth_profile_key
      join public.users u on u.id = v_uid
      where c.id = v_id and c.active and ps.slot_key = v_entry.key
      and (c.required_archetype is null or c.required_archetype = u.adventurer_archetype)) then
      raise exception 'decoration does not fit this spot or class';
    end if;
  end loop;
  -- Check dependencies against the finished layout, not update order.
  if exists (select 1 from jsonb_each_text(p_layout) e
    join public.cosmetics c on c.id = e.value::uuid
    join public.hearth_profile_slots ps on ps.profile_key = c.hearth_profile_key and ps.slot_key = e.key
    where ps.required_equipped_slug is not null and not exists (
      select 1 from jsonb_each_text(p_layout) target join public.cosmetics support
      on support.id = target.value::uuid where support.slug = ps.required_equipped_slug
      and support.active and target.key <> e.key)) then
    raise exception 'required Hearth furniture is not placed';
  end if;
  if exists (select 1 from public.cosmetics where id::text = p_layout->>'left' and hearth_profile_key = 'large_furniture')
    and exists (select 1 from public.cosmetics where id::text = p_layout->>'front' and hearth_profile_key = 'seating') then
    raise exception 'left chair and large furniture overlap';
  end if;
  v_source := coalesce(v_current->>'setting', 'original');
  v_target := coalesce(p_layout->>'setting', 'original');
  v_rooms := jsonb_set(v_state->'rooms', array[v_source], v_current, true);
  v_rooms := jsonb_set(v_rooms, array[v_target], p_layout, true);
  update public.user_cosmetics uc set equipped = false, room_slot = null
    from public.cosmetics c where uc.user_id = v_uid and c.id = uc.cosmetic_id
    and uc.equipped and c.category in ('room','wall_art');
  for v_entry in select key, value from jsonb_each_text(p_layout) loop
    update public.user_cosmetics set equipped = true, room_slot = v_entry.key
      where user_id = v_uid and cosmetic_id = v_entry.value::uuid;
  end loop;
  insert into private.hearth_saved_layouts(user_id, rooms, revision)
    values (v_uid, v_rooms, v_revision + 1)
    on conflict(user_id) do update set rooms = excluded.rooms, revision = excluded.revision;
  return private.read_hearth_layouts();
end $$;

create function public.read_hearth_layouts() returns jsonb
language sql security invoker set search_path = '' as $$ select private.read_hearth_layouts(); $$;
create function public.save_hearth_layout(p_expected_current jsonb, p_expected_revision bigint, p_layout jsonb)
returns jsonb language sql security invoker set search_path = '' as $$
  select private.save_hearth_layout(p_expected_current, p_expected_revision, p_layout); $$;
revoke all on function private.read_hearth_layouts() from public, anon, authenticated, service_role;
revoke all on function private.save_hearth_layout(jsonb,bigint,jsonb) from public, anon, authenticated, service_role;
revoke all on function public.read_hearth_layouts() from public, anon, authenticated, service_role;
revoke all on function public.save_hearth_layout(jsonb,bigint,jsonb) from public, anon, authenticated, service_role;
grant execute on function private.read_hearth_layouts(), private.save_hearth_layout(jsonb,bigint,jsonb),
  public.read_hearth_layouts(), public.save_hearth_layout(jsonb,bigint,jsonb) to authenticated;
