insert into auth.users(id,email) values
('e9625ff1-d535-4ca9-ad46-b601c2a89301','room-slots-a@example.invalid'),
('e9625ff1-d535-4ca9-ad46-b601c2a89302','room-slots-b@example.invalid');
insert into public.user_cosmetics(user_id,cosmetic_id,source,equipped)
 select 'e9625ff1-d535-4ca9-ad46-b601c2a89301',id,'qa',false
 from public.cosmetics where slug in ('walnut-bookshelf','hearth-fern','moonstone-brooch');
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"e9625ff1-d535-4ca9-ad46-b601c2a89301","role":"authenticated"}',true);
do $$
declare shelf uuid; fern uuid; brooch uuid; denied boolean;
begin
 select id into strict shelf from public.cosmetics where slug='walnut-bookshelf';
 select id into strict fern from public.cosmetics where slug='hearth-fern';
 select id into strict brooch from public.cosmetics where slug='moonstone-brooch';
 perform public.equip_cosmetic(brooch);
 perform public.place_hearth_cosmetic(shelf,'right',null);
 perform public.place_hearth_cosmetic(fern,'left',null);
 if (select count(*) from public.user_cosmetics where equipped and cosmetic_id in (shelf,fern,brooch))<>3 then raise exception 'simultaneous placement failed'; end if;
 perform public.place_hearth_cosmetic(shelf,'front',null);
 if exists(select 1 from public.user_cosmetics where equipped and room_slot='right') then raise exception 'move left duplicate'; end if;
 denied:=false;
 begin perform public.place_hearth_cosmetic(fern,'front',null); exception when others then denied:=true; end;
 if not denied then raise exception 'replacement without confirmation'; end if;
 perform public.place_hearth_cosmetic(fern,'front',shelf);
 if exists(select 1 from public.user_cosmetics where cosmetic_id=shelf and equipped) then raise exception 'replacement failed'; end if;
 if not exists(select 1 from public.user_cosmetics where cosmetic_id=shelf) then raise exception 'ownership lost'; end if;
 denied:=false;
 begin perform public.place_hearth_cosmetic(shelf,'front',shelf); exception when others then denied:=true; end;
 if not denied then raise exception 'stale confirmation accepted'; end if;
 denied:=false;
 begin perform public.place_hearth_cosmetic(brooch,'left',null); exception when others then denied:=true; end;
 if not denied then raise exception 'wearable in room'; end if;
 denied:=false;
 begin perform public.place_hearth_cosmetic(shelf,'bad',null); exception when others then denied:=true; end;
 if not denied then raise exception 'invalid spot'; end if;
 perform public.unequip_cosmetic(fern);
 perform public.place_hearth_cosmetic(shelf,'right',null);
 perform public.set_adventurer_archetype('guardian');
 if not exists(select 1 from public.user_cosmetics where cosmetic_id=shelf and equipped and room_slot='right') then raise exception 'class switch lost room'; end if;
 perform set_config('request.jwt.claims','{"sub":"e9625ff1-d535-4ca9-ad46-b601c2a89302","role":"authenticated"}',true);
 denied:=false;
 begin perform public.place_hearth_cosmetic(shelf,'left',null); exception when others then denied:=true; end;
 if not denied then raise exception 'cross account placement'; end if;
 if exists(select 1 from public.user_cosmetics where cosmetic_id=shelf) then raise exception 'cross account read'; end if;
end $$;
