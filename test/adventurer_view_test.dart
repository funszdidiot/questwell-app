import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_adventurer_view.dart';

void main() {
  testWidgets('Appearance, ownership filters and equipment gate work at large text', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.binding.setSurfaceSize(const Size(320, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    String? body;
    var equips = 0;
    var market = 0;
    await tester.pumpWidget(MaterialApp(home: MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
      child: Scaffold(body: QuestwellAdventurerView(archetype: 'scout', bodyType: 'neutral',
        level: 3, xp: 295, coins: 49, description: 'Sample class', mastered: false,
        collectionOwned: 1, collectionTotal: 2, relicName: 'Compass', canClaim: false,
        onClaim: () {}, onBack: () {}, onMarket: () => market++,
        onBody: (v) => body = v, onClass: (_) {}, onEquip: (_) => equips++, onUnequip: (_) {},
        items: const [
          AdventurerInventoryItem(id: 'a', name: 'Owned charm', slug: 'charm', category: 'neck',
            description: 'A keepsake', owned: true, equipped: false, classLocked: false, shop: true),
          AdventurerInventoryItem(id: 'b', name: 'Locked lantern', slug: 'lantern', category: 'room',
            description: 'A light', owned: false, equipped: false, classLocked: false, shop: true),
        ])),
    )));
    await tester.pumpAndSettle();
    for (final title in ['ADVENTURER', 'Scout', 'BODY STYLE', 'YOUR CLASS', 'CLASS MASTERY']) {
      expect(tester.widget<Text>(find.byWidgetPredicate((w) => w is Text && w.data == title && w.style != null)).style?.fontFamily, GoogleFonts.pressStart2p().fontFamily);
    }
    expect(tester.widget<Text>(find.text('Level 3')).style?.fontFamily, GoogleFonts.roboto().fontFamily);
    for (final chip in tester.widgetList<ChoiceChip>(find.byType(ChoiceChip))) {
      expect(chip.labelStyle?.fontFamily, GoogleFonts.roboto().fontFamily);
    }
    await tester.ensureVisible(find.text('Female'));
    await tester.tap(find.text('Female'));
    expect(body, 'female');
    await tester.ensureVisible(find.text('Inventory · 1'));
    await tester.tap(find.text('Inventory · 1'));
    await tester.pumpAndSettle();
    expect(find.text('Owned charm'), findsOneWidget);
    expect(find.text('Locked lantern'), findsNothing);
    final unavailable = find.widgetWithText(OutlinedButton, 'Equip unavailable');
    expect(tester.widget<OutlinedButton>(unavailable).onPressed, isNull);
    expect(equips, 0);
    await tester.tap(find.text('All items'));
    await tester.pumpAndSettle();
    expect(find.text('Locked lantern'), findsOneWidget);
    await tester.ensureVisible(find.text('View in Market'));
    await tester.tap(find.text('View in Market'));
    expect(market, 1);
    await tester.ensureVisible(find.text('Equipped'));
    await tester.tap(find.text('Equipped'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing equipped here yet.'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Nothing equipped here yet.')).style?.fontFamily,
      GoogleFonts.pressStart2p().fontFamily);
    expect(tester.takeException(), isNull);
  });
}
