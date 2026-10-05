import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/services/questwell_cosmetic_models.dart';
import '../lib/widgets/questwell_hearth_catalog_sprite.dart';
import '../lib/widgets/questwell_pixel_art.dart';

void main() {
  testWidgets('unknown seasonal decor renders from backend registry without slug code',
      (tester) async {
    const furniture = QuestwellHearthRenderSpec(
      renderKind: 'static_sprite',
      assetSource: 'bundle',
      assetPath: 'assets/images/questwell/hearth/walnut_bookshelf_front_v1.webp',
      canvasWidth: 1225,
      canvasHeight: 1284,
      visibleBase: 1200 / 1284,
      shadowProfile: 'wide_plinth',
      filterMode: 'pixel',
    );
    const rug = QuestwellHearthRenderSpec(
      renderKind: 'floor_sprite',
      assetSource: 'bundle',
      assetPath: 'assets/images/questwell/hearth/emerald_wayfarer_rug_v3_64bit.webp',
      canvasWidth: 384,
      canvasHeight: 256,
      visibleBase: 1,
      shadowProfile: 'none',
      filterMode: 'pixel',
    );

    await tester.pumpWidget(const MaterialApp(
      home: Center(
        child: SizedBox(
          width: 390,
          child: QuestwellHearthPixelScene(
            height: 360,
            showAvatar: false,
            equippedSlugs: {
              'room:left': 'winter-library-cabinet',
              'room:floor': 'winter-wayfarer-rug',
            },
            hearthProfileBySlug: {
              'winter-library-cabinet': 'large_furniture',
              'winter-wayfarer-rug': 'floor_rug',
            },
            hearthRenderBySlug: {
              'winter-library-cabinet': furniture,
              'winter-wayfarer-rug': rug,
            },
          ),
        ),
      ),
    ));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('hearth-winter-library-cabinet-bounds')),
      findsOneWidget,
    );
    expect(find.byType(QuestwellHearthCatalogSprite), findsOneWidget);
    expect(find.byType(QuestwellHearthFloorSprite), findsOneWidget);

    final furnitureImage = tester.widget<Image>(find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == furniture.assetPath,
    ));
    expect(furnitureImage.filterQuality, FilterQuality.none);

    final rugImage = tester.widget<Image>(find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == rug.assetPath,
    ));
    expect(rugImage.filterQuality, FilterQuality.none);
    expect(tester.takeException(), isNull);
  });
}
