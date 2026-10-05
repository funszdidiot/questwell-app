import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/preview/seasonal_gallery_review.dart';
import '../lib/widgets/questwell_hearth_catalog_sprite.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_wall_art.dart';

Future<void> pumpReview(WidgetTester tester) async {
  // Hearth ambience intentionally schedules ongoing frames. Pump a bounded
  // number of frames so manifest/assets resolve without waiting for animation
  // to become idle.
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 80));
  }
}

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxFrames = 30,
}) async {
  for (var i = 0; i < maxFrames; i++) {
    await tester.pump(const Duration(milliseconds: 80));
    if (finder.evaluate().isNotEmpty) return;
  }
  expect(finder, findsWidgets);
}

void main() {
  testWidgets('seasonal gallery loads manifest and reviews Hearth candidates',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const QuestwellSeasonalGalleryReviewApp());
    await pumpReview(tester);

    expect(find.text('Seasonal Review System'), findsOneWidget);
    expect(find.text('Fixture Solstice Ward Lantern'), findsWidgets);
    expect(find.byType(QuestwellHearthPixelScene), findsWidgets);
    expect(find.byType(QuestwellHearthCatalogSprite), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Fixture Winter Fern Study').first);
    await pumpReview(tester);

    expect(find.byType(QuestwellWallArt), findsWidgets);
    expect(
      find.byKey(const ValueKey('hearth-wall_left-art-bounds')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('seasonal gallery reviews body-specific wearable assets',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const QuestwellSeasonalGalleryReviewApp());
    final scholar = find.text('Fixture Solstice Scholar Robe');
    await pumpUntilFound(tester, scholar);
    expect(tester.takeException(), isNull);

    await tester.tap(scholar.first);
    final baseline = find.textContaining('Locked body baseline');
    await pumpUntilFound(tester, baseline);

    expect(baseline, findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'assets/images/questwell/avatar/classes/scholar/scholar_robe_neutral_polish_v2.webp'),
      findsOneWidget,
    );

    final female = find.text('female');
    await pumpUntilFound(tester, female);
    await tester.tap(female.first);
    await pumpReview(tester);

    expect(
      find.byWidgetPredicate((widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'assets/images/questwell/avatar/classes/scholar/scholar_robe_female_polish_v2.webp'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
