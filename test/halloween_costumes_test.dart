import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/preview/halloween_costumes_review.dart';
import '../lib/widgets/questwell_halloween_costume.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
            'assets/images/questwell/avatar/halloween_v1/$costume/$body/$layer.webp',
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
        'alchemist'
      ]) {
        for (final costume in QuestwellHalloweenCostume.costumes.keys) {
          await tester.pumpWidget(MaterialApp(
              home: SizedBox(
                  width: 240,
                  height: 320,
                  child: QuestwellLayeredAdventurerArt(
                      archetype: archetype,
                      avatarBodyType: body,
                      equippedSlugs: {
                        'chest': costume.replaceAll('_', '-')
                      }))));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.byType(QuestwellHalloweenCostume), findsOneWidget);
          final images = tester
              .widgetList<Image>(find.byType(Image))
              .map((image) => (image.image as AssetImage).assetName)
              .toList();
          expect(
              images.where((name) =>
                  name.contains('/halloween_v1/') &&
                  name.endsWith('/mask.webp')),
              hasLength(1));
          expect(images.where((name) => name.contains('/classes/')), isEmpty);
          expect(
              images.where((name) =>
                  name.contains('/base/') && !name.contains('identity')),
              hasLength(1));
        }
      }
    }
  });

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
