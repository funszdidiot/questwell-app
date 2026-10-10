import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/questwell_pet_magic.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final slug in ['boston-terrier', 'hearth-cat']) {
    Future<List<int>> pixels(double phase, {bool still = false}) async {
      final recorder = ui.PictureRecorder();
      QuestwellPetMagicPainter(slug: slug, phase: phase, still: still)
          .paint(Canvas(recorder), const Size(54, 72));
      final picture = recorder.endRecording();
      final image = await picture.toImage(54, 72);
      final bytes =
          (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
              .buffer
              .asUint8List()
              .toList();
      image.dispose();
      picture.dispose();
      return bytes;
    }

    test(
        '$slug magic remains visible throughout the loop and still when reduced',
        () async {
      final active = slug == 'boston-terrier' ? .90 : .37;
      expect(QuestwellPetMagicPainter.progress(slug, .2), -1);
      expect(QuestwellPetMagicPainter.progress(slug, active), greaterThan(0));
      for (final phase in [0.0, .1, .2, .5, .8, .99, 1.0]) {
        final frame = await pixels(phase);
        final alpha = [for (var i = 3; i < frame.length; i += 4) frame[i]];
        expect(alpha.where((a) => a >= 100).length, greaterThan(15),
            reason: '$slug must remain visible at phase $phase');
      }
      final a = await pixels(active);
      expect(a.any((v) => v != 0), isTrue);
      expect(a, isNot(equals(await pixels(active + .025))));
      expect(
          await pixels(.1, still: true), equals(await pixels(.9, still: true)));
      expect(await pixels(0), equals(await pixels(1)),
          reason: 'Ambient loop must have no reset flash');
      // Eyes, face and collar occupy the center. Magic stays in the margins.
      for (var y = 0; y < 55; y++) {
        for (var x = 15; x < 40; x++) {
          expect(a[(y * 54 + x) * 4 + 3], 0);
        }
      }
    });
  }
  test('Unknown familiars and invalid phases produce no timed accent', () {
    expect(QuestwellPetMagicPainter.progress('unknown', .5), -1);
    expect(QuestwellPetMagicPainter.progress('hearth-cat', double.nan), -1);
    expect(QuestwellPetMagicPainter.progress('hearth-cat', -1), -1);
  });
}
