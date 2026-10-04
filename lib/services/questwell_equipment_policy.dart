/// Renderer capability policy only.
///
/// Catalog/business metadata (category, class, collection, edition, availability)
/// is authoritative in Supabase and must not be duplicated here.
abstract final class QuestwellEquipmentPolicy {
  // Retired renderer capability; ownership/equipment history stays untouched.
  static const retiredSlugs = {'pathfinder-boots'};
  static bool isRetired(String slug) => retiredSlugs.contains(slug);

  static const renderReadySlugs = <String>{
    'woodland-scout-outfit','everyday-adventurer-outfit',
    'midnight-harvest-coat','starter-business-suit','moss-green-cloak','hearthguard-mantle',
    'round-scholar-glasses','tiny-wizard-hat','emerald-scholar-scarf',
    'leather-satchel','wayfarer-satchel','brass-lantern','annotated-grimoire',
    'moonstone-brooch','victory-sparkle','focus-tonic',
    'pumpkin-sprite','mushroom-familiar','tiny-owl-familiar','glass-slime',
    'emerald-dragon','archive-owl','signal-fox','moss-moth',
    'autumn-ember-lantern','harvest-apothecary-display','copper-potion-workbench',
    'walnut-bookshelf','hearth-fern','burgundy-reading-chair','emerald-wayfarer-rug',
    'woodland-cottage','midnight-harvest','enchanted-library','midnight-observatory',
    'alchemists-workshop','astral-sanctuary','emberglass-conservatory',
    'walnut-reading-table','rainy-window','warding-lantern',
    'moonlit-woodland','fern-study','celestial-study',
    'first-journey-trophy','starlit-orrery','scholar-seal','scout-compass',
    'alchemist-phial','guardian-crest','wanderer-star-map',
  };

  // Body-specific renderer fits; the catalog still owns class/collection rules.
  // Male Everyday v2 is approved. Male Woodland awaits its own locked fit.
  static const bodyFits = <String, Set<String>>{
    'everyday-adventurer-outfit': {'female', 'neutral', 'male'},
    'woodland-scout-outfit': {'female', 'neutral'},
  };
  static bool supportsBody(String slug, String body) =>
      bodyFits[slug]?.contains(body) ?? true;

  static bool isClosedCloak(String slug) =>
      slug == 'moss-green-cloak' || slug == 'hearthguard-mantle';

  static bool conflicts(String nextSlug, String nextCategory, String currentSlug, String currentCategory) =>
      (isClosedCloak(nextSlug) && currentCategory == 'hands') ||
      (nextCategory == 'hands' && isClosedCloak(currentSlug));

  static bool isReady(String slug, String category) =>
      !isRetired(slug) && renderReadySlugs.contains(slug);
}
