begin;
insert into auth.users(id,email) values ('e9625ff1-d535-4ca9-ad46-b601c2a89931','hearth-check-20260930@example.invalid');
insert into public.user_cosmetics(user_id,cosmetic_id,source,equipped)
select 'e9625ff1-d535-4ca9-ad46-b601c2a89931',id,'qa',false from public.cosmetics
where slug in ('walnut-bookshelf','hearth-fern','burgundy-reading-chair');
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"e9625ff1-d535-4ca9-ad46-b601c2a89931","role":"authenticated"}',true);
do $$
declare chair uuid; shelf uuid; fern uuid; denied boolean;
begin
select id into strict chair from public.cosmetics where slug='burgundy-reading-chair';
select id into strict shelf from public.cosmetics where slug='walnut-bookshelf';
select id into strict fern from public.cosmetics where slug='hearth-fern';
perform public.place_hearth_cosmetic(shelf,'left',null);
perform public.place_hearth_cosmetic(fern,'front',null);
perform public.place_hearth_cosmetic(chair,'right',null);
if (select count(*) from public.user_cosmetics where equipped and cosmetic_id in (chair,shelf,fern))<>3 then raise exception 'placement failed'; end if;
denied:=false;
begin perform public.place_hearth_cosmetic(chair,'front',null); exception when others then
if sqlerrm <> 'room spot changed; refresh and confirm replacement' then raise; end if;
denied:=true; end;
if not denied then raise exception 'replacement confirmation missing'; end if;
perform public.place_hearth_cosmetic(chair,'front',fern);
if exists(select 1 from public.user_cosmetics where cosmetic_id=fern and (equipped or room_slot is not null)) then raise exception 'replaced item not cleared'; end if;
if exists(select 1 from public.user_cosmetics where equipped and room_slot='right') then raise exception 'duplicate after move'; end if;
perform public.place_hearth_cosmetic(chair,'right',null);
perform set_config('request.jwt.claims','{}',true);
perform set_config('request.jwt.claims','{"sub":"e9625ff1-d535-4ca9-ad46-b601c2a89931","role":"authenticated"}',true);
if not exists(select 1 from public.user_cosmetics where cosmetic_id=chair and equipped and room_slot='right') then raise exception 'saved move not reloaded'; end if;
perform public.unequip_cosmetic(chair);
if exists(select 1 from public.user_cosmetics where cosmetic_id=chair and equipped) then raise exception 'remove failed'; end if;
if (select count(*) from public.user_cosmetics where cosmetic_id in (chair,shelf,fern))<>3 then raise exception 'ownership lost'; end if;
if not exists(select 1 from public.user_cosmetics where cosmetic_id=shelf and equipped and room_slot='left') then raise exception 'unrelated decor changed'; end if;
end $$;
rollback;
select 'PASS: place, move, confirmed replacement, identity reload, removal, ownership retention; synthetic fixture rolled back' as result;
