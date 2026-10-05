-- Harness-only schema. This is NOT a Questwell baseline or app migration.
-- CLI 2.119.0 db query prepares a single statement, including with --file.
do $fixture$
begin
create schema ci_guard;
revoke all on schema ci_guard from public, anon, authenticated;
create table ci_guard.marker (name text primary key);
alter table ci_guard.marker enable row level security;
insert into ci_guard.marker values ('questwell-disposable-ci');

create table public.ci_owner_probe (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  value integer not null default 0
);
create index ci_owner_probe_owner_idx on public.ci_owner_probe(owner_id);
alter table public.ci_owner_probe enable row level security;
revoke all on public.ci_owner_probe from public, anon, authenticated;
grant select on public.ci_owner_probe to anon;
grant select, insert, update, delete on public.ci_owner_probe to authenticated;
create policy ci_owner_only on public.ci_owner_probe
  for all to authenticated
  using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);
notify pgrst, 'reload schema';
end;
$fixture$;
