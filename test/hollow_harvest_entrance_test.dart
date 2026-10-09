import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/widgets/questwell_boss_encounter.dart';
import '../lib/preview/hollow_harvest_review.dart';
import '../lib/widgets/questwell_hollow_harvest.dart';
import '../lib/widgets/questwell_harvest_lanterns.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  Widget scene(
          {double progress = 0,
          bool reduced = false,
          bool defeated = false,
          bool active = true}) =>
      MaterialApp(
          home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: Scaffold(
                  body: SingleChildScrollView(
                      child: SizedBox(
                          width: 320,
                          child: TickerMode(
                              enabled: active,
                              child: QuestwellBossEncounter(
                                  encounterId: 'harvest-test-$reduced',
                                  bossType: 'hollow_harvest',
                                  progress: progress,
                                  defeated: defeated)))))));

  testWidgets('Desktop preview keeps the complete boss within the arena',
      (tester) async {
    tester.view.physicalSize = const Size(1366, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const HollowHarvestReview());
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
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
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
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
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
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
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
    expect(
        tester
            .widget<QuestwellHollowHarvest>(find.byType(QuestwellHollowHarvest))
            .phase,
        1);
    expect(find.byKey(const ValueKey('skip-boss-entrance')), findsNothing);
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Victory leaves an opaque pile and restores it without replay',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(scene(progress: .5));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpWidget(scene(progress: 1, defeated: true));
    await tester.pump(const Duration(milliseconds: 400));
    final during = tester
        .widget<QuestwellHollowHarvest>(find.byType(QuestwellHollowHarvest));
    expect(during.defeatPhase, inExclusiveRange(0, 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(const ValueKey('harvest-body')), findsNothing);
    expect(find.byKey(const ValueKey('harvest-spider')), findsOneWidget);
    expect(
        tester
            .widget<Opacity>(find.byKey(const ValueKey('harvest-pumpkin-pile')))
            .opacity,
        1);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(scene(progress: 1, defeated: true));
    await tester.pump();
    expect(
        tester
            .widget<QuestwellHollowHarvest>(find.byType(QuestwellHollowHarvest))
            .defeatPhase,
        1);
    expect(find.byKey(const ValueKey('skip-boss-entrance')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reduced motion settles victory immediately and stops lanterns',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(scene(progress: .5));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    HarvestLanternGlow glow() => tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((w) => w.painter)
        .whereType<HarvestLanternGlow>()
        .single;
    final before = glow().phase.value;
    await tester.pump(const Duration(milliseconds: 500));
    expect(glow().phase.value, isNot(before));
    await tester.pumpWidget(scene(progress: 1, defeated: true, reduced: true));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<QuestwellHollowHarvest>(find.byType(QuestwellHollowHarvest))
            .defeatPhase,
        1);
    expect(glow().phase.value, 0);
    expect(tester.binding.hasScheduledFrame, isFalse);
    // Re-enable motion, then mute the offstage route and confirm no light ticks.
    await tester.pumpWidget(scene(progress: 1, defeated: true));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpWidget(scene(progress: 1, defeated: true, active: false));
    await tester.pumpAndSettle();
    expect(glow().phase.value, 0);
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });
}
