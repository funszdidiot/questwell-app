import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_home_overview.dart';

void main() {
  testWidgets('Overview supports large text, compact loadout and navigation', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.binding.setSurfaceSize(const Size(320, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var customized = false;
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
          ], onCustomize: () => customized = true, onMarket: () {}),
        QuestwellHomeMomentum(wins: 1, bosses: 0, onOpen: () {}),
        QuestwellHomeCampfireControl(active: true, onChanged: (_) {}),
      ])),
    )));
    await tester.pumpAndSettle();
    for (final heading in ['Scout', '1 win this week', 'Campfire Mode']) {
      expect(tester.widget<Text>(find.text(heading)).style?.fontFamily,
        GoogleFonts.pressStart2p().fontFamily, reason: '$heading must use the approved pixel heading font');
    }
    expect(tester.widget<Text>(find.text('35 XP to level 4')).style?.fontFamily,
      GoogleFonts.roboto().fontFamily);
    expect(find.text('35 XP to level 4'), findsOneWidget);
    expect(find.text('1 worn · 2 room items'), findsOneWidget);
    expect(find.text('Fern Study · Walnut Bookshelf'), findsNothing);
    expect(find.text('View all'), findsNothing);
    expect(find.text('Class collection'), findsNothing);
    expect(find.text('LOADOUT'), findsNothing);
    await tester.tap(find.text('Customize adventurer'));
    expect(customized, isTrue);
    expect(tester.takeException(), isNull);
  });
}
