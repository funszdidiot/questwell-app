begin;

create table public.beta_feedback (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  category text not null check (category in ('bug', 'confusing', 'idea', 'positive')),
  goal text not null check (char_length(btrim(goal)) between 1 and 300),
  message text not null check (char_length(btrim(message)) between 1 and 3000),
  expected text not null default '' check (char_length(expected) <= 1000),
  steps text not null default '' check (char_length(steps) <= 1000),
  reply_email text not null default '' check (char_length(reply_email) <= 254 and
    (reply_email = '' or reply_email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$')),
  device text not null default '' check (char_length(device) <= 200),
  screen text not null check (screen in ('Hearth', 'Quests', 'Boss Battles', 'Expedition', 'Market', 'Adventurer', 'Chronicle', 'New quest', 'Other')),
  build text not null check (char_length(build) between 1 and 64 and build ~ '^[A-Za-z0-9._-]+$'),
  platform text not null check (char_length(platform) between 1 and 64 and platform ~ '^[A-Za-z0-9._-]+$'),
  status text not null default 'new' check (status in ('new', 'reviewed', 'resolved'))
);

comment on table public.beta_feedback is 'Private Questwell beta reports. Founder reviews in Supabase Table Editor. Deleted with the submitting account.';
create index beta_feedback_user_created_idx on public.beta_feedback (user_id, created_at desc);
create index beta_feedback_status_created_idx on public.beta_feedback (status, created_at desc);
alter table public.beta_feedback enable row level security;
revoke all on public.beta_feedback from public, anon, authenticated;
grant select on public.beta_feedback to authenticated;
grant insert (id, user_id, category, goal, message, expected, steps, reply_email, device, screen, build, platform)
  on public.beta_feedback to authenticated;
grant all on public.beta_feedback to service_role;

create policy beta_feedback_read_own on public.beta_feedback
  for select to authenticated using ((select auth.uid()) = user_id);
create policy beta_feedback_submit_own on public.beta_feedback
  for insert to authenticated with check ((select auth.uid()) = user_id);

-- Runs as the submitting role and respects RLS. No elevated privileges or
-- client-supplied timestamps/status values. Lock serializes per-account sends.
create function public.questwell_feedback_insert_guard()
returns trigger language plpgsql security invoker set search_path = '' as $$
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
$$;
revoke all on function public.questwell_feedback_insert_guard() from public, anon, authenticated;
create trigger questwell_feedback_insert_guard before insert on public.beta_feedback
  for each row execute function public.questwell_feedback_insert_guard();

commit;
