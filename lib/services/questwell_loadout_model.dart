/// Shared renderer-facing loadout semantics.
///
/// Keep category -> render-slot mapping out of presentation widgets so visual
/// redesigns cannot silently change inventory/equipment behavior.
abstract final class QuestwellLoadoutModel {
  static String renderKey({
    required String category,
    String? roomSlot,
  }) {
    if (category == 'room') {
      return 'room:${roomSlot ?? "right"}';
    }
    if (category == 'wall_art' &&
        roomSlot != null &&
        roomSlot != 'wall_center') {
      return 'wall_art:$roomSlot';
    }
    return category;
  }

  static String inventoryGroup(String category) {
    if (category == 'room' || category == 'wall_art') return 'Hearth';
    if (category == 'familiar') return 'Familiars';
    if (category == 'effect') return 'Effects';
    if (category == 'chest') return 'Outfits';
    return 'Gear';
  }

  static String roomRenderKey(String slot) => 'room:$slot';

  static String wallArtRenderKey(String slot) =>
      slot == 'wall_center' ? 'wall_art' : 'wall_art:$slot';
}
