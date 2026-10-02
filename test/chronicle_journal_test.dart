import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/pages/chronicle_page/chronicle_page_widget.dart';
import 'package:project_momentum/services/questwell_chronicle_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('journal wraps long titles at 320 px with enlarged text and keeps filters usable', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final date = DateTime(2026, 9, 30, 18);
    await tester.pumpWidget(MaterialApp(theme: ThemeData.dark(),
      builder: (_, child) => MediaQuery(data: const MediaQueryData(textScaler: TextScaler.linear(1.6)), child: child!),
      home: ChroniclePageWidget(previewData: ChronicleSnapshot.fromWins([
        ChronicleWin(kind:'quest',title:'Finish the first paragraph of the project that has been difficult to start',
          completedAt:date,xp:20,coins:10),
        ChronicleWin(kind:'milestone_reward',title:'Starlit Orrery',completedAt:date,xp:0,coins:0,
          cosmeticSlug:'starlit-orrery',source:'level_milestone',level:10),
      ],now:date))));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Milestones'));
    await tester.tap(find.text('Milestones')); await tester.pumpAndSettle();
    expect(find.text('Starlit Orrery'), findsOneWidget);
    expect(find.text('+20 XP'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Bosses')); await tester.pumpAndSettle();
    expect(find.text('A victory worth a page.'), findsOneWidget);
    expect(find.byTooltip('Back to the Hearth'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('history after the first 30 entries remains reachable', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final date = DateTime(2026, 9, 30, 18);
    await tester.pumpWidget(MaterialApp(theme:ThemeData.dark(),home:ChroniclePageWidget(
      previewData:ChronicleSnapshot.fromWins(List.generate(31,(i)=>ChronicleWin(
        kind:'quest',title:'Recorded win $i',completedAt:date.subtract(Duration(minutes:i)),xp:10,coins:5)),now:date))));
    await tester.pumpAndSettle();
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Show earlier pages'), 650, scrollable:scrollable, maxScrolls:30);
    await tester.tap(find.text('Show earlier pages')); await tester.pumpAndSettle();
    expect(find.text('Recorded win 30'), findsOneWidget);
    expect(find.text('Show earlier pages'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search finds older titles, combines filters, and clears', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final date = DateTime(2026, 9, 30, 18);
    final wins = [
      for (var i = 0; i < 31; i++)
        ChronicleWin(kind: 'quest', title: 'Recorded win $i',
          completedAt: date.subtract(Duration(minutes: i)), xp: 10, coins: 5),
      ChronicleWin(kind: 'quest', title: 'Send the proposal',
        completedAt: date.subtract(const Duration(days: 5)), xp: 20, coins: 10),
      ChronicleWin(kind: 'boss', title: 'Proposal dragon',
        completedAt: date.subtract(const Duration(days: 6)), xp: 25, coins: 50),
    ];
    await tester.pumpWidget(MaterialApp(theme: ThemeData.dark(),
      home: ChroniclePageWidget(previewData: ChronicleSnapshot.fromWins(wins, now: date))));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  PROPOSAL  ');
    await tester.pumpAndSettle();
    expect(find.text('Send the proposal'), findsOneWidget);
    expect(find.text('Proposal dragon'), findsOneWidget);
    expect(find.text('Recorded win 0'), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Quests'));
    await tester.pumpAndSettle();
    expect(find.text('Send the proposal'), findsOneWidget);
    expect(find.text('Proposal dragon'), findsNothing);
    await tester.enterText(find.byType(TextField), 'no such quest');
    await tester.pumpAndSettle();
    expect(find.text('No matching entries.'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
    expect(find.text('No matching entries.'), findsNothing);
    expect(find.text('Recorded win 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('repeat creates once, preserves history, and offers the board', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final win = ChronicleWin(kind: 'quest', title: 'Repeat a small win',
      completedAt: DateTime(2026, 10, 1), xp: 20, coins: 10);
    final data = ChronicleSnapshot.fromWins([win]);
    final pending = Completer<void>();
    var calls = 0;
    var opened = false;
    await tester.pumpWidget(MaterialApp(theme: ThemeData.dark(), home: ChroniclePageWidget(
      previewData: data,
      onRepeat: (original) { expect(original, same(win)); calls++; return pending.future; },
      onOpenBoard: () => opened = true)));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Do this quest again'));
    await tester.tap(find.text('Do this quest again'));
    await tester.pump();
    await tester.tap(find.text('Adding quest…'));
    expect(calls, 1);
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.text('Added to board'), findsOneWidget);
    expect(find.text('Repeat a small win'), findsOneWidget);
    expect(data.wins, [win]);
    expect(data.totalXpEarned, 20);
    await tester.tap(find.text('View board'));
    await tester.pumpAndSettle();
    expect(opened, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed repeat can retry; bosses cannot repeat as quests', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var calls = 0;
    final date = DateTime(2026, 10, 1);
    await tester.pumpWidget(MaterialApp(theme: ThemeData.dark(), home: ChroniclePageWidget(
      previewData: ChronicleSnapshot.fromWins([
        ChronicleWin(kind: 'quest', title: 'Try again', completedAt: date, xp: 10, coins: 5),
        ChronicleWin(kind: 'boss', title: 'Hydra', completedAt: date, xp: 25, coins: 50),
      ]),
      onRepeat: (_) async { if (++calls == 1) throw StateError('offline'); })));
    await tester.pumpAndSettle();
    expect(find.text('Do this quest again'), findsOneWidget);
    await tester.ensureVisible(find.text('Do this quest again'));
    await tester.tap(find.text('Do this quest again')); await tester.pumpAndSettle();
    expect(find.text('Could not copy this quest. Please try again.'), findsOneWidget);
    expect(find.text('Added to board'), findsNothing);
    await tester.tap(find.text('Do this quest again')); await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('Added to board'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('set aside stays out of rewards and milestones and restores once', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final date = DateTime.now();
    final aside = ChronicleWin(kind: 'set_aside', taskId: 'aside', title: 'A quest for later',
      completedAt: date, xp: 60, coins: 30);
    final data = ChronicleSnapshot.fromWins([
      aside,
      ChronicleWin(kind: 'quest', title: 'A finished quest', completedAt: date, xp: 10, coins: 5),
    ]);
    expect(data.totalXpEarned, 10);
    expect(data.totalCoinsEarned, 5);
    expect(data.weekWins, 1);
    var calls = 0;
    final pending = Completer<void>();
    await tester.pumpWidget(MaterialApp(theme: ThemeData.dark(), home: ChroniclePageWidget(
      previewData: data, onRepeat: (win) { expect(win, same(aside)); calls++; return pending.future; })));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Milestones')); await tester.pumpAndSettle();
    expect(find.text('A quest for later'), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Set aside')); await tester.pumpAndSettle();
    expect(find.text('A quest for later'), findsOneWidget);
    expect(find.text('A finished quest'), findsNothing);
    expect(find.text('+60 XP'), findsNothing);
    await tester.ensureVisible(find.text('Restore to board'));
    await tester.tap(find.text('Restore to board')); await tester.pump();
    await tester.tap(find.text('Restoring…'));
    expect(calls, 1);
    pending.complete(); await tester.pumpAndSettle();
    expect(find.text('Quest restored to your board.'), findsOneWidget);
    expect(find.text('A quest for later'), findsNothing);
    expect(data.totalXpEarned, 10);
    expect(tester.takeException(), isNull);
  });
}
