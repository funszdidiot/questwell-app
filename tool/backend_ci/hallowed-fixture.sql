-- Canonical lookup rows needed by this collection in the disposable CI stack only.
-- Legacy bookshelf-dependent slots are outside this fixture; its catalog is absent.
do $fixture$
begin
insert into public.hearth_slots(slot_key,zone,default_label,sort_order) values
  ('left','rear','Back left',10),
  ('right','rear','Back right',20),
  ('front','foreground','Foreground',30),
  ('side','side','Beside the chair',40),
  ('wall_left','wall','Left wall',50),
  ('wall_center','wall','Center wall',60),
  ('wall_right','wall','Right wall',70),
  ('mantel','surface','Fireplace mantel',80),
  ('bookshelf_top','surface','On the bookcase',90),
  ('window','window','Window alcove',100),
  ('floor','floor','Beneath the adventurer',110),
  ('setting','setting','Hearth setting',120) on conflict do nothing;
insert into public.hearth_layout_profiles(profile_key,family_key,display_name) values
  ('large_furniture','large_furniture','Large furniture'),
  ('pedestal_light','pedestal_light','Pedestal light'),
  ('seating','seating','Seating'),
  ('plant','plant','Plant'),
  ('side_table','side_table','Side table'),
  ('trophy_surface','surface_collectible','Trophy surface'),
  ('relic_display','relic_display','Class relic display'),
  ('floor_rug','floor_rug','Floor rug'),
  ('window_feature','window_feature','Window feature'),
  ('hearth_setting','hearth_setting','Hearth setting'),
  ('wall_art_side','wall_art','Side wall art'),
  ('wall_art_center','wall_art','Center wall art') on conflict do nothing;
insert into public.hearth_profile_slots(
  profile_key,slot_key,placement_label,sort_order,required_equipped_slug
) values
  ('large_furniture','left','Back left',10,null),
  ('large_furniture','right','Back right',20,null),

  ('pedestal_light','left','Back left',10,null),
  ('pedestal_light','right','Back right',20,null),

  ('seating','front','Left floor',10,null),
  ('seating','right','Right floor',20,null),

  ('plant','left','Back left',10,null),
  ('plant','right','Back right',20,null),
  ('plant','front','Foreground',30,null),

  ('side_table','side','Beside the chair',10,null),

  ('trophy_surface','mantel','Fireplace mantel',10,null),

  ('relic_display','left','Back left pedestal',10,null),
  ('relic_display','right','Back right pedestal',20,null),
  ('relic_display','front','Front left pedestal',30,null),
  ('relic_display','mantel','On the fireplace mantel',40,null),

  ('floor_rug','floor','Beneath the adventurer',10,null),
  ('window_feature','window','Window alcove',10,null),
  ('hearth_setting','setting','Hearth setting',10,null),

  ('wall_art_side','wall_left','Left wall',10,null),
  ('wall_art_side','wall_right','Right wall',20,null),
  ('wall_art_center','wall_center','Center wall',10,null) on conflict do nothing;
end;
$fixture$;
