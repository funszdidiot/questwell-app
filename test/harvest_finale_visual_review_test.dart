import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_boss_encounter.dart';

// Export actual renderer checkpoints for independent review; no auto-approved golden.
void main() {
  testWidgets('capture Harvest finale at phone and desktop widths',
      (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    final capture = GlobalKey();
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Future<void> save(String name) async {
      await tester.runAsync(() async {
        await Future.wait(tester.widgetList<Image>(find.byType(Image)).map(
            (image) => precacheImage(image.image, capture.currentContext!)));
      });
      await tester.pump();
      await tester.runAsync(() async {
        final boundary = capture.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('build/hallowed-review/harvest-finale/$name.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      expect(tester.takeException(), isNull);
    }

    for (final width in [320.0, 390.0, 600.0]) {
      await tester.binding.setSurfaceSize(Size(width, 600));
      Widget scene(bool defeated) => MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(
                  child: RepaintBoundary(
                      key: capture,
                      child: QuestwellBossEncounter(
                          encounterId: 'finale-${width.toInt()}',
                          persistEntrance: false,
                          bossType: 'hollow_harvest',
                          progress: defeated ? 1 : .33,
                          defeated: defeated)))));
      await tester.pumpWidget(scene(false));
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      await save('${width.toInt()}-standing');
      await tester.pumpWidget(scene(true));
      await tester.pump(const Duration(milliseconds: 400));
      await save('${width.toInt()}-transition');
      await tester.pump(const Duration(seconds: 1));
      await save('${width.toInt()}-defeated');
      await tester.pumpWidget(const SizedBox());
    }
  });
}
