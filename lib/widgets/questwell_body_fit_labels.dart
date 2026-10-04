import '../services/questwell_equipment_policy.dart';

/// Presentation text derived from the shared renderer capability policy.
abstract final class QuestwellBodyFitLabels {
  static String bodyName(String body) => switch (body) {
    'neutral' => 'gender-neutral',
    _ => body,
  };

  static String availability(String slug) {
    final bodies = QuestwellEquipmentPolicy.bodyFits[slug];
    if (bodies == null) return 'Available for every body.';
    final names = bodies.map(bodyName).toList();
    if (names.length == 1) return 'Available for the ${names.single} body.';
    final list = names.length == 2
        ? names.join(' and ')
        : '${names.take(names.length - 1).join(', ')}, and ${names.last}';
    return 'Available for $list bodies.';
  }

  static String previewBody(String slug, String currentBody) =>
      QuestwellEquipmentPolicy.supportsBody(slug, currentBody)
          ? currentBody
          : QuestwellEquipmentPolicy.bodyFits[slug]!.first;
}
