import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/preview/male_class_robes_review.dart';
import '../lib/preview/male_everyday_review.dart';
import '../lib/widgets/questwell_male_paper_doll.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all twenty bundled class layers preserve every locked mask value', () async {
    Future<List<int>> alpha(String asset) async {
      final bytes = await rootBundle.load(asset);
      final codec = await ui.instantiateImageCodec(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
      final image = (await codec.getNextFrame()).image;
      try {
        expect(Size(image.width.toDouble(), image.height.toDouble()),
            const Size(240, 320));
        final pixels = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        return [for (var i = 3; i < pixels.lengthInBytes; i += 4) pixels.getUint8(i)];
      } finally {
        image.dispose();
        codec.dispose();
      }
    }

    for (final part in ['rear', 'front', 'collar', 'cuffs']) {
      final locked = await alpha(QuestwellMalePaperDoll.robeAsset('scout', part));
      for (final name in QuestwellMalePaperDoll.classLabels.keys) {
        expect(await alpha(QuestwellMalePaperDoll.robeAsset(name, part)),
            orderedEquals(locked), reason: '$name/$part must retain the exact fit');
      }
    }
  });

  for (final width in [320.0, 390.0, 1363.0]) {
    testWidgets('male class and clothing changes retain the body at $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaleEverydayReviewApp(initialRobe: true));
      await tester.pumpAndSettle();
      final bodyFinder = find.image(const AssetImage(QuestwellMalePaperDoll.baseAsset));
      final bounds = tester.getRect(bodyFinder.first);
      List<String> layers() => tester.widgetList<Image>(find.descendant(
          of: find.byType(QuestwellMalePaperDoll).first, matching: find.byType(Image)))
          .map((image) => (image.image as AssetImage).assetName).toList();

      for (final entry in QuestwellMalePaperDoll.classLabels.entries) {
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text(entry.value).last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(layers(), [
          QuestwellMalePaperDoll.robeAsset(entry.key, 'rear'),
          QuestwellMalePaperDoll.baseAsset,
          QuestwellMalePaperDoll.everydayAsset,
          QuestwellMalePaperDoll.robeAsset(entry.key, 'front'),
          QuestwellMalePaperDoll.identityAsset,
          QuestwellMalePaperDoll.robeAsset(entry.key, 'collar'),
          QuestwellMalePaperDoll.robeAsset(entry.key, 'cuffs'),
        ]);
        expect(tester.getRect(bodyFinder.first), bounds);
        await tester.tap(find.widgetWithText(ChoiceChip, 'Body only'));
        await tester.pumpAndSettle();
        expect(layers(), [QuestwellMalePaperDoll.baseAsset]);
        expect(tester.getRect(bodyFinder.first), bounds);
        await tester.tap(find.widgetWithText(ChoiceChip, 'Outfit'));
        await tester.pumpAndSettle();
        expect(layers(), [QuestwellMalePaperDoll.baseAsset,
          QuestwellMalePaperDoll.everydayAsset, QuestwellMalePaperDoll.identityAsset]);
        await tester.tap(find.widgetWithText(ChoiceChip, 'Robe'));
        await tester.pumpAndSettle();
        expect(layers().first, QuestwellMalePaperDoll.robeAsset(entry.key, 'rear'));
        expect(tester.getRect(bodyFinder.first), bounds);
      }
      // A fresh route restores its requested class, using the same foundation.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(const MaleEverydayReviewApp(
        initialRobe: true, initialArchetype: 'guardian'));
      await tester.pumpAndSettle();
      expect(layers().first, QuestwellMalePaperDoll.robeAsset('guardian', 'rear'));
      expect(find.image(const AssetImage(QuestwellMalePaperDoll.baseAsset)), findsNWidgets(2));
    });

    testWidgets('male lineup wraps without overflow at $width', (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaleClassRobesReviewApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(QuestwellMalePaperDoll), findsNWidgets(5));
      expect(find.image(const AssetImage(QuestwellMalePaperDoll.baseAsset)), findsNWidgets(5));
      for (final label in QuestwellMalePaperDoll.classLabels.values) {
        expect(find.text(label), findsOneWidget);
      }
    });
  }
}
