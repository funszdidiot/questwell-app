-- Run after the development build and outfit verification pass.
-- Founder copies are a separate, explicit account operation.
update public.cosmetics set active=true
where slug in ('woodland-scout-outfit','everyday-adventurer-outfit');
