import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/widgets/questwell_male_paper_doll.dart';
import '../lib/widgets/questwell_pixel_art.dart';

void main() {
  test('robe hides thumb-adjacent trousers at native and fitted canvas sizes', () {
    for (final size in [const Size(240, 320), const Size(480, 640), const Size(360, 320)]) {
      final scale = size.height / 320;
      final dx = (size.width - 240 * scale) / 2;
      final clip = const MaleRobeUnderlayClipper().getClip(size);
      Offset point(double x, double y) => Offset(dx + x * scale, y * scale);
      expect(clip.contains(point(156, 190)), isFalse,
          reason: 'Brown trouser pixels must not cover the robe lining');
      expect(clip.contains(point(83, 184)), isFalse);
      for (final p in [point(120, 155), point(120, 210), point(75, 170), point(80, 295)]) {
        expect(clip.contains(p), isTrue,
            reason: 'Central trousers, shirt, cuffs and boots remain unchanged');
      }
    }
  });

  for (final archetype in QuestwellMalePaperDoll.classLabels.keys) {
    testWidgets('$archetype only clips the hidden garment while wearing a robe', (tester) async {
      for (final everyday in [false, true, false]) {
        await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(
          width: 240, height: 320,
          child: QuestwellLayeredAdventurerArt(archetype: archetype,
            avatarBodyType: 'male', equippedSlugs: {
              if (everyday) 'chest': 'everyday-adventurer-outfit',
            }),
        ))));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final body = find.image(const AssetImage(QuestwellMalePaperDoll.baseAsset));
        expect(body, findsOneWidget);
        expect(find.ancestor(of: body, matching: find.byType(ClipPath)), findsNothing);
        final garment = tester.widget<QuestwellMaleEverydayGarment>(
            find.byType(QuestwellMaleEverydayGarment));
        expect(garment.underRobe, !everyday);
        final clips = tester.widgetList<ClipPath>(find.byType(ClipPath));
        expect(clips.length, everyday ? 0 : 1);
        for (final clip in clips) {
          expect(clip.clipper, isA<MaleRobeUnderlayClipper>());
          expect((clip.child! as Image).image,
              const AssetImage(QuestwellMalePaperDoll.everydayAsset));
        }
      }
    });
  }
}
