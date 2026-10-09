import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/preview/autumn_hearth_review.dart';

void main() {
  testWidgets('real renderer captures autumn decor at mobile and web scales',
      (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    final key = GlobalKey();
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final width in [320.0, 390.0, 430.0, 960.0]) {
      final height = width < 500 ? 420.0 : 640.0;
      await tester.binding.setSurfaceSize(Size(width, height));
      for (final hallowed in [false, true]) {
        await tester.pumpWidget(MaterialApp(
            home: RepaintBoundary(
          key: key,
          child: TickerMode(
              enabled: false,
              child: AutumnHearthScene(height: height, hallowed: hallowed)),
        )));
        await tester.runAsync(() async {
          await Future.wait(tester.widgetList<Image>(find.byType(Image)).map(
                (image) => precacheImage(image.image, key.currentContext!),
              ));
        });
        await tester.pump();
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
              'build/autumn-review/${hallowed ? 'hallowed' : 'standard'}-${width.toInt()}.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    }
  });
}
