import '../lib/widgets/questwell_male_paper_doll.dart';
import '../lib/widgets/questwell_neutral_paper_doll.dart';
import '../lib/widgets/questwell_scout_wardrobe.dart';
import '../lib/widgets/questwell_legacy_chest.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_wanderer_cuffs.dart';
import '../lib/widgets/wanderer_underlayer_clip.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('male cuff revision preserves visible artwork outside lower sleeves', () async {
    Future<ByteData> pixels(String version) async {
      final data = await rootBundle.load('assets/images/questwell/avatar/classes/wanderer/wanderer_coat_male_short_$version.webp');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
      final image = (await codec.getNextFrame()).image;
      final result = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      image.dispose();
      codec.dispose();
      return result;
    }
    final before = await pixels('v3');
    final after = await pixels('v4');
    for (var y = 0; y < 320; y++) {
      for (var x = 0; x < 240; x++) {
        if (y >= 148 && y <= 180 &&
            ((x >= 54 && x <= 89) || (x >= 151 && x <= 185))) continue;
        final at = (y * 240 + x) * 4;
        expect(after.getUint8(at + 3), before.getUint8(at + 3), reason: 'Alpha at $x,$y');
        if (before.getUint8(at + 3) > 0) {
          expect(after.getUint32(at), before.getUint32(at), reason: 'Artwork at $x,$y');
        }
      }
    }
  });
  for (final body in ['female', 'male', 'neutral']) {
    test('$body short coat leaves lower legs clear and retains sleeve ends', () async {
      final data = await rootBundle.load('assets/images/questwell/avatar/classes/wanderer/wanderer_coat_${body}_short_${body == 'female' ? 'v2' : body == 'male' ? 'v4' : 'v3'}.webp');
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
        if (body == 'male' && chest == null) {
          expect(images, contains(QuestwellMalePaperDoll.robeAsset('wanderer', 'front')));
          expect(images, contains(QuestwellMalePaperDoll.robeAsset('wanderer', 'cuffs')));
          expect(images.any((path) => path.contains('wanderer_coat_male_short_')), isFalse);
        } else if (body == 'male') {
          expect(images, contains(QuestwellMalePaperDoll.baseAsset));
          expect(find.byType(QuestwellMaleIdentity), findsWidgets);
          expect(images.any((path) => path.contains('wanderer_coat_male_short_')), isFalse);
          expect(images, isNot(contains(QuestwellMalePaperDoll.robeAsset('wanderer', 'front'))));
        } else if (body == 'female' && chest == null) {
          expect(images, contains('assets/images/questwell/avatar/classes/wanderer/wanderer_robe_female_v3.webp'));
          expect(images, contains('assets/images/questwell/avatar/classes/wanderer/wanderer_robe_cuff_front_female_v3.webp'));
          expect(images.any((path) => path.contains('wanderer_coat_female_short_')), isFalse);
        } else if (body == 'neutral' && chest == null) {
          expect(images, contains('assets/images/questwell/avatar/classes/wanderer/wanderer_robe_neutral_v1.webp'));
          expect(images, contains('assets/images/questwell/avatar/classes/wanderer/wanderer_robe_cuff_front_neutral_v1.webp'));
          expect(images.any((path) => path.contains('wanderer_coat_neutral_short_')), isFalse);
        } else {
          expect(find.byType(QuestwellLegacyChestFoundation), findsWidgets);
          expect(images, contains(body == 'female'
              ? QuestwellScoutWardrobeFoundation.femaleBaseAsset
              : QuestwellNeutralPaperDoll.baseAsset));
          expect(images.any((path) => path.contains('wanderer_coat_${body}_short_')), isFalse);
        }
        expect(images.any((path) => path.contains('wanderer_rear_${body}_wrap_v2')), isFalse);
        expect(tester.takeException(), isNull);
      }
    });
  }
}
