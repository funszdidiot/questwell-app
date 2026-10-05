import 'dart:ui' as ui;
import 'dart:typed_data';
import '../lib/preview/clean_base_review.dart';
import '../lib/preview/neutral_paper_doll_review.dart';
import '../lib/preview/neutral_scout_review.dart';
import '../lib/preview/neutral_robes_review.dart';
import '../lib/widgets/questwell_neutral_scout.dart';
import '../lib/widgets/questwell_neutral_paper_doll.dart';
import '../lib/widgets/questwell_brass_lantern.dart';
import '../lib/widgets/questwell_annotated_grimoire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/questwell_clean_base.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_male_paper_doll.dart';
import '../lib/widgets/questwell_legacy_chest.dart';
import '../lib/widgets/questwell_scout_wardrobe.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Neutral paper doll preserves original identity and clothing covers its legs', () async {
    Future<ByteData> pixels(String path) async {
      final bytes = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List(
          bytes.offsetInBytes, bytes.lengthInBytes));
      final image = (await codec.getNextFrame()).image;
      codec.dispose();
      try {
        expect([image.width, image.height], [240, 320]);
        return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      } finally {
        image.dispose();
      }
    }
    final body = await pixels(QuestwellNeutralPaperDoll.baseAsset);
    final identity = await pixels(QuestwellNeutralPaperDoll.identityAsset);
    final original = await pixels('assets/images/questwell/avatar/base/paper_doll_neutral_v3.webp');
    final outfit = await pixels(QuestwellNeutralScout.outfitAsset);
    final previousOutfit = await pixels('assets/images/questwell/avatar/woodland_scout_unified_neutral_v2.webp');
    final trousers = await pixels(QuestwellNeutralScout.trousersAsset);
    final boots = await pixels(QuestwellNeutralScout.bootsAsset);
    for (var y = 0; y < 320; y++) {
      for (var x = 0; x < 240; x++) {
        final offset = (y * 240 + x) * 4;
        if (y < 62 || y >= 84 || (x >= 116 && x < 131 && y < 69)) {
          // V4 repairs only the jaw/lower-hair/upper-neck join. The centered
          // upper identity and complete body below the join remain fixed.
          final expected = original.getUint32(offset);
          expect(body.getUint32(offset), expected,
              reason: 'Preserve the centered foundation outside its join at $x,$y');
          if (y < 69) expect(identity.getUint32(offset), expected);
        }
        if (y >= 205 && body.getUint8(offset+3) > 180) {
          expect(outfit.getUint8(offset+3), greaterThanOrEqualTo(128),
              reason: 'Clothing must cover the fixed leg/foot at $x,$y');
          expect(trousers.getUint8(offset+3) >= 128 || boots.getUint8(offset+3) >= 128, isTrue,
              reason: 'Everyday trousers and boots must cover the fixed leg/foot at $x,$y');
        }
        final handRepair = (x == 159 && y >= 187 && y <= 195) ||
            (x == 160 && y >= 194 && y <= 196);
        final heelRepair = (x == 111 && y >= 298 && y <= 300) ||
            (x == 147 && y >= 300 && y <= 301);
        if (!handRepair && !heelRepair) {
          expect(outfit.getUint32(offset), previousOutfit.getUint32(offset),
              reason: 'V3 must differ from v2 only inside audited repair pixels at $x,$y');
        }
        if (y < 282) expect(boots.getUint8(offset+3), 0);
        if (y >= 288) expect(trousers.getUint8(offset+3), 0);
      }
    }
    for (final point in const [
      (159,187),(159,188),(159,189),(159,190),(159,191),(159,192),
      (159,193),(159,194),(160,194),(159,195),(160,195),(160,196),
    ]) {
      final offset = (point.$2 * 240 + point.$1) * 4;
      expect(outfit.getUint8(offset + 3), 0,
          reason: 'Neutral Woodland garment must not overlap the preserved right hand at $point');
    }
    for (final point in const [(111,298),(111,299),(111,300),(147,300),(147,301)]) {
      final offset = (point.$2 * 240 + point.$1) * 4;
      expect(outfit.getUint8(offset + 3), 255,
          reason: 'Neutral Woodland boot heel must fully contain the locked foot at $point');
    }
  });
  testWidgets('Neutral clothing subsets keep one fixed body and correct cloth depth', (tester) async {
    Rect? bounds;
    const options = ['top', 'trousers', 'boots', 'robe', 'outfit'];
    for (var bits = 0; bits < 32; bits++) {
      final layers = <String>{
        for (var i = 0; i < options.length; i++) if ((bits & (1 << i)) != 0) options[i],
      };
      await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(
        width: 240, height: 320, child: QuestwellNeutralScout(layers: layers)))));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final body = find.byType(QuestwellNeutralPaperDoll);
      expect(body, findsOneWidget);
      bounds ??= tester.getRect(body);
      expect(tester.getRect(body), bounds);
      expect(find.byType(ClipPath), findsNothing);
      final images = tester.widgetList<Image>(find.byType(Image))
        .map((image) => (image.image as AssetImage).assetName).toList();
      expect(images, [
        if(layers.contains('robe')) QuestwellNeutralScout.rearAsset,
        QuestwellNeutralPaperDoll.baseAsset,
        if(layers.contains('outfit') && !layers.contains('robe')) QuestwellNeutralScout.outfitAsset
        else ...[
          if(layers.contains('boots')) QuestwellNeutralScout.bootsAsset,
          if(layers.contains('trousers')) QuestwellNeutralScout.trousersAsset,
          if(layers.contains('top')) QuestwellNeutralScout.topAsset,
        ],
        if(layers.contains('robe')) QuestwellNeutralScout.robeAsset,
        QuestwellNeutralPaperDoll.identityAsset,
        if(layers.contains('robe')) QuestwellNeutralScout.collarAsset,
        if(layers.contains('robe')) QuestwellNeutralScout.cuffsAsset,
      ]);
    }
  });
  for (final width in [320.0, 390.0, 1200.0]) {
    testWidgets('Neutral foundation review fits a ${width.toInt()}px screen', (tester) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const NeutralPaperDollReviewApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(QuestwellNeutralPaperDoll), findsNWidgets(3));
      expect(find.byType(QuestwellCleanBase), findsNothing);
      await tester.pumpWidget(const NeutralScoutReviewApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(QuestwellNeutralPaperDoll), findsNWidgets(4));
      expect(find.text('Everyday clothes'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilterChip, 'Fit details'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(QuestwellNeutralPaperDoll), findsNWidgets(12));
      await tester.pumpWidget(const NeutralRobesReviewApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(QuestwellNeutralPaperDoll), findsNWidgets(5));
      expect(find.byType(QuestwellCleanBase), findsNothing);
      expect(find.byType(ClipPath), findsNothing);
    });
  }
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
      if (body == 'female') {
        expect(find.byType(QuestwellCleanBase), findsNothing);
        final defaultImages = tester.widgetList<Image>(find.byType(Image))
          .map((i) => (i.image as AssetImage).assetName).toList();
        expect(defaultImages, containsAll([
          'assets/images/questwell/avatar/base/paper_doll_female_v1.webp',
          'assets/images/questwell/avatar/base/paper_doll_female_identity_v1.webp',
          'assets/images/questwell/avatar/scout_top_female_v6.webp',
          'assets/images/questwell/avatar/scout_trousers_female_v6.webp',
          'assets/images/questwell/avatar/scout_boots_female_v6.webp',
          'assets/images/questwell/avatar/classes/wanderer/wanderer_robe_female_v3.webp',
        ]));
      } else if (body == 'neutral') {
        expect(find.byType(QuestwellCleanBase), findsNothing);
        expect(find.byType(QuestwellNeutralPaperDoll), findsOneWidget);
        expect(find.byType(ClipPath), findsNothing);
      } else {
        expect(find.byType(QuestwellCleanBase), findsNothing);
        final defaultImages = tester.widgetList<Image>(find.byType(Image))
          .map((i) => (i.image as AssetImage).assetName).toList();
        expect(defaultImages, containsAll([
          QuestwellMalePaperDoll.baseAsset,
          QuestwellMalePaperDoll.everydayAsset,
          QuestwellMalePaperDoll.identityAsset,
        ]));
      }
      await render({'chest':'starter-business-suit'});
      expect(find.byType(QuestwellCleanBase), findsNothing);
      expect(find.byType(QuestwellLegacyChestFoundation), findsOneWidget);
      var images = tester.widgetList<Image>(find.byType(Image))
        .map((i) => (i.image as AssetImage).assetName).toList();
      final lockedBase = body == 'male'
          ? QuestwellMalePaperDoll.baseAsset
          : body == 'neutral'
              ? QuestwellNeutralPaperDoll.baseAsset
              : QuestwellScoutWardrobeFoundation.femaleBaseAsset;
      final lockedIdentity = body == 'male'
          ? QuestwellMalePaperDoll.identityAsset
          : body == 'neutral'
              ? QuestwellNeutralPaperDoll.identityAsset
              : QuestwellScoutWardrobeFoundation.femaleIdentityAsset;
      expect(images, containsAll([
        lockedBase,
        lockedIdentity,
        'assets/images/questwell/avatar/business_suit_${body}_v1.webp',
      ]));
      await render({'chest':'midnight-harvest-coat'});
      expect(find.byType(QuestwellCleanBase), findsNothing);
      expect(find.byType(QuestwellLegacyChestFoundation), findsOneWidget);
      images = tester.widgetList<Image>(find.byType(Image))
        .map((i) => (i.image as AssetImage).assetName).toList();
      expect(images, containsAll([
        lockedBase,
        lockedIdentity,
        'assets/images/questwell/avatar/harvest_coat_${body}_v4.webp',
      ]));
      if (body == 'male') {
        expect(images, contains(QuestwellMalePaperDoll.everydayAsset));
      } else {
        expect(images, contains(QuestwellScoutWardrobeFoundation.asset(body, 'top')));
        expect(images, contains(QuestwellScoutWardrobeFoundation.asset(body, 'trousers')));
        expect(images, contains(QuestwellScoutWardrobeFoundation.asset(body, 'boots')));
      }
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
            expect(find.byType(QuestwellCleanBase), findsNothing);
            expect(find.byType(QuestwellLegacyChestFoundation), findsWidgets);
            final lockedBase = body == 'male'
                ? QuestwellMalePaperDoll.baseAsset
                : body == 'neutral'
                    ? QuestwellNeutralPaperDoll.baseAsset
                    : QuestwellScoutWardrobeFoundation.femaleBaseAsset;
            final lockedIdentity = body == 'male'
                ? QuestwellMalePaperDoll.identityAsset
                : body == 'neutral'
                    ? QuestwellNeutralPaperDoll.identityAsset
                    : QuestwellScoutWardrobeFoundation.femaleIdentityAsset;
            expect(images, contains(lockedBase));
            expect(images, contains(lockedIdentity));
            if (chest == 'starter-business-suit') {
              expect(images, contains('assets/images/questwell/avatar/business_suit_${body}_v1.webp'));
              expect(images, isNot(contains('assets/images/questwell/avatar/base/base_${body}.webp')),
                  reason: 'Suit art must contain no old anatomy');
            } else if (body == 'male') {
              expect(images, contains(QuestwellMalePaperDoll.everydayAsset));
            } else {
              expect(images, contains(QuestwellScoutWardrobeFoundation.asset(body, 'top')));
              expect(images, contains(QuestwellScoutWardrobeFoundation.asset(body, 'trousers')));
              expect(images, contains(QuestwellScoutWardrobeFoundation.asset(body, 'boots')));
            }
            final primaryBody = find.byWidgetPredicate((widget) => widget is Image &&
                widget.image is AssetImage &&
                (widget.image as AssetImage).assetName == lockedBase).first;
            expect(find.ancestor(of: primaryBody, matching: find.byType(ClipPath)), findsNothing,
                reason: 'The primary locked body cannot be clipped to fit clothing');
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
