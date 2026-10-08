import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../lib/services/questwell_cosmetic_models.dart';
import '../lib/widgets/questwell_market_view.dart';
import '../lib/widgets/questwell_app_style.dart';
import '../lib/widgets/questwell_pixel_art.dart';

QuestwellCosmetic decor(
  String slug, {
  String category = 'room',
  String? slot,
  String? profile,
  List<String> slots = const [],
  QuestwellHearthRenderSpec? spec,
  bool equipped = false,
}) =>
    QuestwellCosmetic.fromJson(
      {
        'id': slug,
        'slug': slug,
        'name': slug,
        'category': category,
        'hearth_profile_key': profile,
      },
      owned: equipped,
      equipped: equipped,
      roomSlot: slot,
      hearthRenderSpec: spec,
      hearthPlacements: [
        for (var n = 0; n < slots.length; n++)
          QuestwellHearthPlacementOption(
            slot: slots[n],
            label: slots[n],
            sortOrder: n,
          ),
      ],
    );

Future<void> openPreview(
  WidgetTester tester,
  List<QuestwellCosmetic> items, {
  Size size = const Size(360, 740),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: QuestwellAppStyle.theme(),
      home: Scaffold(
        body: QuestwellMarketView(
          data: QuestwellCosmeticsSnapshot(
            profile: QuestwellProfile.fromJson({}),
            cosmetics: items,
          ),
          onPurchase: (_) async => fail('Preview must not purchase'),
          onEquip: (_) async => fail('Preview must not equip'),
          onUnequip: (_) async => fail('Preview must not unequip'),
          onRefresh: () async {},
        ),
      ),
    ),
  );
  await tester.scrollUntilVisible(find.text('Preview'), 250,
      scrollable: find.byType(Scrollable).first);
  await tester.pump();
  await tester.tap(find.text('Preview').first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);
  testWidgets(
    'Market uses backend floor slot and render metadata at phone width',
    (tester) async {
      const spec = QuestwellHearthRenderSpec(
        renderKind: 'floor_sprite',
        assetSource: 'bundle',
        assetPath:
            'assets/images/questwell/hearth/emerald_wayfarer_rug_v3_64bit.webp',
        canvasWidth: 384,
        canvasHeight: 256,
        visibleBase: 1,
      );
      final item = decor(
        'a-new-rug',
        profile: 'floor_rug',
        slots: ['floor'],
        spec: spec,
      );
      await openPreview(tester, [item]);
      final scene = tester.widget<QuestwellHearthPixelScene>(
        find.byType(QuestwellHearthPixelScene),
      );
      expect(scene.equippedSlugs, {'room:floor': item.slug});
      expect(scene.hearthProfileBySlug[item.slug], 'floor_rug');
      expect(scene.hearthRenderBySlug[item.slug], same(spec));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Market preserves equipped wall placement without duplicating it',
    (tester) async {
      final item = decor(
        'fern-study',
        category: 'wall_art',
        slot: 'wall_right',
        slots: ['wall_left', 'wall_right'],
        equipped: true,
      );
      await openPreview(tester, [item]);
      final scene = tester.widget<QuestwellHearthPixelScene>(
        find.byType(QuestwellHearthPixelScene),
      );
      expect(scene.equippedSlugs, {'wall_art:wall_right': item.slug});
      expect(tester.takeException(), isNull);
    },
  );
  for (final size in [
    const Size(320, 740),
    const Size(390, 844),
    const Size(599, 900),
    const Size(600, 900),
    const Size(840, 900),
    const Size(1200, 800),
  ]) {
    testWidgets('Room camera matches Hearth at $size and after folding',
        (tester) async {
      final item = decor('fern-study',
          category: 'wall_art', slots: ['wall_left', 'wall_right']);
      await openPreview(tester, [item], size: size);
      final sceneFinder = find.byType(QuestwellHearthPixelScene);
      final initialEquipment = Map<String, String>.of(
          tester.widget<QuestwellHearthPixelScene>(sceneFinder).equippedSlugs);
      for (final viewport in [size, const Size(360, 740), size]) {
        tester.view.physicalSize = viewport;
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        final room =
            tester.getSize(find.byKey(const ValueKey('hearth-room-bounds')));
        final scene = tester.widget<QuestwellHearthPixelScene>(sceneFinder);
        expect(scene.immersive, isTrue);
        expect(room.height, closeTo(room.width * .68 + 8, .01));
        expect(room.width, lessThanOrEqualTo(viewport.width));
        expect(room.width, lessThanOrEqualTo(760));
        expect(scene.equippedSlugs, initialEquipment);
        expect(tester.takeException(), isNull);
      }
      await tester.ensureVisible(find.text('Back to shop'));
      await tester.tap(find.text('Back to shop'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(sceneFinder, findsNothing);
    });
  }
  testWidgets('Market does not invent a position for unregistered decor', (
    tester,
  ) async {
    await openPreview(tester, [decor('unknown-decor')]);
    expect(
      find.text('Room preview unavailable for this item.'),
      findsOneWidget,
    );
    final message = tester.widget<Text>(
      find.text('Room preview unavailable for this item.'),
    );
    expect(message.style?.color, const Color(0xFFF1E4C9));
    expect(find.byType(QuestwellHearthPixelScene), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
