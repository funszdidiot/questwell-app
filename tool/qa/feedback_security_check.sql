-- Disposable transaction; uses the existing dedicated test account without
-- changing auth credentials, profile data, or the founder's real reports.
begin;
select set_config('questwell.test.owner', (select id::text from auth.users
  where lower(email) = 'tanya.almodovar1+questwell-test@gmail.com'), true);
select set_config('questwell.test.other', (select id::text from auth.users
  where lower(email) = 'tanya.almodovar1@gmail.com'), true);
select set_config('request.jwt.claim.sub', current_setting('questwell.test.owner'), true);

insert into public.beta_feedback(id,user_id,category,goal,message,screen,build,platform)
values ('8ed693bb-93ec-4e7b-9194-b0560f8c8120', current_setting('questwell.test.other')::uuid,
  'bug','Synthetic isolation fixture','Rollback-only fixture','Hearth','security-check','web-ios');

set local role authenticated;
do $$
declare fixture_id uuid := '8ed693bb-93ec-4e7b-9194-b0560f8c8121';
begin
  if exists (select 1 from public.beta_feedback where id='8ed693bb-93ec-4e7b-9194-b0560f8c8120') then
    raise exception 'Cross-account SELECT was allowed';
  end if;
  insert into public.beta_feedback(id,user_id,category,goal,message,screen,build,platform)
    values(fixture_id,auth.uid(),'bug','Send a note','Synthetic QA report','Quests','security-check','web-ios');
  if (select count(*) from public.beta_feedback where id=fixture_id) <> 1 then
    raise exception 'Own report was not readable';
  end if;
  begin
    insert into public.beta_feedback(id,user_id,category,goal,message,screen,build,platform)
      values(fixture_id,auth.uid(),'bug','Retry','Same request ID','Quests','security-check','web-ios');
    raise exception 'Duplicate request was accepted';
  exception when unique_violation then null;
  end;
  begin
    insert into public.beta_feedback(id,user_id,category,goal,message,screen,build,platform)
      values(gen_random_uuid(),current_setting('questwell.test.other')::uuid,'bug','Spoof','Blocked','Quests','security-check','web-ios');
    raise exception 'Spoofed owner was accepted';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.beta_feedback(id,user_id,category,goal,message,screen,build,platform,status)
      values(gen_random_uuid(),auth.uid(),'bug','Spoof','Blocked','Quests','security-check','web-ios','resolved');
    raise exception 'Client status override was accepted';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.beta_feedback(id,user_id,category,goal,message,screen,build,platform)
      values(gen_random_uuid(),auth.uid(),'bug','  ','Invalid blank','Quests','security-check','web-ios');
    raise exception 'Blank report was accepted';
  exception when check_violation then null;
  end;
  begin
    insert into public.beta_feedback(id,user_id,category,goal,message,screen,build,platform)
      values(gen_random_uuid(),auth.uid(),'bug','Too long',repeat('x',3001),'Quests','security-check','web-ios');
    raise exception 'Oversized report was accepted';
  exception when check_violation then null;
  end;
  begin
    update public.beta_feedback set message='Modified' where id=fixture_id;
    raise exception 'Client UPDATE was accepted';
  exception when insufficient_privilege then null;
  end;
  begin
    delete from public.beta_feedback where id=fixture_id;
    raise exception 'Client DELETE was accepted';
  exception when insufficient_privilege then null;
  end;
  for i in 1..9 loop
    insert into public.beta_feedback(id,user_id,category,goal,message,screen,build,platform)
      values(gen_random_uuid(),auth.uid(),'idea','Rate limit fixture','Rollback only','Quests','security-check','web-ios');
  end loop;
  begin
    insert into public.beta_feedback(id,user_id,category,goal,message,screen,build,platform)
      values(gen_random_uuid(),auth.uid(),'idea','Rate limit fixture','Must be blocked','Quests','security-check','web-ios');
    raise exception 'Rate limit was not enforced';
  exception when raise_exception then
    if sqlerrm <> 'feedback_rate_limit' then raise; end if;
  end;
  begin
    insert into public.beta_feedback(id,user_id,category,goal,message,screen,build,platform)
      values(fixture_id,auth.uid(),'bug','Retry at limit','Original request','Quests','security-check','web-ios');
    raise exception 'Duplicate retry at limit was accepted';
  exception when unique_violation then null;
  end;
end;
$$;
set local role anon;
do $$
begin
  begin
    perform 1 from public.beta_feedback;
    raise exception 'Anonymous SELECT was accepted';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.beta_feedback(id,user_id,category,goal,message,screen,build,platform)
      values(gen_random_uuid(),current_setting('questwell.test.owner')::uuid,'bug','Anonymous','Blocked','Quests','security-check','web-ios');
    raise exception 'Anonymous INSERT was accepted';
  exception when insufficient_privilege then null;
  end;
end;
$$;
reset role;
select 'PASS: own insert/read, duplicate identity, cross-account isolation, anonymous denial, immutable client reports, payload limits, rate limit' as result;
rollback;
