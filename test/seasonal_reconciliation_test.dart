import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/preview/seasonal_wearable_preview.dart';
import '../lib/widgets/questwell_scout_wardrobe.dart';
import '../lib/widgets/questwell_male_paper_doll.dart';
import '../lib/widgets/questwell_neutral_paper_doll.dart';
import '../lib/widgets/questwell_male_woodland.dart';
import '../lib/widgets/questwell_neutral_scout.dart';
import '../lib/widgets/questwell_woodland_scout.dart';
import '../lib/widgets/questwell_room_picker.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/services/questwell_cosmetic_models.dart';

void main() {
  for (final body in ['female', 'neutral', 'male']) {
    testWidgets(
      'seasonal $body outfit uses locked body and foreground identity',
      (tester) async {
        final overlay = switch (body) {
          'female' => QuestwellWoodlandScoutFoundation.outfitAsset,
          'male' => QuestwellMaleWoodland.outfitAsset,
          _ => QuestwellNeutralScout.outfitAsset,
        };
        final base = switch (body) {
          'female' => QuestwellScoutWardrobeFoundation.femaleBaseAsset,
          'male' => QuestwellMalePaperDoll.baseAsset,
          _ => QuestwellNeutralPaperDoll.baseAsset,
        };
        await tester.pumpWidget(
          MaterialApp(
            home: SizedBox(
              width: 240,
              height: 320,
              child: QuestwellSeasonalWearablePreview(
                body: body,
                overlay: overlay,
              ),
            ),
          ),
        );
        final images = tester
            .widgetList<Image>(find.byType(Image))
            .map((i) => (i.image as AssetImage).assetName)
            .toList();
        expect(images.first, base);
        expect(images, contains(overlay));
        expect(
          images.last,
          body == 'male'
              ? base
              : body == 'female'
              ? QuestwellScoutWardrobeFoundation.femaleIdentityAsset
              : QuestwellNeutralPaperDoll.identityAsset,
        );
        expect(images.any((p) => p.endsWith('/base_$body.webp')), isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  }
  for (final slot in ['wall_left', 'wall_center']) {
    testWidgets('registry $slot art keeps wall key in placement preview', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                child: const Text('Open'),
                onPressed: () => showRoomPicker(
                  context,
                  name: 'New art',
                  id: 'new-art',
                  slug: 'new-art',
                  archetype: 'scout',
                  bodyType: 'female',
                  equippedSlugs: const {},
                  occupants: const {},
                  placementChoices: {slot: 'Wall'},
                  hearthProfileKey: slot == 'wall_center'
                      ? 'wall_art_center'
                      : 'wall_art_side',
                  hearthRenderSpec: const QuestwellHearthRenderSpec(
                    renderKind: 'wall_art_sprite',
                    assetSource: 'bundle',
                    assetPath: 'assets/images/questwell/hearth/fern_study.webp',
                    canvasWidth: 957,
                    canvasHeight: 1644,
                    visibleBase: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final scene = tester.widget<QuestwellHearthPixelScene>(
        find.byType(QuestwellHearthPixelScene),
      );
      expect(scene.equippedSlugs, {
        slot == 'wall_center' ? 'wall_art' : 'wall_art:$slot': 'new-art',
      });
      expect(tester.takeException(), isNull);
    });
  }
}
