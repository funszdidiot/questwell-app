import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/backend/supabase/database/tables/tasks.dart';
import 'package:project_momentum/pages/home_page/home_page_widget.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  for (final featured in [true, false]) {
    testWidgets('Hearth shows saved details on a phone (featured=$featured)', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const notes =
          'Bring the checklist and confirm the room.\nThen review each item with the team before the meeting.';
      var completions = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                QuestwellHomeQuestCard(
                  task: TasksRow({
                    'id': 'quest',
                    'title': 'Prepare for the meeting',
                    'notes': notes,
                    'friction_level': 2,
                    'xp_value': 20,
                    'coin_value': 10,
                  }),
                  frictionLabel: 'A small push',
                  completing: false,
                  featured: featured,
                  onComplete: () => completions++,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(notes), findsOneWidget);
      expect(tester.widget<Text>(find.text(notes)).maxLines, isNull);
      expect(find.text('Prepare for the meeting'), findsOneWidget);
      expect(find.text('+20 XP'), findsOneWidget);
      expect(find.text('+10 coins'), findsOneWidget);
      await tester.ensureVisible(find.text('COMPLETE QUEST'));
      await tester.tap(find.text('COMPLETE QUEST'));
      await tester.pumpAndSettle();
      expect(completions, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
