import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/services/questwell_equipment_policy.dart';

void main() {
  test('every active shop renderer has a discoverable category mapping', () {
    const visibleGroups = {'chest','familiar','effect','room','wall_art','hands',
      'head','face','neck','back','feet','accessory'};
    for (final entry in QuestwellEquipmentPolicy.shopCategories.entries) {
      expect(visibleGroups, contains(entry.value),
        reason: '${entry.key} would be orphaned from Market discovery');
    }
    expect(QuestwellEquipmentPolicy.shopCategories['glass-slime'], 'familiar');
    expect(QuestwellEquipmentPolicy.shopCategories['focus-tonic'], 'effect');
  });
}
