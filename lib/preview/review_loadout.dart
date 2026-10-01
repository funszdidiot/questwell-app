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
  };
  Map<String, String> get equipment => {
    for (final entry in roomSlots.entries)
      '${catalog[entry.key]?.$1 ?? "room"}:${entry.value}': catalog[entry.key]?.$2 ?? entry.key,
    for (final id in {...otherEquipped, if (glasses) 'a', if (satchel) 's'})
      if (catalog[id] case final item?) item.$1: item.$2,
  };
}
