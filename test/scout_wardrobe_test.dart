import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_clean_base.dart';
import '../lib/widgets/questwell_scout_wardrobe.dart';
import '../lib/preview/scout_wardrobe_review.dart';

void main() {
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

  Future<void> renderFemale(WidgetTester tester, Set<String> layers) =>
      tester.pumpWidget(MaterialApp(home: Center(child:
        SizedBox(width: 240, height: 320, child: QuestwellLayeredAdventurerArt(
          archetype: 'scout', avatarBodyType: 'female', equippedSlugs: const {},
          previewScoutLayers: layers)))));

  testWidgets('female body and registration stay fixed for every clothing subset', (tester) async {
    const choices = ['top', 'trousers', 'boots', 'robe'];
    const basePath = QuestwellScoutWardrobeFoundation.femaleBaseAsset;
    final baseFinder = asset(basePath);
    Rect? baseBounds;
    for (var mask = 0; mask < (1 << choices.length); mask++) {
      final layers = <String>{
        for (var i = 0; i < choices.length; i++)
          if ((mask & (1 << i)) != 0) choices[i],
      };
      await renderFemale(tester, layers);
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
      for (final part in choices) {
        expect(paths.contains(QuestwellScoutWardrobeFoundation.asset('female', part)),
            layers.contains(part), reason: '$part with clothing $layers');
      }
      for (final part in ['robe_rear', 'robe_cuff_rear', 'robe_cuff_front']) {
        expect(paths.contains(QuestwellScoutWardrobeFoundation.asset('female', part)),
            layers.contains('robe'));
      }
      expect(paths.any((path) => path.contains('clean_arms_')), isFalse);
      expect(paths, isNot(contains('assets/images/questwell/avatar/base/base_female.webp')));
    }
  });

  testWidgets('female rear cloth stays behind fixed body and front cuff stays ahead', (tester) async {
    await renderFemale(tester, {'top', 'trousers', 'boots', 'robe'});
    final ordered = assets(tester);
    int layer(String part) => ordered.indexOf(
        QuestwellScoutWardrobeFoundation.asset('female', part));
    final base = ordered.indexOf(QuestwellScoutWardrobeFoundation.femaleBaseAsset);
    final identity = ordered.indexOf(QuestwellScoutWardrobeFoundation.femaleIdentityAsset);
    expect(layer('robe_rear'), greaterThanOrEqualTo(0));
    expect(layer('robe_cuff_rear'), greaterThanOrEqualTo(0));
    expect(layer('robe_rear'), lessThan(base));
    expect(layer('robe_cuff_rear'), lessThan(base));
    expect(base, lessThan(layer('trousers')));
    expect(layer('trousers'), lessThan(layer('boots')));
    expect(layer('boots'), lessThan(layer('robe')));
    expect(layer('robe'), lessThan(identity));
    expect(identity, lessThan(layer('robe_cuff_front')));
  });

  for (final body in ['male', 'neutral']) {
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
  test('robe hides protruding sleeves but retains open front and hands', () {
    final clip = ScoutWardrobeClipper('male', 'robeUnder').getClip(const Size(240, 320));
    expect(clip.contains(const Offset(120, 120)), isTrue);
    expect(clip.contains(const Offset(70, 187)), isTrue);
    expect(clip.contains(const Offset(70, 125)), isFalse);
  });

  for (final width in [320.0, 390.0]) {
    testWidgets('three-stage fitting scrolls without overflow at $width', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const ScoutWardrobeReviewApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final stages = tester.widgetList<QuestwellLayeredAdventurerArt>(
        find.byType(QuestwellLayeredAdventurerArt)).toList();
      expect(stages, hasLength(3));
      expect(stages.first.previewScoutLayers, isEmpty);
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
      expect(find.text('Robe').hitTestable(), findsOneWidget);
    });
  }
}
