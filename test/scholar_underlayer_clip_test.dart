import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/widgets/scholar_underlayer_clip.dart';
import 'package:project_momentum/widgets/questwell_pixel_art.dart';

void main() {
  test('female hairline and curl tip remain visible', () {
    final path = const ScholarUnderlayerClipper('female')
        .getClip(const Size(240, 320));
    for (final point in [
      const Offset(104.5, 79.5),
      const Offset(138.5, 82.5),
      const Offset(79.5, 115.5),
    ]) {
      expect(path.contains(point), isTrue, reason: 'Hair at $point');
    }
  });

  testWidgets('Scholar portraits and cards fit small mobile widths', (tester) async {
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
                      archetype: 'scholar', avatarBodyType: body,
                      equippedSlugs: const {}, height: 286,
                      artHeightFactor: .96,
                    ),
                    SizedBox(
                      width: (width - 44) / 2 - 20, height: 176,
                      child: QuestwellLayeredAdventurerArt(
                        archetype: 'scholar', avatarBodyType: body,
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
        final frame = tester.getRect(find.byType(QuestwellEquippedAvatar));
        final layers = find.byType(QuestwellLayeredAdventurerArt);
        expect(frame.contains(tester.getRect(layers.first).topLeft), isTrue);
        expect(frame.contains(tester.getRect(layers.first).bottomRight - const Offset(.01, .01)), isTrue);
      }
    }
  });

  for (final body in ['male', 'female', 'neutral']) {
    test('$body hides jacket while retaining anatomy and front opening', () {
      final path = ScholarUnderlayerClipper(body).getClip(const Size(240, 320));
      for (final point in [
        const Offset(120, 40), // Head.
        const Offset(120, 110), // Shirt/tie.
        const Offset(120, 150), // Belt/trousers.
        const Offset(73, 183), // Left hand.
        const Offset(168, 182), // Right hand.
        const Offset(90, 300), // Left shoe.
        const Offset(166, 300), // Right shoe.
      ]) {
        expect(path.contains(point), isTrue, reason: '$body: $point');
      }
      for (final point in [
        const Offset(86, 149), // Underarm jacket flap.
        const Offset(151, 159), // Opposite jacket hip.
        const Offset(166, 130), // Outer suit sleeve.
      ]) {
        expect(path.contains(point), isFalse, reason: '$body: $point');
      }
    });
  }

  test('clip matches bottom-centered contain in wide and tall viewports', () {
    const clipper = ScholarUnderlayerClipper('male');
    final wide = clipper.getClip(const Size(480, 320));
    expect(wide.contains(const Offset(240, 110)), isTrue);
    expect(wide.contains(const Offset(206, 149)), isFalse);
    final tall = clipper.getClip(const Size(240, 640));
    expect(tall.contains(const Offset(120, 430)), isTrue);
    expect(tall.contains(const Offset(86, 469)), isFalse);
    expect(tall.contains(const Offset(120, 40)), isFalse);
  });
}
