import '../lib/widgets/questwell_scholar_glasses.dart';
import '../lib/widgets/questwell_wizard_hat.dart';
import 'support/neutral_robe_layers.dart';
import '../lib/widgets/questwell_neutral_paper_doll.dart';
import '../lib/widgets/questwell_neutral_scout.dart';
import '../lib/widgets/questwell_male_paper_doll.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_clean_base.dart';
import '../lib/widgets/questwell_scout_wardrobe.dart';
import '../lib/preview/scout_wardrobe_review.dart';
import '../lib/widgets/questwell_woodland_scout.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Female class front, cuffs and rear exactly reuse the locked Alchemist geometry', () async {
    Future<List<int>> alpha(String asset) async {
      final data = await rootBundle.load(asset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
      final image = (await codec.getNextFrame()).image;
      codec.dispose();
      try {
        expect([image.width, image.height], [240, 320]);
        final pixels = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        return [for (var index = 3; index < pixels.lengthInBytes; index += 4) pixels.getUint8(index)];
      } finally {
        image.dispose();
      }
    }
    for (final part in ['robe', 'robe_cuff_front', 'robe_rear']) {
      final locked = await alpha('assets/images/questwell/avatar/classes/alchemist/alchemist_${part}_female_v7.webp');
      expect(await alpha(QuestwellScoutWardrobeFoundation.asset('female', part)),
          locked,
          reason: '$part must preserve the approved outline pixel for pixel');
      expect(await alpha('assets/images/questwell/avatar/classes/scholar/scholar_${part}_female_v3.webp'),
          locked, reason: 'Scholar $part must preserve the same locked outline');
      expect(await alpha('assets/images/questwell/avatar/classes/guardian/guardian_${part}_female_v4.webp'),
          locked, reason: 'Guardian $part must preserve the same locked outline');
      expect(await alpha('assets/images/questwell/avatar/classes/wanderer/wanderer_${part}_female_v3.webp'),
          locked, reason: 'Wanderer $part must preserve the same locked outline');
    }
  });

  test('Every neutral class preserves all four approved robe alpha masks', () async {
    Future<List<int>> alpha(String path) async {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(
          data.offsetInBytes, data.lengthInBytes));
      final image = (await codec.getNextFrame()).image;
      codec.dispose();
      try {
        expect([image.width, image.height], [240, 320]);
        final pixels = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        return [for (var at = 3; at < pixels.lengthInBytes; at += 4) pixels.getUint8(at)];
      } finally {
        image.dispose();
      }
    }
    for (final part in ['robe', 'robe_rear', 'robe_collar', 'robe_cuff_front']) {
      final reference = await alpha(QuestwellScoutWardrobeFoundation.asset('neutral', part));
      for (final archetype in ['scholar', 'alchemist', 'guardian', 'wanderer']) {
        expect(await alpha(QuestwellScoutWardrobeFoundation.asset('neutral', part,
            archetype: archetype)), reference,
            reason: '$archetype/$part cannot alter the approved silhouette or depth');
      }
    }
  });

  List<String> assets(WidgetTester tester) => tester
      .widgetList<Image>(find.byType(Image))
      .map((image) => image.image)
      .whereType<AssetImage>()
      .map((image) => image.assetName)
      .toList();

  Finder asset(String name) => find.byWidgetPredicate((widget) =>
      widget is Image &&
      widget.image is AssetImage &&
      (widget.image as AssetImage).assetName == name);

  Future<void> renderFemale(WidgetTester tester, Set<String> layers, {String archetype = 'scout'}) =>
      tester.pumpWidget(MaterialApp(home: Center(child:
        SizedBox(width: 240, height: 320, child: QuestwellLayeredAdventurerArt(
          archetype: archetype, avatarBodyType: 'female', equippedSlugs: const {},
          previewScoutLayers: layers)))));

  for (final archetype in ['scout', 'alchemist', 'scholar', 'guardian', 'wanderer']) {
  testWidgets('$archetype female body and registration stay fixed for every clothing subset', (tester) async {
    const choices = ['top', 'trousers', 'boots', 'robe'];
    const basePath = QuestwellScoutWardrobeFoundation.femaleBaseAsset;
    final baseFinder = asset(basePath);
    Rect? baseBounds;
    for (var mask = 0; mask < (1 << choices.length); mask++) {
      final layers = <String>{
        for (var i = 0; i < choices.length; i++)
          if ((mask & (1 << i)) != 0) choices[i],
      };
      await renderFemale(tester, layers, archetype: archetype);
      expect(baseFinder, findsOneWidget, reason: 'Clothing: $layers');
      final base = tester.widget<Image>(baseFinder);
      expect(base.fit, BoxFit.contain);
      expect(base.alignment, Alignment.bottomCenter);
      baseBounds ??= tester.getRect(baseFinder);
      expect(tester.getRect(baseFinder), baseBounds);
      expect(tester.getSize(baseFinder), const Size(240, 320));
      expect(find.byType(QuestwellCleanBase), findsNothing);
      expect(tester.widgetList<ClipPath>(find.byType(ClipPath))
          .where((clip) => clip.clipper is ScoutWardrobeClipper), isEmpty);
      final paths = assets(tester);
      String layerAsset(String part) {
        if (const {'alchemist', 'scholar', 'guardian', 'wanderer'}.contains(archetype) && part.startsWith('robe')) {
          final version = switch (archetype) {
            'alchemist' => 'v7', 'guardian' => 'v4', _ => 'v3',
          };
          return 'assets/images/questwell/avatar/classes/$archetype/${archetype}_${part}_female_$version.webp';
        }
        return QuestwellScoutWardrobeFoundation.asset('female', part);
      }
      for (final part in choices) {
        expect(paths.contains(layerAsset(part)),
            layers.contains(part), reason: '$part with clothing $layers');
      }
      for (final part in ['robe_rear', 'robe_cuff_front']) {
        expect(paths.contains(layerAsset(part)),
            layers.contains('robe'));
      }
      expect(paths.any((path) => path.contains('clean_arms_')), isFalse);
      expect(paths, isNot(contains('assets/images/questwell/avatar/base/base_female.webp')));
    }
  });

  }

  testWidgets('female rear cloth stays behind fixed body and front cuff stays ahead', (tester) async {
    await renderFemale(tester, {'top', 'trousers', 'boots', 'robe'});
    final ordered = assets(tester);
    int layer(String part) => ordered.indexOf(
        QuestwellScoutWardrobeFoundation.asset('female', part));
    final base = ordered.indexOf(QuestwellScoutWardrobeFoundation.femaleBaseAsset);
    final identity = ordered.indexOf(QuestwellScoutWardrobeFoundation.femaleIdentityAsset);
    expect(layer('robe_rear'), greaterThanOrEqualTo(0));
    expect(layer('robe_rear'), lessThan(base));
    expect(base, lessThan(layer('trousers')));
    expect(layer('trousers'), lessThan(layer('boots')));
    expect(layer('boots'), lessThan(layer('robe')));
    expect(layer('robe'), lessThan(identity));
    expect(identity, lessThan(layer('robe_cuff_front')));
  });

  testWidgets('unified Woodland outfit keeps the fixed body and full canvas alignment', (tester) async {
    final baseFinder = asset(QuestwellScoutWardrobeFoundation.femaleBaseAsset);
    Rect? bounds;
    for (final layers in [<String>{}, {'outfit'}]) {
      await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(
        width: 240, height: 320, child: QuestwellLayeredAdventurerArt(
          archetype: 'scout', avatarBodyType: 'female', equippedSlugs: const {},
          previewWoodlandLayers: layers)))));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(baseFinder, findsOneWidget);
      bounds ??= tester.getRect(baseFinder);
      expect(tester.getRect(baseFinder), bounds);
      expect(find.byType(QuestwellCleanBase), findsNothing);
      final outfit = asset(QuestwellWoodlandScoutFoundation.outfitAsset);
      expect(outfit, layers.isEmpty ? findsNothing : findsOneWidget);
      if (layers.isNotEmpty) {
        expect(tester.getRect(outfit), bounds);
        final image = tester.widget<Image>(outfit);
        expect(image.fit, BoxFit.contain);
        expect(image.alignment, Alignment.bottomCenter);
      }
      expect(tester.widgetList<ClipPath>(find.byType(ClipPath))
        .where((clip) => clip.clipper is ScoutWardrobeClipper), isEmpty);
    }
    await tester.pumpWidget(const MaterialApp(home: SizedBox(width: 240, height: 320,
      child: QuestwellLayeredAdventurerArt(archetype: 'scout', avatarBodyType: 'female', equippedSlugs: {}))));
    await tester.pumpAndSettle();
    expect(asset(QuestwellWoodlandScoutFoundation.outfitAsset), findsNothing);
    expect(find.byType(QuestwellWoodlandScoutFoundation), findsNothing);
  });

  testWidgets('app outfits equip complete female layers and return to the new Scout robe', (tester) async {
    Future<void> render(String? chest, {String body='female', bool boots=false}) async {
      await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(width:240,height:320,
        child:QuestwellLayeredAdventurerArt(archetype:'scout',avatarBodyType:body,
          equippedSlugs:{if(chest!=null)'chest':chest,if(boots)'feet':'pathfinder-boots'})))));
      await tester.pumpAndSettle();
      expect(tester.takeException(),isNull);
    }
    await render(null);
    final baseline=assets(tester);
    expect(baseline,contains(QuestwellScoutWardrobeFoundation.asset('female','robe')));
    for(final slug in ['woodland-scout-outfit','everyday-adventurer-outfit']) {
      await render(slug);
      expect(asset(QuestwellScoutWardrobeFoundation.femaleBaseAsset),findsOneWidget);
      expect(assets(tester).any((p)=>p.contains('robe_')),isFalse);
      if(slug=='woodland-scout-outfit') {
        expect(asset(QuestwellWoodlandScoutFoundation.outfitAsset), findsOneWidget);
      }else{
        expect(assets(tester),contains(QuestwellScoutWardrobeFoundation.asset('female','top')));
      }
      await render(slug,boots:true);
      if (slug == 'everyday-adventurer-outfit') {
        expect(assets(tester), contains(QuestwellScoutWardrobeFoundation.asset('female', 'boots')));
      }
      // Retired footwear never changes the approved outfit.
      if (slug == 'woodland-scout-outfit') {
        expect(asset(QuestwellWoodlandScoutFoundation.outfitAsset), findsOneWidget);
      }
      await render(null);
      expect(assets(tester),baseline);
      for(final body in ['male','neutral']) {
        await render(slug,body:body);
        expect(asset(QuestwellScoutWardrobeFoundation.femaleBaseAsset),findsNothing);
        expect(asset(QuestwellWoodlandScoutFoundation.outfitAsset),findsNothing);
      }
    }
  });

  testWidgets('neutral Woodland remains review-only on its locked body', (tester) async {
    Future<void> render({bool equipped = false, Set<String>? reviewLayers}) async {
      await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(
        width: 240, height: 320,
        child: QuestwellLayeredAdventurerArt(
          archetype: 'scout', avatarBodyType: 'neutral',
          equippedSlugs: {if (equipped) 'chest': 'woodland-scout-outfit'},
          previewWoodlandLayers: reviewLayers,
        ),
      ))));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await render();
    final classLayers = assets(tester);
    expect(classLayers, neutralRobeLayers('scout'));
    await render(equipped: true);
    expect(assets(tester), classLayers,
        reason: 'An unapproved candidate cannot become account equipment');
    {
      await render(reviewLayers: {'outfit'});
      final paths = assets(tester);
      expect(paths.toSet(), {
        QuestwellNeutralPaperDoll.baseAsset,
        QuestwellNeutralScout.outfitAsset,
        QuestwellNeutralPaperDoll.identityAsset,
      });
      expect(paths.indexOf(QuestwellNeutralPaperDoll.baseAsset),
          lessThan(paths.indexOf(QuestwellNeutralScout.outfitAsset)));
      expect(paths.indexOf(QuestwellNeutralScout.outfitAsset),
          lessThan(paths.lastIndexOf(QuestwellNeutralPaperDoll.identityAsset)));
      expect(find.byType(QuestwellCleanBase), findsNothing);
      expect(find.byType(ClipPath), findsNothing);
      expect(tester.getRect(asset(QuestwellNeutralScout.outfitAsset)),
          tester.getRect(asset(QuestwellNeutralPaperDoll.baseAsset)));
      await render();
      expect(assets(tester), classLayers,
          reason: 'Leaving candidate review returns to the locked class stack');
    }
  });

  for (final archetype in ['scout', 'scholar', 'alchemist', 'guardian', 'wanderer']) {
    testWidgets('$archetype unsupported male Everyday cannot switch the production body', (tester) async {
      Future<void> render({bool everyday = false}) async {
        await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(
          width: 240, height: 320,
          child: QuestwellLayeredAdventurerArt(
            archetype: archetype, avatarBodyType: 'male',
            equippedSlugs: {if (everyday) 'chest': 'everyday-adventurer-outfit'},
          ),
        ))));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await render();
      final classLayers = assets(tester);
      await render(everyday: true);
      expect(assets(tester), classLayers,
          reason: 'An unsupported equipment entry cannot migrate body anatomy');
      expect(find.byType(QuestwellMalePaperDoll), findsNothing,
          reason: 'The locked male foundation remains in its dedicated review');
      await render();
      expect(assets(tester), classLayers,
          reason: 'Equip and unequip retain the same production foundation');
    });
  }

  for (final body in ['male']) {
    testWidgets('$body modular clothing never restores suit trousers', (tester) async {
      Future<void> render(Set<String> layers) => tester.pumpWidget(MaterialApp(home:
        SizedBox(width: 240, height: 320, child: QuestwellLayeredAdventurerArt(
          archetype: 'scout', avatarBodyType: body, equippedSlugs: const {},
          previewScoutLayers: layers))));
      await render({'top', 'trousers', 'robe'});
      expect(tester.widgetList<QuestwellCleanBase>(find.byType(QuestwellCleanBase))
        .every((base) => !base.withTrousers), isTrue);
      List<String> assets() => tester.widgetList<Image>(find.byType(Image))
        .map((im) => im.image).whereType<AssetImage>().map((im) => im.assetName).toList();
      expect(assets(), contains(QuestwellScoutWardrobeFoundation.asset(body, 'trousers')));
      final ordered = assets();
      final rear = ordered.indexOf(QuestwellScoutWardrobeFoundation.asset(body, 'robe_rear'));
      final anatomy = ordered.indexOf('assets/images/questwell/avatar/base/clean_${body}_v1.webp');
      final front = ordered.indexOf(QuestwellScoutWardrobeFoundation.asset(body, 'robe'));
      final rim = ordered.indexOf(QuestwellScoutWardrobeFoundation.asset(body, 'robe_cuff_front'));
      expect(rear, lessThan(anatomy));
      expect(anatomy, lessThan(front));
      expect(front, lessThan(rim));
      await render({'top', 'trousers'});
      expect(assets(), isNot(contains(QuestwellScoutWardrobeFoundation.asset(body, 'robe'))));
      expect(assets(), isNot(contains(QuestwellScoutWardrobeFoundation.asset(body, 'robe_rear'))));
      expect(assets(), isNot(contains(QuestwellScoutWardrobeFoundation.asset(body, 'robe_cuff_front'))));
      expect(assets(), contains(QuestwellScoutWardrobeFoundation.asset(body, 'top')));
      await render({});
      expect(assets().any((path) => path.contains('/scout_')), isFalse);
      expect(find.byType(QuestwellCleanBase), findsWidgets);
    });
  }
  for (final archetype in ['scout', 'scholar', 'alchemist', 'guardian', 'wanderer']) {
    testWidgets('$archetype neutral uses locked body and authored cloth depth in every subset', (tester) async {
      const choices = ['top', 'trousers', 'boots', 'robe'];
      final baseFinder = asset(QuestwellNeutralPaperDoll.baseAsset);
      Rect? bounds;
      for (var mask = 0; mask < 16; mask++) {
        final selection = <String>{
          for (var index = 0; index < choices.length; index++)
            if ((mask & (1 << index)) != 0) choices[index],
        };
        await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(
          width: 240, height: 320,
          child: QuestwellLayeredAdventurerArt(archetype: archetype,
            avatarBodyType: 'neutral', equippedSlugs: const {},
            previewScoutLayers: selection)))));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(baseFinder, findsOneWidget);
        bounds ??= tester.getRect(baseFinder);
        expect(tester.getRect(baseFinder), bounds);
        expect(tester.getSize(baseFinder), const Size(240, 320));
        expect(find.byType(ClipPath), findsNothing,
            reason: 'Fitted garments never clip or reconstruct the approved body');
        expect(find.byType(QuestwellCleanBase), findsNothing);
        final expected = neutralRobeLayers(archetype).where((path) {
          if (path.contains('_robe_')) return selection.contains('robe');
          for (final part in ['top', 'trousers', 'boots']) {
            if (path.contains('everyday_${part}_')) return selection.contains(part);
          }
          return true;
        }).toList();
        expect(assets(tester), expected);
      }
      await tester.pumpWidget(MaterialApp(home: SizedBox(width: 240, height: 320,
        child: QuestwellLayeredAdventurerArt(archetype: archetype,
          avatarBodyType: 'neutral', equippedSlugs: const {}))));
      await tester.pumpAndSettle();
      expect(assets(tester), neutralRobeLayers(archetype),
          reason: 'The default class robe uses exactly the reviewed stack');
      await tester.pumpWidget(MaterialApp(home: SizedBox(width: 240, height: 320,
        child: QuestwellLayeredAdventurerArt(archetype: archetype,
          avatarBodyType: 'neutral',
          equippedSlugs: const {'chest': 'everyday-adventurer-outfit'}))));
      await tester.pumpAndSettle();
      expect(assets(tester), neutralRobeLayers(archetype)
          .where((path) => !path.contains('_robe_')).toList());
    });
  }

  testWidgets('Head accessories follow the approved neutral head at native and double size', (tester) async {
    for (final body in ['neutral', 'female', 'male']) {
      for (final scale in [1.0, 2.0]) {
        for (final legacySuit in [false, true]) {
          await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(
            width: 240 * scale, height: 320 * scale,
            child: QuestwellLayeredAdventurerArt(archetype: 'scout',
              avatarBodyType: body, equippedSlugs: {
                'head': 'tiny-wizard-hat', 'face': 'round-scholar-glasses',
                if (legacySuit) 'chest': 'starter-business-suit',
              })))));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final shift = body == 'neutral' && !legacySuit ? 4.0 : 0.0;
          expect(tester.widget<QuestwellScholarGlasses>(find.byType(QuestwellScholarGlasses)).headOffset,
              Offset(shift, 0));
          expect(tester.widget<QuestwellWizardHat>(find.byType(QuestwellWizardHat)).headOffset,
              Offset(shift, 0));
          final frame = tester.getRect(find.byType(QuestwellLayeredAdventurerArt));
          final actualScale = (frame.width / 240).clamp(0.0, frame.height / 320);
          final left = body == 'male' ? 77.0 : body == 'female' ? 72.0 : 75.0;
          final hat = tester.getRect(asset(QuestwellWizardHat.asset));
          expect(hat.left,
              closeTo(frame.left + (frame.width - 240 * actualScale) / 2 + (left + shift) * actualScale, .001));
        }
      }
    }
  });

  test('robe hides protruding sleeves but retains open front and hands', () {
    final clip = ScoutWardrobeClipper('male', 'robeUnder').getClip(const Size(240, 320));
    expect(clip.contains(const Offset(120, 120)), isTrue);
    expect(clip.contains(const Offset(70, 187)), isTrue);
    expect(clip.contains(const Offset(70, 125)), isFalse);
  });

  for (final width in [320.0, 390.0]) {
    for (final mode in ['scout', 'woodland', 'alchemist', 'scholar', 'guardian', 'wanderer']) {
    final woodland = mode == 'woodland';
    testWidgets('three-stage fitting scrolls without overflow at $width (mode: $mode)', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ScoutWardrobeReviewApp(woodland: woodland, archetype: woodland ? 'scout' : mode));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final stages = tester.widgetList<QuestwellLayeredAdventurerArt>(
        find.byType(QuestwellLayeredAdventurerArt)).toList();
      expect(stages, hasLength(3));
      expect(woodland ? stages.first.previewWoodlandLayers : stages.first.previewScoutLayers, isEmpty);
      expect(stages.first.equippedSlugs, isEmpty);
      final row = find.byWidgetPredicate((widget) =>
        widget is SingleChildScrollView && widget.scrollDirection == Axis.horizontal);
      expect(row, findsOneWidget);
      // The controls wrap above the portraits on a phone. Scroll the outer
      // page down before sending a horizontal gesture to the comparison row.
      await tester.ensureVisible(row);
      await tester.pumpAndSettle();
      await tester.drag(row, const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text(woodland ? 'Woodland Scout' : 'Robe').last.hitTestable(), findsOneWidget);
    });
    }
  }
}
