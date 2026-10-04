import 'support/male_robe_layers.dart';
import 'support/neutral_robe_layers.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/widgets/questwell_pixel_art.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final kind in ['scholar', 'scout', 'alchemist', 'guardian', 'wanderer']) {
    for (final body in ['male', 'female', 'neutral']) {
      final rearRevision = kind == 'wanderer' ? 'short_v1' : 'v1';
      final rear = 'assets/images/questwell/avatar/classes/$kind/${kind}_rear_${body}_wrap_$rearRevision.webp';
      test('$kind $body rear is continuous cloth with clear head and feet', () async {
        final bytes = await rootBundle.load(rear);
        final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
        final image = (await codec.getNextFrame()).image;
        codec.dispose();
        try {
          expect([image.width, image.height], [240, 320]);
          final pixels = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
          int alpha(int x, int y) => pixels.getUint8((y * 240 + x) * 4 + 3);
          for (var y = 180; y <= (kind == 'wanderer' ? 190 : 244); y++) {
            // A rear coat is a single fabric surface, not another pair of
            // front tails. The base legs occlude its center at render time.
            expect(alpha(120, y), greaterThanOrEqualTo(250));
            var runs = 0;
            var inside = false;
            for (var x = 0; x < 240; x++) {
              final opaque = alpha(x, y) >= 128;
              if (opaque && !inside) runs++;
              inside = opaque;
            }
            expect(runs, 1, reason: '$kind $body split rear at row $y');
          }
          for (var y = 0; y < 320; y++) {
            if (y >= 140 && y < (kind == 'wanderer' ? 195 : 268)) continue;
            for (var x = 0; x < 240; x++) {
              expect(alpha(x, y), lessThan(128), reason: 'Rear extends into head/feet');
            }
          }
        } finally { image.dispose(); }
      });

      testWidgets('$kind $body layers rear behind matching base and front', (tester) async {
        await tester.pumpWidget(MaterialApp(home: SizedBox(width:240, height:320,
          child: QuestwellLayeredAdventurerArt(archetype:kind, avatarBodyType:body, equippedSlugs:const {}))));
        final images = tester.widgetList<Image>(find.byType(Image))
            .map((image) => (image.image as AssetImage).assetName).toList();
        if (body == 'male') {
          expect(images, maleRobeLayers(kind));
          expectMaleRobeGarmentOnlyClip(tester, find.byType(QuestwellLayeredAdventurerArt));
          expect(tester.takeException(), isNull);
          return;
        }
        if (body == 'neutral') {
          expect(images, neutralRobeLayers(kind));
          expect(find.byType(ClipPath), findsNothing);
          expect(tester.takeException(), isNull);
          return;
        }
        if (const {'scout', 'alchemist', 'scholar', 'guardian', 'wanderer'}.contains(kind) && body == 'female') {
          final prefix = kind == 'scout' ? 'assets/images/questwell/avatar/scout_'
              : 'assets/images/questwell/avatar/classes/$kind/${kind}_';
          final version = switch (kind) {
            'scout' => 'v8', 'alchemist' => 'v7', 'guardian' => 'v4', _ => 'v3',
          };
          expect(images.first, '${prefix}robe_rear_female_$version.webp');
          final base=images.indexOf('assets/images/questwell/avatar/base/paper_doll_female_v1.webp');
          final front=images.indexOf('${prefix}robe_female_$version.webp');
          expect(base, greaterThan(0));
          expect(front, greaterThan(base));
          expect(images.last, '${prefix}robe_cuff_front_female_$version.webp');
          expect(images.any((p)=>p.contains('/classes/scout/')), isFalse);
          expect(tester.takeException(), isNull);
          return;
        }
        expect(images.length, 5);
        expect(images[0], rear);
        expect(images[1], 'assets/images/questwell/avatar/base/clean_${body}_v1.webp');
        expect(images[2], 'assets/images/questwell/avatar/base/base_$body.webp');
        expect(images[3], 'assets/images/questwell/avatar/base/base_$body.webp');
        expect(images[4], contains('/classes/$kind/'));
        expect(images[4], contains('_${body}_'));
        expect(images[4], isNot(contains('_rear_')));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
