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
        '$slug accent is synchronized, quiet between actions, and still when reduced',
        () async {
      final active = slug == 'boston-terrier' ? .90 : .37;
      expect(QuestwellPetMagicPainter.progress(slug, .2), -1);
      expect(QuestwellPetMagicPainter.progress(slug, active), greaterThan(0));
      expect((await pixels(.2)).every((v) => v == 0), isTrue);
      final a = await pixels(active);
      expect(a.any((v) => v != 0), isTrue);
      expect(a, isNot(equals(await pixels(active + .025))));
      expect(
          await pixels(.1, still: true), equals(await pixels(.9, still: true)));
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
