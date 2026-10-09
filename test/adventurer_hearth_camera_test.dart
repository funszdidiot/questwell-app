import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_adventurer_view.dart';
import '../lib/widgets/questwell_pixel_art.dart';

void main() {
  testWidgets('wide inventory Hearth keeps all wall art within its camera',
      (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: QuestwellAdventurerView(
      archetype: 'wanderer',
      bodyType: 'neutral',
      level: 1,
      xp: 0,
      coins: 0,
      description: '',
      mastered: false,
      collectionOwned: 0,
      collectionTotal: 0,
      relicName: '',
      canClaim: false,
      onClaim: () {},
      onBody: (_) {},
      onClass: (_) {},
      onEquip: (_) {},
      onUnequip: (_) {},
      onMarket: () {},
      onBack: () {},
      items: [
        for (final entry in const {
          'wall_left': 'celestial-study',
          'wall_center': 'moonlit-woodland',
          'wall_right': 'fern-study'
        }.entries)
          AdventurerInventoryItem(
              id: entry.value,
              name: entry.value,
              slug: entry.value,
              category: 'wall_art',
              roomSlot: entry.key,
              description: '',
              owned: true,
              equipped: true,
              classLocked: false,
              shop: false)
      ],
    ))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inventory · 3'));
    await tester.pumpAndSettle();
    final hearthTab = find.widgetWithText(ChoiceChip, 'Hearth');
    await tester.ensureVisible(hearthTab);
    await tester.pumpAndSettle();
    await tester.tap(hearthTab);
    await tester.pumpAndSettle();
    final room =
        tester.getRect(find.byKey(const ValueKey('hearth-room-bounds')));
    expect(room.width, greaterThan(600));
    for (final key in [
      'hearth-wall_left-art-bounds',
      'hearth-wall-art-bounds',
      'hearth-wall_right-art-bounds'
    ]) {
      final art = tester.getRect(find.byKey(ValueKey(key)));
      expect(art.top, greaterThan(room.top));
      expect(art.bottom, lessThan(room.bottom));
    }
    expect(find.byType(QuestwellHearthPixelScene), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
