import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_home_sections.dart';
import '../lib/widgets/questwell_home_overview.dart';
import '../lib/widgets/questwell_hearth_material.dart';
import '../lib/widgets/questwell_app_navigation.dart';
import '../lib/preview/home_sections_review.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  for (final width in [320.0, 390.0, 430.0, 1440.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Full Hearth sequence and controls at $width / $scale',
          (tester) async {
        await tester.binding.setSurfaceSize(Size(width, 1000));
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(() => tester.binding.setSurfaceSize(null));
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(const HomeSectionsReviewApp());
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
        final hero = tester.getRect(find.byType(QuestwellHomeHero));
        final status = tester.getRect(find.byType(QuestwellHomeCharacter));
        final quest = tester.getRect(find.byType(QuestwellHearthQuestFrame));
        final campfire =
            tester.getRect(find.byType(QuestwellHomeCampfireControl));
        expect(hero.width, width.clamp(0, 760));
        expect(status.top, greaterThanOrEqualTo(hero.bottom));
        expect(quest.top, greaterThan(status.bottom));
        expect(campfire.top, greaterThan(quest.bottom));
        expect(
            tester.getBottomLeft(find.text('YOUR NEXT WIN')).dy,
            lessThan(tester
                .getTopLeft(find.text('Clear one small corner of your desk.'))
                .dy));
        expect(find.byType(QuestwellAppNavigation), findsOneWidget);
        await tester.ensureVisible(find.text('Complete quest'));
        await tester.tap(find.text('Complete quest'));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('105 / 130 XP'), findsOneWidget);
        expect(find.text('51 coins'), findsOneWidget);
        expect(find.text('Room to breathe.'), findsOneWidget);
        expect(find.widgetWithText(FilledButton, 'Add quest'), findsOneWidget);
        await tester.ensureVisible(find.byType(Switch));
        await tester.tap(find.byType(Switch));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('ONE SMALL WIN'), findsOneWidget);
        expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
        expect(find.byType(Switch).hitTestable(), findsOneWidget,
            reason:
                'Campfire must retain the scrolled content when embers appear');
        await tester.tap(find.byType(Switch));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('YOUR NEXT WIN'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
  for (final empty in [true, false]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
          'Secondary quests and destinations remain reachable ($empty/$scale)',
          (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final opened = <String>[];
        await tester.pumpWidget(MaterialApp(
            home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: Scaffold(
              body: QuestwellHomeCanvas(children: [
            QuestwellHomeFocusLayout(
                nextWin: Text(empty ? 'Empty board' : 'Featured quest'),
                overview: const Text('Your adventurer'),
                campfire: const Text('Campfire control'),
                secondary: const Text('Next reward'),
                remainingQuests: empty
                    ? const []
                    : const [Text('Second quest'), Text('Third quest')],
                emphasizeAddQuest: empty,
                onOpen: opened.add),
          ])),
        )));
        await tester.pumpAndSettle();
        expect(
            tester.getTopLeft(find.text('Your adventurer')).dy,
            lessThan(tester
                .getTopLeft(find.text(empty ? 'Empty board' : 'Featured quest'))
                .dy));
        expect(find.text('Second quest'), findsNothing);
        if (empty) {
          await tester.tap(find.widgetWithText(FilledButton, 'Add quest'));
          expect(opened, ['quests']);
          opened.clear();
        }
        await tester.ensureVisible(find.text('More at the Hearth'));
        await tester.tap(find.text('More at the Hearth'));
        await tester.pumpAndSettle();
        expect(find.text('Next reward'), findsOneWidget);
        if (!empty) {
          expect(find.text('Second quest'), findsOneWidget);
          expect(find.text('Third quest'), findsOneWidget);
        }
        final add = find.widgetWithText(OutlinedButton, 'Add quest');
        await tester.ensureVisible(add);
        await tester.tap(add);
        await tester.ensureVisible(find.text('Start an expedition'));
        await tester.tap(find.text('Start an expedition'));
        expect(opened, ['quests', 'expedition']);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('Compact progress opens customization and exposes exact XP',
      (tester) async {
    var opened = false;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: QuestwellHomeCharacter(
                compact: true,
                archetype: 'scout',
                className: 'Scout',
                level: 3,
                xp: 95,
                coins: 49,
                mastered: false,
                equippedNames: const [],
                collection: const [],
                onCustomize: () => opened = true,
                onMarket: () {}))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scout'));
    expect(opened, isTrue);
    expect(find.text('95 / 130 XP'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
