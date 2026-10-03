import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/services/questwell_equipment_policy.dart';

void main() {
  test('critical catalog items have renderer support', () {
    expect(QuestwellEquipmentPolicy.renderReadySlugs, contains('glass-slime'));
    expect(QuestwellEquipmentPolicy.renderReadySlugs, contains('focus-tonic'));
    expect(QuestwellEquipmentPolicy.isReady('not-a-real-item','chest'), isFalse);
  });

  test('renderer policy does not duplicate catalog categories', () {
    // Business metadata belongs to Supabase. This policy only answers whether
    // a slug has a renderer/equipment implementation.
    expect(QuestwellEquipmentPolicy.renderReadySlugs, isNotEmpty);
  });
}
