begin;
update public.cosmetics set active=true where slug in ('walnut-reading-table','fern-study','celestial-study');
insert into auth.users(id,email) values ('e9625ff1-d535-4ca9-ad46-b601c2a89961','side-art-qa@example.invalid');
insert into public.user_cosmetics(user_id,cosmetic_id,source,equipped)
select 'e9625ff1-d535-4ca9-ad46-b601c2a89961',id,'qa',false from public.cosmetics where slug in ('walnut-bookshelf','hearth-fern','burgundy-reading-chair','walnut-reading-table','moonlit-woodland','fern-study','celestial-study');
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"e9625ff1-d535-4ca9-ad46-b601c2a89961","role":"authenticated"}',true);
do $$
declare t uuid; chair uuid; shelf uuid; fern uuid; denied boolean; painting uuid; botanical uuid; stars uuid;
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
select id into strict painting from public.cosmetics where slug='moonlit-woodland';
select id into strict botanical from public.cosmetics where slug='fern-study';
select id into strict stars from public.cosmetics where slug='celestial-study';
perform public.equip_cosmetic(painting);
perform public.place_hearth_cosmetic(botanical,'wall_left',null);
perform public.place_hearth_cosmetic(stars,'wall_right',null);
perform public.equip_cosmetic(painting);
if (select count(*) from public.user_cosmetics where equipped and cosmetic_id in (t,chair,shelf,fern,painting,botanical,stars))<>7 then raise exception 'seven items did not coexist'; end if;
denied:=false;
begin perform public.place_hearth_cosmetic(botanical,'wall_right',null); exception when others then
 if sqlerrm<>'room spot changed; refresh and confirm replacement' then raise; end if; denied:=true; end;
if not denied then raise exception 'unconfirmed replacement allowed'; end if;
perform public.place_hearth_cosmetic(botanical,'wall_right',stars);
if exists(select 1 from public.user_cosmetics where cosmetic_id=stars and equipped) then raise exception 'replacement failed'; end if;
perform public.place_hearth_cosmetic(stars,'wall_left',null);
denied:=false;
begin perform public.place_hearth_cosmetic(botanical,'left',shelf); exception when others then
 if sqlerrm<>'item does not fit this wall spot' then raise; end if; denied:=true; end;
if not denied then raise exception 'art allowed on floor'; end if;
denied:=false;
begin perform public.place_hearth_cosmetic(chair,'wall_left',stars); exception when others then
 if sqlerrm<>'item does not fit this room spot' then raise; end if; denied:=true; end;
if not denied then raise exception 'furniture allowed on wall'; end if;
denied:=false;
begin perform public.equip_cosmetic(botanical); exception when others then
 if sqlerrm<>'choose a wall spot' then raise; end if; denied:=true; end;
if not denied then raise exception 'side art bypassed picker'; end if;
perform public.unequip_cosmetic(botanical);
if (select count(*) from public.user_cosmetics where equipped and cosmetic_id in (t,chair,shelf,fern,painting,stars))<>6 then raise exception 'remove affected other items'; end if;
if not exists(select 1 from public.user_cosmetics where cosmetic_id=botanical) then raise exception 'ownership lost'; end if;
end $$;
rollback;
select 'PASS: seven items coexist; side art moves/replaces with confirmation; center and floor items preserved; invalid slots rejected; removal retains ownership; rolled back' as result;
