begin;
update public.cosmetics set active=true where slug='walnut-reading-table';
insert into auth.users(id,email) values ('e9625ff1-d535-4ca9-ad46-b601c2a89941','table-qa@example.invalid');
insert into public.user_cosmetics(user_id,cosmetic_id,source,equipped)
select 'e9625ff1-d535-4ca9-ad46-b601c2a89941',id,'qa',false from public.cosmetics where slug in ('walnut-bookshelf','hearth-fern','burgundy-reading-chair','walnut-reading-table');
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"e9625ff1-d535-4ca9-ad46-b601c2a89941","role":"authenticated"}',true);
do $$
declare t uuid; chair uuid; shelf uuid; fern uuid; denied boolean;
begin
select id into strict t from public.cosmetics where slug='walnut-reading-table';
select id into strict chair from public.cosmetics where slug='burgundy-reading-chair';
select id into strict shelf from public.cosmetics where slug='walnut-bookshelf';
select id into strict fern from public.cosmetics where slug='hearth-fern';
perform public.place_hearth_cosmetic(shelf,'left',null);
perform public.place_hearth_cosmetic(fern,'front',null);
perform public.place_hearth_cosmetic(chair,'right',null);
perform public.place_hearth_cosmetic(t,'side',null);
if (select count(*) from public.user_cosmetics where equipped and cosmetic_id in (t,chair,shelf,fern))<>4 then raise exception 'all four not placed'; end if;
denied:=false;
begin perform public.place_hearth_cosmetic(t,'front',fern); exception when others then
if sqlerrm<>'item does not fit this room spot' then raise; end if; denied:=true; end;
if not denied then raise exception 'table allowed wrong spot'; end if;
denied:=false;
begin perform public.place_hearth_cosmetic(chair,'side',t); exception when others then
if sqlerrm<>'item does not fit this room spot' then raise; end if; denied:=true; end;
if not denied then raise exception 'chair allowed table spot'; end if;
perform public.place_hearth_cosmetic(chair,'front',fern);
if not exists(select 1 from public.user_cosmetics where cosmetic_id=t and equipped and room_slot='side') then raise exception 'chair move lost table'; end if;
perform public.unequip_cosmetic(t);
if exists(select 1 from public.user_cosmetics where cosmetic_id=t and equipped) then raise exception 'remove failed'; end if;
if not exists(select 1 from public.user_cosmetics where cosmetic_id=t) then raise exception 'ownership lost'; end if;
end $$;
rollback;
select 'PASS: four items coexist, dedicated spot restrictions, chair movement preserves table, removal retains ownership; rolled back' as result;
