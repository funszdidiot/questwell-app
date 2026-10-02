-- Applied migration: allow_auth_account_deletion_without_trophy_relayout
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
end $function$
;
