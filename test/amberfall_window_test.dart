import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/questwell_amberfall_window.dart';
import '../lib/widgets/questwell_window_geometry.dart';
import '../lib/widgets/questwell_pixel_art.dart';

Future<Uint8List> frame(double phase, Size size, String roomFile) async {
  final recorder = ui.PictureRecorder();
  AmberfallLeafPainter(
    AlwaysStoppedAnimation(phase),
    roomFile: roomFile,
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
  test('every room has explicit glass registration and preserved leading', () {
    expect(
      QuestwellWindowGeometry.rooms.toSet(),
      QuestwellHearthSetting.values.map((r) => r.file).toSet(),
    );
    expect(() => QuestwellWindowGeometry.glass('unknown'), throwsArgumentError);
    final workshop = QuestwellWindowGeometry.glass('alchemists_workshop_v1');
    expect(workshop.contains(const Offset(1203, 203)), isFalse);
    // Segment plus rounded joint must not cancel under nonzero winding.
    expect(workshop.contains(const Offset(1202, 202)), isFalse);
    expect(workshop.contains(const Offset(1204, 204)), isFalse);
    expect(workshop.contains(const Offset(1205, 215)), isTrue);
    final observatory = QuestwellWindowGeometry.glass(
      'midnight_observatory_v1',
    );
    expect(observatory.contains(const Offset(1210, 148)), isFalse);
    expect(observatory.contains(const Offset(1210, 120)), isTrue);
  });
  test(
    'Hallowed glass follows tall central pane and excludes real mullions',
    () {
      final glass = QuestwellWindowGeometry.glass(
        QuestwellWindowGeometry.hallowed,
      );
      // These are independently measured glass/frame points in the approved art.
      for (final p in [
        const Offset(1150, 320),
        const Offset(1190, 350),
        const Offset(1150, 175),
        const Offset(1105, 145),
      ]) {
        expect(glass.contains(p), isTrue, reason: 'Uncovered glass at $p');
      }
      for (final p in [
        const Offset(1043, 350),
        const Offset(1105, 350),
        const Offset(1205, 350),
        const Offset(1000, 322),
      ]) {
        expect(glass.contains(p), isFalse, reason: 'Effect on wood at $p');
      }
    },
  );
  testWidgets('leaves move, loop exactly and stay inside existing glass', (
    tester,
  ) async {
    for (final setting in QuestwellHearthSetting.values) {
      final roomFile = setting.file;
      for (final size in [
        const Size(390, 390),
        const Size(390, 420),
        const Size(360, 253),
        const Size(960, 640),
      ]) {
        final a = await tester.runAsync(() => frame(0, size, roomFile));
        final b = await tester.runAsync(() => frame(.31, size, roomFile));
        final end = await tester.runAsync(() => frame(1, size, roomFile));
        expect(a, orderedEquals(end!));
        final glass = AmberfallGlassClipper(roomFile: roomFile).getClip(size);
        var painted = 0;
        for (var y = 0; y < size.height.toInt(); y++) {
          for (var x = 0; x < size.width.toInt(); x++) {
            if (b![(y * size.width.toInt() + x) * 4 + 3] == 0) continue;
            painted++;
            // Allow the one-pixel raster coverage at polygon edges, not frames.
            final inside = [
              const Offset(.5, .5),
              Offset.zero,
              const Offset(1, 0),
              const Offset(0, 1),
              const Offset(1, 1),
            ].any(
              (p) => glass.contains(Offset(x.toDouble(), y.toDouble()) + p),
            );
            expect(
              inside,
              isTrue,
              reason: '$roomFile $size ($x,$y) escaped glass',
            );
          }
        }
        // The authored standard room window is cropped off at some wide ratios.
        if (glass.getBounds().overlaps(Offset.zero & size)) {
          expect(painted, greaterThan(0));
          expect(a, isNot(orderedEquals(b!)));
        }
      }
    }
  });

  testWidgets('reduced motion, hidden preview and disposal stop the ticker', (
    tester,
  ) async {
    Widget host({bool reduced = false, bool enabled = true}) => MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduced),
            child: TickerMode(
              enabled: enabled,
              child: const SizedBox(
                width: 390,
                height: 420,
                child: QuestwellAmberfallWindow(
                  roomFile: QuestwellWindowGeometry.hallowed,
                ),
              ),
            ),
          ),
        );
    await tester.pumpWidget(host());
    await tester.pump(const Duration(seconds: 1));
    final painter = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((w) => w.painter)
        .whereType<AmberfallLeafPainter>()
        .single;
    expect((painter.phase as AnimationController).isAnimating, isTrue);
    await tester.pumpWidget(host(reduced: true));
    final paused = painter.phase.value;
    await tester.pump(const Duration(seconds: 1));
    expect(painter.phase.value, paused);
    expect((painter.phase as AnimationController).isAnimating, isFalse);
    await tester.pumpWidget(host());
    expect((painter.phase as AnimationController).isAnimating, isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    expect((painter.phase as AnimationController).isAnimating, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect((painter.phase as AnimationController).isAnimating, isTrue);
    await tester.pumpWidget(host(enabled: false));
    expect((painter.phase as AnimationController).isAnimating, isFalse);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('decorative window does not intercept taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => taps++,
                child: const ColoredBox(color: Colors.black),
              ),
            ),
            const Positioned.fill(
              child: QuestwellAmberfallWindow(
                roomFile: QuestwellWindowGeometry.hallowed,
              ),
            ),
          ],
        ),
      ),
    );
    await tester.tapAt(const Offset(100, 100));
    expect(taps, 1);
    await tester.pumpWidget(const SizedBox());
  });
}
