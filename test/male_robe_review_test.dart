import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/preview/male_everyday_review.dart';
import '../lib/widgets/questwell_male_paper_doll.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled male robe retains foreground and the requested rear repair', () async {
    const sources = {
      QuestwellMalePaperDoll.robeRearAsset: 'rear',
      QuestwellMalePaperDoll.robeFrontAsset: 'front',
      QuestwellMalePaperDoll.robeCollarAsset: 'collar',
      QuestwellMalePaperDoll.robeCuffsAsset: 'cuffs',
    };
    for (final entry in sources.entries) {
      final bundled = await rootBundle.load(entry.key);
      expect(
        bundled.buffer.asUint8List(bundled.offsetInBytes, bundled.lengthInBytes),
        orderedEquals(await File(entry.value == 'rear'
          ? 'tool/art_assets/male_robe_thumb_repair_v1/scout/rear.webp'
          : 'tool/art_assets/male_robe_v3/scout_robe_${entry.value}_male_v3.webp',
        ).readAsBytes()),
      );
    }
  });

  for (final width in [320.0, 390.0, 1200.0]) {
    testWidgets('robe review retains foundation across clothing changes at $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaleEverydayReviewApp(initialRobe: true));
      await tester.pumpAndSettle();

      List<String> layers() => tester
          .widgetList<Image>(find.descendant(
            of: find.byType(QuestwellMalePaperDoll).first,
            matching: find.byType(Image),
          ))
          .map((image) => (image.image as AssetImage).assetName)
          .toList();
      const body = QuestwellMalePaperDoll.baseAsset;
      const outfit = QuestwellMalePaperDoll.everydayAsset;
      const identity = QuestwellMalePaperDoll.identityAsset;
      const robe = [
        QuestwellMalePaperDoll.robeRearAsset,
        body,
        outfit,
        QuestwellMalePaperDoll.robeFrontAsset,
        identity,
        QuestwellMalePaperDoll.robeCollarAsset,
        QuestwellMalePaperDoll.robeCuffsAsset,
      ];
      final bodyImage = find.image(const AssetImage(body));
      final bodyBounds = tester.getRect(bodyImage.first);
      expect(layers(), robe);
      for (final state in ['Body only', 'Outfit', 'Robe']) {
        await tester.tap(find.widgetWithText(ChoiceChip, state));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(tester.getRect(bodyImage.first), bodyBounds);
        expect(layers(), state == 'Robe'
            ? robe : state == 'Outfit' ? [body, outfit, identity] : [body]);
      }
      await tester.tap(find.widgetWithText(FilterChip, 'Enlarged view'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.getSize(bodyImage.first), const Size(480, 640));
      expect(layers(), robe);
      for (final type in [ClipPath, ClipRect, Transform, ColorFiltered]) {
        expect(find.descendant(
          of: find.byType(QuestwellMalePaperDoll), matching: find.byType(type),
        ), findsNothing);
      }
    });
  }
}
