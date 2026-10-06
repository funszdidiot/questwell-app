import '../services/questwell_cosmetic_models.dart';
import '../services/questwell_loadout_model.dart';
import 'questwell_hearth_decor.dart';
import 'questwell_mastery_relic.dart';

/// A temporary loadout only; never purchases, equips or persists anything.
abstract final class QuestwellMarketPreview {
  static Map<String, String>? equipment(
    QuestwellCosmeticsSnapshot data,
    QuestwellCosmetic item,
  ) {
    final result = {
      for (final entry in data.cosmetics.where((entry) => entry.equipped))
        entry.renderKey: entry.slug,
    };
    if (item.category != 'room' && item.category != 'wall_art') {
      result[item.category] = item.slug;
      return result;
    }
    // Backend placements are authoritative. Legacy fixtures may use only
    // explicitly known choices, never the generic unknown-item floor fallback.
    final placements = [...item.hearthPlacements]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final slots =
        (placements.isNotEmpty
                ? placements.map((option) => option.slot)
                : item.hearthProfileKey != null
                ? const <String>[]
                : item.slug == 'moonlit-woodland'
                ? const ['wall_center']
                : QuestwellHearthDecor.choices(item.slug, knownOnly: true).keys)
            .where((slot) => slot.isNotEmpty)
            .where(
              (slot) =>
                  slot != 'bookshelf_top' ||
                  result['room:left'] == 'walnut-bookshelf' ||
                  result['room:right'] == 'walnut-bookshelf',
            )
            .toList();
    if (slots.isEmpty) return null;
    String key(String slot) => QuestwellLoadoutModel.renderKey(
      category: item.category,
      roomSlot: slot,
    );
    final current =
        item.roomSlot ??
        (item.category == 'wall_art' ? 'wall_center' : 'right');
    // Match the picker: retain valid placement, then prefer a free right spot
    // (except relics), then the first available spot in placement order.
    final slot = item.equipped && slots.contains(current)
        ? current
        : !QuestwellMasteryRelic.supports(item.slug) &&
              slots.contains('right') &&
              !result.containsKey(key('right'))
        ? 'right'
        : slots.firstWhere(
            (slot) => !result.containsKey(key(slot)),
            orElse: () => slots.first,
          );
    result.removeWhere(
      (key, value) =>
          (key == item.category || key.startsWith('${item.category}:')) &&
          value == item.slug,
    );
    result[key(slot)] = item.slug;
    return result;
  }
}
