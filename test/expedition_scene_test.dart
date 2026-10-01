import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_expedition_scene.dart';
import '../lib/pages/expedition_page/expedition_page_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  Widget scene({bool motion = true, bool reduced = false, bool ticker = true}) =>
    MaterialApp(home: MediaQuery(data: MediaQueryData(disableAnimations: reduced),
      child: TickerMode(enabled: ticker, child: Center(child: SizedBox(width: 320,
        child: QuestwellExpeditionScene(motion: motion))))));

  testWidgets('Ambience repaints without rebuilding art and stops when motion is disabled', (tester) async {
    await tester.pumpWidget(scene());
    await tester.pump(const Duration(milliseconds: 100));
    final art = tester.widget<Image>(find.byKey(const ValueKey('expedition-trail-art')));
    final painter = tester.widget<CustomPaint>(find.byKey(const ValueKey('expedition-ambience'))).painter!;
    var paints = 0;
    void repaint() => paints++;
    painter.addListener(repaint);
    await tester.pump(const Duration(seconds: 1));
    expect(paints, greaterThan(0));
    expect(identical(art, tester.widget<Image>(find.byKey(const ValueKey('expedition-trail-art')))), isTrue);
    painter.removeListener(repaint);
    for (final mode in [scene(motion: false), scene(reduced: true), scene(ticker: false)]) {
      await tester.pumpWidget(mode);
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(find.byKey(const ValueKey('expedition-trail-art')), findsOneWidget);
    }
    await tester.pumpWidget(scene());
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.binding.hasScheduledFrame, isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('Animated scenery preserves narrow-screen timer controls and reduced motion', (tester) async {
    tester.view.physicalSize = const Size(320, 1700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: MediaQuery(
      data: MediaQueryData(disableAnimations: true, textScaler: TextScaler.linear(1.5)),
      child: ExpeditionPageWidget())));
    await tester.pumpAndSettle();
    expect(find.text('25:00'), findsOneWidget);
    expect(find.byKey(const ValueKey('expedition-trail-art')), findsOneWidget);
    await tester.ensureVisible(find.text('15 min'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15 min'));
    await tester.pumpAndSettle();
    expect(find.text('15:00'), findsOneWidget);
    await tester.ensureVisible(find.text('Begin Expedition'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Begin Expedition'));
    await tester.pump();
    expect(find.text('Pause'), findsOneWidget);
    await tester.tap(find.text('Pause'));
    await tester.pumpAndSettle();
    expect(find.text('Begin Expedition'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byTooltip('Pause scenery'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Pause scenery'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Animate scenery'), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
