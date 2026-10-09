import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/preview/boss_review.dart';
import 'package:project_momentum/widgets/questwell_boss_board.dart';

void main() {
  testWidgets('Practice creation retains the typed attack plan',
      (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(const MaterialApp(home: BossReviewApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start a battle'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Seasonal test challenge');
    await tester.enterText(fields.at(1), 'Choose one small task');
    await tester.enterText(fields.at(2), 'Finish the next useful step');
    await tester.tap(find.text('Start battle'));
    await tester.pumpAndSettle();
    expect(find.text('Start a practice battle'), findsNothing);
    final board =
        tester.widget<QuestwellBossBoard>(find.byType(QuestwellBossBoard));
    final created =
        board.battles.singleWhere((b) => b.title == 'Seasonal test challenge');
    expect(created.steps.map((s) => s.title).toList(),
        ['Choose one small task', 'Finish the next useful step']);
    expect(board.initialBattleId, created.id);
    expect(tester.takeException(), isNull);
  });
}
