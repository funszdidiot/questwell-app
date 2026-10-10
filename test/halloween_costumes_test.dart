import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/preview/halloween_costumes_review.dart';
import '../lib/widgets/questwell_halloween_costume.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Pumpkin Court edge cleanup changes only scoped garment regions',
      () async {
    Future<ByteData> pixels(String file) async {
      final data = await rootBundle.load(
          'assets/images/questwell/avatar/halloween_v1/pumpkin_court/male/$file.webp');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final result =
          (await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      frame.image.dispose();
      codec.dispose();
      return result;
    }

    for (final layer in ['front', 'rear']) {
      final before = await pixels(layer == 'front' ? 'front_v2' : 'rear');
      final after = await pixels('${layer}_v3');
      var changed = 0;
      for (var y = 0; y < 320; y++) {
        for (var x = 0; x < 240; x++) {
          final offset = (y * 240 + x) * 4;
          expect(after.getUint8(offset + 3), before.getUint8(offset + 3));
          final allowed = layer == 'front'
              ? (y >= 77 && y <= 151 && (x < 96 || x > 145)) ||
                  (y >= 254 && y <= 282)
              : y >= 262 && y <= 274;
          for (var channel = 0; channel < 3; channel++) {
            if (!allowed) {
              expect(after.getUint8(offset + channel),
                  before.getUint8(offset + channel),
                  reason: '$layer protected pixel $x,$y');
            } else if (after.getUint8(offset + channel) !=
                before.getUint8(offset + channel)) {
              changed++;
            }
          }
        }
      }
      expect(changed, greaterThan(0));
    }
    final before = await pixels('front_v2');
    final after = await pixels('front_v3');
    for (final point in [(80, 83), (165, 274)]) {
      final offset = (point.$2 * 240 + point.$1) * 4;
      expect(after.getUint8(offset), greaterThan(before.getUint8(offset) + 20));
      expect(after.getUint8(offset), greaterThan(after.getUint8(offset + 1)));
    }
  });

  test(
    'male Pumpkin Court surface repair preserves every fitted alpha pixel',
    () async {
      Future<ByteData> pixels(String asset) async {
        final data = await rootBundle.load(asset);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        final rgba = (await frame.image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!;
        frame.image.dispose();
        codec.dispose();
        return rgba;
      }

      for (final layer in ['front', 'rear', 'collar', 'cuffs']) {
        final original = await pixels(
          'assets/images/questwell/avatar/halloween_v1/pumpkin_court/male/$layer.webp',
        );
        final repaired = await pixels(
          QuestwellHalloweenCostume.assetPath('pumpkin_court', 'male', layer),
        );
        expect(repaired.lengthInBytes, original.lengthInBytes);
        for (var offset = 3; offset < original.lengthInBytes; offset += 4) {
          expect(
            repaired.getUint8(offset),
            original.getUint8(offset),
            reason: '$layer alpha at pixel ${offset ~/ 4}',
          );
        }
      }
    },
  );

  test('all six costume bundles decode at their registered size', () async {
    for (final costume in QuestwellHalloweenCostume.costumes.keys) {
      for (final body in QuestwellHalloweenCostume.bodies) {
        for (final layer in [
          'rear',
          'underlay',
          'front',
          'cuffs',
          'mask',
          if (body != 'female') 'collar',
        ]) {
          final data = await rootBundle.load(
            QuestwellHalloweenCostume.assetPath(costume, body, layer),
          );
          final codec = await ui.instantiateImageCodec(
            data.buffer.asUint8List(),
          );
          final frame = await codec.getNextFrame();
          expect(frame.image.width, 240);
          expect(frame.image.height, 320);
          frame.image.dispose();
          codec.dispose();
        }
      }
    }
  });

  testWidgets(
    'shared renderer keeps complete costumes across every class and body',
    (tester) async {
      for (final body in QuestwellHalloweenCostume.bodies) {
        for (final archetype in [
          'scout',
          'scholar',
          'guardian',
          'wanderer',
          'alchemist',
        ]) {
          for (final costume in QuestwellHalloweenCostume.costumes.keys) {
            await tester.pumpWidget(
              MaterialApp(
                home: SizedBox(
                  width: 240,
                  height: 320,
                  child: QuestwellLayeredAdventurerArt(
                    archetype: archetype,
                    avatarBodyType: body,
                    equippedSlugs: {'chest': costume.replaceAll('_', '-')},
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(find.byType(QuestwellHalloweenCostume), findsOneWidget);
            final images = tester
                .widgetList<Image>(find.byType(Image))
                .map((image) => (image.image as AssetImage).assetName)
                .toList();
            expect(
              images.where(
                (name) =>
                    name.contains('/halloween_v1/') &&
                    name.endsWith('/mask.webp'),
              ),
              hasLength(1),
            );
            expect(images.where((name) => name.contains('/classes/')), isEmpty);
            final repaired = body == 'male' && costume == 'pumpkin_court';
            expect(
              images.where((name) => name.endsWith('_v2.webp')),
              hasLength(repaired ? 2 : 0),
            );
            expect(
              images.where(
                (name) =>
                    name.endsWith('_v3.webp') &&
                    name.contains('/halloween_v1/'),
              ),
              hasLength(repaired ? 2 : 0),
            );
            expect(
              images.where(
                (name) => name.contains('/base/') && !name.contains('identity'),
              ),
              hasLength(1),
            );
          }
        }
      }
    },
  );

  testWidgets(
    'male Pumpkin Court keeps its locked body across equip and reload',
    (tester) async {
      Future<List<String>> render(bool equipped, int revision) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SizedBox(
              width: 240,
              height: 320,
              child: QuestwellHalloweenCostume(
                key: ValueKey(revision),
                body: 'male',
                costume: 'pumpkin_court',
                equipped: equipped,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        return tester
            .widgetList<Image>(find.byType(Image))
            .map((image) => (image.image as AssetImage).assetName)
            .toList();
      }

      const base =
          'assets/images/questwell/avatar/base/paper_doll_male_v3.webp';
      final equipped = await render(true, 1);
      expect(
        equipped.where(
          (path) => path.contains('/base/') && !path.contains('identity'),
        ),
        [base],
      );
      expect(equipped.where((path) => path.endsWith('_v2.webp')), hasLength(2));
      expect(
        equipped.where(
          (path) =>
              path.endsWith('_v3.webp') && path.contains('/halloween_v1/'),
        ),
        hasLength(2),
      );
      expect(await render(false, 2), [base]);
      expect(await render(true, 3), equipped);
    },
  );

  for (final width in [320.0, 1200.0]) {
    testWidgets('costume review preserves bodies through toggles at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const HalloweenCostumesReviewApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(QuestwellHalloweenCostume), findsNWidgets(6));
      List<String> bases() => tester
          .widgetList<Image>(find.byType(Image))
          .map((image) => (image.image as AssetImage).assetName)
          .where(
            (name) => name.contains('/base/') && !name.contains('identity'),
          )
          .toList();
      final original = bases();
      expect(original.length, 6);
      for (final _ in [false, true]) {
        await tester.tap(find.widgetWithText(FilterChip, 'Complete outfit'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(bases(), original);
      }
      await tester.tap(find.widgetWithText(FilterChip, 'Dark backdrop'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(bases(), original);
      expect(find.byType(ClipPath), findsNothing);
    });
  }
}
