-- HISTORICAL: temporary restriction superseded by migration 20261004164110.
-- The newer concurrent founder decision preserves all legacy availability.
-- Initially interpreted from the 2026-10-04 direction: "Push the male robes and every day outfit to the app".
-- Applies the reviewed coherent rollout from PR #9, including temporary male-only
-- restrictions on the four legacy chest fits. Ownership, balances, prices,
-- class requirements, activation flags and all other-body fits remain intact.
-- Five male class robes are default avatar renderers, not new shop items.
begin;
create or replace function private.cosmetic_supports_body(p_slug text, p_body_type text)
returns boolean language sql immutable security invoker set search_path = ''
as $function$
  select case
    when p_slug='everyday-adventurer-outfit' then coalesce(p_body_type in ('female','neutral','male'),false)
    when p_slug='woodland-scout-outfit' then coalesce(p_body_type='female',false)
    when p_slug in ('starter-business-suit','midnight-harvest-coat','moss-green-cloak','hearthguard-mantle')
      then coalesce(p_body_type in ('female','neutral'),false)
    else true
  end;
$function$;
revoke all on function private.cosmetic_supports_body(text,text) from public, anon, authenticated;
-- Serialize against purchase/equip/body changes through their existing user lock.
do $lock$ begin
  perform 1 from public.users where avatar_body_type='male' for update;
end $lock$;
update public.user_cosmetics uc set equipped=false
from public.users u, public.cosmetics c
where uc.user_id=u.id and uc.cosmetic_id=c.id and uc.equipped
  and u.avatar_body_type='male'
  and c.slug in ('starter-business-suit','midnight-harvest-coat','moss-green-cloak','hearthguard-mantle');
update public.cosmetics
set description='A simple ivory shirt, brown trousers and sturdy boots. Available for every body and class.'
where slug='everyday-adventurer-outfit';
commit;
