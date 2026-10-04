import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_adventurer_view.dart';
import 'inventory_icon_test.dart' show inventoryIconTests;
import '../lib/widgets/questwell_class_emblem.dart';
import 'package:go_router/go_router.dart';
import 'package:project_momentum/flutter_flow/nav/nav.dart' show NavigationExtensions;
import '../lib/preview/adventurer_review.dart';
import '../lib/widgets/questwell_brass_lantern.dart';
import '../lib/widgets/questwell_bookshelf.dart';
import '../lib/widgets/questwell_wall_art.dart';
import '../lib/widgets/questwell_moonstone_brooch.dart';

void main() {
  inventoryIconTests();
  for (final gear in [
    (id: 'painting', name: 'Moonlit Woodland', category: 'Wall art', group: 'Hearth', type: QuestwellWallArt),
    (id: 'b', name: 'Brass Lantern', category: 'Hands', group: 'Gear', type: QuestwellBrassLantern),
    (id: 'm', name: 'Moonstone Brooch', category: 'Accessory', group: 'Gear', type: QuestwellMoonstoneBrooch),
    (id: 'bookshelf', name: 'Walnut Bookshelf', category: 'Hearth décor', group: 'Hearth', type: QuestwellBookshelf),
  ]) {
  testWidgets('${gear.name} inventory toggles the illustrated avatar and retains ownership', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.binding.setSurfaceSize(const Size(430, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const AdventurerReviewApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inventory · 14'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.widgetWithText(ChoiceChip, gear.group));
    await tester.tap(find.widgetWithText(ChoiceChip, gear.group));
    await tester.pumpAndSettle();
    expect(find.text(gear.name), findsOneWidget);
    expect(find.byType(gear.type), findsNothing);
    final action = find.widgetWithText(OutlinedButton, gear.type == QuestwellBookshelf ? 'Place in Hearth' : gear.type == QuestwellWallArt ? 'Hang in Hearth' : 'Equip');
    final itemRow = find.byKey(ValueKey('inventory-${gear.id}'));
    final equipButton = find.descendant(of: itemRow, matching: action);
    await tester.ensureVisible(equipButton);
    await tester.tap(equipButton);
    await tester.pumpAndSettle();
    if (gear.type == QuestwellBookshelf) {
      await tester.tap(find.text('Save placement'));
      await tester.pumpAndSettle();
    }
    expect(find.byType(gear.type), findsOneWidget);
    expect(find.text('${gear.type == QuestwellBookshelf ? 'Placed' : gear.type == QuestwellWallArt ? 'Hung' : 'Equipped'} · ${gear.category}'), findsOneWidget);
    final remove = find.descendant(of: itemRow, matching: find.widgetWithText(OutlinedButton,
      (gear.type == QuestwellBookshelf || gear.type == QuestwellWallArt) ? 'Remove from Hearth' : 'Unequip'));
    await tester.ensureVisible(remove);
    await tester.tap(remove);
    await tester.pumpAndSettle();
    expect(find.byType(gear.type), findsNothing);
    expect(find.descendant(of: itemRow, matching: find.text('Owned · ${gear.category}')), findsOneWidget);
    expect(find.text('Inventory · 14'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  }
  for (final directEntry in [true, false]) {
    testWidgets('Adventurer back returns to Hearth (direct entry: $directEntry)', (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      final router = GoRouter(
        initialLocation: directEntry ? '/adventurer' : '/',
        routes: [
          GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('Hearth destination'))),
          GoRoute(path: '/adventurer', builder: (context, state) => Scaffold(
            body: QuestwellAdventurerView(
              archetype: 'scout', bodyType: 'neutral', level: 3, xp: 295, coins: 49,
              description: 'Navigation test', mastered: false, collectionOwned: 0,
              collectionTotal: 0, relicName: 'Compass', canClaim: false,
              onClaim: () {}, onBack: () => context.safePop(), onMarket: () {},
              onBody: (_) {}, onClass: (_) {}, onEquip: (_) {}, onUnequip: (_) {},
              items: const [],
            ),
          )),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      if (!directEntry) {
        router.push('/adventurer');
        await tester.pumpAndSettle();
      }
      expect(router.canPop(), !directEntry);
      await tester.tap(find.byTooltip('Back to the Hearth'));
      await tester.pumpAndSettle();
      expect(find.text('Hearth destination'), findsOneWidget);
      expect(find.byType(QuestwellAdventurerView), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
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
    for (final title in ['ADVENTURER', 'Scout', 'CLASS MASTERY']) {
      expect(tester.widget<Text>(find.byWidgetPredicate((w) => w is Text && w.data == title && w.style != null)).style?.fontFamily, GoogleFonts.pressStart2p().fontFamily);
    }
    expect(tester.widget<Text>(find.text('Level 3')).style?.fontFamily,
      GoogleFonts.roboto(fontWeight: FontWeight.w700).fontFamily);
    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Edit Adventurer'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Edit Adventurer'));
    await tester.pumpAndSettle();
    expect(find.text('EDIT ADVENTURER'), findsOneWidget);
    expect(find.text('Body style'), findsOneWidget);
    expect(find.text('Class'), findsOneWidget);
    expect(find.byType(QuestwellClassEmblem), findsNWidgets(5));
    for (final label in ['Scholar', 'Scout', 'Alchemist', 'Guardian', 'Wanderer']) {
      final chip = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, label));
      expect(chip.onSelected, isNotNull);
      expect(chip.selected, label == 'Scout');
    }
    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Female'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Female'));
    expect(body, 'female');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Done'));
    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pumpAndSettle();
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
    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Equipped').last);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Equipped').last);
    await tester.pumpAndSettle();
    expect(find.text('No items match this view.'), findsOneWidget);
    expect(tester.widget<Text>(find.text('No items match this view.')).style?.fontFamily,
      GoogleFonts.roboto().fontFamily);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Approved accessories honor ownership, class locks, busy saves and unequip', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.binding.setSurfaceSize(const Size(390, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final gear in [(slug: 'round-scholar-glasses', category: 'face'), (slug: 'tiny-wizard-hat', category: 'head'), (slug: 'emerald-scholar-scarf', category: 'neck'), (slug: 'leather-satchel', category: 'back'), (slug: 'brass-lantern', category: 'hands'), (slug: 'moonstone-brooch', category: 'accessory')]) {
    for (final scenario in [
      (owned: true, equipped: false, locked: false, busy: false, label: 'Equip', enabled: true),
      (owned: false, equipped: false, locked: false, busy: false, label: 'View in Market', enabled: true),
      (owned: true, equipped: false, locked: true, busy: false, label: 'Class restricted', enabled: false),
      (owned: true, equipped: false, locked: false, busy: true, label: 'Saving…', enabled: false),
      (owned: true, equipped: true, locked: true, busy: false, label: 'Unequip', enabled: true),
    ]) {
      await tester.pumpWidget(const SizedBox.shrink());
      String? action;
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: QuestwellAdventurerView(
        archetype: 'scholar', bodyType: 'female', level: 3, xp: 295, coins: 49,
        description: 'Sample', mastered: false, collectionOwned: 0, collectionTotal: 1,
        relicName: 'Relic', canClaim: false, onClaim: () {}, onBack: () {},
        onBody: (_) {}, onClass: (_) {}, onMarket: () => action = 'market',
        onEquip: (id) => action = 'equip:$id', onUnequip: (id) => action = 'unequip:$id',
        busyItem: scenario.busy ? 'glasses' : null,
        items: [AdventurerInventoryItem(id: 'glasses', name: 'Round Scholar Glasses',
          slug: gear.slug, category: gear.category, description: 'Approved accessory',
          owned: scenario.owned, equipped: scenario.equipped,
          classLocked: scenario.locked, archetype: 'scholar', shop: true)],
      ))));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inventory · ${scenario.owned ? 1 : 0}'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All items'));
      await tester.pumpAndSettle();
      final button = find.widgetWithText(OutlinedButton, scenario.label);
      await tester.ensureVisible(button);
      expect(tester.widget<OutlinedButton>(button).onPressed != null, scenario.enabled);
      if (scenario.enabled) {
        await tester.tap(button);
        expect(action, scenario.equipped ? 'unequip:glasses' : scenario.owned ? 'equip:glasses' : 'market');
      } else {
        expect(action, isNull);
      }
      expect(tester.takeException(), isNull);
    }
    }
  });

}
