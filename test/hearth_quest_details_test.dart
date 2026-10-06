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
      expect(
        tester.getTopLeft(find.text('Prepare for the meeting')).dy,
        lessThan(tester.getTopLeft(find.text('A small push')).dy),
      );
      expect(find.text('+20 XP'), findsOneWidget);
      expect(find.text('+10 coins'), findsOneWidget);
      await tester.ensureVisible(find.text('Complete quest'));
      await tester.tap(find.text('Complete quest'));
      await tester.pumpAndSettle();
      expect(completions, 1);
      expect(tester.takeException(), isNull);
    });
  }
  for (final featured in [true, false]) {
    for (final completing in [true, false]) {
      testWidgets(
        'Quest action supports large text and pending state ($featured/$completing)',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(320, 700));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          var completions = 0;
          await tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                child: Scaffold(
                  body: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      QuestwellHomeQuestCard(
                        task: TasksRow({
                          'id': 'pinned-quest',
                          'title': 'Prepare a thoughtful plan for tomorrow',
                          'pinned_at': '2026-10-05T12:00:00Z',
                          'notes': 'One small step at a time.',
                          'friction_level': 2,
                          'xp_value': 20,
                          'coin_value': 10,
                        }),
                        frictionLabel: 'A small push',
                        completing: completing,
                        featured: featured,
                        onComplete: () => completions++,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.text('PINNED · NEXT UP'),
            featured ? findsOneWidget : findsNothing,
          );
          final action = find.text(
            completing ? 'Completing…' : 'Complete quest',
          );
          await tester.ensureVisible(action);
          await tester.pumpAndSettle();
          final button = featured
              ? find.byType(FilledButton)
              : find.byType(OutlinedButton);
          expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
          final label = tester.widget<Text>(action);
          expect(label.maxLines, isNull);
          await tester.tap(action);
          await tester.pumpAndSettle();
          expect(completions, completing ? 0 : 1);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
