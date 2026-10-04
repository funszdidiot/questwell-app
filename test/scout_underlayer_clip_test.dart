import 'support/male_robe_layers.dart';
import 'support/neutral_robe_layers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/widgets/questwell_pixel_art.dart';
import 'package:project_momentum/widgets/scout_underlayer_clip.dart';

void main() {
  for (final body in ['male', 'female', 'neutral']) {
    test('$body Scout retains anatomy and hides the original jacket', () {
      final path = ScoutUnderlayerClipper(body).getClip(const Size(240, 320));
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
        const Offset(166, 130), // Suit sleeve outside Scout sleeve.
      ]) {
        expect(path.contains(point), isFalse, reason: '$body: $point');
      }
    });
  }

  test('Scout preserves the female hairline and lower curls', () {
    final path = const ScoutUnderlayerClipper('female')
        .getClip(const Size(240, 320));
    for (final point in [
      const Offset(104.5, 79.5),
      const Offset(138.5, 82.5),
      const Offset(79.5, 115.5),
    ]) {
      expect(path.contains(point), isTrue, reason: 'Hair at $point');
    }
  });

  test('Scout clip follows bottom-centered contain in wide and tall boxes', () {
    const clipper = ScoutUnderlayerClipper('male');
    final wide = clipper.getClip(const Size(480, 320));
    expect(wide.contains(const Offset(240, 110)), isTrue);
    expect(wide.contains(const Offset(206, 149)), isFalse);
    final tall = clipper.getClip(const Size(240, 640));
    expect(tall.contains(const Offset(120, 430)), isTrue);
    expect(tall.contains(const Offset(86, 469)), isFalse);
    expect(tall.contains(const Offset(120, 40)), isFalse);
  });

  testWidgets('Scout body switching uses matching art and clip in both sizes', (tester) async {
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
                      archetype: 'scout', avatarBodyType: body,
                      equippedSlugs: const {}, height: 286,
                      artHeightFactor: .96,
                    ),
                    SizedBox(
                      width: (width - 44) / 2 - 20, height: 176,
                      child: QuestwellLayeredAdventurerArt(
                        archetype: 'scout', avatarBodyType: body,
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
            expect(images, maleRobeLayers('scout'));
            expectMaleRobeGarmentOnlyClip(tester, layer);
            continue;
          }
          if (body == 'neutral') {
            expect(images, neutralRobeLayers('scout'));
            expect(find.descendant(of: layer, matching: find.byType(ClipPath)), findsNothing);
            continue;
          }
          if (body == 'female') {
            expect(images.first,'assets/images/questwell/avatar/scout_robe_rear_female_v8.webp');
            expect(images,contains('assets/images/questwell/avatar/base/paper_doll_female_v1.webp'));
            expect(images.last,'assets/images/questwell/avatar/scout_robe_cuff_front_female_v8.webp');
            expect(find.descendant(of:layer,matching:find.byWidgetPredicate(
              (widget)=>widget is ClipPath && widget.clipper is ScoutUnderlayerClipper)),findsNothing);
            continue;
          }
          expect(images, [
            'assets/images/questwell/avatar/classes/scout/scout_rear_${body}_wrap_v1.webp',
            'assets/images/questwell/avatar/base/clean_${body}_v1.webp',
            'assets/images/questwell/avatar/base/base_$body.webp',
            'assets/images/questwell/avatar/base/base_$body.webp',
            'assets/images/questwell/avatar/classes/scout/scout_coat_${body}_polish_v1.webp',
          ]);
          final clip = tester.widget<ClipPath>(
            find.descendant(of: layer, matching: find.byWidgetPredicate(
              (widget) => widget is ClipPath && widget.clipper is ScoutUnderlayerClipper)),
          ).clipper;
          expect(clip, isA<ScoutUnderlayerClipper>());
          expect((clip! as ScoutUnderlayerClipper).bodyType, body);
        }
      }
    }
  });
}
