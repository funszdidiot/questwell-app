import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/widgets/questwell_male_paper_doll.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled male foundation and outfit are the exact reviewed exports',
      () async {
    const sources = {
      QuestwellMalePaperDoll.baseAsset:
          'tool/art_assets/male_paper_doll_v3/paper_doll_male_candidate_v3.webp',
      QuestwellMalePaperDoll.identityAsset:
          'tool/art_assets/male_paper_doll_v3/paper_doll_male_identity_candidate_v3.webp',
      QuestwellMalePaperDoll.everydayAsset:
          'tool/art_assets/male_everyday_v2/everyday_outfit_male_candidate_v2.webp',
    };
    for (final source in sources.entries) {
      final bundle = await rootBundle.load(source.key);
      final bytes = bundle.buffer
          .asUint8List(bundle.offsetInBytes, bundle.lengthInBytes);
      expect(bytes, orderedEquals(await File(source.value).readAsBytes()),
          reason: 'Runtime art must match the approved export: ${source.key}');
      final codec = await ui.instantiateImageCodec(bytes);
      final image = (await codec.getNextFrame()).image;
      try {
        expect(Size(image.width.toDouble(), image.height.toDouble()),
            const Size(240, 320));
      } finally {
        image.dispose();
        codec.dispose();
      }
    }
  });

  test('identity preserves the locked head and adds no replacement anatomy',
      () async {
    Future<ByteData> pixels(String path) async {
      final bytes = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(bytes.buffer
          .asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
      final image = (await codec.getNextFrame()).image;
      try {
        return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      } finally {
        image.dispose();
        codec.dispose();
      }
    }

    final body = await pixels(QuestwellMalePaperDoll.baseAsset);
    final identity = await pixels(QuestwellMalePaperDoll.identityAsset);
    for (var y = 0; y < 320; y++) {
      for (var x = 0; x < 240; x++) {
        final offset = (y * 240 + x) * 4;
        if (y < 74) {
          expect(identity.getUint32(offset), body.getUint32(offset),
              reason: 'Preserve the original identity at $x,$y');
        } else {
          expect(identity.getUint8(offset + 3), 0,
              reason: 'No replacement anatomy below the identity at $x,$y');
        }
      }
    }
  });

  for (final size in const [Size(240, 320), Size(120, 160), Size(360, 320)]) {
    testWidgets('male clothing keeps authored registration in $size',
        (tester) async {
      for (final showEveryday in [true, false, true]) {
        await tester.pumpWidget(MaterialApp(
          home: Center(
            child: SizedBox.fromSize(
              size: size,
              child: QuestwellMalePaperDoll(showEveryday: showEveryday),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        final doll = find.byType(QuestwellMalePaperDoll);
        final imageFinder = find.descendant(of: doll, matching: find.byType(Image));
        final images = tester.widgetList<Image>(imageFinder).toList();
        expect(images.map((image) => (image.image as AssetImage).assetName), [
          QuestwellMalePaperDoll.baseAsset,
          if (showEveryday) QuestwellMalePaperDoll.everydayAsset,
          if (showEveryday) QuestwellMalePaperDoll.identityAsset,
        ]);
        for (var i = 0; i < images.length; i++) {
          expect(tester.getRect(imageFinder.at(i)), tester.getRect(doll));
          expect(images[i].fit, BoxFit.contain);
          expect(images[i].alignment, Alignment.bottomCenter);
        }
        for (final type in [ClipPath, ClipRect, Transform, ColorFiltered]) {
          expect(find.descendant(of: doll, matching: find.byType(type)),
              findsNothing,
              reason: 'The intact foundation must never be masked or refitted');
        }
      }
    });
  }
}
