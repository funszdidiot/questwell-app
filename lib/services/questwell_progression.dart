/// Shared client version of the server's gentle XP curve.
/// Lifetime XP remains earned XP; legacyOffset only preserves earlier progress.
class QuestwellProgression {
  const QuestwellProgression._();

  static int xpToNextLevel(int level) => 100 + 15 * ((level < 1 ? 1 : level) - 1);

  static int totalAtLevel(int level) {
    final completed = (level < 1 ? 1 : level) - 1;
    return 100 * completed + 15 * completed * (completed - 1) ~/ 2;
  }

  static int levelForXp(int totalXp, {int legacyOffset = 0}) {
    final effective = (totalXp < 0 ? 0 : totalXp) +
        (legacyOffset < 0 ? 0 : legacyOffset);
    var low = 1;
    var high = 2;
    while (totalAtLevel(high) <= effective) {
      high *= 2;
    }
    while (low + 1 < high) {
      final middle = (low + high) ~/ 2;
      if (totalAtLevel(middle) <= effective) {
        low = middle;
      } else {
        high = middle;
      }
    }
    return low;
  }

  static int xpIntoLevel(int totalXp, {int legacyOffset = 0}) {
    final effective = (totalXp < 0 ? 0 : totalXp) +
        (legacyOffset < 0 ? 0 : legacyOffset);
    return effective - totalAtLevel(levelForXp(totalXp, legacyOffset: legacyOffset));
  }
}
