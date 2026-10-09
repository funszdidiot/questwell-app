import '../services/questwell_cosmetic_models.dart';

/// Capability copy follows this client; stored catalog descriptions are intact.
abstract final class QuestwellCosmeticCopy {
  static String description(QuestwellCosmetic item) => item.slug ==
          'amberfall-window'
      ? 'Falling amber leaves beyond the glass. Fits the windows in every Hearth room.'
      : item.description;
}
