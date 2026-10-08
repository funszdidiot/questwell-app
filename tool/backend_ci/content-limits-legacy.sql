do $$
declare owner_id uuid; step_index integer;
begin
  select id into strict owner_id from public.users limit 1;
  insert into public.tasks(id,user_id,title,notes,status,friction_level)
  values ('90000000-0000-4000-8000-000000000120',owner_id,'',repeat('x',4001),'open',1);
  insert into public.boss_battles(id,user_id,title)
  values ('90000000-0000-4000-8000-000000000051',owner_id,'Legacy oversized boss');
  for step_index in 1..51 loop
    insert into public.boss_steps(boss_id,user_id,title,position)
    values ('90000000-0000-4000-8000-000000000051',owner_id,'Step '||step_index,step_index);
  end loop;
end $$;
