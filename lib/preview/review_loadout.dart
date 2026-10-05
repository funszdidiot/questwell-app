import '../services/questwell_equipment_policy.dart';
import '../services/questwell_loadout_model.dart';

/// Shared, account-free state across the mobile preview's screens.
class QuestwellReviewLoadout {
  String archetype = 'alchemist', body = 'female';
  bool masterySeeded = false;
  bool glasses = false, satchel = false;
  final otherEquipped = <String>{};
  final roomSlots = <String, String>{};
  final mastered = <String>{};
  static const catalog = <String, (String, String)>{
    'bookshelf': ('room', 'walnut-bookshelf'), 'fern': ('room', 'hearth-fern'),
    'chair': ('room', 'burgundy-reading-chair'), 'table': ('room', 'walnut-reading-table'),
    'fern-art': ('wall_art', 'fern-study'), 'celestial-art': ('wall_art', 'celestial-study'),
    'painting': ('wall_art', 'moonlit-woodland'), 'm': ('accessory', 'moonstone-brooch'),
    'h': ('head', 'tiny-wizard-hat'), 'n': ('neck', 'emerald-scholar-scarf'),
    'a': ('face', 'round-scholar-glasses'), 's': ('back', 'leather-satchel'),
    'b': ('hands', 'brass-lantern'),
    'everyday': ('chest', 'everyday-adventurer-outfit'),
    'suit': ('chest', 'starter-business-suit'),
  };
  void setBody(String nextBody) {
    body = nextBody;
    otherEquipped.removeWhere((id) {
      final slug = catalog[id]?.$2;
      return slug != null && !QuestwellEquipmentPolicy.supportsBody(slug, nextBody);
    });
  }
  void placeRoom(String id, String slot) {
    roomSlots.removeWhere((key, value) => value == slot || key == id);
    roomSlots[id] = slot;
    _returnUnsupportedCollectibles();
  }
  void removeRoom(String id) {
    roomSlots.remove(id);
    _returnUnsupportedCollectibles();
  }
  void _returnUnsupportedCollectibles() {
    final hasBookcase = roomSlots.entries.any((entry) =>
      catalog[entry.key]?.$2 == 'walnut-bookshelf' &&
      (entry.value == 'left' || entry.value == 'right'));
    if (!hasBookcase) roomSlots.removeWhere((_, slot) => slot == 'bookshelf_top');
  }
  Map<String, String> get equipment => {
    for (final entry in roomSlots.entries)
      if (catalog[entry.key] case final item?)
        (item.$1 == 'wall_art'
            ? QuestwellLoadoutModel.wallArtRenderKey(entry.value)
            : QuestwellLoadoutModel.roomRenderKey(entry.value)): item.$2
      else
        QuestwellLoadoutModel.roomRenderKey(entry.value): entry.key,
    for (final id in {...otherEquipped, if (glasses) 'a', if (satchel) 's'})
      if (catalog[id] case final item?) item.$1: item.$2,
  };
}
