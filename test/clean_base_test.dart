import 'dart:ui' as ui;
import '../lib/preview/clean_base_review.dart';
import '../lib/widgets/questwell_brass_lantern.dart';
import '../lib/widgets/questwell_annotated_grimoire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/questwell_clean_base.dart';
import '../lib/widgets/questwell_pixel_art.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final body in ['female', 'male', 'neutral']) {
    test('$body separates identity, underwear and outfit without restoring the tie', () {
      const canvas = Size(240, 320);
      final identity = CleanBaseClipper(body, 'identity').getClip(canvas);
      final dressed = CleanBaseClipper(body, 'dressedIdentity').getClip(canvas);
      final trousers = CleanBaseClipper(body, 'trousers').getClip(canvas);
      final anatomy = CleanBaseClipper(body, 'anatomy').getClip(canvas);
      final underClothes = CleanBaseClipper(body, 'dressedAnatomy').getClip(canvas);
      for (final point in [const Offset(120,45), const Offset(73,183), const Offset(166,183)]) {
        expect(identity.contains(point), isTrue);
        expect(dressed.contains(point), isTrue);
      }
      for (final point in [const Offset(120,110), const Offset(86,149)]) {
        expect(identity.contains(point), isFalse, reason: 'No suit or tie in identity');
        expect(dressed.contains(point), isFalse);
        expect(trousers.contains(point), isFalse);
      }
      expect(anatomy.contains(const Offset(120,110)), isTrue);
      expect(anatomy.contains(const Offset(120,45)), isFalse, reason: 'Preserve the original face');
      expect(anatomy.contains(const Offset(73,183)), isFalse, reason: 'One pair of hands');
      expect(trousers.contains(const Offset(100,250)), isTrue);
      expect(underClothes.contains(const Offset(100,250)), isFalse, reason: 'No bare legs or toes under boots');
    });
    test('$body clean source is registered on the wardrobe canvas', () async {
      final bytes = await rootBundle.load('assets/images/questwell/avatar/base/clean_${body}_v1.webp');
      final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
      final image = (await codec.getNextFrame()).image;
      expect([image.width,image.height], [240,320]);
      final rgba = (await image.toByteData())!;
      expect(rgba.getUint8(3), 0);
      expect(rgba.getUint8((110*240+120)*4+3), greaterThan(250));
      image.dispose(); codec.dispose();
    });
    testWidgets('$body preserves default clothes and makes the business suit explicit', (tester) async {
      Future<void> render(Map<String,String> equipment) async {
        await tester.pumpWidget(MaterialApp(home: SizedBox(width:240,height:320,
          child: QuestwellLayeredAdventurerArt(archetype:'wanderer', avatarBodyType:body,
            equippedSlugs:equipment))));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await render({});
      expect(find.byType(QuestwellCleanBase), findsOneWidget);
      expect(tester.widget<QuestwellCleanBase>(find.byType(QuestwellCleanBase)).withTrousers, isTrue);
      await render({'chest':'starter-business-suit'});
      expect(find.byType(QuestwellCleanBase), findsNothing);
      final images = tester.widgetList<Image>(find.byType(Image))
        .map((i) => (i.image as AssetImage).assetName).toList();
      expect(images, ['assets/images/questwell/avatar/base/base_$body.webp']);
      await render({'chest':'midnight-harvest-coat'});
      expect(find.byType(QuestwellCleanBase), findsOneWidget);
    });
  }
  for (final archetype in ['scholar','scout','alchemist','guardian','wanderer']) {
    for (final body in ['female','male','neutral']) {
      testWidgets('$archetype/$body restores its wardrobe after each outfit and accessory swap', (tester) async {
        Future<List<String>> render(Map<String,String> equipment) async {
          await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(width:240,height:320,
            child: QuestwellLayeredAdventurerArt(archetype:archetype, avatarBodyType:body,
              equippedSlugs:equipment)))));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          return tester.widgetList<Image>(find.byType(Image))
            .map((i) => (i.image as AssetImage).assetName).toList();
        }
        final baseline = await render({});
        for (final chest in ['midnight-harvest-coat','starter-business-suit','moss-green-cloak','hearthguard-mantle']) {
          for (final held in ['brass-lantern','annotated-grimoire']) {
            final equipment = <String,String>{
              'chest':chest, 'hands':held, 'head':'tiny-wizard-hat',
              'face':'round-scholar-glasses', 'neck':'emerald-scholar-scarf',
              'back':held == 'brass-lantern' ? 'leather-satchel' : 'wayfarer-satchel',
              'feet':'pathfinder-boots', 'accessory':'moonstone-brooch',
            };
            final original = Map<String,String>.of(equipment);
            final images = await render(equipment);
            expect(equipment, original, reason:'Rendering cannot mutate saved equipment');
            final closed = chest == 'moss-green-cloak' || chest == 'hearthguard-mantle';
            expect(find.byType(QuestwellBrassLantern),
              !closed && held == 'brass-lantern' ? findsOneWidget : findsNothing);
            expect(find.byType(QuestwellAnnotatedGrimoire),
              !closed && held == 'annotated-grimoire' ? findsOneWidget : findsNothing);
            if (chest == 'starter-business-suit') {
              expect(find.byType(QuestwellCleanBase), findsNothing);
              expect(images.any((a) => a.contains('/classes/')), isFalse);
            } else {
              expect(find.byType(QuestwellCleanBase), findsWidgets);
              expect(images, contains('assets/images/questwell/avatar/base/clean_${body}_v1.webp'));
            }
            expect(await render({}), baseline, reason:'Unequipping restores this class and body exactly');
          }
        }
      });
    }
  }
  for (final width in [320.0,390.0]) {
    testWidgets('Wardrobe comparison fits a ${width.toInt()}px phone', (tester) async {
      tester.view.physicalSize = Size(width,844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const CleanBaseReviewApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

}
