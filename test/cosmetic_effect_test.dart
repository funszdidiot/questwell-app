import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/questwell_cosmetic_effect.dart';
import '../lib/widgets/questwell_catalog_equipment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final slug in QuestwellCosmeticEffect.names.keys) {
    Future<List<int>> pixels(double phase, {bool still = false}) async {
      final recorder = ui.PictureRecorder();
      QuestwellCosmeticEffectPainter(
              slug: slug, clock: AlwaysStoppedAnimation(phase), still: still)
          .paint(Canvas(recorder), const Size(240, 320));
      final picture = recorder.endRecording();
      final image = await picture.toImage(240, 320);
      final data = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
          .buffer
          .asUint8List()
          .toList();
      image.dispose();
      picture.dispose();
      return data;
    }

    test('$slug moves, stays outside face, and retains a still alternative',
        () async {
      final a = await pixels(.16), b = await pixels(.3);
      expect(a, isNot(equals(b)));
      expect(a.where((v) => v != 0), isNotEmpty);
      for (var y = 0; y < 85; y++) {
        for (var x = 85; x < 155; x++) {
          expect(a[(y * 240 + x) * 4 + 3], 0);
        }
      }
      expect(
          await pixels(.1, still: true), equals(await pixels(.8, still: true)));
      if (slug == 'victory-sparkle') {
        expect((await pixels(.95)).every((v) => v == 0), isTrue);
      }
    });
    testWidgets(
        '$slug pauses for reduced motion and hidden routes and removes on unequip',
        (tester) async {
      Widget scene(
              {bool reduced = false,
              bool active = true,
              bool equipped = true}) =>
          MaterialApp(
              home: MediaQuery(
                  data: MediaQueryData(disableAnimations: reduced),
                  child: TickerMode(
                      enabled: active,
                      child: SizedBox(
                          width: 240,
                          height: 320,
                          child: QuestwellCatalogEquipment(
                              body: 'female',
                              equipment: {if (equipped) 'effect': slug})))));
      await tester.pumpWidget(scene());
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.binding.hasScheduledFrame, isTrue);
      await tester.pumpWidget(scene(reduced: true));
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(find.byType(QuestwellCosmeticEffect), findsOneWidget);
      await tester.pumpWidget(scene());
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.binding.hasScheduledFrame, isTrue);
      await tester.pumpWidget(scene(active: false));
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pumpWidget(scene(equipped: false));
      await tester.pumpAndSettle();
      expect(find.byType(QuestwellCosmeticEffect), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
