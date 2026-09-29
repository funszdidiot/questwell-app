import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/widgets/questwell_pixel_art.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final kind in ['scholar', 'scout', 'alchemist', 'guardian']) {
    for (final body in ['male', 'female', 'neutral']) {
      final rear = 'assets/images/questwell/avatar/classes/$kind/${kind}_rear_${body}_wrap_v1.webp';
      test('$kind $body rear is continuous cloth with clear head and feet', () async {
        final bytes = await rootBundle.load(rear);
        final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
        final image = (await codec.getNextFrame()).image;
        codec.dispose();
        try {
          expect([image.width, image.height], [240, 320]);
          final pixels = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
          int alpha(int x, int y) => pixels.getUint8((y * 240 + x) * 4 + 3);
          for (var y = 180; y <= 244; y++) {
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
            if (y >= 140 && y < 268) continue;
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
        expect(images.length, 3);
        expect(images[0], rear);
        expect(images[1], 'assets/images/questwell/avatar/base/base_$body.webp');
        expect(images[2], contains('/classes/$kind/'));
        expect(images[2], contains('_${body}_'));
        expect(images[2], isNot(contains('_rear_')));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
