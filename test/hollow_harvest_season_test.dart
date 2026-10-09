import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/models/questwell_boss_unlocks.dart';
import 'package:project_momentum/widgets/questwell_boss_picker.dart';

void main() {
  test(
      'Harvest opens at collection start and closes at midnight after November 8 Central',
      () {
    final start = QuestwellBossUnlocks.harvestStart;
    final end = QuestwellBossUnlocks.harvestEnd;
    expect(
        QuestwellBossUnlocks.available('hollow_harvest', 1,
            now: start.subtract(const Duration(microseconds: 1))),
        false);
    expect(
        QuestwellBossUnlocks.available('hollow_harvest', 1, now: start), true);
    expect(
        QuestwellBossUnlocks.available('hollow_harvest', 0, now: start), false);
    expect(
        QuestwellBossUnlocks.available('hollow_harvest', 1,
            now: end.subtract(const Duration(microseconds: 1))),
        true);
    expect(
        QuestwellBossUnlocks.available('hollow_harvest', 20, now: end), false);
    expect(QuestwellBossUnlocks.available('inbox_hydra', 1, now: end), true);
    expect(QuestwellBossUnlocks.next(1), 'meeting_mimic');
  });
  testWidgets(
      'Seasonal picker supports level one and rejects selection after close',
      (tester) async {
    String selected = 'inbox_hydra';
    for (final open in [true, false]) {
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: QuestwellBossPicker(
                  key: ValueKey(open),
                  value: 'inbox_hydra',
                  level: 1,
                  now: open
                      ? QuestwellBossUnlocks.harvestStart
                      : QuestwellBossUnlocks.harvestEnd,
                  onChanged: (value) => selected = value))));
      final menu = tester
          .widget<DropdownButton<String>>(find.byType(DropdownButton<String>));
      expect(
          menu.items!
              .singleWhere((item) => item.value == 'hollow_harvest')
              .enabled,
          open);
      selected = 'inbox_hydra';
      tester
          .widget<DropdownButtonFormField<String>>(
              find.byType(DropdownButtonFormField<String>))
          .onChanged!('hollow_harvest');
      expect(selected, open ? 'hollow_harvest' : 'inbox_hydra');
      expect(tester.takeException(), isNull);
    }
  });
}
