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
  int attempts = 30,
}) async {
  for (var i = 0; i < attempts; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 80));
  }
  expect(finder, findsOneWidget);
}

void main() {
  testWidgets('seasonal gallery loads manifest and reviews Hearth candidates',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const QuestwellSeasonalGalleryReviewApp());
    final lantern = find.byKey(
      const ValueKey('seasonal-item-fixture-solstice-ward-lantern'),
    );
    await pumpUntilFound(tester, lantern);

    expect(find.text('Seasonal Review System'), findsOneWidget);
    expect(find.byType(QuestwellHearthPixelScene), findsWidgets);
    expect(find.byType(QuestwellHearthCatalogSprite), findsOneWidget);
    expect(tester.takeException(), isNull);

    final fern = find.byKey(
      const ValueKey('seasonal-item-fixture-winter-fern-study'),
    );
    await pumpUntilFound(tester, fern);
    await tester.tap(fern);
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

    final robe = find.byKey(
      const ValueKey('seasonal-item-fixture-solstice-scholar-robe'),
    );
    await pumpUntilFound(tester, robe);
    await tester.tap(robe);

    final baseline = find.textContaining('Locked body baseline');
    await pumpUntilFound(tester, baseline);

    expect(
      find.byWidgetPredicate((widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'assets/images/questwell/avatar/classes/scholar/scholar_robe_neutral_polish_v2.webp'),
      findsOneWidget,
    );

    final female = find.byKey(const ValueKey('seasonal-body-female'));
    await pumpUntilFound(tester, female);
    await tester.tap(female);
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
