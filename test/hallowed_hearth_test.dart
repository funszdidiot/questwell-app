import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_hallowed_spiders.dart';
import '../lib/widgets/questwell_catalog_equipment.dart';
import '../lib/widgets/questwell_pixel_art.dart';

Future<Uint8List> paintFrame(double phase,
    {Size size = const Size(390, 260)}) async {
  final recorder = ui.PictureRecorder();
  HallowedSpiderPainter(
    AlwaysStoppedAnimation(phase),
    still: false,
  ).paint(Canvas(recorder), size);
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  final data = await image.toByteData();
  final bytes = Uint8List.fromList(data!.buffer.asUint8List());
  image.dispose();
  picture.dispose();
  return bytes;
}

void main() {
  testWidgets('Hallowed rain stays inside its glass and animates',
      (tester) async {
    Future<Uint8List> frame(double phase) async {
      final recorder = ui.PictureRecorder();
      QuestwellRainyWindowOverlay(phase: phase, hallowed: true)
          .paint(Canvas(recorder), const Size(390, 260));
      final picture = recorder.endRecording();
      final image = await picture.toImage(390, 260);
      final data = await image.toByteData();
      final bytes = Uint8List.fromList(data!.buffer.asUint8List());
      image.dispose();
      picture.dispose();
      return bytes;
    }

    final start = await tester.runAsync(() => frame(0));
    final later = await tester.runAsync(() => frame(.25));
    expect(start, isNot(orderedEquals(later!)));
    var painted = 0;
    for (var y = 0; y < 260; y++) {
      for (var x = 0; x < 390; x++) {
        if (later[(y * 390 + x) * 4 + 3] == 0) continue;
        painted++;
        expect(x, inInclusiveRange(247, 314));
        expect(y, inInclusiveRange(33, 115));
      }
    }
    expect(painted, greaterThan(500));
  });
  testWidgets('portrait crop keeps both animated spiders visible',
      (tester) async {
    final start =
        await tester.runAsync(() => paintFrame(0, size: const Size(390, 420)));
    final middle =
        await tester.runAsync(() => paintFrame(.5, size: const Size(390, 420)));
    expect(start, isNot(orderedEquals(middle!)));
    var left = 0;
    var right = 0;
    for (var y = 0; y < 168; y++) {
      for (var x = 0; x < 390; x++) {
        if (middle[(y * 390 + x) * 4 + 3] != 0) {
          if (x < 195) {
            left++;
          } else {
            right++;
          }
        }
      }
    }
    expect(left, greaterThan(20));
    expect(right, greaterThan(20));
    expect(middle.skip(390 * 168 * 4).every((byte) => byte == 0), isTrue);
  });
  testWidgets(
    'motion paints changes, loops continuously and leaves floor clear',
    (tester) async {
      final start = await tester.runAsync(() => paintFrame(0));
      final middle = await tester.runAsync(() => paintFrame(.5));
      final end = await tester.runAsync(() => paintFrame(1));
      expect(start, isNot(orderedEquals(middle!)));
      expect(start, orderedEquals(end!));
      // Every spider pixel stays above 40% of the room, including legs and silk.
      expect(middle.skip(390 * 104 * 4).every((byte) => byte == 0), isTrue);
    },
  );

  testWidgets(
    'spiders preserve taps and stop on reduced motion or hidden route',
    (tester) async {
      var taps = 0;
      Widget host({bool reduced = false, bool enabled = true}) => MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: TickerMode(
                enabled: enabled,
                child: Stack(
                  children: [
                    TextButton(
                        onPressed: () => taps++, child: const Text('Quest')),
                    const Positioned.fill(child: QuestwellHallowedSpiders()),
                  ],
                ),
              ),
            ),
          );
      await tester.pumpWidget(host());
      await tester.pump(const Duration(seconds: 2));
      expect(tester.binding.hasScheduledFrame, isTrue);
      await tester.tap(find.text('Quest'));
      expect(taps, 1);
      await tester.pumpWidget(host(reduced: true));
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pumpWidget(host());
      await tester.pump(const Duration(seconds: 1));
      expect(tester.binding.hasScheduledFrame, isTrue);
      await tester.pumpWidget(host(enabled: false));
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('real Hearth loads the approved room with setting-only spiders', (
    tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    for (final width in [320.0, 390.0, 430.0, 960.0]) {
      await tester.binding.setSurfaceSize(Size(width, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestwellHearthPixelScene(
              setting: QuestwellHearthSetting.hallowedHearth,
              height: width / 1.5,
              immersive: true,
              showAvatar: false,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(QuestwellHallowedSpiders), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName ==
                  QuestwellHearthSetting.hallowedHearth.asset,
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QuestwellHearthPixelScene(immersive: true, showAvatar: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(QuestwellHallowedSpiders), findsNothing);
    expect(QuestwellHearthSetting.supports('hallowed-hearth'), isTrue);
    expect(QuestwellHearthSetting.fromSlug('hallowed-hearth'),
        QuestwellHearthSetting.hallowedHearth);
    await tester.binding.setSurfaceSize(null);
  });
}
