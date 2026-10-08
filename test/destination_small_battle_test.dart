import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/models/questwell_boss.dart';
import 'package:project_momentum/widgets/questwell_boss_board.dart';
import 'package:project_momentum/widgets/questwell_boss_encounter.dart';
import 'package:project_momentum/widgets/questwell_app_navigation.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  testWidgets('small enlarged screen reveals selected battle above navigation',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    QuestwellBossBattle battle(String id) => QuestwellBossBattle(
            id: id,
            title: 'Challenge $id',
            bossType: 'inbox_hydra',
            status: 'open',
            rewardXp: 25,
            rewardCoins: 10,
            steps: [
              QuestwellBossStep(
                  id: '$id-1',
                  title: 'One useful action',
                  position: 0,
                  completed: false)
            ]);
    final battles = [battle('a'), battle('b')];
    await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
      data: const MediaQueryData(
          textScaler: TextScaler.linear(2), disableAnimations: true),
      child: Scaffold(
        bottomNavigationBar:
            const QuestwellAppNavigation(current: QuestwellDestination.bosses),
        body: QuestwellBossBoard(
            battles: battles,
            onHome: () {},
            onCreate: () {},
            onAttack: (_, __) {}),
      ),
    )));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const ValueKey('select-b')), 150,
        scrollable: find.byType(Scrollable).first, maxScrolls: 50);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('select-b')));
    await tester.pumpAndSettle();
    expect(find.byType(QuestwellBossEncounter), findsOneWidget);
    final encounter = tester.getRect(find.byType(QuestwellBossEncounter));
    final navigation = tester.getRect(find.byType(QuestwellAppNavigation));
    expect(encounter.top, greaterThanOrEqualTo(0));
    expect(encounter.top, lessThan(navigation.top));
    expect(
        tester
            .widget<QuestwellBossEncounter>(find.byType(QuestwellBossEncounter))
            .encounterId,
        'b');
    expect(tester.takeException(), isNull);
  });
}
