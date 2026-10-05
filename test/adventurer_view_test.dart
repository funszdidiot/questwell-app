import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/widgets/questwell_adventurer_view.dart';
import 'inventory_icon_test.dart' show inventoryIconTests;
import 'package:project_momentum/widgets/questwell_class_emblem.dart';
import 'package:go_router/go_router.dart';
import 'package:project_momentum/flutter_flow/nav/nav.dart' show NavigationExtensions;
import 'package:project_momentum/preview/adventurer_review.dart';
import 'package:project_momentum/preview/mobile_review.dart';
import 'package:project_momentum/preview/review_loadout.dart';
import 'package:project_momentum/widgets/questwell_app_navigation.dart';
import 'package:project_momentum/widgets/questwell_scout_wardrobe.dart';
import 'package:project_momentum/widgets/questwell_pixel_art.dart';
import 'package:project_momentum/widgets/questwell_brass_lantern.dart';
import 'package:project_momentum/widgets/questwell_bookshelf.dart';
import 'package:project_momentum/widgets/questwell_wall_art.dart';
import 'package:project_momentum/widgets/questwell_moonstone_brooch.dart';

void main() {
  inventoryIconTests();
  test('preview body switching removes unsupported equipment and retains its sample catalog', () {
    final loadout = QuestwellReviewLoadout()
      ..otherEquipped.addAll({'everyday', 'h'});
    loadout.setBody('neutral');
    expect(loadout.equipment['chest'], 'everyday-adventurer-outfit');
    loadout.setBody('male');
    expect(loadout.body, 'male');
    expect(loadout.equipment['chest'], 'everyday-adventurer-outfit');
    loadout.setBody('female');
    loadout.otherEquipped..remove('everyday')..add('suit');
    loadout.setBody('male');
    expect(loadout.equipment['chest'], 'starter-business-suit',
        reason: 'The legacy suit stays available but now renders on locked male v3');
    expect(loadout.equipment['head'], 'tiny-wizard-hat');
    expect(QuestwellReviewLoadout.catalog['everyday']?.$2, 'everyday-adventurer-outfit');
    loadout.setBody('female');
    expect(loadout.equipment['chest'], 'starter-business-suit',
        reason: 'Supported legacy equipment remains equipped across body changes');
  });
  testWidgets('approved female Everyday carries in-memory equipment across Hearth and re-entry without changing body', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.binding.setSurfaceSize(const Size(1000, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MediaQuery(
      data: MediaQueryData(size: Size(1000, 1000), disableAnimations: true),
      child: MobileReviewApp(initialScreen: 'Adventurer'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Sample content · Changes stay in this preview'), findsOneWidget);
    final lockedBody = find.byWidgetPredicate((widget) => widget is Image &&
        widget.image is AssetImage && (widget.image as AssetImage).assetName ==
            QuestwellScoutWardrobeFoundation.femaleBaseAsset);
    expect(lockedBody, findsOneWidget);

    Future<void> inventory() async {
      final view = tester.widget<QuestwellAdventurerView>(find.byType(QuestwellAdventurerView));
      final owned = view.items.where((item) => item.owned).length;
      final tab = find.text('Inventory · $owned');
      await tester.ensureVisible(tab);
      await tester.tap(tab);
      await tester.pumpAndSettle();
    }

    Future<void> open(QuestwellDestination destination) async {
      Finder tab(String label) => find.descendant(of: find.byType(QuestwellAppNavigation),
          matching: find.widgetWithText(TextButton, label));
      if (destination == QuestwellDestination.hearth) {
        await tester.tap(tab('Hearth'));
      } else {
        await tester.tap(tab('Explore'));
        await tester.pumpAndSettle();
        final target = find.widgetWithText(ListTile, destination.label);
        await tester.ensureVisible(target);
        await tester.tap(target);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(lockedBody, findsOneWidget,
          reason: 'Navigation and clothing cannot select another foundation');
    }

    await inventory();
    final everyday = find.byKey(const ValueKey('inventory-everyday'));
    final equip = find.descendant(of: everyday,
        matching: find.widgetWithText(OutlinedButton, 'Equip'));
    await tester.dragUntilVisible(equip.hitTestable(), find.byType(ListView),
        const Offset(0, -200), maxIteration: 40);
    await tester.tap(equip);
    await tester.pumpAndSettle();
    await open(QuestwellDestination.hearth);
    var hearth = tester.widget<QuestwellHearthPixelScene>(find.byType(QuestwellHearthPixelScene));
    expect(hearth.avatarBodyType, 'female');
    expect(hearth.equippedSlugs['chest'], 'everyday-adventurer-outfit');
    await open(QuestwellDestination.adventurer);
    var restored = tester.widget<QuestwellAdventurerView>(find.byType(QuestwellAdventurerView));
    expect(restored.items.singleWhere((item) => item.id == 'everyday').equipped, isTrue);

    await inventory();
    final remove = find.descendant(of: everyday,
        matching: find.widgetWithText(OutlinedButton, 'Wear Alchemist outfit'));
    await tester.dragUntilVisible(remove.hitTestable(), find.byType(ListView),
        const Offset(0, -200), maxIteration: 40);
    await tester.tap(remove);
    await tester.pumpAndSettle();
    await open(QuestwellDestination.hearth);
    hearth = tester.widget<QuestwellHearthPixelScene>(find.byType(QuestwellHearthPixelScene));
    expect(hearth.avatarBodyType, 'female');
    expect(hearth.equippedSlugs['chest'], isNull);
    await open(QuestwellDestination.adventurer);
    restored = tester.widget<QuestwellAdventurerView>(find.byType(QuestwellAdventurerView));
    expect(restored.items.singleWhere((item) => item.id == 'everyday').equipped, isFalse);
    // One preview session only; server/refresh persistence needs authenticated RPC QA.
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('inventory exposes approved outfit fits and preserves body and class gates', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.binding.setSurfaceSize(const Size(390, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final scenario in [
      (body: 'male', slug: 'everyday-adventurer-outfit', classLocked: false, label: 'Equip'),
      for (final slug in ['starter-business-suit', 'midnight-harvest-coat', 'moss-green-cloak', 'hearthguard-mantle'])
        (body: 'male', slug: slug, classLocked: false, label: 'Equip'),
      (body: 'neutral', slug: 'everyday-adventurer-outfit', classLocked: false, label: 'Equip'),
      (body: 'neutral', slug: 'woodland-scout-outfit', classLocked: false, label: 'Equip'),
      (body: 'male', slug: 'woodland-scout-outfit', classLocked: false, label: 'Equip'),
      (body: 'female', slug: 'woodland-scout-outfit', classLocked: true, label: 'Class restricted'),
      (body: 'male', slug: 'woodland-scout-outfit', classLocked: true, label: 'Class restricted'),
    ]) {
      await tester.pumpWidget(const SizedBox.shrink());
      String? equipped;
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: QuestwellAdventurerView(
        archetype: scenario.classLocked ? 'scholar' : 'scout', bodyType: scenario.body,
        level: 3, xp: 295, coins: 49, description: 'Outfit eligibility', mastered: false,
        collectionOwned: 0, collectionTotal: 1, relicName: 'Relic', canClaim: false,
        onClaim: () {}, onBack: () {}, onBody: (_) {}, onClass: (_) {}, onMarket: () {},
        onEquip: (id) => equipped = id, onUnequip: (_) {},
        items: [AdventurerInventoryItem(id: 'outfit', name: 'Outfit', slug: scenario.slug,
          category: 'chest', description: '', owned: true, equipped: false,
          classLocked: scenario.classLocked, archetype: 'scout', shop: true)],
      ))));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inventory · 1'));
      await tester.pumpAndSettle();
      final action = find.widgetWithText(OutlinedButton, scenario.label);
      await tester.ensureVisible(action);
      expect(tester.widget<OutlinedButton>(action).onPressed != null, scenario.label == 'Equip');
      if (scenario.label == 'Equip') {
        await tester.tap(action);
        expect(equipped, 'outfit');
      } else {
        expect(equipped, isNull);
      }
      expect(tester.takeException(), isNull);
    }
  });
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
    await tester.tap(find.text('Inventory · 15'));
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
    if (gear.type == QuestwellBookshelf || gear.type == QuestwellWallArt) {
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
    expect(find.text('Inventory · 15'), findsOneWidget);
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
