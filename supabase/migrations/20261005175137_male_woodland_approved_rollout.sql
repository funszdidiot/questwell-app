-- Approved male Woodland v2, on the immutable male v3 foundation.
-- Apply only through a reviewed deployment path; see supabase/README.md.
-- Public RPC signatures, price, class, activation and ownership are unchanged.
begin;
create or replace function private.cosmetic_supports_body(p_slug text, p_body_type text)
returns boolean language sql immutable security invoker set search_path = ''
as $function$
  select case
    when p_slug='everyday-adventurer-outfit' then coalesce(p_body_type in ('female','neutral','male'),false)
    when p_slug='woodland-scout-outfit' then coalesce(p_body_type in ('female','neutral','male'),false)
    else true
  end;
$function$;
revoke all on function private.cosmetic_supports_body(text,text) from public, anon, authenticated;
update public.cosmetics
set description='Moss leather, an ivory rolled-sleeve shirt, reinforced trousers and travel boots. Available for female, neutral and male Scout avatars.'
where slug='woodland-scout-outfit';
commit;
