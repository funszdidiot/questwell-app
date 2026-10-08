import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/services/questwell_cosmetic_models.dart';
import '../lib/services/questwell_equipment_policy.dart';
import '../lib/widgets/questwell_hearth_layout.dart';
import '../lib/widgets/questwell_hearth_decor.dart';
import '../lib/widgets/questwell_pixel_art.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('seasonal boundary is inclusive start and exclusive end', () {
    final start = DateTime.utc(2026, 10, 8);
    final end = DateTime.utc(2026, 11, 9, 6);
    final item = QuestwellCosmetic.fromJson({
      'availability_start': start.toIso8601String(),
      'availability_end': end.toIso8601String(),
    });
    expect(
        item.availableForPurchaseAt(start.subtract(const Duration(seconds: 1))),
        isFalse);
    expect(item.availableForPurchaseAt(start), isTrue);
    expect(
        item.availableForPurchaseAt(
            end.subtract(const Duration(microseconds: 1))),
        isTrue);
    expect(item.availableForPurchaseAt(end), isFalse);
    expect(item.copyWith(owned: true).owned, isTrue);
    expect(QuestwellCosmetic.fromJson({}).availableForPurchaseAt(end), isTrue);
  });

  test('new profile neighbors retain canonical chair and table spacing', () {
    const scene = Size(390, 420);
    for (final chairSlot in ['front', 'left', 'right']) {
      for (final hasTable in [false, true]) {
        final legacy = <String, String>{
          'room:$chairSlot': 'burgundy-reading-chair',
          if (hasTable) 'room:side': 'walnut-reading-table',
        };
        final seasonal = <String, String>{
          'room:$chairSlot': 'velvet-batwing-chair',
          if (hasTable) 'room:side': 'moonbrew-side-table',
        };
        for (final entry in {
          'burgundy-reading-chair': chairSlot,
          'walnut-reading-table': 'side'
        }.entries) {
          final profile =
              entry.key.contains('chair') ? 'seating' : 'side_table';
          Rect bounds(Map<String, String> equipment,
                  Map<String, String> profiles) =>
              QuestwellHearthLayout.bounds(
                slug: entry.key,
                profileKey: profile,
                slot: entry.value,
                scene: scene,
                equipment: equipment,
                profileBySlug: profiles,
              );
          expect(
              bounds(seasonal, const {
                'velvet-batwing-chair': 'seating',
                'moonbrew-side-table': 'side_table',
              }),
              bounds(legacy, const {}));
        }
      }
    }
  });

  test(
      'mantel collectibles follow the new source art without moving original anchors',
      () {
    for (final scene in [
      const Size(390, 260),
      const Size(390, 420),
      const Size(960, 640)
    ]) {
      final anchor = QuestwellHearthSetting.hallowedHearth.mantelAnchor(scene)!;
      expect(QuestwellHearthSetting.original.mantelAnchor(scene), isNull);
      final trophy = QuestwellHearthDecor.trophyPositioned(
        slot: 'mantel',
        scene: scene,
        equipment: const {},
        mantelAnchor: anchor,
      );
      expect(trophy.left! + trophy.width! * .48, closeTo(anchor.dx, .001));
      expect(trophy.top! + trophy.height! * .955, closeTo(anchor.dy, .001));
      final relic = QuestwellHearthDecor.relicSurfacePositioned(
        slug: 'scholar-seal',
        slot: 'mantel',
        scene: scene,
        equipment: const {},
        mantelAnchor: anchor,
      );
      expect(relic.top! + relic.height!, closeTo(anchor.dy, .001));
      expect(relic.left! + relic.width! / 2, closeTo(anchor.dx, .001));
    }
    final original = QuestwellHearthDecor.trophyPositioned(
        slot: 'mantel', scene: const Size(390, 260), equipment: const {});
    expect(original.left! + original.width! * .48, closeTo(390 * .082, .001));
    expect(original.top! + original.height! * .955,
        closeTo(390 * .340 - 130 * .52, .001));
  });

  testWidgets(
      'approved furnishing manifest composes at mobile and desktop widths',
      (tester) async {
    final manifest = jsonDecode(await rootBundle
            .loadString('assets/jsons/hallowed_hearth_decor_2026.json'))
        as Map<String, dynamic>;
    final profiles = <String, String>{};
    final renders = <String, QuestwellHearthRenderSpec>{};
    for (final item in manifest['items'] as List) {
      final slug = item['slug'] as String;
      final hearth = item['hearth'] as Map<String, dynamic>;
      profiles[slug] = hearth['profile_key'] as String;
      renders[slug] = QuestwellHearthRenderSpec.fromJson(
          hearth['render'] as Map<String, dynamic>);
      expect(QuestwellEquipmentPolicy.isReady(slug, item['category'] as String),
          isTrue);
    }
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final width in [320.0, 390.0, 430.0, 960.0]) {
      await tester.binding.setSurfaceSize(Size(width, 800));
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: TickerMode(
        enabled: false,
        child: QuestwellHearthPixelScene(
          height: width / 1.5,
          immersive: true,
          showAvatar: false,
          equippedSlugs: const {
            'room:setting': 'hallowed-hearth',
            'room:right': 'witchlight-bookcase',
            'room:front': 'velvet-batwing-chair',
            'room:side': 'moonbrew-side-table',
            'room:floor': 'moonweb-rug',
            'wall_art:wall_left': 'midnight-visitors-print',
          },
          hearthProfileBySlug: profiles,
          hearthRenderBySlug: renders,
        ),
      ))));
      await tester.pumpAndSettle();
      for (final render in renders.values) {
        expect(
            find.byWidgetPredicate((widget) =>
                widget is Image &&
                widget.image is AssetImage &&
                (widget.image as AssetImage).assetName == render.assetPath),
            // Wall art deliberately draws the same sprite twice: its alpha
            // silhouette shadow, then the room-lit foreground artwork.
            findsNWidgets(render.renderKind == 'wall_art_sprite' ? 2 : 1));
      }
      expect(tester.takeException(), isNull);
    }
  });
}
