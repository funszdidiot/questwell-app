-- Approved Hearth follow-through, 2026-10-01.
-- Return every supported collectible if its final bookcase is removed or replaced.
-- Preserve ownership, reward progress, and existing function privileges.
begin;
create or replace function private.return_unsupported_trophy()
returns trigger language plpgsql set search_path='' as $function$
begin
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
end $function$;

-- Repair any previously hidden display; no item is deleted or revoked.
update public.user_cosmetics uc set equipped=false,room_slot=null
from public.cosmetics c
where uc.cosmetic_id=c.id and uc.equipped and uc.room_slot='bookshelf_top'
 and c.slug in ('first-journey-trophy','starlit-orrery','scholar-seal',
   'scout-compass','alchemist-phial','guardian-crest','wanderer-star-map')
 and not exists(
   select 1 from public.user_cosmetics support
   join public.cosmetics shelf on shelf.id=support.cosmetic_id
   where support.user_id=uc.user_id and support.equipped and shelf.active
     and shelf.slug='walnut-bookshelf' and support.room_slot in ('left','right')
 );
commit;
