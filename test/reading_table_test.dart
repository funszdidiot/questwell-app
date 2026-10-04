import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_hearth_decor.dart';
import '../lib/widgets/questwell_reading_table.dart';
import '../lib/services/questwell_equipment_policy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  testWidgets('Table shares the room with all decor and follows the chair', (tester) async {
    expect(QuestwellEquipmentPolicy.isReady(QuestwellReadingTable.slug, 'room'), true);
    expect(QuestwellEquipmentPolicy.isReady(QuestwellReadingTable.slug, 'hands'), true,
      reason: 'Renderer readiness does not duplicate catalog category rules.');
    expect(QuestwellHearthDecor.choices(QuestwellReadingTable.slug).keys, ['side']);
    for (final width in [320.0,390.0]) {
      for (final chairSlot in ['front','right']) {
        for (final body in ['female','male','neutral']) {
          final equipment = {'room:side': QuestwellReadingTable.slug,
            'room:$chairSlot': 'burgundy-reading-chair',
            'room:left': 'walnut-bookshelf',
            'room:${chairSlot == 'front' ? 'right' : 'front'}': 'hearth-fern'};
          await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(width: width,
            child: QuestwellHearthPixelScene(height: 310, avatarBodyType: body, equippedSlugs: equipment)))));
          await tester.pump();
          final table = tester.getRect(find.byKey(const ValueKey('hearth-table-bounds')));
          final chair = tester.getRect(find.byKey(const ValueKey('hearth-chair-bounds')));
          final scene = tester.getRect(find.byKey(const ValueKey('hearth-room-bounds')));
          expect(table.left, greaterThan(scene.left));
          expect(table.right, lessThan(scene.right));
          expect(table.bottom, lessThan(scene.bottom));
          expect(table.bottom, greaterThan(chair.bottom));
          expect(table.height, greaterThan(chair.height * .60));
          expect(table.center.dx < chair.center.dx, chairSlot == 'front');
          expect(find.byType(QuestwellReadingTable), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      }
    }
    await tester.pumpWidget(const MaterialApp(home: QuestwellEquippedAvatar(
      archetype: 'scholar', avatarBodyType: 'female', height: 250,
      equippedSlugs: {'room:side': QuestwellReadingTable.slug})));
    await tester.pump();
    expect(find.byType(QuestwellReadingTable), findsNothing);
  });
}
