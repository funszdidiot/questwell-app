import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../lib/services/questwell_cosmetic_models.dart';
import '../lib/preview/autumn_hearth_review.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/questwell_hearth_layout.dart';
import '../lib/widgets/questwell_hearth_room_plan.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_room_geometry.dart';

const rooms = [
  'original',
  'astral-sanctuary',
  'hallowed-hearth',
  'midnight-harvest',
  'woodland-cottage',
  'enchanted-library',
  'midnight-observatory',
  'alchemists-workshop',
  'emberglass-conservatory',
];
const arrangements = {
  'autumn-window': {
    'room:window': 'amberfall-window',
    'room:right': 'copper-potion-workbench',
  },
  'wall-standards': {
    'wall_art': 'moonlit-woodland',
    'wall_art:wall_left': 'celestial-study',
    'wall_art:wall_right': 'fern-study',
  },
  'reading-left': {
    'room:front': 'burgundy-reading-chair',
    'room:side': 'walnut-reading-table',
    'room:right': 'copper-potion-workbench',
  },
  'reading-right': {
    'room:right': 'burgundy-reading-chair',
    'room:side': 'walnut-reading-table',
    'room:left': 'walnut-bookshelf',
  },
  'reported-cabinet-chair': {
    'room:left': 'copper-potion-workbench',
    'room:right': 'burgundy-reading-chair',
    'room:side': 'moonbrew-side-table',
    'room:floor': 'maple-hearth-rug',
    'outfit': 'pumpkin-court',
  },
  'cushions': {
    'room:front': 'sages-rest',
    'room:left': 'harvest-lanterns',
    'room:right': 'mooncap-grove',
  },
  'halloween-reading': {
    'room:front': 'velvet-batwing-chair',
    'room:side': 'moonbrew-side-table',
    'room:right': 'witchlight-bookcase',
  },
  'display': {
    'room:left': 'walnut-bookshelf',
    'room:right': 'copper-potion-workbench',
    'room:side': 'walnut-reading-table',
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final profiles = {...AutumnHearthFixture.profiles};
  final renders = {...AutumnHearthFixture.renders};
  setUpAll(() async {
    final manifest = jsonDecode(await rootBundle.loadString(
      'assets/jsons/hallowed_hearth_decor_2026.json',
    )) as Map<String, dynamic>;
    for (final item in manifest['items'] as List) {
      final hearth = item['hearth'] as Map<String, dynamic>;
      profiles[item['slug'] as String] = hearth['profile_key'] as String;
      renders[item['slug'] as String] = QuestwellHearthRenderSpec.fromJson(
          hearth['render'] as Map<String, dynamic>);
    }
  });

  test('artistic skins share exactly two architectural maps', () {
    final maps = rooms.map(QuestwellHearthRoomPlan.forSetting).toSet();
    expect(maps.length, 2);
    for (final room in rooms.where((r) => r != 'hallowed-hearth')) {
      expect(
          identical(QuestwellHearthRoomPlan.forSetting(room),
              QuestwellHearthRoomPlan.standard),
          isTrue);
      for (final profile in ['large_furniture', 'seating', 'side_table']) {
        final slug = {
          'large_furniture': 'copper-potion-workbench',
          'seating': 'burgundy-reading-chair',
          'side_table': 'walnut-reading-table',
        }[profile]!;
        Rect bounds(String setting) => QuestwellHearthLayout.bounds(
            slug: slug,
            profileKey: profile,
            slot: 'right',
            scene: const Size(600, 416),
            equipment: {'room:setting': setting});
        expect(bounds(room), bounds('original'), reason: '$room/$profile');
      }
    }
  });

  test('cabinet envelopes clear the fireplace and meet the rear wall', () {
    if (!QuestwellHearthRoomPlan.enabled) return;
    for (final room in rooms) {
      for (final requested in [const Size(284, 342), const Size(760, 526)]) {
        final size = Size(
            requested.width,
            QuestwellRoomGeometry.framedHeight(
                room, requested.width, requested.height));
        final geometry = QuestwellRoomGeometry.forSetting(room, size);
        final source = QuestwellRoomGeometry.sourceForSetting(room);
        for (final slug in [
          'walnut-bookshelf',
          'copper-potion-workbench',
          'harvest-apothecary-display',
          'witchlight-bookcase'
        ]) {
          final rect = QuestwellHearthLayout.bounds(
              slug: slug,
              profileKey: 'large_furniture',
              slot: 'left',
              scene: size,
              equipment: {'room:setting': room},
              renderSpec: renders[slug]);
          if (room == 'hallowed-hearth') {
            // Measured opening starts at x=.29 of the full Hallowed plate.
            expect(rect.right,
                lessThan(geometry.point(Offset(source.width * .28, 0)).dx));
          } else {
            // Flat rear wall starts beyond the timber post at x=.245.
            expect(rect.left,
                greaterThan(geometry.point(Offset(source.width * .24, 0)).dx));
          }
        }
      }
    }
  });

  test('tables leave the sitting surface clear on both sides and both maps',
      () {
    if (!QuestwellHearthRoomPlan.enabled) return;
    for (final room in ['original', 'hallowed-hearth']) {
      for (final slot in ['front', 'right']) {
        for (final chairSlug in [
          'burgundy-reading-chair',
          'velvet-batwing-chair'
        ]) {
          for (final tableSlug in [
            'walnut-reading-table',
            'moonbrew-side-table'
          ]) {
            for (final requested in [
              const Size(284, 342),
              const Size(760, 526)
            ]) {
              final size = Size(
                  requested.width,
                  QuestwellRoomGeometry.framedHeight(
                      room, requested.width, requested.height));
              final equipment = {
                'room:setting': room,
                'room:$slot': chairSlug,
                'room:side': tableSlug
              };
              Rect bounds(String slug, String profile, String s) =>
                  QuestwellHearthLayout.bounds(
                      slug: slug,
                      profileKey: profile,
                      slot: s,
                      scene: size,
                      equipment: equipment,
                      profileBySlug: profiles,
                      renderSpec: renders[slug]);
              final chair = bounds(chairSlug, 'seating', slot);
              final table = bounds(tableSlug, 'side_table', 'side');
              expect(table.intersect(chair).width, lessThan(chair.width * .12));
              expect(table.height, lessThan(chair.height * .65));
              expect(table.left, greaterThanOrEqualTo(0));
              expect(table.right, lessThanOrEqualTo(size.width));
            }
          }
        }
      }
    }
  });
  test(
    'table follows its chair and clears a cabinet when the chair is absent',
    () {
      for (final room in rooms) {
        final plan = QuestwellHearthRoomPlan.forSetting(room);
        final left = plan.center('side_table', 'side', chairOnLeft: true);
        final right = plan.center(
          'side_table',
          'side',
          chairOnLeft: false,
          chairOnRight: true,
        );
        expect(left, lessThan(plan.seatLeft));
        expect(right, greaterThan(plan.seatRight));
        expect(
          plan.center(
            'side_table',
            'side',
            chairOnLeft: false,
            largeOnRight: true,
          ),
          left,
        );
      }
    },
  );
  test(
    'rear floor contact follows source wall under wide and portrait crops',
    () {
      if (!QuestwellHearthRoomPlan.enabled) return;
      for (final room in rooms) {
        for (final size in [
          const Size(390, 280),
          const Size(284, 342),
          const Size(600, 416),
        ]) {
          final plan = QuestwellHearthRoomPlan.forSetting(room);
          final geometry = QuestwellRoomGeometry.forSetting(room, size);
          final source = QuestwellRoomGeometry.sourceForSetting(room);
          final rect = QuestwellHearthLayout.bounds(
            slug: 'copper-potion-workbench',
            profileKey: 'large_furniture',
            slot: 'right',
            scene: size,
            equipment: {'room:setting': room},
          );
          final contact = rect.top + rect.height * 1119 / 1173;
          final wall = geometry
              .point(Offset(
                  0, source.height * (room == 'hallowed-hearth' ? .575 : .60)))
              .dy;
          // A rear cabinet must sit just in front of the wall, not on the
          // foreground floor. The previous .75 * viewport height fails this.
          expect(
            contact - wall,
            inInclusiveRange(0, source.height * geometry.scale * .025),
          );
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(size.width));
          expect(rect.width / rect.height, closeTo(1341 / 1173, 1e-9));
          expect(plan.isRear('seating', 'right'), isFalse);
        }
      }
    },
  );
  test('room cover transform retains the measured Hallowed back wall', () {
    final square = QuestwellRoomGeometry.forSetting(
      'hallowed-hearth',
      const Size(390, 390),
    );
    expect(square.point(const Offset(768, 614.4)), const Offset(195, 234));
    final wide = QuestwellRoomGeometry.forSetting(
      'hallowed-hearth',
      const Size(600, 400),
    );
    expect(wide.point(const Offset(768, 614.4)), const Offset(300, 240));
  });
  test('portrait camera retains both authored side walls', () {
    for (final room in rooms) {
      final height = QuestwellRoomGeometry.framedHeight(room, 284, 342);
      final geometry =
          QuestwellRoomGeometry.forSetting(room, Size(284, height));
      final source = QuestwellRoomGeometry.sourceForSetting(room);
      expect(geometry.point(Offset.zero).dx, closeTo(0, 1e-9));
      expect(geometry.point(Offset(source.width, 0)).dx, closeTo(284, 1e-9));
      expect(height, lessThanOrEqualTo(342));
    }
  });
  testWidgets('capture complete room compositions for visual review', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey();
    for (final room in rooms) {
      for (final arrangement in arrangements.entries) {
        for (final size in [
          const Size(390, 280),
          const Size(284, 342),
          const Size(600, 416),
          const Size(760, 526),
        ]) {
          tester.view.physicalSize = size;
          await tester.pumpWidget(
            MaterialApp(
              home: RepaintBoundary(
                key: key,
                child: Scaffold(
                  body: MediaQuery(
                    data: const MediaQueryData(disableAnimations: true),
                    child: QuestwellHearthPixelScene(
                      height: size.height,
                      setting: arrangement.key == 'autumn-window'
                          ? QuestwellHearthSetting.fromSlug(room)
                          : null,
                      immersive: true,
                      avatarBodyType: 'male',
                      hearthProfileBySlug: profiles,
                      hearthRenderBySlug: renders,
                      equippedSlugs: {
                        ...arrangement.value,
                        if (room != 'original' &&
                            arrangement.key != 'autumn-window')
                          'room:setting': room,
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.runAsync(() async {
            await Future.wait(
              tester.widgetList<Image>(find.byType(Image)).map(
                    (i) => precacheImage(
                      i.image,
                      tester.element(find.byType(Scaffold)),
                    ),
                  ),
            );
          });
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(key),
          );
          await tester.runAsync(() async {
            final image = await boundary.toImage();
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            final file = File(
              'build/hearth-composition/$room-${arrangement.key}-${size.width.toInt()}x${size.height.toInt()}.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(data!.buffer.asUint8List());
            image.dispose();
          });
        }
      }
    }
  });
}
