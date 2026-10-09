-- Approved Autumn Hearth catalog, staged until the served client is verified.
-- Existing catalog, ownership, balances, policies and functions stay unchanged.
begin;

insert into public.cosmetics(slug,name,category,rarity,description,price,premium,required_archetype,unlock_method,milestone_level,collection_key,edition_type,active,hearth_profile_key) values
  ('amberfall-window','Amberfall Window','room','uncommon','Falling amber leaves beyond the glass. Designed for the Original and Hallowed Hearth windows.',120,false,null,'shop',null,'autumn-hearth','seasonal',false,'window_feature'),
  ('maple-hearth-rug','Maple Hearth Rug','room','uncommon','A warm woven maple rug for the floor beneath your adventurer.',60,false,null,'shop',null,'autumn-hearth','seasonal',false,'floor_rug'),
  ('mooncap-grove','Mooncap Grove','room','uncommon','A little grove of moonlit mushrooms to brighten a cozy corner.',120,false,null,'shop',null,'autumn-hearth','seasonal',false,'plant'),
  ('harvest-lanterns','Harvest Lanterns','room','rare','A pair of warm harvest lanterns for long autumn evenings.',240,false,null,'shop',null,'autumn-hearth','seasonal',false,'pedestal_light'),
  ('sages-rest','Sage’s Rest','room','uncommon','Layered cushions for a quiet pause beside the hearth.',120,false,null,'shop',null,'autumn-hearth','seasonal',false,'seating');

insert into public.hearth_render_registry(cosmetic_id,render_kind,asset_source,asset_path,canvas_width,canvas_height,visible_base,shadow_profile,effect_profile,filter_mode,asset_revision,min_client_build)
select c.id,r.render_kind,r.asset_source,r.asset_path,r.canvas_width,r.canvas_height,r.visible_base,r.shadow_profile,r.effect_profile,r.filter_mode,r.asset_revision,r.min_client_build::integer from (values
  ('maple-hearth-rug','floor_sprite','bundle','assets/images/questwell/hearth/maple_rug_candidate_v1.png',1816,866,1,'none',null,'pixel',1,null),
  ('mooncap-grove','static_sprite','bundle','assets/images/questwell/hearth/mooncap_grove_candidate_v1.png',1254,1254,0.91707,'plant',null,'pixel',1,null),
  ('harvest-lanterns','static_sprite','bundle','assets/images/questwell/hearth/harvest_lanterns_candidate_v1.png',1254,1254,0.94338,'pedestal',null,'pixel',1,null),
  ('sages-rest','static_sprite','bundle','assets/images/questwell/hearth/sages_rest_candidate_v1.png',1254,1254,0.82616,'seating',null,'pixel',1,null)
) as r(slug,render_kind,asset_source,asset_path,canvas_width,canvas_height,visible_base,shadow_profile,effect_profile,filter_mode,asset_revision,min_client_build) join public.cosmetics c using(slug);
commit;
