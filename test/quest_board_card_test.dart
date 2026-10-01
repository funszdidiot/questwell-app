import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/widgets/questwell_quest_card.dart';
import 'package:project_momentum/preview/quest_board_review.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  testWidgets('Long quest stays usable at narrow width and enlarged text', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var completed = 0;
    await tester.pumpWidget(MaterialApp(home: MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
      child: Scaffold(body: SingleChildScrollView(child: QuestwellQuestCard(
        title: 'Outline the first three steps of your important project',
        effort: 'Hard to Start', xp: 30, coins: 6, favorite: false,
        onFavorite: () {}, onComplete: () => completed++,
      ))),
    )));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Complete quest'));
    expect(completed, 1);
    expect(tester.getSize(find.byType(FilledButton)).height, greaterThanOrEqualTo(48));
  });
  testWidgets('Review completion removes only that quest and updates visit count', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const QuestBoardReviewApp());
    await tester.pump();
    await tester.ensureVisible(find.text('Complete quest').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete quest').first);
    await tester.pump();
    expect(find.text('Send the email you have been putting off'), findsNothing);
    expect(find.text('1 quest finished this visit. Keep your momentum.'), findsOneWidget);
    expect(find.byType(QuestwellQuestCard), findsNWidgets(2));
  });

  testWidgets('Board filters and creation remain usable on a short phone with large text', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MediaQuery(
      data: MediaQueryData(size: Size(320, 568), textScaler: TextScaler.linear(2), disableAnimations: true),
      child: QuestBoardReviewApp()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final low = find.widgetWithText(QuestwellBoardFilter, 'Low Energy');
    await tester.ensureVisible(low); await tester.pumpAndSettle();
    await tester.tap(low); await tester.pumpAndSettle();
    expect(find.text('Clear one small corner of your desk'), findsOneWidget);
    expect(find.text('Send the email you have been putting off'), findsNothing);
    final all = find.widgetWithText(QuestwellBoardFilter, 'All quests');
    await tester.ensureVisible(all); await tester.pumpAndSettle();
    await tester.tap(all); await tester.pumpAndSettle();
    final create = find.text('New quest');
    await tester.dragUntilVisible(create.hitTestable(), find.byType(ListView),
      const Offset(0, 180), maxIteration: 30); await tester.pumpAndSettle();
    await tester.tap(create); await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(TextFormField));
    await tester.enterText(find.byType(TextFormField), 'Take one small step');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Easy')); await tester.pumpAndSettle();
    await tester.tap(find.text('Easy')); await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Post to Quest Board')); await tester.pumpAndSettle();
    await tester.tap(find.text('Post to Quest Board')); await tester.pumpAndSettle();
    await tester.dragUntilVisible(find.text('Take one small step').hitTestable(), find.byType(ListView),
      const Offset(0, -180), maxIteration: 60); await tester.pumpAndSettle();
    expect(find.text('Take one small step'), findsOneWidget);
    expect(find.byType(QuestwellQuestCard), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });
}
