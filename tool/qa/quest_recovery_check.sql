-- Run each PHASE as a separate database request, in order. Always run cleanup.
-- PHASE: setup
begin;
-- Disposable fixture only. A collision fails instead of modifying existing data.
insert into auth.users(id,email) values ('a7833b0a-2655-4a41-b9e2-29a0747c312e','a7833b0a-2655-4a41-b9e2-29a0747c312e@quest-retry.example.invalid');
update public.users set total_xp=0, level=1, coin_balance=0, level_xp_offset=0 where id='a7833b0a-2655-4a41-b9e2-29a0747c312e';
insert into public.tasks(id,user_id,title,status,xp_value,coin_value)
values ('be462130-fbb0-43b1-9259-ad0d8411a45c','a7833b0a-2655-4a41-b9e2-29a0747c312e','Disposable quest retry check','open',25,5);
commit;
-- PHASE: abort
begin;
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"a7833b0a-2655-4a41-b9e2-29a0747c312e","role":"authenticated"}',true);

do $$ begin
  begin
    perform public.complete_task('be462130-fbb0-43b1-9259-ad0d8411a45c');
    raise exception using errcode='QW001',message='Injected transaction abort';
  exception when sqlstate 'QW001' then null;
  end;
  if not exists(select 1 from public.tasks where id='be462130-fbb0-43b1-9259-ad0d8411a45c' and status='open' and completed_at is null)
    or not exists(select 1 from public.users where id=auth.uid() and total_xp=0 and coin_balance=0)
    or exists(select 1 from public.reward_events where task_id='be462130-fbb0-43b1-9259-ad0d8411a45c')
  then raise exception 'Aborted completion left partial state'; end if;
end $$;
commit;
-- PHASE: commit_without_result
begin;
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"a7833b0a-2655-4a41-b9e2-29a0747c312e","role":"authenticated"}',true);

-- Intentionally discard the RPC result. Commit before a separate retry call.
-- This simulates a lost response; it does not interrupt a physical network.
do $$ begin perform public.complete_task('be462130-fbb0-43b1-9259-ad0d8411a45c'); end $$;
commit;
-- PHASE: retry_and_verify
begin;
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"a7833b0a-2655-4a41-b9e2-29a0747c312e","role":"authenticated"}',true);

do $$
declare n int; rejected bool; saved_time timestamptz;
begin
  select completed_at into strict saved_time from public.tasks where id='be462130-fbb0-43b1-9259-ad0d8411a45c';
  if saved_time is null then raise exception 'Completion was not persisted'; end if;
  for n in 1..5 loop
    rejected := false;
    begin perform public.complete_task('be462130-fbb0-43b1-9259-ad0d8411a45c');
    exception when others then
      if sqlerrm <> 'task not found, not owned by caller, or already completed' then raise; end if;
      rejected := true;
    end;
    if not rejected then raise exception 'Duplicate completion was accepted'; end if;
  end loop;
  if not exists(select 1 from public.tasks where id='be462130-fbb0-43b1-9259-ad0d8411a45c' and status='completed' and completed_at=saved_time)
    or not exists(select 1 from public.users where id=auth.uid() and total_xp=25 and coin_balance=5 and level=1)
    or (select count(*) from public.reward_events where task_id='be462130-fbb0-43b1-9259-ad0d8411a45c')<>1
    or not exists(select 1 from public.reward_events where task_id='be462130-fbb0-43b1-9259-ad0d8411a45c' and event_type='task_completed' and xp_amount=25 and coin_amount=5)
  then raise exception 'Retry changed completion, totals or reward event'; end if;
end $$;
select 'PASS: committed completion plus five retries = 25 XP, 5 coins, one event; timestamp unchanged' as verification;
commit;
-- PHASE: cleanup
begin;
-- Run this phase even when an earlier assertion fails; exact fixture identity only.
delete from auth.users where id='a7833b0a-2655-4a41-b9e2-29a0747c312e' and email='a7833b0a-2655-4a41-b9e2-29a0747c312e@quest-retry.example.invalid';
do $$ begin
  if exists(select 1 from auth.users where id='a7833b0a-2655-4a41-b9e2-29a0747c312e')
    or exists(select 1 from public.users where id='a7833b0a-2655-4a41-b9e2-29a0747c312e')
    or exists(select 1 from public.tasks where id='be462130-fbb0-43b1-9259-ad0d8411a45c')
    or exists(select 1 from public.reward_events where task_id='be462130-fbb0-43b1-9259-ad0d8411a45c')
  then raise exception 'Fixture cleanup incomplete'; end if;
end $$;
commit;
select 'PASS: disposable account, quest and reward removed' as cleanup;
