import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Issue 6 v3 assets are decodable runtime images', () async {
    const expected = {
      'assets/images/questwell/hearth/warding_lantern_v3_64bit.webp': (960, 1680),
      'assets/images/questwell/hearth/emerald_wayfarer_rug_v3_64bit.webp': (384, 256),
    };

    for (final entry in expected.entries) {
      final data = await rootBundle.load(entry.key);
      expect(data.lengthInBytes, greaterThan(0), reason: entry.key);

      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        ),
      );
      final frame = await codec.getNextFrame();
      expect(
        (frame.image.width, frame.image.height),
        entry.value,
        reason: entry.key,
      );
      frame.image.dispose();
      codec.dispose();
    }
  });
}
