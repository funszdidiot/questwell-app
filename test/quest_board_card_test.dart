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
}
