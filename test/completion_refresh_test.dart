import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/backend/supabase/supabase.dart';
import 'package:project_momentum/pages/home_page/home_page_widget.dart';
import 'package:project_momentum/pages/boss_battles_page/boss_battles_page_widget.dart';
import 'package:project_momentum/services/questwell_boss_service.dart';
import 'package:project_momentum/services/questwell_chronicle_service.dart';
import 'package:project_momentum/services/questwell_cosmetic_service.dart';
import 'package:project_momentum/services/questwell_reward_response.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  const appearance = QuestwellCosmeticsSnapshot(
    profile: QuestwellProfile(
      level: 1,
      totalXp: 0,
      coinBalance: 0,
      currentEnergyMode: 'normal',
      onboardingCompleted: true,
      adventurerArchetype: 'scholar',
      avatarBodyType: 'female',
    ),
    cosmetics: [],
  );
  const momentum = ChronicleSnapshot(
    wins: [],
    totalXpEarned: 0,
    totalCoinsEarned: 0,
    weekWins: 0,
    bossesDefeated: 0,
  );
  for (final boss in [false, true]) {
    for (final refreshMode in [
      'success',
      'failure',
      'pending',
      if (!boss) ...[
        'momentum failure',
        'appearance failure',
        'appearance pending'
      ]
    ]) {
      final refreshFails = refreshMode == 'failure';
      testWidgets(
          '${boss ? 'Boss' : 'Home'} reconciles an unconfirmed completion; refresh=$refreshMode',
          (tester) async {
        await tester.binding.setSurfaceSize(const Size(1000, 1500));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final pending = Completer<void>();
        var committed = false;
        var writes = 0;
        var postWriteReads = 0;
        var postWriteProfiles = 0;
        Future<QuestwellCosmeticsSnapshot> loadAppearance() async {
          if (committed) postWriteProfiles++;
          if (refreshMode == 'appearance failure') {
            throw StateError('private appearance details');
          }
          if (refreshMode == 'appearance pending') await pending.future;
          return appearance;
        }

        void read() {
          if (!committed) return;
          postWriteReads++;
          if (refreshFails) throw StateError('private refresh details');
        }

        final Widget page = boss
            ? BossBattlesPageWidget(
                loadAppearance: loadAppearance,
                currentOwner: () => 'owner',
                loadBattles: () async {
                  read();
                  if (committed && refreshMode == 'pending')
                    await pending.future;
                  return [
                    QuestwellBossBattle(
                      id: 'battle',
                      title: 'Finish the report',
                      status: committed ? 'completed' : 'open',
                      rewardXp: 25,
                      rewardCoins: 50,
                      bossType: 'inbox_hydra',
                      steps: [
                        QuestwellBossStep(
                            id: 'step',
                            title: 'Review draft',
                            position: 0,
                            completed: committed)
                      ],
                    )
                  ];
                },
                completeStep: (_) async {
                  writes++;
                  committed = true;
                  QuestwellRewardResponse.singleRow([{}]);
                  QuestwellRewardResponse.integer({}, 'xp_awarded');
                  throw StateError('unreachable');
                },
              )
            : HomePageWidget(
                loadAppearance: loadAppearance,
                loadMomentum: () async {
                  if (committed && refreshMode == 'momentum failure') {
                    throw StateError('private momentum details');
                  }
                  return momentum;
                },
                loadTasks: () async {
                  read();
                  if (committed && refreshMode == 'pending')
                    await pending.future;
                  return committed
                      ? []
                      : [
                          TasksRow({
                            'id': 'task',
                            'title': 'Review draft',
                            'status': 'open',
                            'friction_level': 1,
                            'created_at': '2026-01-01T00:00:00Z',
                          })
                        ];
                },
                completeTask: (_) async {
                  writes++;
                  committed = true;
                  QuestwellRewardResponse.integer({}, 'xp_awarded');
                  throw StateError('unreachable');
                },
              );
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData.dark(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: page,
        ));
        if (refreshMode == 'appearance pending') {
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));
        } else {
          await tester.pumpAndSettle();
        }
        final action = boss
            ? find.widgetWithText(FilledButton, 'Attack')
            : find.text('Complete quest');
        await tester.ensureVisible(action.first);
        await tester.tap(action.first);
        if (refreshMode == 'pending') {
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          if (boss) {
            expect(action, findsWidgets);
            for (final button in tester.widgetList<FilledButton>(action)) {
              expect(button.onPressed, isNull);
            }
          } else {
            expect(action, findsNothing);
          }
          expect(writes, 1);
          pending.complete();
        }
        if (refreshMode == 'appearance pending') {
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));
        } else {
          await tester.pumpAndSettle();
        }
        expect(writes, 1);
        expect(postWriteReads, greaterThan(0));
        if (!boss) expect(postWriteReads, 1);
        expect(postWriteProfiles, greaterThan(0));
        expect(find.textContaining('Completion was not confirmed.'),
            findsOneWidget);
        expect(find.textContaining('private refresh details'), findsNothing);
        expect(find.textContaining('Quest complete.'), findsNothing);
        expect(action, findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
