import 'support/male_robe_layers.dart';
import 'support/neutral_robe_layers.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/widgets/questwell_pixel_art.dart';
import 'package:project_momentum/widgets/wanderer_underlayer_clip.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final body in ['male', 'female', 'neutral']) {
    final revision = 'v2';
    test('$body Wanderer covers trousers and keeps waist trim open', () async {
      Future<ui.Image> loadImage(String asset) async {
        final bytes = await rootBundle.load(asset);
        final codec = await ui.instantiateImageCodec(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        );
        final frame = await codec.getNextFrame();
        codec.dispose();
        return frame.image;
      }

      final base = await loadImage(
        'assets/images/questwell/avatar/base/base_$body.webp',
      );
      final coat = await loadImage(
        'assets/images/questwell/avatar/classes/wanderer/wanderer_coat_${body}_$revision.webp',
      );
      try {
        expect([base.width, base.height, coat.width, coat.height],
            [240, 320, 240, 320]);
        final basePixels = (await base.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        final coatPixels = (await coat.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        final exposed = <String>[];
        // Below the hands, the outside of each trouser leg belongs behind
        // the coat. The center opening stays visible. Check the actual art,
        // independent of the underlayer clip or the export's control points.
        for (var y = 196; y <= 240; y++) {
          var left = 240, right = -1;
          for (var x = 0; x < 240; x++) {
            if (coatPixels.getUint8((y * 240 + x) * 4 + 3) >= 128) {
              if (x < left) left = x;
              right = x;
            }
          }
          expect(left, lessThan(right), reason: '$body coat row $y');
          for (var x = 0; x < 240; x++) {
            if ((x < left || x > right) &&
                basePixels.getUint8((y * 240 + x) * 4 + 3) >= 128) {
              exposed.add('($x,$y)');
            }
          }
        }
        expect(exposed, isEmpty,
            reason: '$body trousers outside coat: ${exposed.take(12).join(', ')}');

        // Guard against pinched openings and thick gold wedges. Inspect
        // the actual exported piping, independently of the fit-control data.
        bool isGold(int x, int y) {
          final offset = (y * 240 + x) * 4;
          final red = coatPixels.getUint8(offset);
          final green = coatPixels.getUint8(offset + 1);
          final blue = coatPixels.getUint8(offset + 2);
          return red > 175 && green > 110 && blue < green * .85 &&
              coatPixels.getUint8(offset + 3) > 180;
        }
        for (var y = 130; y <= 160; y++) {
          var left = -1, right = 240;
          for (var x = 100; x < 140; x++) {
            if (!isGold(x, y)) continue;
            if (x < 119) {
              left = x;
            } else if (right == 240) {
              right = x;
            }
          }
          expect(left, greaterThanOrEqualTo(100), reason: '$body left piping at $y');
          expect(right, lessThan(140), reason: '$body right piping at $y');
          expect(right - left - 1, greaterThanOrEqualTo(10),
              reason: '$body gold edges pinch the front opening at $y');
          var leftWidth = 0, rightWidth = 0;
          for (var x = left; x >= 100 && isGold(x, y); x--) { leftWidth++; }
          for (var x = right; x < 140 && isGold(x, y); x++) { rightWidth++; }
          expect(leftWidth, lessThanOrEqualTo(3), reason: '$body thick left piping at $y');
          expect(rightWidth, lessThanOrEqualTo(3), reason: '$body thick right piping at $y');
        }
        if (body == 'female') {
          // Inspect the exported sleeve and hip silhouette for abrupt steps.
          int outerEdge(int y) {
            for (var x = 179; x >= 135; x--) {
              if (coatPixels.getUint8((y * 240 + x) * 4 + 3) >= 128) return x;
            }
            throw StateError('Missing female garment at row $y');
          }
          for (final interval in [[125, 159], [171, 210]]) {
            for (var y = interval.first + 1; y <= interval.last; y++) {
              expect((outerEdge(y) - outerEdge(y - 1)).abs(), lessThanOrEqualTo(1),
                  reason: 'Female sleeve/hip makes an abrupt step at row $y');
            }
          }
        }
      } finally {
        base.dispose();
        coat.dispose();
      }
    });

    test('$body Wanderer retains anatomy and hides the original jacket', () {
      final path = WandererUnderlayerClipper(body).getClip(const Size(240, 320));
      for (final point in [
        const Offset(120, 40), // Head.
        const Offset(120, 110), // Shirt and tie.
        const Offset(120, 150), // Belt and trousers.
        const Offset(73, 183), // Left hand.
        const Offset(168, 182), // Right hand.
        const Offset(90, 300), // Left shoe.
        const Offset(166, 300), // Right shoe.
      ]) {
        expect(path.contains(point), isTrue, reason: '$body: $point');
      }
      for (final point in [
        const Offset(86, 149), // Underarm jacket.
        const Offset(151, 159), // Jacket hip flap.
        const Offset(166, 130), // Suit sleeve outside Wanderer sleeve.
      ]) {
        expect(path.contains(point), isFalse, reason: '$body: $point');
      }
    });
  }

  test('Wanderer preserves the female hairline and lower curls', () {
    final path = const WandererUnderlayerClipper('female')
        .getClip(const Size(240, 320));
    for (final point in [
      const Offset(104.5, 79.5),
      const Offset(138.5, 82.5),
      const Offset(79.5, 115.5),
    ]) {
      expect(path.contains(point), isTrue, reason: 'Hair at $point');
    }
  });

  test('Wanderer clip follows bottom-centered contain in wide and tall boxes', () {
    const clipper = WandererUnderlayerClipper('male');
    final wide = clipper.getClip(const Size(480, 320));
    expect(wide.contains(const Offset(240, 110)), isTrue);
    expect(wide.contains(const Offset(206, 149)), isFalse);
    final tall = clipper.getClip(const Size(240, 640));
    expect(tall.contains(const Offset(120, 430)), isTrue);
    expect(tall.contains(const Offset(86, 469)), isFalse);
    expect(tall.contains(const Offset(120, 40)), isFalse);
  });

  testWidgets('Wanderer body switching uses matching art and clip in both sizes', (tester) async {
    for (final width in [320.0, 390.0, 430.0]) {
      for (final body in ['male', 'female', 'neutral']) {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width - 36,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    QuestwellEquippedAvatar(
                      archetype: 'wanderer', avatarBodyType: body,
                      equippedSlugs: const {}, height: 286,
                      artHeightFactor: .96,
                    ),
                    SizedBox(
                      width: (width - 44) / 2 - 20, height: 176,
                      child: QuestwellLayeredAdventurerArt(
                        archetype: 'wanderer', avatarBodyType: body,
                        equippedSlugs: const {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
        await tester.pump();
        expect(tester.takeException(), isNull,
            reason: '$body portrait/card at $width px');
        final layers = find.byType(QuestwellLayeredAdventurerArt);
        expect(layers, findsNWidgets(2));
        final frame = tester.getRect(find.byType(QuestwellEquippedAvatar));
        final portrait = tester.getRect(layers.first);
        expect(frame.contains(portrait.topLeft), isTrue);
        expect(frame.contains(portrait.bottomRight - const Offset(.01, .01)), isTrue);
        expect(tester.getSize(layers.last).height, 176);
        for (final layer in [layers.first, layers.last]) {
          final images = tester.widgetList<Image>(
            find.descendant(of: layer, matching: find.byType(Image)),
          ).map((image) => (image.image as AssetImage).assetName).toList();
          if (body == 'male') {
            expect(images, maleRobeLayers('wanderer'));
            expectMaleRobeGarmentOnlyClip(tester, layer);
            continue;
          }
          if (body == 'neutral') {
            expect(images, neutralRobeLayers('wanderer'));
            expect(find.descendant(of: layer, matching: find.byType(ClipPath)), findsNothing);
            continue;
          }
          if (body == 'female') {
            expect(images, [
              'assets/images/questwell/avatar/classes/wanderer/wanderer_robe_rear_female_v3.webp',
              'assets/images/questwell/avatar/base/paper_doll_female_v1.webp',
              'assets/images/questwell/avatar/scout_trousers_female_v6.webp',
              'assets/images/questwell/avatar/scout_top_female_v6.webp',
              'assets/images/questwell/avatar/scout_boots_female_v6.webp',
              'assets/images/questwell/avatar/classes/wanderer/wanderer_robe_female_v3.webp',
              'assets/images/questwell/avatar/base/paper_doll_female_identity_v1.webp',
              'assets/images/questwell/avatar/classes/wanderer/wanderer_robe_cuff_front_female_v3.webp',
            ]);
            expect(find.descendant(of: layer, matching: find.byWidgetPredicate(
              (widget) => widget is ClipPath && widget.clipper is WandererUnderlayerClipper)), findsNothing);
            continue;
          }
          expect(images, [
            'assets/images/questwell/avatar/classes/wanderer/wanderer_rear_${body}_wrap_short_v1.webp',
            'assets/images/questwell/avatar/base/clean_${body}_v1.webp',
            'assets/images/questwell/avatar/base/base_$body.webp',
            'assets/images/questwell/avatar/base/base_$body.webp',
            'assets/images/questwell/avatar/classes/wanderer/wanderer_coat_${body}_short_${body == 'female' ? 'v2' : body == 'male' ? 'v4' : 'v3'}.webp',
          ]);
          final clip = tester.widget<ClipPath>(
            find.descendant(of: layer, matching: find.byWidgetPredicate(
              (widget) => widget is ClipPath && widget.clipper is WandererUnderlayerClipper)),
          ).clipper;
          expect(clip, isA<WandererUnderlayerClipper>());
          expect((clip! as WandererUnderlayerClipper).bodyType, body);
        }
      }
    }
  });
}
