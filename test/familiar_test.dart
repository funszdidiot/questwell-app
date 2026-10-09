import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_familiar.dart';
import '../lib/widgets/questwell_pet_frame.dart';
import '../lib/widgets/questwell_pet_motion.dart';
import '../lib/widgets/questwell_catalog_equipment.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/preview/market_catalog.dart';
import '../lib/services/questwell_equipment_policy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  test('Every equipped familiar is available through the Market', () {
    final entries =
        marketReviewCatalog.where((c) => c['category'] == 'familiar');
    expect(entries.map((c) => c['slug']).toSet(),
        QuestwellFamiliarLayer.names.keys.toSet());
    for (final entry in entries) {
      expect(
          QuestwellEquipmentPolicy.isReady(entry['slug'] as String, 'familiar'),
          isTrue);
      expect(entry['unlock_method'], 'shop');
    }
  });
  testWidgets('Every familiar, including dragon, fits all three avatar bodies',
      (tester) async {
    for (final slug in QuestwellFamiliarLayer.names.keys) {
      for (final body in ['female', 'male', 'neutral']) {
        await tester.pumpWidget(MaterialApp(
            home: MediaQuery(
                data: const MediaQueryData(disableAnimations: true),
                child: Center(
                    child: SizedBox(
                        width: 240,
                        height: 320,
                        child: QuestwellLayeredAdventurerArt(
                            archetype: 'scholar',
                            avatarBodyType: body,
                            equippedSlugs: {'familiar': slug}))))));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$slug / $body');
        final image = find.byWidgetPredicate((w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName ==
                QuestwellFamiliarLayer.asset(slug));
        expect(image, findsOneWidget);
        final art = tester.getRect(find.byType(QuestwellLayeredAdventurerArt));
        final sprite = tester.getRect(QuestwellPetMotion.names.containsKey(slug)
            ? find.byType(QuestwellPetFrame)
            : image);
        expect(sprite.left, greaterThanOrEqualTo(art.left));
        expect(sprite.right, lessThanOrEqualTo(art.right));
        expect(sprite.bottom, lessThanOrEqualTo(art.bottom));
      }
    }
  });
  testWidgets(
      'Idle movement runs, then settles for reduced motion and hidden screens',
      (tester) async {
    Widget scene({bool reduced = false, bool active = true}) => MaterialApp(
        home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduced),
            child: TickerMode(
                enabled: active,
                child: const SizedBox(
                    width: 240,
                    height: 320,
                    child: QuestwellFamiliarLayer(slug: 'emerald-dragon')))));
    await tester.pumpWidget(scene());
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(scene(reduced: true));
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
    await tester.pumpWidget(scene());
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(scene(active: false));
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
  });
  test('Smoke drifts upward from the nose and disappears between exhales',
      () async {
    Future<List<int>> pixels(double phase) async {
      final recorder = ui.PictureRecorder();
      QuestwellDragonSmokePainter(phase: phase)
          .paint(Canvas(recorder), const Size(72, 80));
      final picture = recorder.endRecording();
      final image = await picture.toImage(72, 80);
      final data = (await image.toByteData())!.buffer.asUint8List().toList();
      image.dispose();
      picture.dispose();
      return data;
    }

    expect((await pixels(0)).every((b) => b == 0), isTrue);
    final early = await pixels(.08), later = await pixels(.45);
    expect(early, isNot(later));
    double meanY(List<int> bytes) {
      var total = 0.0, weight = 0.0;
      for (var y = 0; y < 80; y++) {
        for (var x = 0; x < 72; x++) {
          final alpha = bytes[(y * 72 + x) * 4 + 3];
          total += y * alpha;
          weight += alpha;
        }
      }
      expect(weight, greaterThan(0));
      return total / weight;
    }

    expect(meanY(later), lessThan(meanY(early)));
    expect((await pixels(.95)).every((b) => b == 0), isTrue);
  });
  test('Rain moves only inside the registered window panes', () async {
    Future<List<int>> pixels(double phase) async {
      final recorder = ui.PictureRecorder();
      QuestwellRainyWindowOverlay(phase: phase)
          .paint(Canvas(recorder), const Size(768, 768));
      final picture = recorder.endRecording();
      final image = await picture.toImage(768, 768);
      final data = (await image.toByteData())!.buffer.asUint8List().toList();
      image.dispose();
      picture.dispose();
      return data;
    }

    final first = await pixels(0), next = await pixels(.27);
    expect(first, isNot(next));
    for (final bytes in [first, next]) {
      for (var y = 0; y < 768; y++) {
        expect(bytes[(y * 768 + 754) * 4 + 3], 0,
            reason: 'Wooden vertical mullion');
        expect(bytes[(y * 768 + 700) * 4 + 3], 0, reason: 'Adjacent wall');
      }
      expect(bytes[(190 * 768 + 730) * 4 + 3], greaterThan(0));
      expect(bytes[(228 * 768 + 730) * 4 + 3], 0,
          reason: 'Wooden horizontal mullion');
    }
  });
  testWidgets('Rain respects reduced motion, hidden screens, and unequipping',
      (tester) async {
    Widget scene(
            {bool reduced = false, bool active = true, bool equipped = true}) =>
        MaterialApp(
            home: MediaQuery(
                data: MediaQueryData(disableAnimations: reduced),
                child: TickerMode(
                    enabled: active,
                    child: SizedBox(
                        width: 390,
                        height: 342,
                        child: equipped
                            ? const QuestwellRainyWindow()
                            : const SizedBox.shrink()))));
    await tester.pumpWidget(scene());
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(scene(reduced: true));
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
    await tester.pumpWidget(scene());
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(scene(active: false));
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
    await tester.pumpWidget(scene());
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(scene(equipped: false));
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.takeException(), isNull);
  });
}
