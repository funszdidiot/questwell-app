begin;
create function public.account_export_snapshot()
returns jsonb language plpgsql stable security invoker set search_path = '' as $$
declare result jsonb; item record;
begin
 if not private.export_session_allowed() then raise exception 'Active session required' using errcode='42501'; end if;
 -- STABLE function reads all groups and Storage metadata at the calling query snapshot.
 select jsonb_build_object('collectedAt',statement_timestamp(),'tables',jsonb_build_object(
 'users', (select coalesce(jsonb_agg(to_jsonb(r)), '[]'::jsonb) from (select id,created_at,email,display_name,level,total_xp,coin_balance,current_energy_mode,onboarding_completed,adventurer_archetype,avatar_body_type,level_xp_offset from public.users where id=(select auth.uid()) order by id limit 10001) r),
 'tasks', (select coalesce(jsonb_agg(to_jsonb(r)), '[]'::jsonb) from (select id,user_id,created_at,title,notes,status,due_date,xp_value,coin_value,completed_at,friction_level,pinned_at from public.tasks where user_id=(select auth.uid()) order by id limit 10001) r),
 'boss_battles', (select coalesce(jsonb_agg(to_jsonb(r)), '[]'::jsonb) from (select id,user_id,title,status,reward_xp,reward_coins,created_at,completed_at,boss_type from public.boss_battles where user_id=(select auth.uid()) order by id limit 10001) r),
 'boss_steps', (select coalesce(jsonb_agg(to_jsonb(r)), '[]'::jsonb) from (select id,user_id,boss_id,title,position,completed,completed_at,created_at from public.boss_steps where user_id=(select auth.uid()) order by id limit 10001) r),
 'user_cosmetics', (select coalesce(jsonb_agg(to_jsonb(r)), '[]'::jsonb) from (select user_id,cosmetic_id,unlocked_at,source,equipped,room_slot from public.user_cosmetics where user_id=(select auth.uid()) order by cosmetic_id limit 10001) r),
 'progression_events', (select coalesce(jsonb_agg(to_jsonb(r)), '[]'::jsonb) from (select id,user_id,kind,event_key,title,level,cosmetic_slug,source,occurred_at from public.progression_events where user_id=(select auth.uid()) order by id limit 10001) r),
 'reward_events', (select coalesce(jsonb_agg(to_jsonb(r)), '[]'::jsonb) from (select id,user_id,task_id,event_type,xp_amount,coin_amount,created_at from public.reward_events where user_id=(select auth.uid()) order by id limit 10001) r),
 'beta_feedback', (select coalesce(jsonb_agg(to_jsonb(r)), '[]'::jsonb) from (select id,user_id,created_at,category,goal,message,expected,steps,reply_email,device,screen,build,platform,status,attachment_path,attachment_paths from public.beta_feedback where user_id=(select auth.uid()) order by id limit 10001) r)
 ),'objects',(select coalesce(jsonb_agg(to_jsonb(o)), '[]'::jsonb) from (
 select id,name as path,owner_id,version,metadata->>'eTag' as etag,(metadata->>'size')::bigint as size
 from storage.objects where bucket_id='beta-feedback' and owner_id=(select auth.uid())::text
 order by name limit 101) o)) into result;
 for item in select value from jsonb_each(result->'tables') loop
  if jsonb_array_length(item.value)>10000 then raise exception 'Export row limit';end if;
 end loop;
 if jsonb_array_length(result->'objects')>100 or octet_length(result::text)>8388608 then raise exception 'Export size limit';end if;
 return result;
end;
$$;
revoke all on function public.account_export_snapshot() from public,anon;
grant execute on function public.account_export_snapshot() to authenticated;
commit;
