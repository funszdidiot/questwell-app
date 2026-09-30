import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_bookshelf.dart';
import '../lib/services/questwell_equipment_policy.dart';
import '../lib/preview/hearth_review.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  testWidgets('Bookshelf is behind the avatar and only uses the room slot', (tester) async {
    expect(QuestwellEquipmentPolicy.isReady('walnut-bookshelf', 'room'), true);
    expect(QuestwellEquipmentPolicy.isReady('walnut-bookshelf', 'accessory'), false);
    for (final width in [320.0, 390.0, 768.0]) {
      for (final placed in [true, false]) {
        await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(width: width,
          child: QuestwellHearthPixelScene(height: 342, equippedSlugs: {
            'accessory': 'moonstone-brooch', 'neck': 'emerald-scholar-scarf',
            if (placed) 'room': 'walnut-bookshelf',
          }),
        ))));
        await tester.pump();
        expect(find.byType(QuestwellBookshelf), placed ? findsOneWidget : findsNothing);
        final avatar = tester.widget<QuestwellLayeredAdventurerArt>(find.byType(QuestwellLayeredAdventurerArt));
        expect(avatar.equippedSlugs['accessory'], 'moonstone-brooch');
        expect(avatar.equippedSlugs['neck'], 'emerald-scholar-scarf');
        if (placed) {
          final stack = tester.widgetList<Stack>(find.byType(Stack)).firstWhere(
            (s) => s.children.any((c) => c.key == const ValueKey('hearth-bookshelf-bounds')));
          expect(stack.children.indexWhere((c) => c.key == const ValueKey('hearth-bookshelf-bounds')),
            lessThan(stack.children.indexWhere((c) => c.key == const ValueKey('hearth-avatar-bounds'))));
          final shelf = tester.getRect(find.byKey(const ValueKey('hearth-bookshelf-bounds')));
          final scene = tester.getRect(find.byKey(const ValueKey('hearth-room-bounds')));
          expect(shelf.left, greaterThan(scene.left));
          expect(shelf.right, lessThan(scene.right));
          expect(shelf.bottom, lessThan(scene.bottom));
        }
        expect(tester.takeException(), isNull);
      }
    }
  });
  testWidgets('Bookshelf preview places and removes the same item', (tester) async {
    await tester.pumpWidget(const HearthReviewApp(bookshelf: true));
    await tester.pump();
    expect(find.byType(QuestwellBookshelf), findsOneWidget);
    await tester.ensureVisible(find.text('Remove from Hearth'));
    await tester.tap(find.text('Remove from Hearth'));
    await tester.pump();
    expect(find.byType(QuestwellBookshelf), findsNothing);
    await tester.tap(find.text('Place in Hearth'));
    await tester.pump();
    expect(find.byType(QuestwellBookshelf), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
