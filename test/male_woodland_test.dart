import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/preview/male_everyday_review.dart';
import '../lib/widgets/questwell_annotated_grimoire.dart';
import '../lib/widgets/questwell_male_paper_doll.dart';
import '../lib/widgets/questwell_male_woodland.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import 'support/male_robe_layers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final size in [const Size(240, 320), const Size(480, 640)]) {
    testWidgets('shared Woodland pixels match the approved review at $size', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final capture = GlobalKey();
      Future<List<int>> pixels(Widget art, Color background) async {
        await tester.pumpWidget(MaterialApp(home: Center(child: RepaintBoundary(
          key: capture, child: SizedBox.fromSize(size: size,
            child: ColoredBox(color: background, child: art)),
        ))));
        await tester.pumpAndSettle();
        return (await tester.runAsync(() async {
          final boundary = capture.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          try {
            final data = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
            return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes).toList();
          } finally {
            image.dispose();
          }
        }))!;
      }
      for (final background in [Colors.white, const Color(0xff17202a)]) {
        for (final grimoire in [false, true]) {
          final approved = await pixels(Stack(fit: StackFit.expand, children: [
            const QuestwellMaleWoodland(),
            if (grimoire) const QuestwellAnnotatedGrimoire(bodyType: 'male'),
          ]), background);
          final shared = await pixels(QuestwellLayeredAdventurerArt(
            archetype: 'scout', avatarBodyType: 'male', equippedSlugs: {
              'chest': 'woodland-scout-outfit',
              if (grimoire) 'hands': 'annotated-grimoire',
            },
          ), background);
          expect(shared.length, approved.length);
          expect([for (var i = 0; i < shared.length; i++)
            if (shared[i] != approved[i]) i].length, 0,
            reason: 'Shared rendering must preserve approved pixels, including the belt book');
          expect(tester.takeException(), isNull);
        }
      }
    });
  }

  testWidgets('male Woodland equip, body review, class change and reload retain v3', (tester) async {
    Future<void> render({String archetype = 'scout', String? chest,
        Set<String>? reviewLayers}) async {
      await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(
        width: 240, height: 320, child: QuestwellLayeredAdventurerArt(
          archetype: archetype, avatarBodyType: 'male',
          equippedSlugs: {if (chest != null) 'chest': chest},
          previewWoodlandLayers: reviewLayers,
        ),
      ))));
      await tester.pumpAndSettle();
      final body = find.image(const AssetImage(QuestwellMalePaperDoll.baseAsset)).first;
      expect(tester.getSize(body), const Size(240, 320));
      expect(find.ancestor(of: body, matching: find.byType(ClipPath)), findsNothing);
      expect(tester.takeException(), isNull);
    }
    List<String> paths() => tester.widgetList<Image>(find.byType(Image))
        .map((image) => (image.image as AssetImage).assetName).toList();
    const woodland = [QuestwellMalePaperDoll.baseAsset,
      QuestwellMaleWoodland.outfitAsset, QuestwellMalePaperDoll.baseAsset];
    await render();
    expect(paths(), maleRobeLayers('scout'));
    await render(chest: 'woodland-scout-outfit');
    expect(paths(), woodland);
    await tester.pumpWidget(const SizedBox());
    await render(chest: 'woodland-scout-outfit');
    expect(paths(), woodland);
    await render(reviewLayers: {});
    expect(paths(), [QuestwellMalePaperDoll.baseAsset, QuestwellMalePaperDoll.baseAsset]);
    await render(reviewLayers: {'outfit'});
    expect(paths(), woodland);
    await render(chest: 'everyday-adventurer-outfit');
    expect(paths(), [QuestwellMalePaperDoll.baseAsset,
      QuestwellMalePaperDoll.everydayAsset, QuestwellMalePaperDoll.baseAsset]);
    // The server removes Scout-only equipment when the class changes.
    for (final archetype in QuestwellMalePaperDoll.classLabels.keys) {
      await render(archetype: archetype);
      expect(paths(), maleRobeLayers(archetype));
    }
  });

  test('Woodland covers the locked shorts, legs and feet and clears both hands', () async {
    Future<List<int>> alpha(String asset) async {
      final bytes = await rootBundle.load(asset);
      final codec = await ui.instantiateImageCodec(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
      final image = (await codec.getNextFrame()).image;
      try {
        expect(Size(image.width.toDouble(), image.height.toDouble()), const Size(240, 320));
        final pixels = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        return [for (var i = 3; i < pixels.lengthInBytes; i += 4) pixels.getUint8(i)];
      } finally {
        image.dispose();
        codec.dispose();
      }
    }

    final body = await alpha(QuestwellMalePaperDoll.baseAsset);
    final outfit = await alpha(QuestwellMaleWoodland.outfitAsset);
    var covered = 0;
    var hands = 0;
    // Actual first-pass defects: shorts outside both seams, a high translucent
    // crotch, exposed inner calf/heel, and a buckle touching the left hand.
    for (var y = 170; y < 314; y++) {
      for (var x = 50; x < 200; x++) {
        final i = y * 240 + x;
        if (body[i] < 250) continue;
        if (y >= 198 || (x >= 86 && x <= 156)) {
          covered++;
          expect(outfit[i], greaterThanOrEqualTo(250), reason: 'Coverage at $x,$y');
        }
        if (y < 198 && (x <= 83 || (x >= 158 && x <= 190))) {
          hands++;
          expect(outfit[i], lessThanOrEqualTo(2), reason: 'Hand clearance at $x,$y');
        }
      }
    }
    expect(covered, greaterThan(4300));
    expect(hands, greaterThan(400));
  });

  for (final width in [320.0, 390.0, 1363.0]) {
    testWidgets('Woodland transitions and route restoration preserve the body at $width', (tester) async {
      tester.view.physicalSize = Size(width, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaleEverydayReviewApp(initialWoodland: true));
      await tester.pumpAndSettle();
      final body = find.image(const AssetImage(QuestwellMalePaperDoll.baseAsset));
      final bounds = tester.getRect(body.first);
      List<String> assets() => tester.widgetList<Image>(find.byType(Image))
          .map((image) => (image.image as AssetImage).assetName).toList();
      const woodland = [QuestwellMalePaperDoll.baseAsset,
        QuestwellMaleWoodland.outfitAsset, QuestwellMalePaperDoll.baseAsset];
      expect(assets(), [...woodland, ...woodland]);
      for (final stage in ['Body only', 'Outfit', 'Robe', 'Woodland']) {
        await tester.tap(find.widgetWithText(ChoiceChip, stage));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(body, findsNWidgets(stage == 'Body only' ? 2 : 4));
        expect(tester.getRect(body.first), bounds);
      }
      expect(assets(), [...woodland, ...woodland]);
      await tester.tap(find.widgetWithText(FilterChip, 'Belt grimoire'));
      await tester.pumpAndSettle();
      expect(assets(), [
        ...woodland, QuestwellAnnotatedGrimoire.asset,
        ...woodland, QuestwellAnnotatedGrimoire.asset,
      ]);
      expect(tester.getRect(body.first), bounds);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Body only'));
      await tester.pumpAndSettle();
      expect(find.image(const AssetImage(QuestwellAnnotatedGrimoire.asset)), findsNothing);
      expect(tester.getRect(body.first), bounds);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Woodland'));
      await tester.pumpAndSettle();
      expect(find.image(const AssetImage(QuestwellAnnotatedGrimoire.asset)), findsNWidgets(2));
      await tester.tap(find.widgetWithText(FilterChip, 'Belt grimoire'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Enlarged view'));
      await tester.pumpAndSettle();
      expect(tester.getSize(body.first), const Size(480, 640));
      expect(assets(), [...woodland, ...woodland]);
      expect(tester.takeException(), isNull);
      // Local inspection controls do not become account equipment/persistence.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(const MaleEverydayReviewApp(initialWoodland: true));
      await tester.pumpAndSettle();
      expect(assets(), [...woodland, ...woodland]);
      expect(tester.getRect(body.first), bounds);
    });
  }
}
