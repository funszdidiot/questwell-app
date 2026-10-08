do $$
declare t public.tasks; u uuid; b uuid; n integer;
begin
  select * into strict t from public.tasks where id='90000000-0000-4000-8000-000000000120';
  if t.title <> '' or char_length(t.notes) <> 4001 then raise exception 'Legacy record was modified'; end if;
  update public.tasks set pinned_at=now() where id=t.id;
  begin
    update public.tasks set title=title where id=t.id;
    raise exception 'Invalid legacy title edit accepted';
  exception when invalid_parameter_value then null; end;
  update public.tasks set title='Corrected by owner' where id=t.id;
  if (select char_length(notes) from public.tasks where id=t.id) <> 4001 then raise exception 'Legacy notes truncated'; end if;
  begin
    update public.tasks set notes=repeat('x',4002) where id=t.id;
    raise exception 'Long notes accepted';
  exception when invalid_parameter_value then null; end;
  update public.tasks set notes=repeat('🧭',4000) where id=t.id;
  update public.boss_steps set completed=true where boss_id='90000000-0000-4000-8000-000000000051';
  if (select count(*) from public.boss_steps where boss_id='90000000-0000-4000-8000-000000000051' and completed) <> 51 then
    raise exception 'Oversized legacy boss completion blocked';
  end if;
  u := t.user_id;
  insert into public.boss_battles(user_id,title) values(u,'Content limit fixture') returning id into b;
  for n in 1..50 loop
    insert into public.boss_steps(boss_id,user_id,title,position) values(b,u,'Step '||n,n);
  end loop;
  begin
    insert into public.boss_steps(boss_id,user_id,title,position) values(b,u,'Step 51',51);
    raise exception 'Step 51 accepted';
  exception when invalid_parameter_value then null; end;
  if (select count(*) from public.boss_steps where boss_id=b) <> 50 then raise exception 'Step count changed'; end if;
  update public.boss_steps set completed=true where boss_id=b;
  if (select count(*) from public.boss_steps where boss_id=b and completed) <> 50 then raise exception 'Completion blocked'; end if;
  if has_function_privilege('anon','private.enforce_content_limits()','EXECUTE') then raise exception 'Trigger helper exposed'; end if;
end $$;
