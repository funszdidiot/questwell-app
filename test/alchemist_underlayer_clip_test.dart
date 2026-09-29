import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/widgets/questwell_pixel_art.dart';
import 'package:project_momentum/widgets/alchemist_underlayer_clip.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final body in ['male', 'female', 'neutral']) {
    test('$body Alchemist panels cover the outside trouser edges', () async {
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
        'assets/images/questwell/avatar/classes/alchemist/alchemist_coat_${body}_lab_v4.webp',
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
      } finally {
        base.dispose();
        coat.dispose();
      }
    });

    test('$body Alchemist retains anatomy and hides the original jacket', () {
      final path = AlchemistUnderlayerClipper(body).getClip(const Size(240, 320));
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
        const Offset(166, 130), // Suit sleeve outside Alchemist sleeve.
      ]) {
        expect(path.contains(point), isFalse, reason: '$body: $point');
      }
    });
  }

  test('Alchemist preserves the female hairline and lower curls', () {
    final path = const AlchemistUnderlayerClipper('female')
        .getClip(const Size(240, 320));
    for (final point in [
      const Offset(104.5, 79.5),
      const Offset(138.5, 82.5),
      const Offset(79.5, 115.5),
    ]) {
      expect(path.contains(point), isTrue, reason: 'Hair at $point');
    }
  });

  test('Alchemist clip follows bottom-centered contain in wide and tall boxes', () {
    const clipper = AlchemistUnderlayerClipper('male');
    final wide = clipper.getClip(const Size(480, 320));
    expect(wide.contains(const Offset(240, 110)), isTrue);
    expect(wide.contains(const Offset(206, 149)), isFalse);
    final tall = clipper.getClip(const Size(240, 640));
    expect(tall.contains(const Offset(120, 430)), isTrue);
    expect(tall.contains(const Offset(86, 469)), isFalse);
    expect(tall.contains(const Offset(120, 40)), isFalse);
  });

  testWidgets('Alchemist body switching uses matching art and clip in both sizes', (tester) async {
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
                      archetype: 'alchemist', avatarBodyType: body,
                      equippedSlugs: const {}, height: 286,
                      artHeightFactor: .96,
                    ),
                    SizedBox(
                      width: (width - 44) / 2 - 20, height: 176,
                      child: QuestwellLayeredAdventurerArt(
                        archetype: 'alchemist', avatarBodyType: body,
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
          expect(images, [
            'assets/images/questwell/avatar/classes/alchemist/alchemist_rear_${body}_wrap_v1.webp',
            'assets/images/questwell/avatar/base/base_$body.webp',
            'assets/images/questwell/avatar/classes/alchemist/alchemist_coat_${body}_lab_v4.webp',
          ]);
          final clip = tester.widget<ClipPath>(
            find.descendant(of: layer, matching: find.byType(ClipPath)),
          ).clipper;
          expect(clip, isA<AlchemistUnderlayerClipper>());
          expect((clip! as AlchemistUnderlayerClipper).bodyType, body);
        }
      }
    }
  });
}
