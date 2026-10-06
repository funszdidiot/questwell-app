import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/services/questwell_cosmetic_models.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_wall_art.dart';

void main() {
  testWidgets('unknown seasonal side wall art renders from registry metadata',
      (tester) async {
    const spec = QuestwellHearthRenderSpec(
      renderKind: 'wall_art_sprite',
      assetSource: 'bundle',
      assetPath: 'assets/images/questwell/hearth/fern_study.webp',
      canvasWidth: 957,
      canvasHeight: 1644,
      visibleBase: 1,
      shadowProfile: 'none',
      filterMode: 'smooth',
    );

    await tester.pumpWidget(const MaterialApp(
      home: SizedBox(
        width: 390,
        child: QuestwellHearthPixelScene(
          height: 360,
          showAvatar: false,
          equippedSlugs: {
            'wall_art:wall_left': 'winter-fern-print',
          },
          hearthProfileBySlug: {
            'winter-fern-print': 'wall_art_side',
          },
          hearthRenderBySlug: {
            'winter-fern-print': spec,
          },
        ),
      ),
    ));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('hearth-wall_left-art-bounds')),
      findsOneWidget,
    );
    final art = tester.widget<QuestwellWallArt>(find.byType(QuestwellWallArt));
    expect(art.artSlug, 'winter-fern-print');
    expect(art.renderSpec?.renderKind, 'wall_art_sprite');
    expect(
      find.byWidgetPredicate((widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == spec.assetPath),
      findsWidgets,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('unknown seasonal center wall art renders from registry metadata',
      (tester) async {
    const spec = QuestwellHearthRenderSpec(
      renderKind: 'wall_art_sprite',
      assetSource: 'bundle',
      assetPath: 'assets/images/questwell/hearth/moonlit_woodland.webp',
      canvasWidth: 1400,
      canvasHeight: 1000,
      visibleBase: 1,
      shadowProfile: 'none',
      filterMode: 'smooth',
    );

    await tester.pumpWidget(const MaterialApp(
      home: SizedBox(
        width: 390,
        child: QuestwellHearthPixelScene(
          height: 360,
          showAvatar: false,
          equippedSlugs: {
            'wall_art': 'winter-centerpiece',
          },
          hearthProfileBySlug: {
            'winter-centerpiece': 'wall_art_center',
          },
          hearthRenderBySlug: {
            'winter-centerpiece': spec,
          },
        ),
      ),
    ));
    await tester.pump();

    expect(find.byKey(const ValueKey('hearth-wall-art-bounds')), findsOneWidget);
    final art = tester.widget<QuestwellWallArt>(find.byType(QuestwellWallArt));
    expect(art.artSlug, 'winter-centerpiece');
    expect(art.renderSpec?.assetPath, spec.assetPath);
    expect(tester.takeException(), isNull);
  });
}
