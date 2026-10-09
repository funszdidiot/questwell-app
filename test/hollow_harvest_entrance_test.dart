import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/widgets/questwell_boss_encounter.dart';
import '../lib/preview/hollow_harvest_review.dart';
import '../lib/widgets/questwell_hollow_harvest.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  Widget scene({double progress = 0, bool reduced = false}) => MaterialApp(
      home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: Scaffold(
              body: SingleChildScrollView(
                  child: SizedBox(
                      width: 320,
                      child: QuestwellBossEncounter(
                          encounterId: 'harvest-test-$reduced',
                          bossType: 'hollow_harvest',
                          progress: progress))))));

  testWidgets('Desktop preview keeps the complete boss within the arena',
      (tester) async {
    tester.view.physicalSize = const Size(1366, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const HollowHarvestReview());
    await tester.pumpAndSettle();
    final arena = tester.getRect(find.byKey(const ValueKey('boss-arena')));
    final boss = tester.getRect(find.byType(QuestwellHollowHarvest));
    expect(arena.width, lessThanOrEqualTo(600));
    expect(boss.top, greaterThanOrEqualTo(arena.top));
    expect(boss.bottom, lessThanOrEqualTo(arena.bottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Assembly completes once and does not restart on strikes or remount',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(scene());
    await tester.pumpAndSettle();
    expect(
        find.byKey(const ValueKey('harvest-clearing-arena')), findsOneWidget);
    expect(
        tester
            .widget<QuestwellHollowHarvest>(find.byType(QuestwellHollowHarvest))
            .phase,
        1);
    expect(find.text('A few unfinished tasks? How delicious.'), findsOneWidget);
    await tester.pumpWidget(scene(progress: .33));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
        tester
            .widget<QuestwellHollowHarvest>(find.byType(QuestwellHollowHarvest))
            .phase,
        1);
    expect(find.byKey(const ValueKey('skip-boss-entrance')), findsNothing);
    await tester.pumpAndSettle();
    expect(
        (await SharedPreferences.getInstance())
            .getBool('questwell.boss.intro.v1.harvest-test-false'),
        isTrue);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(scene());
    await tester.pump();
    expect(find.byKey(const ValueKey('skip-boss-entrance')), findsNothing);
    expect(
        tester
            .widget<QuestwellHollowHarvest>(find.byType(QuestwellHollowHarvest))
            .phase,
        1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Reduced motion shows assembled boss and settles without movement',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(scene(reduced: true));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<QuestwellHollowHarvest>(find.byType(QuestwellHollowHarvest))
            .phase,
        1);
    expect(find.byKey(const ValueKey('skip-boss-entrance')), findsNothing);
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });
}
