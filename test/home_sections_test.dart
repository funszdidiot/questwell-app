import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../lib/widgets/questwell_home_sections.dart';
import '../lib/preview/home_sections_review.dart';

void main() {
  for (final viewport in [const Size(320, 740), const Size(1440, 1000)]) {
    testWidgets('Composed Hearth scrolls and toggles at $viewport',
        (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      await tester.binding.setSurfaceSize(viewport);
      tester.platformDispatcher.textScaleFactorTestValue =
          viewport.width == 320 ? 2 : 1;
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(const HomeSectionsReviewApp());
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byType(Switch));
      await tester.tap(find.byType(Switch));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('ONE SMALL WIN'), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      await tester.ensureVisible(find.text('Customize adventurer'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('35 XP to level 4'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  for (final width in [320.0, 390.0, 430.0, 1440.0]) {
    testWidgets('Hearth canvas bounds room and content at $width px',
        (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MaterialApp(
          home: Scaffold(
        body: QuestwellHomeCanvas(children: [
          QuestwellHomeRoomFrame(
              child: SizedBox(
                  key: ValueKey('room'), width: double.infinity, height: 342)),
          SizedBox(
              key: ValueKey('content'), width: double.infinity, height: 200),
        ]),
      )));
      final room = tester.getRect(find.byKey(const ValueKey('room')));
      final content = tester.getRect(find.byKey(const ValueKey('content')));
      expect(room.width, width < 680 ? width - 40 : 640);
      expect(content.width, width < 1000 ? width - 40 : 960);
      expect(room.center.dx, closeTo(width / 2, .01));
      expect(content.center.dx, closeTo(width / 2, .01));
      expect(tester.takeException(), isNull);
    });
  }

  for (final scale in [1.0, 2.0]) {
    testWidgets(
        'Wide Hearth respects text size and retains every quest ($scale)',
        (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      await tester.binding.setSurfaceSize(const Size(1440, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final opened = <String>[];
      await tester.pumpWidget(MaterialApp(
          home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Scaffold(
            body: QuestwellHomeCanvas(children: [
          QuestwellHomeFocusLayout(
            nextWin: const Text('Featured quest'),
            overview:
                const SizedBox(height: 220, child: Text('Your adventurer')),
            remainingQuests: const [Text('Second quest'), Text('Third quest')],
            onOpen: opened.add,
          ),
        ])),
      )));
      await tester.pumpAndSettle();
      final featured = tester.getRect(find.text('Featured quest'));
      final overview = tester.getRect(find.text('Your adventurer'));
      if (scale == 1) {
        expect(overview.left, greaterThan(featured.right));
        expect(overview.top, closeTo(featured.top, .01));
      } else {
        expect(
            overview.top,
            greaterThan(
                tester.getBottomLeft(find.text('Start an expedition')).dy));
      }
      expect(tester.getTopLeft(find.text('Second quest')).dy,
          greaterThan(overview.bottom));
      expect(find.text('Third quest'), findsOneWidget);
      await tester.tap(find.text('Add quest'));
      await tester.tap(find.text('Start an expedition'));
      expect(opened, ['quests', 'expedition']);
      expect(tester.takeException(), isNull);
    });
  }

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
                      remainingQuests:
                          empty ? const [] : const [Text('Another quest')],
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
