-- OBSERVED APPLICATION SCHEMA — disposable CI reconstruction only.

-- Source: read-only PostgreSQL catalogs, Project Momentum, 2026-10-05.

-- Preserves observed behavior, INCLUDING known security defects. Not a hardening migration.

-- Root historical migrations and live migration history remain unchanged.

-- No user rows, catalog inventory, Storage object bytes, tokens or credentials are included.

begin;

do $guard$ begin
  if to_regclass('public.users') is not null or exists (select 1 from auth.users) then
    raise exception 'Observed baseline requires an empty disposable application database';
  end if;
end $guard$;

set local check_function_bodies = off;

set local search_path = pg_catalog;

create schema "private";

alter schema "private" owner to "postgres";

alter schema "public" owner to "pg_database_owner";

create extension if not exists "pgcrypto" with schema "extensions";

create extension if not exists "uuid-ossp" with schema "extensions";

create table "public"."beta_feedback" (
  "id" uuid not null,
  "user_id" uuid not null,
  "created_at" timestamp with time zone not null,
  "category" text not null,
  "goal" text not null,
  "message" text not null,
  "expected" text not null,
  "steps" text not null,
  "reply_email" text not null,
  "device" text not null,
  "screen" text not null,
  "build" text not null,
  "platform" text not null,
  "status" text not null,
  "attachment_path" text,
  "attachment_paths" text[] not null,
  "priority" text not null,
  "action_state" text not null,
  "action_summary" text not null,
  "github_issue_number" integer,
  "github_issue_url" text,
  "triaged_at" timestamp with time zone,
  "fixed_at" timestamp with time zone,
  "verified_at" timestamp with time zone
);

alter table "public"."beta_feedback" owner to "postgres";

create table "public"."boss_battles" (
  "id" uuid not null,
  "user_id" uuid not null,
  "title" text not null,
  "status" text not null,
  "reward_xp" integer not null,
  "reward_coins" integer not null,
  "created_at" timestamp with time zone not null,
  "completed_at" timestamp with time zone,
  "boss_type" text not null
);

alter table "public"."boss_battles" owner to "postgres";

create table "public"."boss_steps" (
  "id" uuid not null,
  "boss_id" uuid not null,
  "user_id" uuid not null,
  "title" text not null,
  "position" integer not null,
  "completed" boolean not null,
  "completed_at" timestamp with time zone,
  "created_at" timestamp with time zone not null
);

alter table "public"."boss_steps" owner to "postgres";

create table "public"."cosmetics" (
  "id" uuid not null,
  "slug" text not null,
  "name" text not null,
  "category" text not null,
  "rarity" text not null,
  "description" text,
  "price" integer not null,
  "premium" boolean not null,
  "asset_key" text,
  "active" boolean not null,
  "created_at" timestamp with time zone not null,
  "required_archetype" text,
  "unlock_method" text not null,
  "milestone_level" integer,
  "collection_key" text,
  "edition_type" text not null,
  "availability_start" timestamp with time zone,
  "availability_end" timestamp with time zone,
  "hearth_profile_key" text
);

alter table "public"."cosmetics" owner to "postgres";

create table "public"."hearth_layout_profiles" (
  "profile_key" text not null,
  "family_key" text not null,
  "display_name" text not null,
  "layout_version" smallint not null
);

alter table "public"."hearth_layout_profiles" owner to "postgres";

create table "public"."hearth_profile_slots" (
  "profile_key" text not null,
  "slot_key" text not null,
  "placement_label" text not null,
  "sort_order" smallint not null,
  "required_equipped_slug" text
);

alter table "public"."hearth_profile_slots" owner to "postgres";

create table "public"."hearth_render_registry" (
  "cosmetic_id" uuid not null,
  "render_kind" text not null,
  "asset_source" text not null,
  "asset_path" text not null,
  "canvas_width" integer not null,
  "canvas_height" integer not null,
  "visible_base" numeric(6,5) not null,
  "shadow_profile" text,
  "effect_profile" text,
  "filter_mode" text not null,
  "asset_revision" integer not null,
  "min_client_build" integer
);

alter table "public"."hearth_render_registry" owner to "postgres";

create table "public"."hearth_slots" (
  "slot_key" text not null,
  "zone" text not null,
  "default_label" text not null,
  "sort_order" smallint not null
);

alter table "public"."hearth_slots" owner to "postgres";

create table "public"."progression_events" (
  "id" uuid not null,
  "user_id" uuid not null,
  "kind" text not null,
  "event_key" text not null,
  "title" text not null,
  "level" integer not null,
  "cosmetic_slug" text,
  "source" text not null,
  "occurred_at" timestamp with time zone not null
);

alter table "public"."progression_events" owner to "postgres";

create table "public"."reward_events" (
  "id" uuid not null,
  "created_at" timestamp with time zone not null,
  "user_id" uuid,
  "task_id" uuid,
  "event_type" text,
  "xp_amount" integer,
  "coin_amount" integer
);

alter table "public"."reward_events" owner to "postgres";

create table "public"."tasks" (
  "id" uuid not null,
  "created_at" timestamp with time zone not null,
  "user_id" uuid,
  "title" text,
  "notes" text,
  "status" text,
  "due_date" timestamp with time zone,
  "xp_value" integer,
  "coin_value" integer,
  "completed_at" timestamp with time zone,
  "friction_level" integer,
  "pinned_at" timestamp with time zone
);

alter table "public"."tasks" owner to "postgres";

create table "public"."user_cosmetics" (
  "user_id" uuid not null,
  "cosmetic_id" uuid not null,
  "unlocked_at" timestamp with time zone not null,
  "source" text not null,
  "equipped" boolean not null,
  "room_slot" text
);

alter table "public"."user_cosmetics" owner to "postgres";

create table "public"."users" (
  "id" uuid not null,
  "created_at" timestamp with time zone not null,
  "email" text,
  "display_name" text,
  "level" integer,
  "total_xp" integer,
  "coin_balance" integer,
  "current_energy_mode" text,
  "onboarding_completed" boolean not null,
  "adventurer_archetype" text not null,
  "avatar_body_type" text not null,
  "level_xp_offset" bigint not null
);

alter table "public"."users" owner to "postgres";

CREATE OR REPLACE FUNCTION private.award_first_journey()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin
 insert into public.user_cosmetics(user_id,cosmetic_id,source,equipped)
  select new.id,c.id,'level_milestone',false from public.cosmetics c
  where c.unlock_method='level_milestone' and c.milestone_level<=new.level
    and c.slug in ('first-journey-trophy','starlit-orrery')
  on conflict(user_id,cosmetic_id) do nothing;
 return new;
end $function$;

CREATE OR REPLACE FUNCTION private.claim_class_mastery_reward()
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare
  v_uid uuid := auth.uid();
  v_archetype text;
  v_reward_id uuid;
  v_missing integer;
begin
  if v_uid is null then raise exception 'authentication required'; end if;

  select adventurer_archetype into v_archetype
  from public.users where id = v_uid;

  select count(*) into v_missing
  from public.cosmetics c
  where c.active = true
    and c.required_archetype = v_archetype
    and c.unlock_method = 'shop'
    and not exists (
      select 1 from public.user_cosmetics uc
      where uc.user_id = v_uid and uc.cosmetic_id = c.id
    );

  if v_missing > 0 then
    raise exception 'class collection is not complete';
  end if;

  select id into v_reward_id
  from public.cosmetics
  where active = true
    and required_archetype = v_archetype
    and unlock_method = 'class_mastery'
  order by created_at
  limit 1;

  if v_reward_id is null then raise exception 'class mastery reward not found'; end if;

  insert into public.user_cosmetics(user_id, cosmetic_id, source)
  values (v_uid, v_reward_id, 'class_mastery')
  on conflict (user_id, cosmetic_id) do nothing;

  return v_reward_id;
end;
$function$;

CREATE OR REPLACE FUNCTION private.complete_boss_step(p_step_id uuid)
 RETURNS TABLE(boss_completed boolean, xp_awarded integer, coins_awarded integer, total_xp integer, coin_balance integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare
  v_user_id uuid := auth.uid();
  v_boss_id uuid;
  v_step_completed boolean;
  v_reward_xp integer := 0;
  v_reward_coins integer := 0;
  v_remaining integer;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  select boss_id, completed
    into v_boss_id, v_step_completed
  from public.boss_steps
  where id = p_step_id
    and user_id = v_user_id
  for update;

  if v_boss_id is null then
    raise exception 'Boss step not found';
  end if;

  if v_step_completed then
    raise exception 'Boss step already completed';
  end if;

  update public.boss_steps
  set completed = true,
      completed_at = now()
  where id = p_step_id
    and user_id = v_user_id
    and completed = false;

  select count(*)
    into v_remaining
  from public.boss_steps
  where boss_id = v_boss_id
    and user_id = v_user_id
    and completed = false;

  if v_remaining = 0 then
    update public.boss_battles
    set status = 'completed',
        completed_at = now()
    where id = v_boss_id
      and user_id = v_user_id
      and status = 'open'
    returning reward_xp, reward_coins
      into v_reward_xp, v_reward_coins;

    if found then
      insert into public.reward_events(
        user_id,
        task_id,
        event_type,
        xp_amount,
        coin_amount
      )
      values (
        v_user_id,
        null,
        'boss_battle_completed',
        v_reward_xp,
        v_reward_coins
      );

      update public.users
      set total_xp = public.users.total_xp + v_reward_xp,
          coin_balance = public.users.coin_balance + v_reward_coins,
          level = private.level_for_xp(public.users.total_xp::bigint + v_reward_xp + public.users.level_xp_offset)
      where id = v_user_id;
    end if;
  end if;

  return query
  select
    (select status = 'completed'
       from public.boss_battles
      where id = v_boss_id),
    v_reward_xp,
    v_reward_coins,
    u.total_xp,
    u.coin_balance
  from public.users u
  where u.id = v_user_id;
end;
$function$;

CREATE OR REPLACE FUNCTION private.complete_task(p_task_id uuid)
 RETURNS TABLE(task_id uuid, xp_awarded integer, coins_awarded integer, total_xp integer, coin_balance integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare
  v_uid uuid := auth.uid();
  v_task public.tasks%rowtype;
  v_total_xp integer;
  v_coin_balance integer;
begin
  if v_uid is null then
    raise exception 'authentication required';
  end if;

  select *
    into v_task
  from public.tasks
  where id = p_task_id
    and user_id = v_uid
    and status = 'open'
  for update;

  if not found then
    raise exception 'task not found, not owned by caller, or already completed';
  end if;

  update public.tasks
  set status = 'completed',
      completed_at = now()
  where id = p_task_id
    and user_id = v_uid
    and status = 'open';

  insert into public.reward_events (
    user_id,
    task_id,
    event_type,
    xp_amount,
    coin_amount
  )
  values (
    v_uid,
    p_task_id,
    'task_completed',
    coalesce(v_task.xp_value, 0),
    coalesce(v_task.coin_value, 0)
  );

  update public.users
  set total_xp = coalesce(public.users.total_xp, 0) + coalesce(v_task.xp_value, 0),
      coin_balance = coalesce(public.users.coin_balance, 0) + coalesce(v_task.coin_value, 0),
      level = private.level_for_xp(
        coalesce(public.users.total_xp, 0)::bigint + coalesce(v_task.xp_value, 0)
        + public.users.level_xp_offset
      )
  where id = v_uid
  returning public.users.total_xp, public.users.coin_balance
    into v_total_xp, v_coin_balance;

  return query
  select
    p_task_id,
    coalesce(v_task.xp_value, 0),
    coalesce(v_task.coin_value, 0),
    v_total_xp,
    v_coin_balance;
end;
$function$;

CREATE OR REPLACE FUNCTION private.cosmetic_supports_body(p_slug text, p_body_type text)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO ''
AS $function$
  select case
    when p_slug='everyday-adventurer-outfit' then coalesce(p_body_type in ('female','neutral','male'),false)
    when p_slug='woodland-scout-outfit' then coalesce(p_body_type in ('female','neutral'),false)
    else true
  end;
$function$;

CREATE OR REPLACE FUNCTION private.create_boss_battle(p_title text, p_steps text[], p_reward_xp integer DEFAULT 25, p_reward_coins integer DEFAULT 50, p_boss_type text DEFAULT 'inbox_hydra'::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_user_id uuid := auth.uid();
  v_boss_id uuid;
  v_step text;
  v_position integer := 0;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  if p_title is null or char_length(trim(p_title)) = 0 then
    raise exception 'Boss title is required';
  end if;

  if p_steps is null or array_length(p_steps, 1) is null or array_length(p_steps, 1) < 2 then
    raise exception 'A Boss Battle requires at least two steps';
  end if;

  if p_boss_type not in (
    'inbox_hydra','meeting_mimic','spreadsheet_slime','calendar_kraken',
    'printer_poltergeist','notification_swarm','ticket_troll','update_dragon'
  ) then
    raise exception 'Unsupported boss type';
  end if;


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

  insert into public.boss_battles(
    user_id, title, reward_xp, reward_coins, boss_type
  )
  values (
    v_user_id,
    trim(p_title),
    least(greatest(coalesce(p_reward_xp,25),0),25),
    greatest(coalesce(p_reward_coins,50),0),
    p_boss_type
  )
  returning id into v_boss_id;

  foreach v_step in array p_steps loop
    if v_step is not null and char_length(trim(v_step)) > 0 then
      insert into public.boss_steps(boss_id, user_id, title, position)
      values (v_boss_id, v_user_id, trim(v_step), v_position);
      v_position := v_position + 1;
    end if;
  end loop;

  if v_position < 2 then
    delete from public.boss_battles where id = v_boss_id;
    raise exception 'A Boss Battle requires at least two non-empty steps';
  end if;

  return v_boss_id;
end;
$function$;

CREATE OR REPLACE FUNCTION private.equip_cosmetic(p_cosmetic_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_category text; v_required text; v_class text; v_slug text;
  v_body text; v_occupant uuid;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  select adventurer_archetype,avatar_body_type into v_class,v_body
    from public.users where id=v_uid for update;
  select c.category,c.required_archetype,c.slug into v_category,v_required,v_slug
    from public.user_cosmetics uc join public.cosmetics c on c.id=uc.cosmetic_id
    where uc.user_id=v_uid and c.id=p_cosmetic_id;
  if v_category is null then raise exception 'cosmetic not owned'; end if;
  if v_required is not null and v_required<>v_class then raise exception 'cosmetic restricted'; end if;
  if not private.cosmetic_supports_body(v_slug,v_body) then
    raise exception 'outfit unavailable for selected body';
  end if;
  if v_category='room' then
    perform private.place_hearth_cosmetic(p_cosmetic_id,'right',null); return;
  end if;
  if v_category='wall_art' then
    if v_slug in ('fern-study','celestial-study') then raise exception 'choose a wall spot'; end if;
    select cosmetic_id into v_occupant from public.user_cosmetics
      where user_id=v_uid and equipped and room_slot='wall_center';
    perform private.place_hearth_cosmetic(p_cosmetic_id,'wall_center',v_occupant); return;
  end if;
  update public.user_cosmetics uc set equipped=false from public.cosmetics c
    where uc.cosmetic_id=c.id and uc.user_id=v_uid and (c.category=v_category
      or (v_slug in ('moss-green-cloak','hearthguard-mantle') and c.category='hands')
      or (v_category='hands' and c.slug in ('moss-green-cloak','hearthguard-mantle')));
  update public.user_cosmetics set equipped=true where user_id=v_uid and cosmetic_id=p_cosmetic_id;
end;
$function$;

CREATE OR REPLACE FUNCTION private.equip_cosmetic_loadout(p_cosmetic_id uuid, p_expected_conflict uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=auth.uid(); v_slug text; v_category text; v_conflict uuid;
begin
 if v_uid is null then raise exception 'authentication required'; end if;
 perform 1 from public.users where id=v_uid for update;
 if not found then raise exception 'profile missing'; end if;
 select c.slug,c.category into v_slug,v_category from public.cosmetics c
 join public.user_cosmetics uc on uc.cosmetic_id=c.id
 where uc.user_id=v_uid and c.id=p_cosmetic_id;
 if v_slug is null then raise exception 'cosmetic not owned'; end if;
 select uc.cosmetic_id into v_conflict from public.user_cosmetics uc
 join public.cosmetics c on c.id=uc.cosmetic_id
 where uc.user_id=v_uid and uc.equipped and
 ((v_slug in ('moss-green-cloak','hearthguard-mantle') and c.category='hands')
 or (v_category='hands' and c.slug in ('moss-green-cloak','hearthguard-mantle')));
 if v_conflict is distinct from p_expected_conflict then
   raise exception 'equipment changed; refresh and confirm the swap';
 end if;
 perform private.equip_cosmetic(p_cosmetic_id);
end $function$;

CREATE OR REPLACE FUNCTION private.level_for_xp(p_xp bigint)
 RETURNS integer
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO ''
AS $function$
declare
  v_xp bigint := greatest(coalesce(p_xp, 0), 0);
  v_level integer;
begin
  v_level := greatest(1, floor((sqrt(34225::numeric + 120::numeric * v_xp) - 185) / 30)::integer + 1);
  -- Exact integer checks protect the threshold from square-root rounding.
  while private.xp_at_level(v_level + 1) <= v_xp loop v_level := v_level + 1; end loop;
  while private.xp_at_level(v_level) > v_xp loop v_level := v_level - 1; end loop;
  return v_level;
end;
$function$;

CREATE OR REPLACE FUNCTION private.place_hearth_cosmetic(p_cosmetic_id uuid, p_slot text, p_expected_occupant uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_occupant uuid;
  v_class text;
  v_required text;
  v_profile text;
  v_required_equipped_slug text;
begin
  if v_uid is null then raise exception 'authentication required'; end if;

  if p_slot is null or not exists (
    select 1 from public.hearth_slots hs where hs.slot_key = p_slot
  ) then
    raise exception 'invalid room spot';
  end if;

  -- Serialize placement with other profile operations, including concurrent devices.
  select adventurer_archetype
    into v_class
    from public.users
    where id = v_uid
    for update;
  if not found then raise exception 'profile missing'; end if;

  select c.required_archetype, c.hearth_profile_key
    into v_required, v_profile
    from public.cosmetics c
    join public.user_cosmetics uc on uc.cosmetic_id = c.id
    where uc.user_id = v_uid
      and c.id = p_cosmetic_id
      and c.active
      and c.category in ('room','wall_art');
  if not found then raise exception 'room item not owned or unavailable'; end if;

  select hps.required_equipped_slug
    into v_required_equipped_slug
    from public.hearth_profile_slots hps
    where hps.profile_key = v_profile
      and hps.slot_key = p_slot;
  if not found then
    raise exception 'item does not fit this room spot';
  end if;

  if v_required_equipped_slug is not null and not exists (
    select 1
      from public.user_cosmetics uc
      join public.cosmetics c on c.id = uc.cosmetic_id
      where uc.user_id = v_uid
        and uc.equipped
        and c.active
        and c.slug = v_required_equipped_slug
  ) then
    raise exception 'required Hearth furniture is not placed';
  end if;

  if v_required is not null and v_required <> v_class then
    raise exception 'class restricted';
  end if;

  select cosmetic_id
    into v_occupant
    from public.user_cosmetics
    where user_id = v_uid
      and equipped
      and room_slot = p_slot;

  if v_occupant is distinct from p_expected_occupant
     and v_occupant is distinct from p_cosmetic_id then
    raise exception 'room spot changed; refresh and confirm replacement';
  end if;

  update public.user_cosmetics
    set equipped = false, room_slot = null
    where user_id = v_uid
      and equipped
      and room_slot = p_slot
      and cosmetic_id <> p_cosmetic_id;

  update public.user_cosmetics
    set equipped = true, room_slot = p_slot
    where user_id = v_uid
      and cosmetic_id = p_cosmetic_id;
end
$function$;

CREATE OR REPLACE FUNCTION private.protect_level_xp_offset()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin
  if current_user in ('anon', 'authenticated') then
    if tg_op = 'INSERT' then
      if new.level_xp_offset <> 0 then
        raise exception 'Progression credit is server managed' using errcode = '42501';
      end if;
    elsif new.level_xp_offset is distinct from old.level_xp_offset then
      raise exception 'Progression credit is server managed' using errcode = '42501';
    end if;
  end if;
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION private.purchase_cosmetic(p_cosmetic_id uuid)
 RETURNS TABLE(cosmetic_id uuid, remaining_coins integer, already_owned boolean)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_price integer; v_balance integer;
  v_required_archetype text; v_user_archetype text; v_unlock_method text;
  v_body text; v_slug text;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  -- Preserve serialization across devices/retries and the existing catalog authority.
  select u.coin_balance,u.adventurer_archetype,u.avatar_body_type
    into v_balance,v_user_archetype,v_body
    from public.users u where u.id=v_uid for update;
  if not found then raise exception 'profile not found'; end if;
  select c.price,c.required_archetype,c.unlock_method,c.slug
    into v_price,v_required_archetype,v_unlock_method,v_slug
    from public.cosmetics c where c.id=p_cosmetic_id and c.active for share;
  if v_price is null then raise exception 'cosmetic not found'; end if;
  if not private.cosmetic_supports_body(v_slug,v_body) then
    raise exception 'outfit unavailable for selected body';
  end if;
  if v_unlock_method<>'shop' then raise exception 'cosmetic is not purchasable'; end if;
  if v_required_archetype is not null and v_required_archetype<>v_user_archetype then
    raise exception 'cosmetic restricted to % archetype',v_required_archetype;
  end if;
  if exists(select 1 from public.user_cosmetics uc
      where uc.user_id=v_uid and uc.cosmetic_id=p_cosmetic_id) then
    return query select p_cosmetic_id,v_balance,true;
    return;
  end if;
  if v_balance<v_price then raise exception 'not enough coins'; end if;
  update public.users u set coin_balance=u.coin_balance-v_price
    where u.id=v_uid returning u.coin_balance into v_balance;
  insert into public.user_cosmetics(user_id,cosmetic_id,source)
    values(v_uid,p_cosmetic_id,'shop');
  insert into public.reward_events(user_id,task_id,event_type,xp_amount,coin_amount)
    values(v_uid,null,'cosmetic_purchase',0,-v_price);
  return query select p_cosmetic_id,v_balance,false;
end;
$function$;

CREATE OR REPLACE FUNCTION private.record_level_milestones()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin
 if new.level>old.level then
  insert into public.progression_events(user_id,kind,event_key,title,level,source)
   select new.id,'level_up',n::text,'Level '||n||' reached',n,'progression'
   from generate_series(greatest(old.level+1,2),new.level) n
   on conflict(user_id,kind,event_key) do nothing;
 end if;
 return new;
end $function$;

CREATE OR REPLACE FUNCTION private.record_milestone_reward()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin
 insert into public.progression_events(user_id,kind,event_key,title,level,cosmetic_slug,source,occurred_at)
  select new.user_id,'milestone_reward',c.slug,c.name,c.milestone_level,c.slug,new.source,new.unlocked_at
  from public.cosmetics c where c.id=new.cosmetic_id and c.unlock_method='level_milestone' and c.milestone_level is not null
  on conflict(user_id,kind,event_key) do nothing;
 return new;
end $function$;

CREATE OR REPLACE FUNCTION private.return_unsupported_trophy()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin
 -- Auth's account deletion cascades the entire inventory; no furniture remains
 -- to rearrange. Keep the trigger invoker-rights and avoid widening Auth grants.
 if tg_op = 'DELETE' and current_user = 'supabase_auth_admin' then
   return null;
 end if;
 if old.equipped and exists(
   select 1 from public.cosmetics where id=old.cosmetic_id and slug='walnut-bookshelf'
 ) then
  if tg_op='DELETE' or not new.equipped or new.room_slot is null or new.room_slot not in ('left','right') then
   if not exists(
     select 1 from public.user_cosmetics support
     join public.cosmetics c on c.id=support.cosmetic_id
     where support.user_id=old.user_id and support.equipped and c.active
       and c.slug='walnut-bookshelf' and support.room_slot in ('left','right')
   ) then
    update public.user_cosmetics uc set equipped=false,room_slot=null
    from public.cosmetics c where uc.cosmetic_id=c.id and uc.user_id=old.user_id
      and c.slug in ('first-journey-trophy','starlit-orrery','scholar-seal',
        'scout-compass','alchemist-phial','guardian-crest','wanderer-star-map')
      and uc.equipped and uc.room_slot='bookshelf_top';
   end if;
  end if;
 end if;
 return null;
end $function$;

CREATE OR REPLACE FUNCTION private.set_adventurer_archetype(p_archetype text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'authentication required';
  end if;

  if p_archetype not in ('scholar','scout','alchemist','guardian','wanderer') then
    raise exception 'unsupported archetype';
  end if;

  update public.users
  set adventurer_archetype = p_archetype
  where id = v_uid;

  update public.user_cosmetics uc
  set equipped = false
  from public.cosmetics c
  where uc.user_id = v_uid
    and uc.cosmetic_id = c.id
    and uc.equipped = true
    and c.required_archetype is not null
    and c.required_archetype <> p_archetype;
end;
$function$;

CREATE OR REPLACE FUNCTION private.set_avatar_body_type(p_body_type text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid := auth.uid();
begin
  if v_uid is null then raise exception 'Authentication required'; end if;
  if p_body_type is null or p_body_type not in ('male','female','neutral') then
    raise exception 'Unsupported avatar body type';
  end if;
  -- UPDATE holds the same user-row lock used by purchase/equip until transaction end.
  update public.users set avatar_body_type=p_body_type where id=v_uid;
  -- Unsupported fits return to inventory. Supported equipped fits stay equipped.
  update public.user_cosmetics uc set equipped=false from public.cosmetics c
    where uc.cosmetic_id=c.id and uc.user_id=v_uid and uc.equipped
      and not private.cosmetic_supports_body(c.slug,p_body_type);
end;
$function$;

CREATE OR REPLACE FUNCTION private.unequip_cosmetic(p_cosmetic_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  update public.user_cosmetics
  set equipped = false
  where user_id = v_user_id
    and cosmetic_id = p_cosmetic_id
    and equipped = true;

  if not found then
    raise exception 'Cosmetic is not currently equipped';
  end if;
end;
$function$;

CREATE OR REPLACE FUNCTION private.xp_at_level(p_level integer)
 RETURNS bigint
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO ''
AS $function$
  select 100::bigint * greatest(p_level - 1, 0)
    + 15::bigint * greatest(p_level - 1, 0) * greatest(p_level - 2, 0) / 2;
$function$;

CREATE OR REPLACE FUNCTION public.claim_class_mastery_reward()
 RETURNS uuid
 LANGUAGE sql
 SET search_path TO 'private', 'public', 'pg_temp'
AS $function$ select private.claim_class_mastery_reward(); $function$;

CREATE OR REPLACE FUNCTION public.complete_boss_step(p_step_id uuid)
 RETURNS TABLE(boss_completed boolean, xp_awarded integer, coins_awarded integer, total_xp integer, coin_balance integer)
 LANGUAGE sql
 SET search_path TO 'private', 'public', 'pg_temp'
AS $function$ select * from private.complete_boss_step(p_step_id); $function$;

CREATE OR REPLACE FUNCTION public.complete_task(p_task_id uuid)
 RETURNS TABLE(task_id uuid, xp_awarded integer, coins_awarded integer, total_xp integer, coin_balance integer)
 LANGUAGE sql
 SET search_path TO 'private', 'public', 'pg_temp'
AS $function$ select * from private.complete_task(p_task_id); $function$;

CREATE OR REPLACE FUNCTION public.create_boss_battle(p_title text, p_steps text[], p_reward_xp integer DEFAULT 25, p_reward_coins integer DEFAULT 50, p_boss_type text DEFAULT 'inbox_hydra'::text)
 RETURNS uuid
 LANGUAGE sql
 SET search_path TO 'private', 'public', 'pg_temp'
AS $function$
  select private.create_boss_battle(
    p_title, p_steps,
    least(greatest(coalesce(p_reward_xp,25),0),25),
    least(greatest(coalesce(p_reward_coins,50),0),50),
    p_boss_type
  );
$function$;

CREATE OR REPLACE FUNCTION public.enforce_collection_archetype()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin
  if new.collection_key='woodland-scout' and new.required_archetype is distinct from 'scout' then
    raise exception 'Woodland Scout collection items must require scout archetype.';
  end if;
  return new;
end; $function$;

CREATE OR REPLACE FUNCTION public.equip_cosmetic(p_cosmetic_id uuid)
 RETURNS void
 LANGUAGE sql
 SET search_path TO 'private', 'public', 'pg_temp'
AS $function$ select private.equip_cosmetic(p_cosmetic_id); $function$;

CREATE OR REPLACE FUNCTION public.equip_cosmetic_loadout(p_cosmetic_id uuid, p_expected_conflict uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE sql
 SET search_path TO ''
AS $function$
 select private.equip_cosmetic_loadout(p_cosmetic_id,p_expected_conflict);
$function$;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_cosmetic_id uuid;
begin
  insert into public.users (id, email)
  values (new.id, new.email)
  on conflict (id) do update
    set email = excluded.email;

  select id
    into v_cosmetic_id
  from public.cosmetics
  where slug = 'starter-business-suit'
  limit 1;

  if v_cosmetic_id is not null then
    insert into public.user_cosmetics (
      user_id,
      cosmetic_id,
      source,
      equipped
    )
    values (
      new.id,
      v_cosmetic_id,
      'starter',
      true
    )
    on conflict (user_id, cosmetic_id)
    do update set
      source = 'starter',
      equipped = true;
  end if;

  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.place_hearth_cosmetic(p_cosmetic_id uuid, p_slot text, p_expected_occupant uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE sql
 SET search_path TO ''
AS $function$
select private.place_hearth_cosmetic(p_cosmetic_id,p_slot,p_expected_occupant); $function$;

CREATE OR REPLACE FUNCTION public.purchase_cosmetic(p_cosmetic_id uuid)
 RETURNS TABLE(cosmetic_id uuid, remaining_coins integer, already_owned boolean)
 LANGUAGE sql
 SET search_path TO 'private', 'public', 'pg_temp'
AS $function$ select * from private.purchase_cosmetic(p_cosmetic_id); $function$;

CREATE OR REPLACE FUNCTION public.questwell_feedback_default_triage()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin
  new.priority := case
    when new.category = 'bug' then 'high'
    when new.category = 'confusing' then 'normal'
    when new.category = 'idea' then 'low'
    else 'low'
  end;
  new.action_state := 'triage';
  new.action_summary := case
    when new.category = 'bug' then 'Reproduce the reported behavior, identify root cause, add regression coverage, and verify the fix.'
    when new.category = 'confusing' then 'Review the reported UX friction, identify the confusing interaction, and propose a clarity improvement.'
    when new.category = 'idea' then 'Evaluate the idea against Questwell scope and beta goals before scheduling implementation.'
    else 'Capture the positive signal and identify whether the praised behavior should be protected by regression coverage.'
  end;
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.questwell_feedback_insert_guard()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin
  if current_user = 'authenticated' then
    if auth.uid() is null or new.user_id is distinct from auth.uid() then
      raise exception 'Feedback must belong to the signed-in account.' using errcode = '42501';
    end if;
    perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(new.user_id::text, 84392));
    -- Permit the uniqueness check to identify an already-received retry, even
    -- at the hourly limit. The client then checks that the existing row is its own.
    if exists (select 1 from public.beta_feedback where id = new.id and user_id = new.user_id) then
      return new;
    end if;
    if (select count(*) from public.beta_feedback
        where user_id = new.user_id and created_at > now() - interval '1 hour') >= 10 then
      raise exception 'feedback_rate_limit' using errcode = 'P0001';
    end if;
  end if;
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.set_adventurer_archetype(p_archetype text)
 RETURNS void
 LANGUAGE sql
 SET search_path TO 'private', 'public', 'pg_temp'
AS $function$ select private.set_adventurer_archetype(p_archetype); $function$;

CREATE OR REPLACE FUNCTION public.set_avatar_body_type(p_body_type text)
 RETURNS void
 LANGUAGE sql
 SET search_path TO 'private', 'public', 'pg_temp'
AS $function$ select private.set_avatar_body_type(p_body_type); $function$;

CREATE OR REPLACE FUNCTION public.set_pinned_quest(p_task_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
declare v_uid uuid := auth.uid();
begin
  if v_uid is null then raise exception 'Authentication required.' using errcode='42501'; end if;
  if not exists(select 1 from public.tasks where id=p_task_id and user_id=v_uid and status='open') then
    raise exception 'Quest is not open.' using errcode='P0002';
  end if;
  update public.tasks set pinned_at=null where user_id=v_uid and status='open' and pinned_at is not null and id<>p_task_id;
  update public.tasks set pinned_at=case when pinned_at is null then now() else null end
    where id=p_task_id and user_id=v_uid and status='open';
end;
$function$;

CREATE OR REPLACE FUNCTION public.unequip_cosmetic(p_cosmetic_id uuid)
 RETURNS void
 LANGUAGE sql
 SET search_path TO 'private', 'public', 'pg_temp'
AS $function$ select private.unequip_cosmetic(p_cosmetic_id); $function$;

alter table "public"."beta_feedback" alter column "created_at" set default now();

alter table "public"."beta_feedback" alter column "expected" set default ''::text;

alter table "public"."beta_feedback" alter column "steps" set default ''::text;

alter table "public"."beta_feedback" alter column "reply_email" set default ''::text;

alter table "public"."beta_feedback" alter column "device" set default ''::text;

alter table "public"."beta_feedback" alter column "status" set default 'new'::text;

alter table "public"."beta_feedback" alter column "attachment_paths" set default '{}'::text[];

alter table "public"."beta_feedback" alter column "priority" set default 'normal'::text;

alter table "public"."beta_feedback" alter column "action_state" set default 'triage'::text;

alter table "public"."beta_feedback" alter column "action_summary" set default ''::text;

alter table "public"."boss_battles" alter column "id" set default gen_random_uuid();

alter table "public"."boss_battles" alter column "status" set default 'open'::text;

alter table "public"."boss_battles" alter column "reward_xp" set default 100;

alter table "public"."boss_battles" alter column "reward_coins" set default 50;

alter table "public"."boss_battles" alter column "created_at" set default now();

alter table "public"."boss_battles" alter column "boss_type" set default 'inbox_hydra'::text;

alter table "public"."boss_steps" alter column "id" set default gen_random_uuid();

alter table "public"."boss_steps" alter column "completed" set default false;

alter table "public"."boss_steps" alter column "created_at" set default now();

alter table "public"."cosmetics" alter column "id" set default gen_random_uuid();

alter table "public"."cosmetics" alter column "rarity" set default 'common'::text;

alter table "public"."cosmetics" alter column "price" set default 0;

alter table "public"."cosmetics" alter column "premium" set default false;

alter table "public"."cosmetics" alter column "active" set default true;

alter table "public"."cosmetics" alter column "created_at" set default now();

alter table "public"."cosmetics" alter column "unlock_method" set default 'shop'::text;

alter table "public"."cosmetics" alter column "edition_type" set default 'standard'::text;

alter table "public"."hearth_layout_profiles" alter column "layout_version" set default 1;

alter table "public"."hearth_profile_slots" alter column "sort_order" set default 0;

alter table "public"."hearth_render_registry" alter column "asset_source" set default 'bundle'::text;

alter table "public"."hearth_render_registry" alter column "visible_base" set default 1;

alter table "public"."hearth_render_registry" alter column "filter_mode" set default 'pixel'::text;

alter table "public"."hearth_render_registry" alter column "asset_revision" set default 1;

alter table "public"."hearth_slots" alter column "sort_order" set default 0;

alter table "public"."progression_events" alter column "id" set default gen_random_uuid();

alter table "public"."progression_events" alter column "occurred_at" set default now();

alter table "public"."reward_events" alter column "id" set default gen_random_uuid();

alter table "public"."reward_events" alter column "created_at" set default now();

alter table "public"."reward_events" alter column "xp_amount" set default 0;

alter table "public"."reward_events" alter column "coin_amount" set default 0;

alter table "public"."tasks" alter column "id" set default gen_random_uuid();

alter table "public"."tasks" alter column "created_at" set default now();

alter table "public"."tasks" alter column "status" set default '''open'''::text;

alter table "public"."tasks" alter column "xp_value" set default 0;

alter table "public"."tasks" alter column "coin_value" set default 0;

alter table "public"."user_cosmetics" alter column "unlocked_at" set default now();

alter table "public"."user_cosmetics" alter column "source" set default 'shop'::text;

alter table "public"."user_cosmetics" alter column "equipped" set default false;

alter table "public"."users" alter column "created_at" set default now();

alter table "public"."users" alter column "level" set default 1;

alter table "public"."users" alter column "total_xp" set default 0;

alter table "public"."users" alter column "coin_balance" set default 0;

alter table "public"."users" alter column "current_energy_mode" set default '''normal'''::text;

alter table "public"."users" alter column "onboarding_completed" set default false;

alter table "public"."users" alter column "adventurer_archetype" set default 'wanderer'::text;

alter table "public"."users" alter column "avatar_body_type" set default 'neutral'::text;

alter table "public"."users" alter column "level_xp_offset" set default 0;

alter table "public"."beta_feedback" add constraint "beta_feedback_action_state_check" CHECK ((action_state = ANY (ARRAY['triage'::text, 'ready'::text, 'in_progress'::text, 'needs_founder'::text, 'blocked'::text, 'fixed'::text, 'verified'::text, 'declined'::text])));

alter table "public"."beta_feedback" add constraint "beta_feedback_action_summary_check" CHECK ((char_length(action_summary) <= 500));

alter table "public"."beta_feedback" add constraint "beta_feedback_attachment_path_safe" CHECK (((attachment_path IS NULL) OR (((char_length(attachment_path) >= 1) AND (char_length(attachment_path) <= 500)) AND (attachment_path !~ '(^|/)\.\.(/|$)'::text))));

alter table "public"."beta_feedback" add constraint "beta_feedback_attachment_paths_limit" CHECK ((cardinality(attachment_paths) <= 5));

alter table "public"."beta_feedback" add constraint "beta_feedback_build_check" CHECK ((((char_length(build) >= 1) AND (char_length(build) <= 64)) AND (build ~ '^[A-Za-z0-9._-]+$'::text)));

alter table "public"."beta_feedback" add constraint "beta_feedback_category_check" CHECK ((category = ANY (ARRAY['bug'::text, 'confusing'::text, 'idea'::text, 'positive'::text])));

alter table "public"."beta_feedback" add constraint "beta_feedback_device_check" CHECK ((char_length(device) <= 200));

alter table "public"."beta_feedback" add constraint "beta_feedback_expected_check" CHECK ((char_length(expected) <= 1000));

alter table "public"."beta_feedback" add constraint "beta_feedback_goal_check" CHECK (((char_length(btrim(goal)) >= 1) AND (char_length(btrim(goal)) <= 300)));

alter table "public"."beta_feedback" add constraint "beta_feedback_message_check" CHECK (((char_length(btrim(message)) >= 1) AND (char_length(btrim(message)) <= 3000)));

alter table "public"."beta_feedback" add constraint "beta_feedback_pkey" PRIMARY KEY (id);

alter table "public"."beta_feedback" add constraint "beta_feedback_platform_check" CHECK ((((char_length(platform) >= 1) AND (char_length(platform) <= 64)) AND (platform ~ '^[A-Za-z0-9._-]+$'::text)));

alter table "public"."beta_feedback" add constraint "beta_feedback_priority_check" CHECK ((priority = ANY (ARRAY['low'::text, 'normal'::text, 'high'::text, 'critical'::text])));

alter table "public"."beta_feedback" add constraint "beta_feedback_reply_email_check" CHECK (((char_length(reply_email) <= 254) AND ((reply_email = ''::text) OR (reply_email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'::text))));

alter table "public"."beta_feedback" add constraint "beta_feedback_screen_check" CHECK ((screen = ANY (ARRAY['Hearth'::text, 'Quests'::text, 'Boss Battles'::text, 'Expedition'::text, 'Market'::text, 'Adventurer'::text, 'Chronicle'::text, 'New quest'::text, 'Other'::text])));

alter table "public"."beta_feedback" add constraint "beta_feedback_status_check" CHECK ((status = ANY (ARRAY['new'::text, 'reviewed'::text, 'resolved'::text])));

alter table "public"."beta_feedback" add constraint "beta_feedback_steps_check" CHECK ((char_length(steps) <= 1000));

alter table "public"."boss_battles" add constraint "boss_battles_boss_type_check" CHECK ((boss_type = ANY (ARRAY['inbox_hydra'::text, 'meeting_mimic'::text, 'spreadsheet_slime'::text, 'calendar_kraken'::text, 'printer_poltergeist'::text, 'notification_swarm'::text, 'ticket_troll'::text, 'update_dragon'::text])));

alter table "public"."boss_battles" add constraint "boss_battles_pkey" PRIMARY KEY (id);

alter table "public"."boss_battles" add constraint "boss_battles_reward_coins_check" CHECK ((reward_coins >= 0));

alter table "public"."boss_battles" add constraint "boss_battles_reward_xp_check" CHECK ((reward_xp >= 0));

alter table "public"."boss_battles" add constraint "boss_battles_status_check" CHECK ((status = ANY (ARRAY['open'::text, 'completed'::text])));

alter table "public"."boss_battles" add constraint "boss_battles_title_check" CHECK ((char_length(TRIM(BOTH FROM title)) > 0));

alter table "public"."boss_steps" add constraint "boss_steps_boss_id_position_key" UNIQUE (boss_id, "position");

alter table "public"."boss_steps" add constraint "boss_steps_pkey" PRIMARY KEY (id);

alter table "public"."boss_steps" add constraint "boss_steps_position_check" CHECK (("position" >= 0));

alter table "public"."boss_steps" add constraint "boss_steps_title_check" CHECK ((char_length(TRIM(BOTH FROM title)) > 0));

alter table "public"."cosmetics" add constraint "cosmetics_category_check" CHECK ((category = ANY (ARRAY['head'::text, 'face'::text, 'neck'::text, 'chest'::text, 'hands'::text, 'legs'::text, 'feet'::text, 'back'::text, 'familiar'::text, 'room'::text, 'effect'::text, 'outfit'::text, 'accessory'::text, 'wall_art'::text])));

alter table "public"."cosmetics" add constraint "cosmetics_edition_type_check" CHECK ((edition_type = ANY (ARRAY['standard'::text, 'seasonal'::text, 'limited'::text, 'event_reward'::text, 'founder_beta'::text])));

alter table "public"."cosmetics" add constraint "cosmetics_hearth_profile_required" CHECK (((category <> ALL (ARRAY['room'::text, 'wall_art'::text])) OR (hearth_profile_key IS NOT NULL)));

alter table "public"."cosmetics" add constraint "cosmetics_milestone_level_check" CHECK (((milestone_level IS NULL) OR (milestone_level >= 2)));

alter table "public"."cosmetics" add constraint "cosmetics_pkey" PRIMARY KEY (id);

alter table "public"."cosmetics" add constraint "cosmetics_price_check" CHECK ((price >= 0));

alter table "public"."cosmetics" add constraint "cosmetics_rarity_check" CHECK ((rarity = ANY (ARRAY['common'::text, 'uncommon'::text, 'rare'::text, 'epic'::text, 'legendary'::text])));

alter table "public"."cosmetics" add constraint "cosmetics_required_archetype_check" CHECK (((required_archetype IS NULL) OR (required_archetype = ANY (ARRAY['scholar'::text, 'scout'::text, 'alchemist'::text, 'guardian'::text, 'wanderer'::text]))));

alter table "public"."cosmetics" add constraint "cosmetics_slug_key" UNIQUE (slug);

alter table "public"."cosmetics" add constraint "cosmetics_unlock_method_check" CHECK ((unlock_method = ANY (ARRAY['shop'::text, 'class_mastery'::text, 'level_milestone'::text])));

alter table "public"."hearth_layout_profiles" add constraint "hearth_layout_profiles_layout_version_check" CHECK ((layout_version > 0));

alter table "public"."hearth_layout_profiles" add constraint "hearth_layout_profiles_pkey" PRIMARY KEY (profile_key);

alter table "public"."hearth_profile_slots" add constraint "hearth_profile_slots_pkey" PRIMARY KEY (profile_key, slot_key);

alter table "public"."hearth_render_registry" add constraint "hearth_render_registry_asset_revision_check" CHECK ((asset_revision > 0));

alter table "public"."hearth_render_registry" add constraint "hearth_render_registry_asset_source_check" CHECK ((asset_source = ANY (ARRAY['bundle'::text, 'network'::text])));

alter table "public"."hearth_render_registry" add constraint "hearth_render_registry_canvas_height_check" CHECK ((canvas_height > 0));

alter table "public"."hearth_render_registry" add constraint "hearth_render_registry_canvas_width_check" CHECK ((canvas_width > 0));

alter table "public"."hearth_render_registry" add constraint "hearth_render_registry_effect_profile_check" CHECK ((effect_profile = ANY (ARRAY['ward_glow'::text, 'warm_glow'::text])));

alter table "public"."hearth_render_registry" add constraint "hearth_render_registry_filter_mode_check" CHECK ((filter_mode = ANY (ARRAY['pixel'::text, 'smooth'::text])));

alter table "public"."hearth_render_registry" add constraint "hearth_render_registry_min_client_build_check" CHECK (((min_client_build IS NULL) OR (min_client_build > 0)));

alter table "public"."hearth_render_registry" add constraint "hearth_render_registry_pkey" PRIMARY KEY (cosmetic_id);

alter table "public"."hearth_render_registry" add constraint "hearth_render_registry_render_kind_check" CHECK ((render_kind = ANY (ARRAY['static_sprite'::text, 'floor_sprite'::text, 'wall_art_sprite'::text])));

alter table "public"."hearth_render_registry" add constraint "hearth_render_registry_shadow_profile_check" CHECK ((shadow_profile = ANY (ARRAY['wide_plinth'::text, 'pedestal'::text, 'seating'::text, 'side_table'::text, 'plant'::text, 'none'::text])));

alter table "public"."hearth_render_registry" add constraint "hearth_render_registry_visible_base_check" CHECK (((visible_base > (0)::numeric) AND (visible_base <= (1)::numeric)));

alter table "public"."hearth_slots" add constraint "hearth_slots_pkey" PRIMARY KEY (slot_key);

alter table "public"."hearth_slots" add constraint "hearth_slots_zone_check" CHECK ((zone = ANY (ARRAY['rear'::text, 'foreground'::text, 'side'::text, 'wall'::text, 'surface'::text, 'window'::text, 'floor'::text, 'setting'::text])));

alter table "public"."progression_events" add constraint "progression_events_kind_check" CHECK ((kind = ANY (ARRAY['level_up'::text, 'milestone_reward'::text])));

alter table "public"."progression_events" add constraint "progression_events_level_check" CHECK ((level >= 2));

alter table "public"."progression_events" add constraint "progression_events_pkey" PRIMARY KEY (id);

alter table "public"."progression_events" add constraint "progression_events_user_id_kind_event_key_key" UNIQUE (user_id, kind, event_key);

alter table "public"."reward_events" add constraint "reward_events_pkey" PRIMARY KEY (id);

alter table "public"."tasks" add constraint "tasks_pkey" PRIMARY KEY (id);

alter table "public"."user_cosmetics" add constraint "user_cosmetics_pkey" PRIMARY KEY (user_id, cosmetic_id);

alter table "public"."users" add constraint "users_adventurer_archetype_check" CHECK ((adventurer_archetype = ANY (ARRAY['scholar'::text, 'scout'::text, 'alchemist'::text, 'guardian'::text, 'wanderer'::text])));

alter table "public"."users" add constraint "users_avatar_body_type_check" CHECK ((avatar_body_type = ANY (ARRAY['male'::text, 'female'::text, 'neutral'::text])));

alter table "public"."users" add constraint "users_level_xp_offset_check" CHECK ((level_xp_offset >= 0));

alter table "public"."users" add constraint "users_pkey" PRIMARY KEY (id);

alter table "public"."beta_feedback" add constraint "beta_feedback_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

alter table "public"."boss_battles" add constraint "boss_battles_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

alter table "public"."boss_steps" add constraint "boss_steps_boss_id_fkey" FOREIGN KEY (boss_id) REFERENCES public.boss_battles(id) ON DELETE CASCADE;

alter table "public"."boss_steps" add constraint "boss_steps_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

alter table "public"."cosmetics" add constraint "cosmetics_hearth_profile_key_fkey" FOREIGN KEY (hearth_profile_key) REFERENCES public.hearth_layout_profiles(profile_key) ON DELETE RESTRICT;

alter table "public"."hearth_profile_slots" add constraint "hearth_profile_slots_profile_key_fkey" FOREIGN KEY (profile_key) REFERENCES public.hearth_layout_profiles(profile_key) ON DELETE CASCADE;

alter table "public"."hearth_profile_slots" add constraint "hearth_profile_slots_required_equipped_slug_fkey" FOREIGN KEY (required_equipped_slug) REFERENCES public.cosmetics(slug) ON DELETE RESTRICT;

alter table "public"."hearth_profile_slots" add constraint "hearth_profile_slots_slot_key_fkey" FOREIGN KEY (slot_key) REFERENCES public.hearth_slots(slot_key) ON DELETE RESTRICT;

alter table "public"."hearth_render_registry" add constraint "hearth_render_registry_cosmetic_id_fkey" FOREIGN KEY (cosmetic_id) REFERENCES public.cosmetics(id) ON DELETE CASCADE;

alter table "public"."progression_events" add constraint "progression_events_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

alter table "public"."reward_events" add constraint "reward_events_task_id_fkey" FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE SET NULL;

alter table "public"."reward_events" add constraint "reward_events_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

alter table "public"."tasks" add constraint "tasks_user_id_fkey1" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

alter table "public"."user_cosmetics" add constraint "user_cosmetics_cosmetic_id_fkey" FOREIGN KEY (cosmetic_id) REFERENCES public.cosmetics(id) ON DELETE CASCADE;

alter table "public"."user_cosmetics" add constraint "user_cosmetics_room_slot_fkey" FOREIGN KEY (room_slot) REFERENCES public.hearth_slots(slot_key) ON UPDATE CASCADE ON DELETE RESTRICT;

alter table "public"."user_cosmetics" add constraint "user_cosmetics_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

alter table "public"."users" add constraint "users_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;

CREATE INDEX beta_feedback_action_queue_idx ON public.beta_feedback USING btree (action_state, priority, created_at);

CREATE INDEX beta_feedback_status_created_idx ON public.beta_feedback USING btree (status, created_at DESC);

CREATE INDEX beta_feedback_user_created_idx ON public.beta_feedback USING btree (user_id, created_at DESC);

CREATE INDEX progression_events_user_time ON public.progression_events USING btree (user_id, occurred_at DESC);

CREATE UNIQUE INDEX tasks_one_pinned_open_per_user_idx ON public.tasks USING btree (user_id) WHERE ((pinned_at IS NOT NULL) AND (status = 'open'::text));

CREATE INDEX tasks_user_open_pinned_idx ON public.tasks USING btree (user_id, pinned_at DESC) WHERE (status = 'open'::text);

CREATE UNIQUE INDEX user_cosmetics_placed_room_slot ON public.user_cosmetics USING btree (user_id, room_slot) WHERE (equipped AND (room_slot IS NOT NULL));

alter table "public"."beta_feedback" enable row level security;

alter table "public"."boss_battles" enable row level security;

alter table "public"."boss_steps" enable row level security;

alter table "public"."cosmetics" enable row level security;

alter table "public"."hearth_layout_profiles" enable row level security;

alter table "public"."hearth_profile_slots" enable row level security;

alter table "public"."hearth_render_registry" enable row level security;

alter table "public"."hearth_slots" enable row level security;

alter table "public"."progression_events" enable row level security;

alter table "public"."reward_events" enable row level security;

alter table "public"."tasks" enable row level security;

alter table "public"."user_cosmetics" enable row level security;

alter table "public"."users" enable row level security;

create policy "beta_feedback_read_own" on "public"."beta_feedback" as PERMISSIVE for SELECT to "authenticated" using ((( SELECT auth.uid() AS uid) = user_id));

create policy "beta_feedback_submit_own" on "public"."beta_feedback" as PERMISSIVE for INSERT to "authenticated" with check ((( SELECT auth.uid() AS uid) = user_id));

create policy "boss_battles_select_own" on "public"."boss_battles" as PERMISSIVE for SELECT to "authenticated" using ((user_id = auth.uid()));

create policy "boss_steps_select_own" on "public"."boss_steps" as PERMISSIVE for SELECT to "authenticated" using ((user_id = auth.uid()));

create policy "Authenticated users can view active cosmetics" on "public"."cosmetics" as PERMISSIVE for SELECT to "authenticated" using ((active = true));

create policy "Authenticated users can view Hearth layout profiles" on "public"."hearth_layout_profiles" as PERMISSIVE for SELECT to "authenticated" using (true);

create policy "Authenticated users can view Hearth profile slots" on "public"."hearth_profile_slots" as PERMISSIVE for SELECT to "authenticated" using (true);

create policy "Authenticated users can view Hearth render registry" on "public"."hearth_render_registry" as PERMISSIVE for SELECT to "authenticated" using (true);

create policy "Authenticated users can view Hearth slots" on "public"."hearth_slots" as PERMISSIVE for SELECT to "authenticated" using (true);

create policy "progression_events_read_own" on "public"."progression_events" as PERMISSIVE for SELECT to "authenticated" using ((( SELECT auth.uid() AS uid) = user_id));

create policy "Users can create own reward events" on "public"."reward_events" as PERMISSIVE for INSERT to "authenticated" with check ((( SELECT auth.uid() AS uid) = user_id));

create policy "Users can view own reward events" on "public"."reward_events" as PERMISSIVE for SELECT to "authenticated" using ((( SELECT auth.uid() AS uid) = user_id));

create policy "Users can create own tasks" on "public"."tasks" as PERMISSIVE for INSERT to "authenticated" with check ((( SELECT auth.uid() AS uid) = user_id));

create policy "Users can delete own tasks" on "public"."tasks" as PERMISSIVE for DELETE to "authenticated" using ((( SELECT auth.uid() AS uid) = user_id));

create policy "Users can update own tasks" on "public"."tasks" as PERMISSIVE for UPDATE to "authenticated" using ((( SELECT auth.uid() AS uid) = user_id)) with check ((( SELECT auth.uid() AS uid) = user_id));

create policy "Users can view own tasks" on "public"."tasks" as PERMISSIVE for SELECT to "authenticated" using ((( SELECT auth.uid() AS uid) = user_id));

create policy "Users can view own cosmetics" on "public"."user_cosmetics" as PERMISSIVE for SELECT to "authenticated" using ((( SELECT auth.uid() AS uid) = user_id));

create policy "Users can create own profile" on "public"."users" as PERMISSIVE for INSERT to "authenticated" with check ((( SELECT auth.uid() AS uid) = id));

create policy "Users can update own profile" on "public"."users" as PERMISSIVE for UPDATE to "authenticated" using ((( SELECT auth.uid() AS uid) = id)) with check ((( SELECT auth.uid() AS uid) = id));

create policy "Users can view own profile" on "public"."users" as PERMISSIVE for SELECT to "authenticated" using ((( SELECT auth.uid() AS uid) = id));

create policy "beta feedback screenshot delete own" on "storage"."objects" as PERMISSIVE for DELETE to "authenticated" using (((bucket_id = 'beta-feedback'::text) AND ((storage.foldername(name))[1] = (( SELECT auth.uid() AS uid))::text)));

create policy "beta feedback screenshot read own" on "storage"."objects" as PERMISSIVE for SELECT to "authenticated" using (((bucket_id = 'beta-feedback'::text) AND ((storage.foldername(name))[1] = (( SELECT auth.uid() AS uid))::text)));

create policy "beta feedback screenshot upload" on "storage"."objects" as PERMISSIVE for INSERT to "authenticated" with check (((bucket_id = 'beta-feedback'::text) AND ((storage.foldername(name))[1] = (( SELECT auth.uid() AS uid))::text)));

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER questwell_feedback_default_triage BEFORE INSERT ON public.beta_feedback FOR EACH ROW EXECUTE FUNCTION public.questwell_feedback_default_triage();

CREATE TRIGGER questwell_feedback_insert_guard BEFORE INSERT ON public.beta_feedback FOR EACH ROW EXECUTE FUNCTION public.questwell_feedback_insert_guard();

CREATE TRIGGER enforce_collection_archetype BEFORE INSERT OR UPDATE ON public.cosmetics FOR EACH ROW EXECUTE FUNCTION public.enforce_collection_archetype();

CREATE TRIGGER record_milestone_reward AFTER INSERT ON public.user_cosmetics FOR EACH ROW EXECUTE FUNCTION private.record_milestone_reward();

CREATE TRIGGER return_unsupported_trophy AFTER DELETE OR UPDATE ON public.user_cosmetics FOR EACH ROW EXECUTE FUNCTION private.return_unsupported_trophy();

CREATE TRIGGER award_first_journey AFTER INSERT OR UPDATE OF level ON public.users FOR EACH ROW EXECUTE FUNCTION private.award_first_journey();

CREATE TRIGGER protect_level_xp_offset BEFORE INSERT OR UPDATE OF level_xp_offset ON public.users FOR EACH ROW EXECUTE FUNCTION private.protect_level_xp_offset();

CREATE TRIGGER record_level_milestones AFTER UPDATE OF level ON public.users FOR EACH ROW EXECUTE FUNCTION private.record_level_milestones();

-- Explicit ACLs reproduce observed privileges, including known over-grants.

revoke all on schema "private" from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

revoke all on schema "public" from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

revoke all on table "public"."beta_feedback" from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

revoke all on table "public"."boss_battles" from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

revoke all on table "public"."boss_steps" from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

revoke all on table "public"."cosmetics" from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

revoke all on table "public"."hearth_layout_profiles" from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

revoke all on table "public"."hearth_profile_slots" from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

revoke all on table "public"."hearth_render_registry" from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

revoke all on table "public"."hearth_slots" from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

revoke all on table "public"."progression_events" from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

revoke all on table "public"."reward_events" from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

revoke all on table "public"."tasks" from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

revoke all on table "public"."user_cosmetics" from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

revoke all on table "public"."users" from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "private"."award_first_journey"() owner to "postgres";

revoke all on function "private"."award_first_journey"() from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "private"."claim_class_mastery_reward"() owner to "postgres";

revoke all on function "private"."claim_class_mastery_reward"() from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "private"."complete_boss_step"(p_step_id uuid) owner to "postgres";

revoke all on function "private"."complete_boss_step"(p_step_id uuid) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "private"."complete_task"(p_task_id uuid) owner to "postgres";

revoke all on function "private"."complete_task"(p_task_id uuid) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "private"."cosmetic_supports_body"(p_slug text, p_body_type text) owner to "postgres";

revoke all on function "private"."cosmetic_supports_body"(p_slug text, p_body_type text) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "private"."create_boss_battle"(p_title text, p_steps text[], p_reward_xp integer, p_reward_coins integer, p_boss_type text) owner to "postgres";

revoke all on function "private"."create_boss_battle"(p_title text, p_steps text[], p_reward_xp integer, p_reward_coins integer, p_boss_type text) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "private"."equip_cosmetic"(p_cosmetic_id uuid) owner to "postgres";

revoke all on function "private"."equip_cosmetic"(p_cosmetic_id uuid) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "private"."equip_cosmetic_loadout"(p_cosmetic_id uuid, p_expected_conflict uuid) owner to "postgres";

revoke all on function "private"."equip_cosmetic_loadout"(p_cosmetic_id uuid, p_expected_conflict uuid) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "private"."level_for_xp"(p_xp bigint) owner to "postgres";

revoke all on function "private"."level_for_xp"(p_xp bigint) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "private"."place_hearth_cosmetic"(p_cosmetic_id uuid, p_slot text, p_expected_occupant uuid) owner to "postgres";

revoke all on function "private"."place_hearth_cosmetic"(p_cosmetic_id uuid, p_slot text, p_expected_occupant uuid) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "private"."protect_level_xp_offset"() owner to "postgres";

revoke all on function "private"."protect_level_xp_offset"() from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "private"."purchase_cosmetic"(p_cosmetic_id uuid) owner to "postgres";

revoke all on function "private"."purchase_cosmetic"(p_cosmetic_id uuid) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "private"."record_level_milestones"() owner to "postgres";

revoke all on function "private"."record_level_milestones"() from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "private"."record_milestone_reward"() owner to "postgres";

revoke all on function "private"."record_milestone_reward"() from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "private"."return_unsupported_trophy"() owner to "postgres";

revoke all on function "private"."return_unsupported_trophy"() from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "private"."set_adventurer_archetype"(p_archetype text) owner to "postgres";

revoke all on function "private"."set_adventurer_archetype"(p_archetype text) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "private"."set_avatar_body_type"(p_body_type text) owner to "postgres";

revoke all on function "private"."set_avatar_body_type"(p_body_type text) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "private"."unequip_cosmetic"(p_cosmetic_id uuid) owner to "postgres";

revoke all on function "private"."unequip_cosmetic"(p_cosmetic_id uuid) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "private"."xp_at_level"(p_level integer) owner to "postgres";

revoke all on function "private"."xp_at_level"(p_level integer) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "public"."claim_class_mastery_reward"() owner to "postgres";

revoke all on function "public"."claim_class_mastery_reward"() from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "public"."complete_boss_step"(p_step_id uuid) owner to "postgres";

revoke all on function "public"."complete_boss_step"(p_step_id uuid) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "public"."complete_task"(p_task_id uuid) owner to "postgres";

revoke all on function "public"."complete_task"(p_task_id uuid) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "public"."create_boss_battle"(p_title text, p_steps text[], p_reward_xp integer, p_reward_coins integer, p_boss_type text) owner to "postgres";

revoke all on function "public"."create_boss_battle"(p_title text, p_steps text[], p_reward_xp integer, p_reward_coins integer, p_boss_type text) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "public"."enforce_collection_archetype"() owner to "postgres";

revoke all on function "public"."enforce_collection_archetype"() from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "public"."equip_cosmetic"(p_cosmetic_id uuid) owner to "postgres";

revoke all on function "public"."equip_cosmetic"(p_cosmetic_id uuid) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "public"."equip_cosmetic_loadout"(p_cosmetic_id uuid, p_expected_conflict uuid) owner to "postgres";

revoke all on function "public"."equip_cosmetic_loadout"(p_cosmetic_id uuid, p_expected_conflict uuid) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "public"."handle_new_user"() owner to "postgres";

revoke all on function "public"."handle_new_user"() from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "public"."place_hearth_cosmetic"(p_cosmetic_id uuid, p_slot text, p_expected_occupant uuid) owner to "postgres";

revoke all on function "public"."place_hearth_cosmetic"(p_cosmetic_id uuid, p_slot text, p_expected_occupant uuid) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "public"."purchase_cosmetic"(p_cosmetic_id uuid) owner to "postgres";

revoke all on function "public"."purchase_cosmetic"(p_cosmetic_id uuid) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "public"."questwell_feedback_default_triage"() owner to "postgres";

revoke all on function "public"."questwell_feedback_default_triage"() from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "public"."questwell_feedback_insert_guard"() owner to "postgres";

revoke all on function "public"."questwell_feedback_insert_guard"() from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "public"."set_adventurer_archetype"(p_archetype text) owner to "postgres";

revoke all on function "public"."set_adventurer_archetype"(p_archetype text) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "public"."set_avatar_body_type"(p_body_type text) owner to "postgres";

revoke all on function "public"."set_avatar_body_type"(p_body_type text) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "public"."set_pinned_quest"(p_task_id uuid) owner to "postgres";

revoke all on function "public"."set_pinned_quest"(p_task_id uuid) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter function "public"."unequip_cosmetic"(p_cosmetic_id uuid) owner to "postgres";

revoke all on function "public"."unequip_cosmetic"(p_cosmetic_id uuid) from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

grant INSERT ("attachment_path") on table "public"."beta_feedback" to "authenticated";

grant INSERT ("attachment_paths") on table "public"."beta_feedback" to "authenticated";

grant INSERT ("build") on table "public"."beta_feedback" to "authenticated";

grant INSERT ("category") on table "public"."beta_feedback" to "authenticated";

grant INSERT ("device") on table "public"."beta_feedback" to "authenticated";

grant INSERT ("expected") on table "public"."beta_feedback" to "authenticated";

grant INSERT ("goal") on table "public"."beta_feedback" to "authenticated";

grant INSERT ("id") on table "public"."beta_feedback" to "authenticated";

grant INSERT ("message") on table "public"."beta_feedback" to "authenticated";

grant INSERT ("platform") on table "public"."beta_feedback" to "authenticated";

grant INSERT ("reply_email") on table "public"."beta_feedback" to "authenticated";

grant INSERT ("screen") on table "public"."beta_feedback" to "authenticated";

grant INSERT ("steps") on table "public"."beta_feedback" to "authenticated";

grant INSERT ("user_id") on table "public"."beta_feedback" to "authenticated";

grant UPDATE ("current_energy_mode") on table "public"."users" to "authenticated";

grant UPDATE ("display_name") on table "public"."users" to "authenticated";

grant UPDATE ("onboarding_completed") on table "public"."users" to "authenticated";

grant EXECUTE on function "private"."award_first_journey"() to "postgres";

grant EXECUTE on function "private"."claim_class_mastery_reward"() to "authenticated";

grant EXECUTE on function "private"."claim_class_mastery_reward"() to "postgres";

grant EXECUTE on function "private"."claim_class_mastery_reward"() to "service_role";

grant EXECUTE on function "private"."complete_boss_step"(p_step_id uuid) to "authenticated";

grant EXECUTE on function "private"."complete_boss_step"(p_step_id uuid) to "postgres";

grant EXECUTE on function "private"."complete_boss_step"(p_step_id uuid) to "service_role";

grant EXECUTE on function "private"."complete_task"(p_task_id uuid) to "authenticated";

grant EXECUTE on function "private"."complete_task"(p_task_id uuid) to "postgres";

grant EXECUTE on function "private"."complete_task"(p_task_id uuid) to "service_role";

grant EXECUTE on function "private"."cosmetic_supports_body"(p_slug text, p_body_type text) to "postgres";

grant EXECUTE on function "private"."create_boss_battle"(p_title text, p_steps text[], p_reward_xp integer, p_reward_coins integer, p_boss_type text) to "authenticated";

grant EXECUTE on function "private"."create_boss_battle"(p_title text, p_steps text[], p_reward_xp integer, p_reward_coins integer, p_boss_type text) to "postgres";

grant EXECUTE on function "private"."create_boss_battle"(p_title text, p_steps text[], p_reward_xp integer, p_reward_coins integer, p_boss_type text) to "service_role";

grant EXECUTE on function "private"."equip_cosmetic"(p_cosmetic_id uuid) to "authenticated";

grant EXECUTE on function "private"."equip_cosmetic"(p_cosmetic_id uuid) to "postgres";

grant EXECUTE on function "private"."equip_cosmetic"(p_cosmetic_id uuid) to "service_role";

grant EXECUTE on function "private"."equip_cosmetic_loadout"(p_cosmetic_id uuid, p_expected_conflict uuid) to "authenticated";

grant EXECUTE on function "private"."equip_cosmetic_loadout"(p_cosmetic_id uuid, p_expected_conflict uuid) to "postgres";

grant EXECUTE on function "private"."level_for_xp"(p_xp bigint) to "postgres";

grant EXECUTE on function "private"."place_hearth_cosmetic"(p_cosmetic_id uuid, p_slot text, p_expected_occupant uuid) to "authenticated";

grant EXECUTE on function "private"."place_hearth_cosmetic"(p_cosmetic_id uuid, p_slot text, p_expected_occupant uuid) to "postgres";

grant EXECUTE on function "private"."protect_level_xp_offset"() to "postgres";

grant EXECUTE on function "private"."purchase_cosmetic"(p_cosmetic_id uuid) to "authenticated";

grant EXECUTE on function "private"."purchase_cosmetic"(p_cosmetic_id uuid) to "postgres";

grant EXECUTE on function "private"."purchase_cosmetic"(p_cosmetic_id uuid) to "service_role";

grant EXECUTE on function "private"."record_level_milestones"() to "postgres";

grant EXECUTE on function "private"."record_milestone_reward"() to "postgres";

grant EXECUTE on function "private"."return_unsupported_trophy"() to "postgres";

grant EXECUTE on function "private"."set_adventurer_archetype"(p_archetype text) to "authenticated";

grant EXECUTE on function "private"."set_adventurer_archetype"(p_archetype text) to "postgres";

grant EXECUTE on function "private"."set_adventurer_archetype"(p_archetype text) to "service_role";

grant EXECUTE on function "private"."set_avatar_body_type"(p_body_type text) to "authenticated";

grant EXECUTE on function "private"."set_avatar_body_type"(p_body_type text) to "postgres";

grant EXECUTE on function "private"."set_avatar_body_type"(p_body_type text) to "service_role";

grant EXECUTE on function "private"."unequip_cosmetic"(p_cosmetic_id uuid) to "authenticated";

grant EXECUTE on function "private"."unequip_cosmetic"(p_cosmetic_id uuid) to "postgres";

grant EXECUTE on function "private"."unequip_cosmetic"(p_cosmetic_id uuid) to "service_role";

grant EXECUTE on function "private"."xp_at_level"(p_level integer) to "postgres";

grant EXECUTE on function "public"."claim_class_mastery_reward"() to "authenticated";

grant EXECUTE on function "public"."claim_class_mastery_reward"() to "postgres";

grant EXECUTE on function "public"."claim_class_mastery_reward"() to "service_role";

grant EXECUTE on function "public"."complete_boss_step"(p_step_id uuid) to "authenticated";

grant EXECUTE on function "public"."complete_boss_step"(p_step_id uuid) to "postgres";

grant EXECUTE on function "public"."complete_boss_step"(p_step_id uuid) to "service_role";

grant EXECUTE on function "public"."complete_task"(p_task_id uuid) to "authenticated";

grant EXECUTE on function "public"."complete_task"(p_task_id uuid) to "postgres";

grant EXECUTE on function "public"."complete_task"(p_task_id uuid) to "service_role";

grant EXECUTE on function "public"."create_boss_battle"(p_title text, p_steps text[], p_reward_xp integer, p_reward_coins integer, p_boss_type text) to "authenticated";

grant EXECUTE on function "public"."create_boss_battle"(p_title text, p_steps text[], p_reward_xp integer, p_reward_coins integer, p_boss_type text) to "postgres";

grant EXECUTE on function "public"."create_boss_battle"(p_title text, p_steps text[], p_reward_xp integer, p_reward_coins integer, p_boss_type text) to "service_role";

grant EXECUTE on function "public"."enforce_collection_archetype"() to "postgres";

grant EXECUTE on function "public"."enforce_collection_archetype"() to "service_role";

grant EXECUTE on function "public"."equip_cosmetic"(p_cosmetic_id uuid) to "authenticated";

grant EXECUTE on function "public"."equip_cosmetic"(p_cosmetic_id uuid) to "postgres";

grant EXECUTE on function "public"."equip_cosmetic"(p_cosmetic_id uuid) to "service_role";

grant EXECUTE on function "public"."equip_cosmetic_loadout"(p_cosmetic_id uuid, p_expected_conflict uuid) to "authenticated";

grant EXECUTE on function "public"."equip_cosmetic_loadout"(p_cosmetic_id uuid, p_expected_conflict uuid) to "postgres";

grant EXECUTE on function "public"."equip_cosmetic_loadout"(p_cosmetic_id uuid, p_expected_conflict uuid) to "service_role";

grant EXECUTE on function "public"."handle_new_user"() to "postgres";

grant EXECUTE on function "public"."handle_new_user"() to "service_role";

grant EXECUTE on function "public"."place_hearth_cosmetic"(p_cosmetic_id uuid, p_slot text, p_expected_occupant uuid) to "authenticated";

grant EXECUTE on function "public"."place_hearth_cosmetic"(p_cosmetic_id uuid, p_slot text, p_expected_occupant uuid) to "postgres";

grant EXECUTE on function "public"."place_hearth_cosmetic"(p_cosmetic_id uuid, p_slot text, p_expected_occupant uuid) to "service_role";

grant EXECUTE on function "public"."purchase_cosmetic"(p_cosmetic_id uuid) to "authenticated";

grant EXECUTE on function "public"."purchase_cosmetic"(p_cosmetic_id uuid) to "postgres";

grant EXECUTE on function "public"."purchase_cosmetic"(p_cosmetic_id uuid) to "service_role";

grant EXECUTE on function "public"."questwell_feedback_default_triage"() to "postgres";

grant EXECUTE on function "public"."questwell_feedback_default_triage"() to "service_role";

grant EXECUTE on function "public"."questwell_feedback_insert_guard"() to "postgres";

grant EXECUTE on function "public"."questwell_feedback_insert_guard"() to "service_role";

grant EXECUTE on function "public"."set_adventurer_archetype"(p_archetype text) to "authenticated";

grant EXECUTE on function "public"."set_adventurer_archetype"(p_archetype text) to "postgres";

grant EXECUTE on function "public"."set_adventurer_archetype"(p_archetype text) to "service_role";

grant EXECUTE on function "public"."set_avatar_body_type"(p_body_type text) to "authenticated";

grant EXECUTE on function "public"."set_avatar_body_type"(p_body_type text) to "postgres";

grant EXECUTE on function "public"."set_avatar_body_type"(p_body_type text) to "service_role";

grant EXECUTE on function "public"."set_pinned_quest"(p_task_id uuid) to "authenticated";

grant EXECUTE on function "public"."set_pinned_quest"(p_task_id uuid) to "postgres";

grant EXECUTE on function "public"."set_pinned_quest"(p_task_id uuid) to "service_role";

grant EXECUTE on function "public"."unequip_cosmetic"(p_cosmetic_id uuid) to "authenticated";

grant EXECUTE on function "public"."unequip_cosmetic"(p_cosmetic_id uuid) to "postgres";

grant EXECUTE on function "public"."unequip_cosmetic"(p_cosmetic_id uuid) to "service_role";

grant USAGE on schema "private" to "authenticated";

grant CREATE, USAGE on schema "private" to "postgres";

grant USAGE on schema "public" to "anon";

grant USAGE on schema "public" to "authenticated";

grant CREATE, USAGE on schema "public" to "pg_database_owner";

grant USAGE on schema "public" to "postgres";

grant USAGE on schema "public" to PUBLIC;

grant USAGE on schema "public" to "service_role";

grant SELECT on table "public"."beta_feedback" to "authenticated";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."beta_feedback" to "postgres";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."beta_feedback" to "service_role";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."boss_battles" to "anon";

grant MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE on table "public"."boss_battles" to "authenticated";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."boss_battles" to "postgres";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."boss_battles" to "service_role";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."boss_steps" to "anon";

grant MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE on table "public"."boss_steps" to "authenticated";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."boss_steps" to "postgres";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."boss_steps" to "service_role";

grant MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE on table "public"."cosmetics" to "authenticated";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."cosmetics" to "postgres";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."cosmetics" to "service_role";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."hearth_layout_profiles" to "anon";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."hearth_layout_profiles" to "authenticated";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."hearth_layout_profiles" to "postgres";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."hearth_layout_profiles" to "service_role";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."hearth_profile_slots" to "anon";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."hearth_profile_slots" to "authenticated";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."hearth_profile_slots" to "postgres";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."hearth_profile_slots" to "service_role";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."hearth_render_registry" to "anon";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."hearth_render_registry" to "authenticated";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."hearth_render_registry" to "postgres";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."hearth_render_registry" to "service_role";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."hearth_slots" to "anon";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."hearth_slots" to "authenticated";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."hearth_slots" to "postgres";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."hearth_slots" to "service_role";

grant SELECT on table "public"."progression_events" to "authenticated";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."progression_events" to "postgres";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."progression_events" to "service_role";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."reward_events" to "anon";

grant DELETE, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."reward_events" to "authenticated";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."reward_events" to "postgres";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."reward_events" to "service_role";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."tasks" to "anon";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."tasks" to "authenticated";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."tasks" to "postgres";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."tasks" to "service_role";

grant MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE on table "public"."user_cosmetics" to "authenticated";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."user_cosmetics" to "postgres";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."user_cosmetics" to "service_role";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."users" to "anon";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE on table "public"."users" to "authenticated";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."users" to "postgres";

grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on table "public"."users" to "service_role";

-- Preserve postgres's observed per-schema defaults for future isolated migrations.

alter default privileges for role postgres in schema "public" revoke all on functions from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter default privileges for role postgres in schema "public" revoke all on tables from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter default privileges for role postgres in schema "public" revoke all on sequences from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter default privileges for role postgres in schema "private" revoke all on functions from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter default privileges for role postgres in schema "private" revoke all on tables from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter default privileges for role postgres in schema "private" revoke all on sequences from PUBLIC, "anon", "authenticated", "service_role", "postgres", "pg_database_owner";

alter default privileges for role postgres in schema "public" grant EXECUTE on functions to "anon";

alter default privileges for role postgres in schema "public" grant EXECUTE on functions to "authenticated";

alter default privileges for role postgres in schema "public" grant EXECUTE on functions to "postgres";

alter default privileges for role postgres in schema "public" grant EXECUTE on functions to "service_role";

alter default privileges for role postgres in schema "public" grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on tables to "anon";

alter default privileges for role postgres in schema "public" grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on tables to "authenticated";

alter default privileges for role postgres in schema "public" grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on tables to "postgres";

alter default privileges for role postgres in schema "public" grant DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE on tables to "service_role";

alter default privileges for role postgres in schema "public" grant SELECT, UPDATE, USAGE on sequences to "anon";

alter default privileges for role postgres in schema "public" grant SELECT, UPDATE, USAGE on sequences to "authenticated";

alter default privileges for role postgres in schema "public" grant SELECT, UPDATE, USAGE on sequences to "postgres";

alter default privileges for role postgres in schema "public" grant SELECT, UPDATE, USAGE on sequences to "service_role";

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values ('beta-feedback', 'beta-feedback', false, 5242880, array['image/png', 'image/jpeg', 'image/webp']::text[]);

notify pgrst, 'reload schema';

commit;
