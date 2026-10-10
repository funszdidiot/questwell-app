-- REVIEW CANDIDATE ONLY. Prices and account activation need Tanya's approval.
-- Not a migration and not wired to any deployment workflow.
-- Run only inside the disposable harness transaction, or promote to a reviewed
-- forward migration after approval. No updates, grants or ownership writes.
insert into public.hearth_layout_profiles(profile_key,family_key,display_name)
values ('wall_textile','wall_art','Wall textile');

insert into public.hearth_profile_slots(profile_key,slot_key,placement_label,sort_order)
values ('wall_textile','wall_left','Left wall',10),
       ('wall_textile','wall_center','Center / Hearth',20),
       ('wall_textile','wall_right','Right wall',30);

insert into public.cosmetics(slug,name,category,rarity,description,price,premium,
  required_archetype,unlock_method,collection_key,edition_type,active,hearth_profile_key)
values
  ('hearthwoven-macrame','Hearthwoven Macramé','wall_art','uncommon',
   'A generous woven hanging for a quiet corner or a gathered gallery wall.',120,false,
   null,'shop','evergreen-hearth','standard',false,'wall_textile'),
  ('woodland-path-tapestry','Woodland Path Tapestry','wall_art','uncommon',
   'A woven woodland path that brings the promise of adventure indoors.',120,false,
   null,'shop','evergreen-hearth','standard',false,'wall_textile'),
  ('guardians-oath-tapestry','Guardian’s Oath Tapestry','wall_art','uncommon',
   'A blue-and-gold tribute to the Guardian’s promise of shelter and protection.',120,false,
   'guardian','shop','evergreen-hearth','standard',false,'wall_textile'),
  ('mad-alchemists-lab','Mad Alchemist’s Lab','room','rare',
   'A warm laboratory hearth for experiments, discoveries and unfinished ideas.',300,false,
   null,'shop','evergreen-hearth','standard',false,'hearth_setting'),
  ('guardians-keep','Guardian’s Keep','room','rare',
   'A sheltered stone keep with a glowing hearth and a place to rest between quests.',300,false,
   null,'shop','evergreen-hearth','standard',false,'hearth_setting');

insert into public.hearth_render_registry(cosmetic_id,render_kind,asset_source,
  asset_path,canvas_width,canvas_height,visible_base,shadow_profile,filter_mode,asset_revision)
select c.id,'wall_art_sprite','bundle',r.asset_path,r.width,r.height,1,'none','smooth',1
from (values
  ('hearthwoven-macrame','assets/images/questwell/hearth/hearthwoven_macrame_v1.png',1402,1122),
  ('woodland-path-tapestry','assets/images/questwell/hearth/woodland_path_tapestry_v1.png',1536,1024),
  ('guardians-oath-tapestry','assets/images/questwell/hearth/guardians_oath_tapestry_v1.png',1536,1024)
) r(slug,asset_path,width,height) join public.cosmetics c using(slug);
