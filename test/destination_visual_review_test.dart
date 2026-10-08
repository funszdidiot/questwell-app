import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/preview/mobile_review.dart';
import 'package:project_momentum/preview/adventurer_review.dart';

// Render the actual shared page integrations; image capture is not approval.
void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('standalone Adventurer settings opens and closes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const AdventurerReviewApp());
    await tester.pump();
    await tester.tap(find.byTooltip('Account settings'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Close'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('capture all six destination integrations', (tester) async {
    final font = FontLoader(GoogleFonts.pressStart2p().fontFamily!)
      ..addFont(rootBundle.load('assets/fonts/PressStart2P-Regular.ttf'));
    await font.load();
    for (final entry in const {
      'Roboto': 'assets/fonts/Roboto-Regular.ttf',
      'HearthSerif': 'assets/fonts/DejaVuSerif-Bold.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(rootBundle.load(entry.value));
      await loader.load();
    }
    for (final entry in {
      FontWeight.w400: 'Roboto-Regular.ttf',
      FontWeight.w500: 'Roboto-Medium.ttf',
      FontWeight.w700: 'Roboto-ExtraBold.ttf',
      FontWeight.w800: 'Roboto-ExtraBold.ttf',
    }.entries) {
      final loader =
          FontLoader(GoogleFonts.roboto(fontWeight: entry.key).fontFamily!)
            ..addFont(rootBundle.load('assets/fonts/${entry.value}'));
      await loader.load();
    }
    final capture = GlobalKey();
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final size in [const Size(390, 1000), const Size(320, 1100)]) {
      await tester.binding.setSurfaceSize(size);
      final scale = size.width == 320 ? 2.0 : 1.0;
      for (final screen in [
        'Quests',
        'Boss Battles',
        'Adventurer',
        'Chronicle',
        'Expedition',
        'Market',
      ]) {
        await tester.pumpWidget(
          RepaintBoundary(
            key: capture,
            child: MobileReviewApp(
              key: ValueKey('$screen-$scale'),
              initialScreen: screen,
              initialWidth: size.width,
              initialTextScale: scale,
            ),
          ),
        );
        await tester.pump();
        await tester.runAsync(() async {
          await Future.wait(
            tester.widgetList<Image>(find.byType(Image)).map(
                  (image) =>
                      precacheImage(image.image, capture.currentContext!),
                ),
          );
        });
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull, reason: '$screen/$scale');
        final boundary = capture.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            'build/hallowed-review/entrances/${screen.toLowerCase().replaceAll(' ', '-')}-${size.width.toInt()}.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
