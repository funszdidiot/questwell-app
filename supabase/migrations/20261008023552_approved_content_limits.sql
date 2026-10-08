-- New/explicitly edited content only. No scan, UPDATE, truncation or purge.
-- This forward proposal must pass disposable CI and target review before deployment.
create function private.enforce_content_limits()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  -- Unicode White_Space plus BOM, matching Dart String.trim.
  trim_chars constant text := U&'\0009\000A\000B\000C\000D\0020\0085\00A0\1680\2000\2001\2002\2003\2004\2005\2006\2007\2008\2009\200A\2028\2029\202F\205F\3000\FEFF';
  title_size integer;
begin
  title_size := pg_catalog.char_length(pg_catalog.btrim(new.title, trim_chars));
  if title_size is null or title_size < 1 or title_size > 120 then
    raise exception using errcode = '22023', message = 'Name must contain 1-120 characters after trimming.';
  end if;
  if tg_table_name = 'tasks' then
    if tg_op = 'INSERT' then
      if pg_catalog.char_length(new.notes) > 4000 then
        raise exception using errcode = '22023', message = 'Description must contain at most 4000 characters.';
      end if;
    elsif new.notes is distinct from old.notes and pg_catalog.char_length(new.notes) > 4000 then
      raise exception using errcode = '22023', message = 'Description must contain at most 4000 characters.';
    end if;
  end if;
  return new;
end
$$;
revoke all on function private.enforce_content_limits() from public, anon, authenticated, service_role;

create trigger content_limits_tasks
before insert or update of title, notes on public.tasks
for each row execute function private.enforce_content_limits();
create trigger content_limits_bosses
before insert or update of title on public.boss_battles
for each row execute function private.enforce_content_limits();
create trigger content_limits_steps
before insert or update of title on public.boss_steps
for each row execute function private.enforce_content_limits();

create function private.enforce_boss_step_limit()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE' then
    if new.boss_id is not distinct from old.boss_id then return new; end if;
  end if;
  -- Serialize additions to one boss. A count without this lock races at step 50.
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(new.boss_id::text, 73650));
  if (select count(*) from public.boss_steps where boss_id = new.boss_id) >= 50 then
    raise exception using errcode = '22023', message = 'A boss may have at most 50 attack steps.';
  end if;
  return new;
end
$$;
revoke all on function private.enforce_boss_step_limit() from public, anon, authenticated, service_role;
create trigger content_limits_step_count
before insert or update of boss_id on public.boss_steps
for each row execute function private.enforce_boss_step_limit();
