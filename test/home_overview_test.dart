import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_home_overview.dart';

void main() {
  testWidgets('Overview supports large text, collection states and navigation', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.binding.setSurfaceSize(const Size(320, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var customized = false;
    var market = false;
    await tester.pumpWidget(MaterialApp(home: MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
      child: Scaffold(body: ListView(padding: const EdgeInsets.all(16), children: [
        QuestwellHomeCharacter(archetype: 'scout', className: 'Scout', level: 3,
          xp: 95, coins: 49, mastered: true, equippedNames: const ['Trail charm'], decorNames: const ['Fern Study', 'Walnut Bookshelf'],
          collection: const [
            HomeCollectionItem(name: 'Trail charm', slug: 'charm', category: 'accessory',
              owned: true, equipped: true),
            HomeCollectionItem(name: 'A long name for a woodland cloak', slug: 'cloak', category: 'outfit',
              owned: false, equipped: false),
            HomeCollectionItem(name: 'Travel pack', slug: 'pack', category: 'accessory',
              owned: true, equipped: false),
          ], onCustomize: () => customized = true, onMarket: () => market = true),
        QuestwellHomeMomentum(wins: 1, bosses: 0, onOpen: () {}),
        QuestwellHomeCampfireControl(active: true, onChanged: (_) {}),
      ])),
    )));
    await tester.pumpAndSettle();
    for (final heading in ['Scout', 'LOADOUT', 'Class collection', '1 win this week', 'Campfire Mode']) {
      expect(tester.widget<Text>(find.text(heading)).style?.fontFamily,
        GoogleFonts.pressStart2p().fontFamily, reason: '$heading must use the approved pixel heading font');
    }
    expect(tester.widget<Text>(find.text('5 XP to level 4')).style?.fontFamily,
      GoogleFonts.roboto().fontFamily);
    expect(find.text('5 XP to level 4'), findsOneWidget);
    expect(find.text('1 worn · 2 room items'), findsOneWidget);
    expect(find.text('Fern Study · Walnut Bookshelf'), findsNothing);
    await tester.tap(find.text('View all'));
    await tester.pumpAndSettle();
    expect(find.text('WORN EQUIPMENT'), findsOneWidget);
    expect(find.text('ROOM DÉCOR'), findsOneWidget);
    expect(find.text('Fern Study · Walnut Bookshelf'), findsOneWidget);
    await tester.tap(find.text('View all'));
    await tester.pumpAndSettle();
    expect(find.text('1 win this week'), findsOneWidget);
    await tester.tap(find.text('Customize adventurer'));
    expect(customized, isTrue);
    await tester.tap(find.text('Class collection'));
    await tester.pumpAndSettle();
    expect(find.text('Equipped'), findsOneWidget);
    expect(find.text('Owned'), findsOneWidget);
    expect(find.text('Locked · Available in Market'), findsOneWidget);
    await tester.ensureVisible(find.text('Browse Market'));
    await tester.tap(find.text('Browse Market'));
    expect(market, isTrue);
    expect(tester.takeException(), isNull);
  });
}
