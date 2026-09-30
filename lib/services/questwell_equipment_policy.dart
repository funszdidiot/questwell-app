/// Only founder-approved artwork can be newly equipped in the rich renderer.
abstract final class QuestwellEquipmentPolicy {
  static bool isReady(String slug, String category) =>
      (slug == 'round-scholar-glasses' && category == 'face') ||
      (slug == 'tiny-wizard-hat' && category == 'head') ||
      (slug == 'emerald-scholar-scarf' && category == 'neck') ||
      (slug == 'leather-satchel' && category == 'back');
}
