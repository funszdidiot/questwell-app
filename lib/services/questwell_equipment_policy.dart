/// Catalog entries with a connected avatar or Hearth renderer.
abstract final class QuestwellEquipmentPolicy {
  static const shopCategories = <String,String>{
    'starter-business-suit':'chest', 'moss-green-cloak':'chest', 'hearthguard-mantle':'chest',
    'round-scholar-glasses':'face', 'tiny-wizard-hat':'head', 'emerald-scholar-scarf':'neck',
    'leather-satchel':'back', 'wayfarer-satchel':'back', 'brass-lantern':'hands',
    'annotated-grimoire':'hands', 'moonstone-brooch':'accessory', 'pathfinder-boots':'feet',
    'victory-sparkle':'effect', 'focus-tonic':'effect',
    'mushroom-familiar':'familiar', 'tiny-owl-familiar':'familiar', 'glass-slime':'familiar',
    'emerald-dragon':'familiar', 'archive-owl':'familiar', 'signal-fox':'familiar', 'moss-moth':'familiar',
    'walnut-bookshelf':'room', 'hearth-fern':'room', 'burgundy-reading-chair':'room',
    'walnut-reading-table':'room', 'rainy-window':'room', 'warding-lantern':'room',
    'moonlit-woodland':'wall_art', 'fern-study':'wall_art', 'celestial-study':'wall_art',
  };
  static bool isReady(String slug, String category) => shopCategories[slug] == category ||
    (['first-journey-trophy','starlit-orrery'].contains(slug) && category == 'room');
}
