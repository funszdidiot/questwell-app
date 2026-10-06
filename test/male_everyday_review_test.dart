import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/preview/male_everyday_review.dart';
import '../lib/widgets/questwell_male_paper_doll.dart';

void main() {
  for (final width in [320.0, 390.0, 1200.0]) {
    testWidgets('isolated male fit review preserves the body at $width px',
        (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaleEverydayReviewApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Male wardrobe fit review'), findsOneWidget);
      expect(
          find.text('Woodland v2 fit approved · Account rollout in verification'),
          findsOneWidget);
      expect(find.byType(QuestwellMalePaperDoll), findsNWidgets(2));

      List<String> assets() => tester.widgetList<Image>(find.byType(Image))
          .map((image) => (image.image as AssetImage).assetName)
          .toList();
      const dressed = [
        QuestwellMalePaperDoll.baseAsset,
        QuestwellMalePaperDoll.everydayAsset,
        QuestwellMalePaperDoll.baseAsset,
      ];
      expect(assets(), [...dressed, ...dressed]);
      final bodyImage = find.image(const AssetImage(QuestwellMalePaperDoll.baseAsset));
      final nativeBodyRect = tester.getRect(bodyImage.first);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Body only'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(assets(), [
        QuestwellMalePaperDoll.baseAsset,
        QuestwellMalePaperDoll.baseAsset,
      ]);
      expect(tester.getRect(bodyImage.first), nativeBodyRect,
          reason: 'Removing clothing must not switch or move the foundation');

      await tester.tap(find.widgetWithText(ChoiceChip, 'Outfit'));
      await tester.pumpAndSettle();
      expect(assets(), [...dressed, ...dressed]);
      expect(tester.getRect(bodyImage.first), nativeBodyRect);

      await tester.tap(find.widgetWithText(FilterChip, 'Enlarged view'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.getSize(bodyImage.first), const Size(480, 640));
      expect(assets(), [...dressed, ...dressed]);
      expect(find.text('Light background'), findsOneWidget);
      expect(find.text('Dark background'), findsOneWidget);
    });
  }
}
