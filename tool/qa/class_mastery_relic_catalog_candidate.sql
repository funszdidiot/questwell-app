-- CANDIDATE ONLY: apply to a development database after founder review.
-- No ownership, reward requirements, item IDs, XP, or coin values change.
begin;

-- Existing hand/effect relics return to inventory before changing their slot type.
update public.user_cosmetics uc set equipped=false, room_slot=null
from public.cosmetics c
where uc.cosmetic_id=c.id and c.unlock_method='class_mastery'
  and c.slug in ('scholar-seal','scout-compass','alchemist-phial','guardian-crest','wanderer-star-map')
  and c.category <> 'room';

update public.cosmetics set category='room',
  description=case slug
    when 'scholar-seal' then 'A gilt archive seal, earned through Scholar mastery. Display it on its walnut stand in your Hearth.'
    when 'scout-compass' then 'A brass compass with a jade dial, earned through Scout mastery. A keepsake for your Hearth.'
    when 'alchemist-phial' then 'An emerald phial in a brass holder, earned through Alchemist mastery. Display it in your Hearth.'
    when 'guardian-crest' then 'A burgundy and gold crest, earned through Guardian mastery. A place of honor in your Hearth.'
    when 'wanderer-star-map' then 'A framed constellation map, earned through Wanderer mastery. Display the paths you have made.'
  end
where unlock_method='class_mastery'
  and slug in ('scholar-seal','scout-compass','alchemist-phial','guardian-crest','wanderer-star-map');

-- Uses existing owned-item, class, slot, and replacement checks in
-- place_hearth_cosmetic. No new grants, functions, or RLS changes.
commit;
