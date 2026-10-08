import 'dart:io';
import 'market_grouping_test.dart' as fixture;
import '../lib/preview/market_catalog.dart';
import '../lib/services/questwell_cosmetic_models.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

// Render the actual shared page integrations; image capture is not approval.
void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('capture grouped Market at normal and enlarged text',
      (tester) async {
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
      FontWeight.w700: 'Roboto-Bold.ttf',
      FontWeight.w800: 'Roboto-Bold.ttf',
    }.entries) {
      final loader =
          FontLoader(GoogleFonts.roboto(fontWeight: entry.key).fontFamily!)
            ..addFont(rootBundle.load('assets/fonts/${entry.value}'));
      await loader.load();
    }
    final capture = GlobalKey();
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final size in [const Size(390, 844), const Size(320, 740)]) {
      await tester.binding.setSurfaceSize(size);
      final scale = size.width == 320 ? 2.0 : 1.0;
      for (final screen in ['Market']) {
        await tester.pumpWidget(
          RepaintBoundary(
            key: capture,
            child: KeyedSubtree(
                key: ValueKey(scale),
                child: fixture.market(
                    marketReviewCatalog
                        .map((row) => QuestwellCosmetic.fromJson(row))
                        .toList(),
                    scale: scale)),
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
        final browse = find.byKey(const ValueKey('market-browse-type'));
        await tester.dragUntilVisible(
            browse.hitTestable(), find.byType(ListView), const Offset(0, -120));
        await Scrollable.ensureVisible(tester.element(browse), alignment: 0.15);
        await tester.pump(const Duration(milliseconds: 400));
        for (final phase in ['browse', 'menu', 'outfits', 'hearth']) {
          if (phase == 'hearth') {
            await tester.dragUntilVisible(browse.hitTestable(),
                find.byType(ListView), const Offset(0, 140));
            await Scrollable.ensureVisible(tester.element(browse),
                alignment: 0.2);
            await tester.pump(const Duration(milliseconds: 400));
            await tester.tap(browse);
            await tester.pump(const Duration(milliseconds: 400));
            await tester.ensureVisible(find.text('Hearth').last);
            await tester.pump(const Duration(milliseconds: 400));
            await tester.tap(find.text('Hearth').last);
            await tester.pump(const Duration(milliseconds: 400));
          }
          if (phase == 'menu') {
            await tester.tap(browse);
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 400));
          }
          if (phase == 'outfits' || phase == 'hearth') {
            final heading = find.byKey(ValueKey(
                'market-section-${phase == 'outfits' ? 'Outfits' : 'Hearth settings'}'));
            await tester.dragUntilVisible(
                heading, find.byType(ListView), const Offset(0, -140));
            await Scrollable.ensureVisible(tester.element(heading),
                alignment: 0.1);
            await tester.pump(const Duration(milliseconds: 400));
          }
          final boundary = capture.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: 1);
            final bytes =
                await image.toByteData(format: ui.ImageByteFormat.png);
            final file = File(
              'build/market-groups/${phase}-${screen.toLowerCase().replaceAll(' ', '-')}-${size.width.toInt()}.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
          if (phase == 'menu') {
            await tester.sendKeyEvent(LogicalKeyboardKey.escape);
            await tester.pump(const Duration(milliseconds: 400));
          }
          expect(tester.takeException(), isNull);
        }
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
