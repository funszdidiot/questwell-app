import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/widgets/questwell_starlit_orrery.dart';
import 'package:project_momentum/widgets/questwell_milestone_reward.dart';
import 'package:project_momentum/widgets/questwell_next_reward.dart';
import 'package:project_momentum/services/questwell_cosmetic_service.dart';
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
            'room:bookshelf_top': QuestwellStarlitOrrery.slug,
            if (shelfSlot != 'absent') 'room:$shelfSlot': 'walnut-bookshelf',
          })))));
        await tester.pumpAndSettle();
        expect(find.byType(QuestwellStarlitOrrery), shelfSlot == 'absent' ? findsNothing : findsOneWidget);
        if (shelfSlot != 'absent') {
          final trophy = tester.getRect(find.byKey(const ValueKey('hearth-orrery-bounds')));
          final shelf = tester.getRect(find.byKey(const ValueKey('hearth-bookshelf-bounds')));
          expect(trophy.left, greaterThan(shelf.left));
          expect(trophy.right, lessThan(shelf.right));
          expect(trophy.bottom, closeTo(shelf.top + shelf.height * .145 + trophy.height * .02, .1));
          final stack = tester.widgetList<Stack>(find.byType(Stack)).firstWhere(
            (s) => s.children.any((c) => c.key == const ValueKey('hearth-orrery-bounds')));
          expect(stack.children.indexWhere((c) => c.key == const ValueKey('hearth-orrery-bounds')),
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
          result = await showRoomPicker(context, name: 'Starlit Orrery', id: 'trophy',
            slug: QuestwellStarlitOrrery.slug, archetype: 'wanderer', bodyType: 'neutral',
            equippedSlugs: {if (hasShelf) 'room:right': 'walnut-bookshelf'}, occupants: const {});
        })))));
      await tester.tap(find.text('Open')); await tester.pumpAndSettle();
      expect(find.byType(RadioListTile<String>), findsNWidgets(hasShelf ? 2 : 1));
      expect(find.text('Fireplace mantel'), findsOneWidget);
      expect(find.text('On the bookcase'), hasShelf ? findsOneWidget : findsNothing);
      expect(find.byType(QuestwellStarlitOrrery), findsOneWidget);
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
            builder: (_) => QuestwellMilestoneUnlockDialog(rewards: QuestwellMilestoneReward.crossed(9, 10), level: 10, xpAwarded: 200, coinsAwarded: 10)))))));
      await tester.tap(find.text('Open')); await tester.pumpAndSettle();
      expect(find.text('Level 10 reached!'), findsOneWidget);
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
      items: const [AdventurerInventoryItem(id: 'trophy', name: 'Starlit Orrery',
        slug: QuestwellStarlitOrrery.slug, category: 'room', description: 'Earned at level 10.', milestoneLevel: 10,
        owned: false, equipped: false, classLocked: false, shop: false)],
    ))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inventory · 0')); await tester.pumpAndSettle();
    await tester.tap(find.text('All items')); await tester.pumpAndSettle();
    expect(find.byType(QuestwellStarlitOrrery), findsOneWidget);
    expect(tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Unlocks at level 10')).onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  test('milestone crossing handles skipped levels without repeat celebrations', () {
    expect(QuestwellMilestoneReward.crossed(4, 4), isEmpty);
    expect(QuestwellMilestoneReward.crossed(4, 5).map((r) => r.level), [5]);
    expect(QuestwellMilestoneReward.crossed(9, 10).map((r) => r.level), [10]);
    expect(QuestwellMilestoneReward.crossed(4, 11).map((r) => r.level), [5, 10]);
    expect(QuestwellMilestoneReward.crossed(10, 11), isEmpty);
  });

  testWidgets('next reward uses the Orrery after owning First Journey', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: QuestwellNextReward(cosmetics: [
      QuestwellCosmetic.fromJson({'slug':'first-journey-trophy','name':'First Journey',
        'unlock_method':'level_milestone','milestone_level':5}, owned:true),
      QuestwellCosmetic.fromJson({'slug':'starlit-orrery','name':'Starlit Orrery',
        'unlock_method':'level_milestone','milestone_level':10}),
    ]))));
    await tester.pumpAndSettle();
    expect(find.text('Next reward · Level 10'), findsOneWidget);
    expect(find.byType(QuestwellStarlitOrrery), findsOneWidget);
  });

  testWidgets('both trophies can share the room on separate surfaces', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox(width:390,
      child: QuestwellHearthPixelScene(height:342, equippedSlugs: {
        'room:left':'walnut-bookshelf', 'room:bookshelf_top':'starlit-orrery',
        'room:mantel':'first-journey-trophy',
      }))));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('hearth-orrery-bounds')), findsOneWidget);
    expect(find.byKey(const ValueKey('hearth-trophy-bounds')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
