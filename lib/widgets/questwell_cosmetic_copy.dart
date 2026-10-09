/// Capability copy follows this client; stored catalog descriptions are intact.
abstract final class QuestwellCosmeticCopy {
  static String description(String slug, String storedDescription) => slug ==
          'amberfall-window'
      ? 'Falling amber leaves beyond the glass. Fits the windows in every Hearth room.'
      : storedDescription;
}
