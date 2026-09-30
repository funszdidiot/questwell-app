alter table public.cosmetics add column milestone_level integer
 check (milestone_level is null or milestone_level >= 2);
update public.cosmetics set milestone_level=5 where slug='first-journey-trophy';

-- A journal, not an additional source of XP or coins.
create table public.progression_events (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.users(id) on delete cascade,
 kind text not null check (kind in ('level_up','milestone_reward')),
 event_key text not null,
 title text not null,
 level integer not null check (level >= 2),
 cosmetic_slug text,
 source text not null,
 occurred_at timestamptz not null default now(),
 unique(user_id,kind,event_key)
);
create index progression_events_user_time on public.progression_events(user_id,occurred_at desc);
alter table public.progression_events enable row level security;
revoke all on public.progression_events from public,anon,authenticated;
grant select on public.progression_events to authenticated;
create policy progression_events_read_own on public.progression_events
 for select to authenticated using ((select auth.uid())=user_id);

create function private.record_level_milestones()
returns trigger language plpgsql security invoker set search_path='' as $$
begin
 if new.level>old.level then
  insert into public.progression_events(user_id,kind,event_key,title,level,source)
   select new.id,'level_up',n::text,'Level '||n||' reached',n,'progression'
   from generate_series(greatest(old.level+1,2),new.level) n
   on conflict(user_id,kind,event_key) do nothing;
 end if;
 return new;
end $$;
revoke all on function private.record_level_milestones() from public,anon,authenticated;
create trigger record_level_milestones after update of level on public.users
 for each row execute function private.record_level_milestones();

create function private.record_milestone_reward()
returns trigger language plpgsql security invoker set search_path='' as $$
begin
 insert into public.progression_events(user_id,kind,event_key,title,level,cosmetic_slug,source,occurred_at)
  select new.user_id,'milestone_reward',c.slug,c.name,c.milestone_level,c.slug,new.source,new.unlocked_at
  from public.cosmetics c where c.id=new.cosmetic_id and c.unlock_method='level_milestone' and c.milestone_level is not null
  on conflict(user_id,kind,event_key) do nothing;
 return new;
end $$;
revoke all on function private.record_milestone_reward() from public,anon,authenticated;
create trigger record_milestone_reward after insert on public.user_cosmetics
 for each row execute function private.record_milestone_reward();

-- Ownership has a real timestamp, so it can be backfilled faithfully.
-- Historical level-up dates are unknown and are deliberately not invented.
insert into public.progression_events(user_id,kind,event_key,title,level,cosmetic_slug,source,occurred_at)
 select uc.user_id,'milestone_reward',c.slug,c.name,c.milestone_level,c.slug,uc.source,uc.unlocked_at
 from public.user_cosmetics uc join public.cosmetics c on c.id=uc.cosmetic_id
 where c.unlock_method='level_milestone' and c.milestone_level is not null
 on conflict(user_id,kind,event_key) do nothing;
notify pgrst, 'reload schema';
