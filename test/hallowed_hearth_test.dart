import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_hallowed_spiders.dart';
import '../lib/widgets/questwell_pixel_art.dart';

Future<Uint8List> paintFrame(double phase) async {
  final recorder = ui.PictureRecorder();
  HallowedSpiderPainter(
    AlwaysStoppedAnimation(phase),
    still: false,
  ).paint(Canvas(recorder), const Size(390, 260));
  final picture = recorder.endRecording();
  final image = await picture.toImage(390, 260);
  final data = await image.toByteData();
  final bytes = Uint8List.fromList(data!.buffer.asUint8List());
  image.dispose();
  picture.dispose();
  return bytes;
}

void main() {
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
