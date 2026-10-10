import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  'display': {
    'room:left': 'walnut-bookshelf',
    'room:right': 'copper-potion-workbench',
    'room:side': 'walnut-reading-table',
  },
};

void main() {
  test(
    'every room preserves family sizes and keeps paired seating out of center',
    () {
      for (final room in rooms) {
        final plan = QuestwellHearthRoomPlan.forSetting(room);
        expect(plan.seatLeft, lessThan(.30));
        expect(plan.seatRight, greaterThan(.70));
        for (final profile in ['large_furniture', 'seating', 'side_table']) {
          final slug = {
            'large_furniture': 'copper-potion-workbench',
            'seating': 'burgundy-reading-chair',
            'side_table': 'walnut-reading-table',
          }[profile]!;
          final base = QuestwellHearthLayout.bounds(
            slug: slug,
            profileKey: profile,
            slot: 'right',
            scene: const Size(390, 280),
          );
          final themed = QuestwellHearthLayout.bounds(
            slug: slug,
            profileKey: profile,
            slot: 'right',
            scene: const Size(390, 280),
            equipment: {'room:setting': room},
          );
          expect(
            themed.size,
            base.size,
            reason: 'Scale changed in $room/$profile',
          );
        }
      }
    },
  );
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
          final wall = geometry.point(Offset(0, source.height * .60)).dy;
          // A rear cabinet must sit just in front of the wall, not on the
          // foreground floor. The previous .75 * viewport height fails this.
          expect(
            contact - wall,
            inInclusiveRange(0, source.height * geometry.scale * .065),
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
                      immersive: true,
                      equippedSlugs: {
                        ...arrangement.value,
                        if (room != 'original') 'room:setting': room,
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
