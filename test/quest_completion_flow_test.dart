import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/backend/supabase/supabase.dart';
import 'package:project_momentum/pages/home_page/home_page_widget.dart';
import 'package:project_momentum/services/questwell_chronicle_service.dart';
import 'package:project_momentum/services/questwell_cosmetic_models.dart';
import 'package:project_momentum/services/questwell_task_service.dart';
import 'package:project_momentum/widgets/questwell_quest_completion.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  testWidgets(
      'Hearth celebrates the server result once and preserves the completed quest title',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var writes = 0;
    await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!),
        home: HomePageWidget(
          loadAppearance: () async => QuestwellCosmeticsSnapshot(
              profile: QuestwellProfile.fromJson({
                'onboarding_completed': true,
                'total_xp': 100,
                'level_xp_offset': 215
              }),
              cosmetics: const []),
          loadMomentum: () async => const ChronicleSnapshot(
              wins: [],
              totalXpEarned: 0,
              totalCoinsEarned: 0,
              weekWins: 0,
              bossesDefeated: 0),
          loadTasks: () async => writes > 0
              ? []
              : [
                  TasksRow({
                    'id': 'task',
                    'title': 'Make room for what matters',
                    'status': 'open',
                    'friction_level': 1,
                    'xp_value': 999,
                    'coin_value': 999,
                    'created_at': '2026-01-01T00:00:00Z'
                  })
                ],
          completeTask: (id) async {
            expect(id, 'task');
            writes++;
            return const QuestwellTaskCompletionResult(
                taskId: 'task',
                xpAwarded: 17,
                coinsAwarded: 3,
                totalXp: 117,
                coinBalance: 53);
          },
        )));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Complete quest'));
    await tester.tap(find.text('Complete quest'));
    await tester.pumpAndSettle();
    final dialog = find.byType(QuestwellQuestCompletionDialog);
    expect(dialog, findsOneWidget);
    expect(tester.widget<QuestwellQuestCompletionDialog>(dialog).level, 3);
    expect(
        find.descendant(
            of: dialog, matching: find.text('Make room for what matters')),
        findsOneWidget);
    expect(find.text('+17 XP'), findsOneWidget);
    expect(find.text('+3 coins'), findsOneWidget);
    expect(find.text('+999 XP'), findsNothing);
    await tester.ensureVisible(find.text('Keep Going'));
    await tester.tap(find.text('Keep Going'));
    await tester.pumpAndSettle();
    expect(dialog, findsNothing);
    expect(writes, 1);
    expect(find.text('Complete quest'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final appearanceFails in [false, true]) {
    for (final rejectFirst in [false, true]) {
      testWidgets(
        'Hearth completes with appearance ${appearanceFails ? 'failed' : 'pending'}; retry=$rejectFirst',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1000, 1500));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final appearance = Completer<QuestwellCosmeticsSnapshot>();
          var reply = Completer<QuestwellTaskCompletionResult>();
          var writes = 0;
          var committed = false;
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData.dark(),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              ),
              home: HomePageWidget(
                loadAppearance: () async {
                  if (appearanceFails)
                    throw StateError('private appearance error');
                  return appearance.future;
                },
                loadMomentum: () async => const ChronicleSnapshot(
                  wins: [],
                  totalXpEarned: 0,
                  totalCoinsEarned: 0,
                  weekWins: 0,
                  bossesDefeated: 0,
                ),
                loadTasks: () async => committed
                    ? []
                    : [
                        TasksRow({
                          'id': 'task',
                          'title': 'Review draft',
                          'status': 'open',
                          'friction_level': 1,
                          'xp_value': 999,
                          'coin_value': 999,
                          'created_at': '2026-01-01T00:00:00Z',
                        }),
                      ],
                completeTask: (id) {
                  expect(id, 'task');
                  writes++;
                  return reply.future;
                },
              ),
            ),
          );
          // A permanently pending appearance intentionally keeps a spinner alive.
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));
          final action = find.text('Complete quest');
          await tester.ensureVisible(action);
          await tester.tap(action);
          await tester.tap(action);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));
          expect(writes, 1);
          expect(find.textContaining('Quest complete.'), findsNothing);
          expect(find.byType(QuestwellQuestCompletionDialog), findsNothing);

          if (rejectFirst) {
            reply.completeError(StateError('private completion error'));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 200));
            expect(
              find.textContaining('Completion was not confirmed.'),
              findsOneWidget,
            );
            expect(find.textContaining('Quest complete.'), findsNothing);
            expect(find.byType(QuestwellQuestCompletionDialog), findsNothing);
            expect(writes, 1); // Reconciliation must not retry the write.
            expect(action, findsOneWidget);
            // Let the warning expire, then explicitly retry the still-open task.
            await tester.pump(const Duration(seconds: 5));
            await tester.pump(const Duration(milliseconds: 300));
            reply = Completer<QuestwellTaskCompletionResult>();
            await tester.ensureVisible(action);
            await tester.tap(action);
            await tester.pump();
            expect(writes, 2);
          }

          committed = true;
          reply.complete(
            const QuestwellTaskCompletionResult(
              taskId: 'task',
              xpAwarded: 17,
              coinsAwarded: 3,
              totalXp: 117,
              coinBalance: 53,
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
          expect(
            find.text('Quest complete. +17 XP · +3 coins.'),
            findsOneWidget,
          );
          expect(find.byType(QuestwellQuestCompletionDialog), findsNothing);
          expect(action, findsNothing);
          expect(find.textContaining('private'), findsNothing);
          expect(writes, rejectFirst ? 2 : 1);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }
}
