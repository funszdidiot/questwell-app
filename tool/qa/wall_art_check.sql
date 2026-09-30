begin;
insert into public.cosmetics(slug,name,category,rarity,price,active) values ('qa-other-painting','QA Other Painting','wall_art','common',0,true);
update public.cosmetics set active=true where slug in ('walnut-reading-table','moonlit-woodland');
insert into auth.users(id,email) values ('e9625ff1-d535-4ca9-ad46-b601c2a89951','wall-qa@example.invalid');
insert into public.user_cosmetics(user_id,cosmetic_id,source,equipped)
select 'e9625ff1-d535-4ca9-ad46-b601c2a89951',id,'qa',false from public.cosmetics where slug in ('walnut-bookshelf','hearth-fern','burgundy-reading-chair','walnut-reading-table','moonlit-woodland','qa-other-painting');
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"e9625ff1-d535-4ca9-ad46-b601c2a89951","role":"authenticated"}',true);
do $$
declare t uuid; chair uuid; shelf uuid; fern uuid; denied boolean; painting uuid; other uuid;
begin
select id into strict t from public.cosmetics where slug='walnut-reading-table';
select id into strict chair from public.cosmetics where slug='burgundy-reading-chair';
select id into strict shelf from public.cosmetics where slug='walnut-bookshelf';
select id into strict fern from public.cosmetics where slug='hearth-fern';
select id into strict painting from public.cosmetics where slug='moonlit-woodland';
select id into strict other from public.cosmetics where slug='qa-other-painting';
perform public.place_hearth_cosmetic(shelf,'left',null);
perform public.place_hearth_cosmetic(fern,'front',null);
perform public.place_hearth_cosmetic(chair,'right',null);
perform public.place_hearth_cosmetic(t,'side',null);
if (select count(*) from public.user_cosmetics where equipped and cosmetic_id in (t,chair,shelf,fern))<>4 then raise exception 'all four not placed'; end if;
perform public.equip_cosmetic(painting);
perform public.equip_cosmetic(other);
if exists(select 1 from public.user_cosmetics where cosmetic_id=painting and equipped) then raise exception 'old painting remains hung'; end if;
if not exists(select 1 from public.user_cosmetics where cosmetic_id=other and equipped) then raise exception 'new painting missing'; end if;
if (select count(*) from public.user_cosmetics where equipped and cosmetic_id in (t,chair,shelf,fern))<>4 then raise exception 'swap moved furniture'; end if;
perform public.unequip_cosmetic(other);
if exists(select 1 from public.user_cosmetics where cosmetic_id=other and equipped) then raise exception 'remove failed'; end if;
if (select count(*) from public.user_cosmetics where cosmetic_id in (painting,other))<>2 then raise exception 'ownership lost'; end if;
end $$;
rollback;
select 'PASS: painting swap and removal preserve all four furniture pieces and ownership; rolled back' as result;
