import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/services/questwell_cosmetic_models.dart';
import '../lib/widgets/questwell_item_icon.dart';
import '../lib/widgets/questwell_pixel_art.dart';

// Capture the real renderer for visual review on CI; no golden is auto-approved.
void main() {
  testWidgets('capture Halloween room and icons for independent visual review',
      (tester) async {
    final manifest = jsonDecode(await rootBundle
            .loadString('assets/jsons/hallowed_hearth_decor_2026.json'))
        as Map<String, dynamic>;
    final profiles = <String, String>{};
    final renders = <String, QuestwellHearthRenderSpec>{};
    for (final item in manifest['items'] as List) {
      final hearth = item['hearth'] as Map<String, dynamic>;
      profiles[item['slug'] as String] = hearth['profile_key'] as String;
      renders[item['slug'] as String] = QuestwellHearthRenderSpec.fromJson(
          hearth['render'] as Map<String, dynamic>);
    }
    final capture = GlobalKey();
    Future<void> save(String name) async {
      await tester.runAsync(() async {
        await Future.wait(tester.widgetList<Image>(find.byType(Image)).map(
              (image) => precacheImage(image.image, capture.currentContext!),
            ));
      });
      await tester.pump();
      final boundary =
          capture.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('build/hallowed-review/$name.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      expect(tester.takeException(), isNull);
    }

    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final width in [390.0, 960.0]) {
      final height = width == 390 ? 420.0 : 640.0;
      await tester.binding.setSurfaceSize(Size(width, height));
      for (final body in ['female', 'neutral', 'male']) {
        await tester.pumpWidget(MaterialApp(
            home: Scaffold(
                body: RepaintBoundary(
          key: capture,
          child: TickerMode(
              enabled: false,
              child: QuestwellHearthPixelScene(
                height: height,
                immersive: true,
                avatarBodyType: body,
                equippedSlugs: const {
                  'room:setting': 'hallowed-hearth',
                  'room:right': 'witchlight-bookcase',
                  'room:front': 'velvet-batwing-chair',
                  'room:side': 'moonbrew-side-table',
                  'room:floor': 'moonweb-rug',
                  'wall_art:wall_left': 'midnight-visitors-print',
                  'room:mantel': 'first-journey-trophy',
                },
                hearthProfileBySlug: profiles,
                hearthRenderBySlug: renders,
              )),
        ))));
        await tester.pump();
        await save('room-${width.toInt()}-$body');
      }
    }
    await tester.binding.setSurfaceSize(const Size(384, 64));
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
          key: capture,
          child: ColoredBox(
            color: const Color(0xFFF1E4C9),
            child: Row(children: [
              for (final slug in ['hallowed-hearth', ...profiles.keys])
                QuestwellItemIcon(slug: slug)
            ]),
          )),
    ));
    await save('icons');
  });
}
