/// Only founder-approved artwork can be newly equipped in the rich renderer.
abstract final class QuestwellEquipmentPolicy {
  static bool isReady(String slug, String category) =>
      (slug == 'round-scholar-glasses' && category == 'face') ||
      (slug == 'tiny-wizard-hat' && category == 'head') ||
      (slug == 'emerald-scholar-scarf' && category == 'neck') ||
      (slug == 'leather-satchel' && category == 'back') ||
      (slug == 'brass-lantern' && category == 'hands') ||
      (slug == 'moonstone-brooch' && category == 'accessory') ||
      (slug == 'walnut-bookshelf' && category == 'room') ||
      (slug == 'hearth-fern' && category == 'room') ||
      (slug == 'burgundy-reading-chair' && category == 'room') ||
      (slug == 'walnut-reading-table' && category == 'room') ||
      (['moonlit-woodland', 'fern-study', 'celestial-study'].contains(slug) && category == 'wall_art');
}
