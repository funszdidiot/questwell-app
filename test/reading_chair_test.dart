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
  testWidgets('Room layout separates fern and chair and clears fireplace', (tester) async {
    for (final width in [320.0,390.0]) {
      await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(width: width,
        child: const QuestwellHearthPixelScene(height: 310, equippedSlugs: {
          'room:left': QuestwellFern.slug, 'room:right': QuestwellBookshelf.slug,
          'room:front': QuestwellReadingChair.slug,
        })))));
      await tester.pump();
      final fern = tester.getRect(find.byKey(const ValueKey('hearth-fern-bounds')));
      final chair = tester.getRect(find.byKey(const ValueKey('hearth-chair-bounds')));
      final scene = tester.getRect(find.byType(QuestwellHearthPixelScene));
      expect(fern.overlaps(chair), false);
      expect(fern.left, greaterThan(scene.left + scene.width * .15));
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets('Chair fits every spot at phone widths alongside other decor', (tester) async {
    expect(QuestwellEquipmentPolicy.isReady('burgundy-reading-chair','room'), true);
    expect(QuestwellEquipmentPolicy.isReady('burgundy-reading-chair','accessory'), false);
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
        final scene = tester.getRect(find.byType(QuestwellHearthPixelScene));
        expect(chair.left, greaterThan(scene.left));
        expect(chair.right, lessThan(scene.right));
        expect(chair.bottom, lessThan(scene.bottom));
        expect(chair.bottom, greaterThan(scene.top + scene.height * .78));
        final fern = tester.getRect(find.byKey(const ValueKey('hearth-fern-bounds')));
        final shelf = tester.getRect(find.byKey(const ValueKey('hearth-bookshelf-bounds')));
        expect(chair.overlaps(fern), false);
        expect(chair.overlaps(shelf), false);
        expect(fern.overlaps(shelf), false);
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
