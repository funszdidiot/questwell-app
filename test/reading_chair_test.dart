import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_bookshelf.dart';
import '../lib/widgets/questwell_fern.dart';
import '../lib/widgets/questwell_reading_chair.dart';
import '../lib/services/questwell_equipment_policy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  testWidgets('Adult furniture overlaps naturally in depth order behind the avatar', (tester) async {
    for (final width in [320.0, 390.0]) {
      await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(width: width,
        child: const QuestwellHearthPixelScene(height: 310, equippedSlugs: {
          'room:left': QuestwellFern.slug, 'room:right': QuestwellBookshelf.slug,
          'room:front': QuestwellReadingChair.slug,
        })))));
      await tester.pump();
      final fern = tester.getRect(find.byKey(const ValueKey('hearth-fern-bounds')));
      final chair = tester.getRect(find.byKey(const ValueKey('hearth-chair-bounds')));
      final avatar = tester.getRect(find.byKey(const ValueKey('hearth-avatar-bounds')));
      expect(chair.height, greaterThan(avatar.height * .50));
      expect(chair.overlaps(fern), true);
      expect(chair.overlaps(avatar), true);
      expect(chair.bottom, greaterThan(fern.bottom));
      final children = tester.widgetList<Stack>(find.byType(Stack)).firstWhere(
        (s) => s.children.any((c) => c.key == const ValueKey('hearth-chair-bounds'))).children;
      int index(String key) => children.indexWhere((c) => c.key == ValueKey(key));
      expect(index('hearth-bookshelf-bounds'), lessThan(index('hearth-fern-bounds')));
      expect(index('hearth-fern-bounds'), lessThan(index('hearth-chair-bounds')));
      expect(index('hearth-chair-bounds'), lessThan(index('hearth-avatar-bounds')));
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets('Chair fits every spot at phone widths alongside other decor', (tester) async {
    expect(QuestwellEquipmentPolicy.isReady('burgundy-reading-chair','room'), true);
    expect(QuestwellEquipmentPolicy.isReady('burgundy-reading-chair','accessory'), true,
      reason: 'Renderer readiness does not duplicate catalog category rules.');
    for (final width in [320.0, 390.0]) {
      for (final slot in ['left','right','front']) {
        final others = ['left','right','front']..remove(slot);
        await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(width: width,
          child: QuestwellHearthPixelScene(height: 342, equippedSlugs: {
            'room:$slot': QuestwellReadingChair.slug,
            'room:${others[0]}': QuestwellBookshelf.slug,
            'room:${others[1]}': QuestwellFern.slug,
            'neck': 'emerald-scholar-scarf',
          })))));
        await tester.pump();
        expect(find.byType(QuestwellReadingChair), findsOneWidget);
        expect(find.byType(QuestwellBookshelf), findsOneWidget);
        expect(find.byType(QuestwellFern), findsOneWidget);
        final chair = tester.getRect(find.byKey(const ValueKey('hearth-chair-bounds')));
        final scene = tester.getRect(find.byKey(const ValueKey('hearth-room-bounds')));
        expect(chair.left, greaterThan(scene.left));
        expect(chair.right, lessThan(scene.right));
        expect(chair.bottom, lessThan(scene.bottom));
        expect(chair.bottom, greaterThan(scene.top + scene.height * .78));
        final avatar = tester.getRect(find.byKey(const ValueKey('hearth-avatar-bounds')));
        expect(chair.height, greaterThan(avatar.height * .50));
        final facing = tester.widget<Transform>(find.byKey(
          const ValueKey('hearth-burgundy-reading-chair-facing')));
        expect(facing.transform.entry(0, 0), slot == 'right' ? 1 : -1);
        expect(tester.takeException(), isNull);
      }
    }
    await tester.pumpWidget(const MaterialApp(home: QuestwellEquippedAvatar(
      archetype: 'scholar', avatarBodyType: 'female', height: 250,
      equippedSlugs: {'room:right': QuestwellReadingChair.slug})));
    await tester.pump();
    expect(find.byType(QuestwellReadingChair), findsNothing);
  });
}
