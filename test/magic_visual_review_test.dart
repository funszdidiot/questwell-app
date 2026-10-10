import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_item_icon.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  testWidgets('capture new magic on all fixed bodies', (tester) async {
    await tester.binding.setSurfaceSize(const Size(480, 420));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final body in ['female', 'neutral', 'male']) {
      for (final background in const {
        'dark': Color(0xFF172930),
        'light': Color(0xFFF5F0E6),
      }.entries) {
        final capture = GlobalKey();
        await tester.pumpWidget(MaterialApp(
            home: RepaintBoundary(
          key: capture,
          child: ColoredBox(
            color: background.value,
            child: MediaQuery(
                data: const MediaQueryData(disableAnimations: true),
                child: Row(children: [
                  for (final effect in ['starlight-aura', 'enchanted-leaves'])
                    SizedBox(
                        width: 240,
                        child: Column(children: [
                          const SizedBox(height: 16),
                          QuestwellItemIcon(slug: effect, size: 32),
                          SizedBox(
                              width: 240,
                              height: 320,
                              child: QuestwellLayeredAdventurerArt(
                                archetype: 'scholar',
                                avatarBodyType: body,
                                equippedSlugs: {
                                  'effect': effect,
                                  'familiar': effect == 'starlight-aura'
                                      ? 'boston-terrier'
                                      : 'hearth-cat'
                                },
                              )),
                        ])),
                ])),
          ),
        )));
        await tester.runAsync(() async {
          await Future.wait(tester.widgetList<Image>(find.byType(Image)).map(
              (image) => precacheImage(image.image, capture.currentContext!)));
        });
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final boundary = capture.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
          for (final scale in [1, 2]) {
            final image = await boundary.toImage(pixelRatio: scale.toDouble());
            final bytes =
                await image.toByteData(format: ui.ImageByteFormat.png);
            final file = File(
                'build/magic-review/$body-${background.key}-${scale}x.png');
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          }
        });
        expect(tester.takeException(), isNull);
      }
    }
  });
}
