import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/widgets/questwell_first_journey.dart';
import 'package:project_momentum/widgets/questwell_pixel_art.dart';
import 'package:project_momentum/widgets/questwell_room_picker.dart';
import 'package:project_momentum/widgets/questwell_adventurer_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('trophy rests inside either bookcase and requires its support', (tester) async {
    for (final width in [320.0, 390.0]) {
      for (final shelfSlot in ['left', 'right', 'absent']) {
        await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(width: width,
          child: QuestwellHearthPixelScene(height: 342, equippedSlugs: {
            'room:bookshelf_top': QuestwellFirstJourney.slug,
            if (shelfSlot != 'absent') 'room:$shelfSlot': 'walnut-bookshelf',
          })))));
        await tester.pumpAndSettle();
        expect(find.byType(QuestwellFirstJourney), shelfSlot == 'absent' ? findsNothing : findsOneWidget);
        if (shelfSlot != 'absent') {
          final trophy = tester.getRect(find.byKey(const ValueKey('hearth-trophy-bounds')));
          final shelf = tester.getRect(find.byKey(const ValueKey('hearth-bookshelf-bounds')));
          expect(trophy.left, greaterThan(shelf.left));
          expect(trophy.right, lessThan(shelf.right));
          expect(trophy.bottom, closeTo(shelf.top + shelf.height * .12 + trophy.height * .06, .1));
          final stack = tester.widgetList<Stack>(find.byType(Stack)).firstWhere(
            (s) => s.children.any((c) => c.key == const ValueKey('hearth-trophy-bounds')));
          expect(stack.children.indexWhere((c) => c.key == const ValueKey('hearth-trophy-bounds')),
            lessThan(stack.children.indexWhere((c) => c.key == const ValueKey('hearth-avatar-bounds'))));
        }
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('picker offers mantel without furniture and bookcase only when supported', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final hasShelf in [false, true]) {
      RoomPlacement? result;
      await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) => Scaffold(
        body: TextButton(child: const Text('Open'), onPressed: () async {
          result = await showRoomPicker(context, name: 'First Journey', id: 'trophy',
            slug: QuestwellFirstJourney.slug, archetype: 'wanderer', bodyType: 'neutral',
            equippedSlugs: {if (hasShelf) 'room:right': 'walnut-bookshelf'}, occupants: const {});
        })))));
      await tester.tap(find.text('Open')); await tester.pumpAndSettle();
      expect(find.byType(RadioListTile<String>), findsNWidgets(hasShelf ? 2 : 1));
      expect(find.text('Fireplace mantel · Empty'), findsOneWidget);
      expect(find.text('On the bookcase · Empty'), hasShelf ? findsOneWidget : findsNothing);
      expect(find.byType(QuestwellFirstJourney), findsOneWidget);
      await tester.tap(find.text('Save placement')); await tester.pumpAndSettle();
      expect(result?.slot, hasShelf ? 'bookshelf_top' : 'mantel');
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('milestone dialog handles small screens and both choices', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final place in [false, true]) {
      bool? result;
      await tester.pumpWidget(MaterialApp(theme: ThemeData.dark(),
        builder: (_, child) => MediaQuery(data: const MediaQueryData(textScaler: TextScaler.linear(1.6)), child: child!),
        home: Builder(builder: (context) => Scaffold(body: TextButton(child: const Text('Open'),
          onPressed: () async => result = await showDialog<bool>(context: context,
            builder: (_) => const FirstJourneyUnlockDialog(level: 6, xpAwarded: 200, coinsAwarded: 10)))))));
      await tester.tap(find.text('Open')); await tester.pumpAndSettle();
      expect(find.text('Level 6 reached!'), findsOneWidget);
      final button = find.text(place ? 'Place in Hearth' : 'Keep in inventory');
      await tester.ensureVisible(button); await tester.tap(button); await tester.pumpAndSettle();
      expect(result, place);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('unearned trophy has its own icon and disabled milestone label', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: QuestwellAdventurerView(
      archetype: 'wanderer', bodyType: 'neutral', level: 4, xp: 55, coins: 79,
      description: 'Sample', mastered: false, collectionOwned: 0, collectionTotal: 0,
      relicName: 'Relic', canClaim: false, onClaim: () {}, onBack: () {}, onMarket: () {},
      onBody: (_) {}, onClass: (_) {}, onEquip: (_) {}, onUnequip: (_) {},
      items: const [AdventurerInventoryItem(id: 'trophy', name: 'First Journey',
        slug: QuestwellFirstJourney.slug, category: 'room', description: 'Earned at level 5.',
        owned: false, equipped: false, classLocked: false, shop: false)],
    ))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inventory · 0')); await tester.pumpAndSettle();
    await tester.tap(find.text('All items')); await tester.pumpAndSettle();
    expect(find.byType(QuestwellFirstJourney), findsOneWidget);
    expect(tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Unlocks at level 5')).onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
