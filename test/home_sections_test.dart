import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../lib/widgets/questwell_home_sections.dart';

void main() {
  testWidgets(
    'Home actions remain readable and route correctly on narrow screens',
    (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      await tester.binding.setSurfaceSize(const Size(320, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      String? destination;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
            child: Scaffold(
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const QuestwellHomeEmptyBoard(),
                  QuestwellHomeActions(onOpen: (value) => destination = value),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Add quest'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('Room to breathe.')).style?.fontFamily,
        GoogleFonts.pressStart2p().fontFamily,
      );
      for (final entry in {
        'Add quest': 'quests',
        'Start an expedition': 'expedition',
      }.entries) {
        await tester.ensureVisible(find.text(entry.key));
        await tester.pumpAndSettle();
        await tester.tap(find.text(entry.key));
        expect(destination, entry.value);
      }
    },
  );
  for (final empty in [true, false]) {
    testWidgets(
      'Featured action precedes overview and remaining quests (empty=$empty)',
      (tester) async {
        GoogleFonts.config.allowRuntimeFetching = false;
        await tester.binding.setSurfaceSize(const Size(320, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final opened = <String>[];
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: Scaffold(
                body: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    QuestwellHomeFocusLayout(
                      nextWin: Text(empty ? 'Empty board' : 'Featured quest'),
                      overview: const Text('Character overview'),
                      remainingQuests: empty
                          ? const []
                          : const [Text('Another quest')],
                      emphasizeAddQuest: empty,
                      onOpen: opened.add,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final next = find.text(empty ? 'Empty board' : 'Featured quest');
        final overview = find.text('Character overview');
        expect(
          tester.getTopLeft(next).dy,
          lessThan(tester.getTopLeft(find.text('Add quest')).dy),
        );
        expect(
          tester.getTopLeft(find.text('Start an expedition')).dy,
          lessThan(tester.getTopLeft(overview).dy),
        );
        if (!empty) {
          expect(
            tester.getTopLeft(overview).dy,
            lessThan(tester.getTopLeft(find.text('Another quest')).dy),
          );
        }
        expect(
          find.byType(FilledButton),
          empty ? findsOneWidget : findsNothing,
        );
        expect(
          find.byType(OutlinedButton),
          empty ? findsNothing : findsOneWidget,
        );
        await tester.tap(find.text('Add quest'));
        await tester.tap(find.text('Start an expedition'));
        expect(opened, ['quests', 'expedition']);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
