import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_wall_art.dart';
import '../lib/widgets/questwell_reading_table.dart';
import '../lib/services/questwell_equipment_policy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  testWidgets('Wall art fits the upper wall with all floor furniture', (tester) async {
    expect(QuestwellEquipmentPolicy.isReady(QuestwellWallArt.slug, 'wall_art'), true);
    expect(QuestwellEquipmentPolicy.isReady(QuestwellWallArt.slug, 'room'), true,
      reason: 'Renderer readiness is slug-only; catalog metadata owns the category.');
    for (final width in [320.0, 390.0]) {
      for (final body in ['female', 'male', 'neutral']) {
        await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(width: width,
          child: QuestwellHearthPixelScene(height: 310, avatarBodyType: body,
            equippedSlugs: const {'wall_art': QuestwellWallArt.slug,
              'room:left': 'walnut-bookshelf', 'room:right': 'burgundy-reading-chair',
              'room:front': 'hearth-fern', 'room:side': 'walnut-reading-table'})))));
        await tester.pump();
        final painting = tester.getRect(find.byKey(const ValueKey('hearth-wall-art-bounds')));
        final scene = tester.getRect(find.byKey(const ValueKey('hearth-room-bounds')));
        expect(painting.left, greaterThan(scene.left));
        expect(painting.right, lessThan(scene.right));
        expect(painting.top, greaterThan(scene.top));
        expect(painting.top, greaterThan(scene.top + scene.height * .08));
        expect(painting.bottom, lessThan(scene.top + scene.height * .3));
        expect(find.byType(QuestwellReadingTable), findsOneWidget);
        expect(find.byType(QuestwellWallArt), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
    await tester.pumpWidget(const MaterialApp(home: QuestwellEquippedAvatar(
      archetype: 'scholar', avatarBodyType: 'female', height: 250,
      equippedSlugs: {'wall_art': QuestwellWallArt.slug})));
    await tester.pump();
    expect(find.byType(QuestwellWallArt), findsNothing);
  });
}
