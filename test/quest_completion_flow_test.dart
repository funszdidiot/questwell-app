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
              profile: QuestwellProfile.fromJson(
                  {'onboarding_completed': true, 'total_xp': 100}),
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
}
