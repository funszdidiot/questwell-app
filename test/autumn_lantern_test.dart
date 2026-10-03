import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/questwell_autumn_lantern.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Lantern clock pauses for accessibility, inactive routes and lifecycle, and disposes on removal', (tester) async {
    Widget app({bool still = false, bool ticking = true}) => MaterialApp(home:
      MediaQuery(data: MediaQueryData(disableAnimations: still), child:
        TickerMode(enabled: ticking, child: const SizedBox(width: 100, height: 180,
          child: QuestwellAutumnLantern()))));
    AutumnLanternPainter painter() => tester.widgetList<CustomPaint>(find.byType(CustomPaint))
      .map((w) => w.painter).whereType<AutumnLanternPainter>().first;
    await tester.pumpWidget(app());
    await tester.pump(const Duration(milliseconds: 200));
    final clock = painter().clock;
    final started = clock.value;
    await tester.pump(const Duration(milliseconds: 400));
    expect(clock.value, isNot(started));
    for (final inactive in [app(still: true), app(ticking: false)]) {
      await tester.pumpWidget(inactive);
      final frozen = clock.value;
      await tester.pump(const Duration(seconds: 1));
      expect(clock.value, frozen);
    }
    await tester.pumpWidget(app());
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    final background = clock.value;
    await tester.pump(const Duration(seconds: 1));
    expect(clock.value, background);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(clock.value, isNot(background));
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });
  test('Light and leaf art changes across the animation cycle', () async {
    Future<List<int>> pixels(double value) async {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      for (final front in [false,true]) {
        AutumnLanternPainter(AlwaysStoppedAnimation(value), foreground: front)
          .paint(canvas, const Size(100,180));
      }
      final picture = recorder.endRecording();
      final image = await picture.toImage(100,180);
      final bytes = (await image.toByteData())!.buffer.asUint8List().toList();
      image.dispose(); picture.dispose();
      return bytes;
    }
    final first = await pixels(.15);
    final second = await pixels(.40);
    expect(first.any((b) => b != 0), isTrue);
    expect(first, isNot(equals(second)));
  });
}
