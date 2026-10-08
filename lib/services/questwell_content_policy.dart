/// Founder-approved limits for new or explicitly edited user content.
/// Count Unicode scalar values, not UTF-16 units. Never truncate stored content.
class QuestwellContentPolicy {
  const QuestwellContentPolicy._();

  static const titleLimit = 120;
  static const descriptionLimit = 4000;
  static const bossStepLimit = 50;

  static String? titleError(String value) {
    final count = value.trim().runes.length;
    if (count == 0) return 'Give this a name first.';
    if (count > titleLimit) return 'Use 120 characters or fewer for the name.';
    return null;
  }

  static String? descriptionError(String? value) =>
      (value?.runes.length ?? 0) > descriptionLimit
          ? 'Use 4,000 characters or fewer for the description.'
          : null;

  static String? bossError(String title, List<String> steps) {
    final error = titleError(title);
    if (error != null) return error;
    if (steps.length < 2 || steps.length > bossStepLimit) {
      return 'Add between 2 and 50 attack steps.';
    }
    for (final step in steps) {
      if (titleError(step) != null) {
        return 'Give every attack step a name of 1–120 characters.';
      }
    }
    return null;
  }

  static String displayTitle(String? value, String fallback) =>
      value == null || value.trim().isEmpty ? fallback : value;
}
