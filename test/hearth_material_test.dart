import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../lib/widgets/questwell_home_overview.dart';
import '../lib/widgets/questwell_home_sections.dart';

void main() {
  for (final width in [320.0, 390.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Framed Hearth controls remain usable at $width / $scale',
          (tester) async {
        GoogleFonts.config.allowRuntimeFetching = false;
        await tester.binding.setSurfaceSize(Size(width, 1600));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        var active = false;
        final destinations = <String>[];
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData.dark(useMaterial3: true),
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: Scaffold(
              body: StatefulBuilder(builder: (context, setState) {
                return QuestwellHomeCanvas(children: [
                  const QuestwellHomeEmptyBoard(),
                  QuestwellHomeActions(onOpen: destinations.add),
                  QuestwellHomeCharacter(
                    archetype: 'alchemist',
                    className: 'Alchemist',
                    level: 3,
                    xp: 95,
                    coins: 49,
                    mastered: false,
                    equippedNames: const [],
                    collection: const [],
                    onCustomize: () => destinations.add('adventurer'),
                    onMarket: () {},
                  ),
                  QuestwellHomeCampfireControl(
                    active: active,
                    onChanged: (value) => setState(() => active = value),
                  ),
                ]);
              }),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        for (final label in [
          'Add quest',
          'Start an expedition',
          'Customize adventurer'
        ]) {
          await tester.ensureVisible(find.text(label));
          await tester.tap(find.text(label));
          await tester.pumpAndSettle();
        }
        expect(destinations, ['quests', 'expedition', 'adventurer']);
        final button = find.widgetWithText(FilledButton, 'Add quest');
        expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
        await tester.ensureVisible(find.byType(Switch));
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        expect(active, isTrue);
        expect(find.text('One gentle quest. A little warmth.'), findsOneWidget);
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        expect(active, isFalse);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('Campfire remains disabled during a pending account change',
      (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: const Scaffold(
        body: QuestwellHomeCampfireControl(active: false, onChanged: null),
      ),
    ));
    await tester.pumpAndSettle();
    final control = tester.widget<Switch>(find.byType(Switch));
    expect(control.onChanged, isNull);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    expect(tester.takeException(), isNull);
  });
}
