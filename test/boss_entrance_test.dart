import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/widgets/questwell_boss_encounter.dart';
import '../lib/widgets/questwell_pixel_art.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  Widget scene({String id = 'sample', bool reduced = false, bool persist = false,
      double progress = 0, bool defeated = false, String type = 'inbox_hydra'}) => MaterialApp(home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduced), child: Center(child: SizedBox(width: 360,
      child: QuestwellBossEncounter(encounterId: id, persistEntrance: persist, bossType: type,
        progress: progress, defeated: defeated)))));
  testWidgets('Entrance reaches dialogue and YOUR MOVE, with health from task progress', (tester) async {
    await tester.pumpWidget(scene());
    expect(find.text('BOSS APPROACHING'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('You said you’d do it tomorrow.'), findsOneWidget);
    expect(find.text('YOUR MOVE'), findsOneWidget);
    await tester.pumpWidget(scene(progress: 1 / 3));
    expect(tester.widget<QuestwellPixelMeter>(find.byType(QuestwellPixelMeter)).value, closeTo(2 / 3, .001));
    expect(find.text('BOSS APPROACHING'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Meeting Mimic uses its own art and taunt, with reduced motion and defeat', (tester) async {
    await tester.pumpWidget(scene(id: 'mimic', type: 'meeting_mimic'));
    expect(find.text('MEETING MIMIC'), findsOneWidget);
    expect(find.text('BOSS APPROACHING'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('This could have been an email.'), findsOneWidget);
    expect(find.text('You said you’d do it tomorrow.'), findsNothing);
    expect(find.byWidgetPredicate((w) => w is Image && w.image is AssetImage &&
      (w.image as AssetImage).assetName.endsWith('questwell_meeting_mimic_v1.webp')), findsOneWidget);
    await tester.pumpWidget(scene(id: 'mimic', type: 'meeting_mimic', reduced: true, progress: 1, defeated: true));
    await tester.pumpAndSettle();
    expect(find.text('MEETING MIMIC · DEFEATED'), findsOneWidget);
    expect(find.text('VICTORY'), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Spreadsheet Slime reveals its taunt and settles its squash animation', (tester) async {
    await tester.pumpWidget(scene(id: 'slime', type: 'spreadsheet_slime'));
    expect(find.text('SPREADSHEET SLIME'), findsOneWidget);
    expect(find.text('BOSS APPROACHING'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('It worked in the other tab.'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Image && w.image is AssetImage &&
      (w.image as AssetImage).assetName.endsWith('questwell_spreadsheet_slime_v1.webp')), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pumpWidget(scene(id: 'slime', type: 'spreadsheet_slime', reduced: true, progress: 1, defeated: true));
    await tester.pumpAndSettle();
    expect(find.text('SPREADSHEET SLIME · DEFEATED'), findsOneWidget);
    expect(find.text('VICTORY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Calendar Kraken rises then settles, supports skip and reduced motion', (tester) async {
    await tester.pumpWidget(scene(id: 'kraken', type: 'calendar_kraken'));
    expect(find.text('CALENDAR KRAKEN'), findsOneWidget);
    expect(find.text('BOSS APPROACHING'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('skip-boss-entrance')));
    await tester.pumpAndSettle();
    expect(find.text('I found a gap in your calendar.'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Image && w.image is AssetImage &&
      (w.image as AssetImage).assetName.endsWith('questwell_calendar_kraken_v1.webp')), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pumpWidget(scene(id: 'kraken', type: 'calendar_kraken', reduced: true, progress: 1, defeated: true));
    await tester.pumpAndSettle();
    expect(find.text('CALENDAR KRAKEN · DEFEATED'), findsOneWidget);
    expect(find.text('VICTORY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Printer Poltergeist reveals art and dialogue then stops animating', (tester) async {
    await tester.pumpWidget(scene(id: 'printer', type: 'printer_poltergeist'));
    expect(find.text('PRINTER POLTERGEIST'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Paper jam. Naturally.'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Image && w.image is AssetImage &&
      (w.image as AssetImage).assetName.endsWith('questwell_printer_poltergeist_v1.webp')), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pumpWidget(scene(id: 'printer', type: 'printer_poltergeist', reduced: true, progress: 1, defeated: true));
    await tester.pumpAndSettle();
    expect(find.text('PRINTER POLTERGEIST · DEFEATED'), findsOneWidget);
    expect(find.text('VICTORY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Notification Swarm settles its flutter and uses its own dialogue', (tester) async {
    await tester.pumpWidget(scene(id: 'swarm', type: 'notification_swarm'));
    expect(find.text('NOTIFICATION SWARM'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Just one more ping.'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Image && w.image is AssetImage &&
      (w.image as AssetImage).assetName.endsWith('questwell_notification_swarm_v2.webp')), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pumpWidget(scene(id: 'swarm', type: 'notification_swarm', reduced: true, progress: 1, defeated: true));
    await tester.pumpAndSettle();
    expect(find.text('NOTIFICATION SWARM · DEFEATED'), findsOneWidget);
    expect(find.text('VICTORY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Skip persists and does not replay after remount', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(scene(id: 'persistent-test', persist: true));
    await tester.pump(); await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const ValueKey('skip-boss-entrance')));
    await tester.pumpAndSettle();
    expect(find.text('YOUR MOVE'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getBool('questwell.boss.intro.v1.persistent-test'), isTrue);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(scene(id: 'persistent-test', persist: true));
    await tester.pumpAndSettle();
    expect(find.text('BOSS APPROACHING'), findsNothing);
    expect(find.text('YOUR MOVE'), findsOneWidget);
  });
  testWidgets('Reduced motion and resumed battles bypass moving entrance; defeat shows zero health', (tester) async {
    await tester.pumpWidget(scene(reduced: true)); await tester.pumpAndSettle();
    expect(find.text('YOUR MOVE'), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pumpWidget(scene(reduced: true, progress: 1, defeated: true)); await tester.pumpAndSettle();
    expect(find.text('VICTORY'), findsOneWidget);
    expect(tester.widget<QuestwellPixelMeter>(find.byType(QuestwellPixelMeter)).value, 0);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(scene(id: 'resumed', progress: .5)); await tester.pumpAndSettle();
    expect(find.text('BOSS APPROACHING'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
