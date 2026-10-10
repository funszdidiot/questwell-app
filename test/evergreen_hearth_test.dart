import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/preview/evergreen_hearth_review.dart';
import '../lib/services/questwell_equipment_policy.dart';
import '../lib/widgets/questwell_hallowed_spiders.dart';
import '../lib/widgets/questwell_catalog_equipment.dart';
import '../lib/widgets/questwell_hearth_decor.dart';
import '../lib/widgets/questwell_hearth_room_plan.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_room_geometry.dart';
import '../lib/widgets/questwell_wall_art.dart';
import '../lib/widgets/questwell_window_geometry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const additions = [
    QuestwellHearthSetting.madAlchemistsLab,
    QuestwellHearthSetting.guardiansKeep
  ];

  test('evergreen skins inherit Hallowed geometry and stay account gated', () {
    for (final room in additions) {
      expect(QuestwellHearthSetting.fromSlug(room.slug), room);
      expect(QuestwellHearthSetting.supports(room.slug), isTrue);
      expect(QuestwellRoomGeometry.sourceForSetting(room.slug),
          const Size(1536, 1024));
      expect(QuestwellHearthRoomPlan.forSetting(room.slug),
          same(QuestwellHearthRoomPlan.hallowed));
      expect(
          room.mantelAnchor(const Size(960, 640)),
          QuestwellHearthSetting.hallowedHearth
              .mantelAnchor(const Size(960, 640)));
      expect(QuestwellWindowGeometry.source(room.file), const Size(1536, 1024));
      expect(QuestwellEquipmentPolicy.isReady(room.slug, 'room'), isFalse);
    }
    for (final slug in EvergreenHearthFixture.names.keys) {
      expect(QuestwellEquipmentPolicy.isReady(slug, 'wall_art'), isFalse);
    }
  });

  test('new window masks follow their own painted mullions', () {
    final keep = QuestwellWindowGeometry.glass('guardians_keep_v1');
    final lab = QuestwellWindowGeometry.glass('mad_alchemists_lab_v1');
    for (final glass in [keep, lab]) {
      for (final point in [
        const Offset(1000, 270),
        const Offset(1075, 270),
        const Offset(1160, 300),
        const Offset(1105, 158)
      ]) {
        expect(glass.contains(point), isTrue);
      }
      for (final point in [
        const Offset(1043, 280),
        const Offset(1105, 280),
        const Offset(1000, 322),
        const Offset(1250, 300)
      ]) {
        expect(glass.contains(point), isFalse);
      }
    }
    // The Keep's wide pane has no invented vertical or horizontal bar.
    expect(keep.contains(const Offset(1205, 350)), isTrue);
    expect(keep.contains(const Offset(1220, 322)), isTrue);
    expect(lab.contains(const Offset(1205, 350)), isFalse);
    expect(lab.contains(const Offset(1220, 322)), isFalse);
  });

  test('textiles stay above the mantel and within the side wall bays', () {
    const size = Size(1536, 1024);
    final center = QuestwellHearthDecor.wallArtBounds(size, 'wall_center',
        hallowed: true, profileKey: 'wall_textile');
    expect(center.bottom, lessThan(280));
    expect(center.center.dx, 568);
    expect(
        center.width,
        greaterThan(QuestwellHearthDecor.wallArtBounds(size, 'wall_center',
                hallowed: true)
            .width));
    for (final slot in ['wall_left', 'wall_center', 'wall_right']) {
      final bounds = QuestwellHearthDecor.wallArtBounds(size, slot,
          hallowed: true, profileKey: 'wall_textile');
      expect((Offset.zero & size).contains(bounds.topLeft), isTrue);
      expect((Offset.zero & size).contains(bounds.bottomRight), isTrue);
      // Window frame and fire opening are never covered by a textile envelope.
      expect(bounds.overlaps(const Rect.fromLTWH(945, 90, 345, 400)), isFalse);
      expect(bounds.overlaps(const Rect.fromLTWH(410, 395, 325, 170)), isFalse);
    }
  });

  test('textile bounds clear the standard avatar and Hallowed bookshelf', () {
    const size = Size(1024, 1024);
    for (final gallery in [false, true]) {
      expect(
          QuestwellHearthDecor.wallArtBounds(size, 'wall_center',
                  profileKey: 'wall_textile', galleryWall: gallery)
              .bottom,
          lessThan(180));
    }
    expect(
        QuestwellHearthDecor.wallArtBounds(const Size(1536, 1024), 'wall_right',
                hallowed: true, profileKey: 'wall_textile')
            .bottom,
        lessThan(350));
  });

  test('gallery groups keep visible gaps and the established wall slots', () {
    for (final hallowed in [false, true]) {
      final size = hallowed ? const Size(1536, 1024) : const Size(1024, 1024);
      Rect bounds(String slot) => QuestwellHearthDecor.wallArtBounds(size, slot,
          hallowed: hallowed, galleryWall: true);
      final center = bounds('wall_center');
      expect(bounds('wall_left').right, lessThan(center.left));
      expect(bounds('wall_right').left, greaterThan(center.right));
      expect(center.bottom, lessThan(hallowed ? 280 : 300));
      expect(center.width, greaterThan(bounds('wall_left').width * 3));
    }
  });

  testWidgets(
      'gallery uses one statement textile with two existing framed works',
      (tester) async {
    await tester.pumpWidget(const EvergreenHearthReviewApp());
    await tester.pump();
    final scene = tester.widget<QuestwellHearthPixelScene>(
        find.byType(QuestwellHearthPixelScene));
    expect(scene.equippedSlugs['wall_art'], 'hearthwoven-macrame');
    expect(scene.equippedSlugs['wall_art:wall_left'], 'fern-study');
    expect(scene.equippedSlugs['wall_art:wall_right'], 'celestial-study');
    expect(find.byType(QuestwellWallArt), findsNWidgets(3));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'real room renderer loads every textile and slot without seasonal leakage',
      (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final capture = GlobalKey();
    for (final width in [390.0, 960.0]) {
      await tester.binding.setSurfaceSize(Size(width, width));
      for (final room in EvergreenHearthFixture.rooms) {
        for (final art in EvergreenHearthFixture.names.keys) {
          for (final slot in [
            'wall_center',
            'wall_left',
            'wall_right',
            'gallery'
          ]) {
            final gallery = slot == 'gallery';
            final wallSlot = gallery ? 'wall_center' : slot;
            final height = width / (room.usesHallowedLayout ? 1.5 : 1);
            await tester.pumpWidget(MaterialApp(
                home: Scaffold(
                    body: RepaintBoundary(
                        key: capture,
                        child: TickerMode(
                            enabled: false,
                            child: QuestwellHearthPixelScene(
                              height: height,
                              immersive: true,
                              setting: room,
                              showAvatar: true,
                              archetype: 'guardian',
                              hearthProfileBySlug:
                                  EvergreenHearthFixture.profiles,
                              hearthRenderBySlug:
                                  EvergreenHearthFixture.renders,
                              equippedSlugs: {
                                (wallSlot == 'wall_center'
                                    ? 'wall_art'
                                    : 'wall_art:$wallSlot'): art,
                                if (gallery) ...{
                                  'wall_art:wall_left': 'fern-study',
                                  'wall_art:wall_right': 'celestial-study',
                                },
                                'room:right': 'walnut-bookshelf',
                                'room:front': 'burgundy-reading-chair',
                                'room:side': 'walnut-reading-table',
                              },
                            ))))));
            await tester.runAsync(() async {
              await Future.wait(tester
                  .widgetList<Image>(find.byType(Image))
                  .map((image) => precacheImage(
                      image.image, capture.currentContext!,
                      onError: (Object error, StackTrace? stack) =>
                          fail('Asset did not load: $error'))));
            });
            await tester.pump();
            expect(tester.takeException(), isNull);
            expect(
                find.byType(QuestwellWallArt), findsNWidgets(gallery ? 3 : 1));
            final wall = tester
                .widgetList<QuestwellWallArt>(find.byType(QuestwellWallArt))
                .firstWhere((w) => w.artSlug == art);
            expect(wall.artSlug, art);
            expect(wall.wallSlot, wallSlot);
            expect(
                find.byType(QuestwellHallowedSpiders),
                room == QuestwellHearthSetting.hallowedHearth
                    ? findsOneWidget
                    : findsNothing);
            final rect = tester.getRect(find.byKey(ValueKey(
                wallSlot == 'wall_center'
                    ? 'hearth-wall-art-bounds'
                    : 'hearth-$wallSlot-art-bounds')));
            final expected = QuestwellHearthDecor.wallArtBounds(
                Size(width, height), wallSlot,
                hallowed: room.usesHallowedLayout,
                profileKey: 'wall_textile',
                galleryWall: gallery);
            expect(rect, expected);
            // The same screenshots test the actual renderer, not a reconstruction.
            await tester.runAsync(() async {
              final boundary = capture.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
              final image = await boundary.toImage(pixelRatio: 1);
              final bytes =
                  await image.toByteData(format: ui.ImageByteFormat.png);
              final file = File(
                  'build/hearth-composition/evergreen-${room.slug}-$art-$slot-${width.toInt()}.png');
              await file.parent.create(recursive: true);
              await file.writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
        }
      }
    }
  });

  testWidgets('rain uses the selected evergreen glass registration',
      (tester) async {
    for (final room in additions) {
      await tester.pumpWidget(MaterialApp(
          home: TickerMode(
              enabled: false,
              child: QuestwellHearthPixelScene(
                  height: 400,
                  immersive: true,
                  showAvatar: false,
                  setting: room,
                  equippedSlugs: const {'room:window': 'rainy-window'}))));
      final rain = tester
          .widget<QuestwellRainyWindow>(find.byType(QuestwellRainyWindow));
      expect(rain.glassMask, same(QuestwellWindowGeometry.glass(room.file)));
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('room switch keeps the selected textile and saved slot semantics',
      (tester) async {
    await tester.pumpWidget(const EvergreenHearthReviewApp());
    await tester.pump();
    final art = tester.widget<DropdownButton<String>>(
        find.byKey(const ValueKey('evergreen-art')));
    art.onChanged!('hearthwoven-macrame');
    await tester.pump();
    await tester.tap(find.text('Left wall'));
    await tester.pump();
    for (final room in EvergreenHearthFixture.rooms) {
      tester
          .widget<DropdownButton<QuestwellHearthSetting>>(
              find.byKey(const ValueKey('evergreen-room')))
          .onChanged!(room);
      await tester.pump();
      final scene = tester.widget<QuestwellHearthPixelScene>(
          find.byType(QuestwellHearthPixelScene));
      expect(scene.equippedSlugs['wall_art:wall_left'], 'hearthwoven-macrame');
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
  });
}
