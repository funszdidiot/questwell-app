import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_wanderer_cuffs.dart';
import '../lib/widgets/wanderer_underlayer_clip.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final body in ['female', 'male', 'neutral']) {
    test('$body short coat leaves lower legs clear and retains sleeve ends', () async {
      final data = await rootBundle.load('assets/images/questwell/avatar/classes/wanderer/wanderer_coat_${body}_short_v2.webp');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
      final image = (await codec.getNextFrame()).image;
      codec.dispose();
      expect([image.width, image.height], [240, 320]);
      final pixels = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      int alpha(int x, int y) => pixels.getUint8((y * 240 + x) * 4 + 3);
      for (var y = 224; y < 320; y++) {
        for (var x = 0; x < 240; x++) {
          expect(alpha(x, y), 0, reason: 'Long coat tail at $x,$y');
        }
      }
      final cuffY = body == 'female' ? 164 : 169;
      expect(alpha(75, cuffY), greaterThan(128));
      expect(alpha(164, cuffY), greaterThan(128));
      final underlayer = WandererUnderlayerClipper(body).getClip(const Size(240, 320));
      expect(underlayer.contains(const Offset(100, 225)), isTrue);
      expect(underlayer.contains(const Offset(150, 225)), isTrue);
      image.dispose();
    });
    testWidgets('$body uses painted cuffs through satchel and outfit changes', (tester) async {
      for (final chest in [null, 'moss-green-cloak', 'hearthguard-mantle', 'starter-business-suit']) {
        await tester.pumpWidget(MaterialApp(home: SizedBox(width: 240, height: 320,
          child: QuestwellLayeredAdventurerArt(archetype: 'wanderer', avatarBodyType: body,
            equippedSlugs: {'back': 'wayfarer-satchel', if (chest != null) 'chest': chest}))));
        await tester.pumpAndSettle();
        expect(find.byType(QuestwellWandererCuffs), findsNothing);
        final images = tester.widgetList<Image>(find.byType(Image))
            .map((image) => (image.image as AssetImage).assetName).toList();
        expect(images.any((path) => path.contains('wanderer_coat_${body}_short_v2')), chest != 'starter-business-suit');
        expect(images.any((path) => path.contains('wanderer_rear_${body}_wrap_v2')), isFalse);
        expect(tester.takeException(), isNull);
      }
    });
  }
}
