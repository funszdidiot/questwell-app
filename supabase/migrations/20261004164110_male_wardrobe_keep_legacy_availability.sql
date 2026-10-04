-- Correct the temporary restriction after reconciling Tanya's newer
-- 2026-10-04 decision: keep legacy male items available on locked v3.
-- Preserve Everyday male support, ownership, balances, prices and class rules.
begin;
create or replace function private.cosmetic_supports_body(p_slug text, p_body_type text)
returns boolean language sql immutable security invoker set search_path = ''
as $function$
  select case
    when p_slug='everyday-adventurer-outfit' then coalesce(p_body_type in ('female','neutral','male'),false)
    when p_slug='woodland-scout-outfit' then coalesce(p_body_type='female',false)
    else true
  end;
$function$;
revoke all on function private.cosmetic_supports_body(text,text) from public, anon, authenticated;
commit;
