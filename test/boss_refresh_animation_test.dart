import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/pages/boss_battles_page/boss_battles_page_widget.dart';
import '../lib/services/questwell_boss_service.dart';
import '../lib/services/questwell_cosmetic_models.dart';
import '../lib/widgets/questwell_boss_encounter.dart';
import '../lib/widgets/questwell_pixel_art.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  for (final reduced in [false, true]) {
    for (final fails in [false, true]) {
      testWidgets('Server refresh preserves attack animation ($reduced/$fails)',
          (tester) async {
        SharedPreferences.setMockInitialValues({});
        tester.view.physicalSize = const Size(390, 1800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final refresh = Completer<List<QuestwellBossBattle>>();
        var reads = 0;
        var writes = 0;
        QuestwellBossBattle battle(bool hit) => QuestwellBossBattle(
                id: 'animation-$reduced-$fails',
                title: 'Clear the inbox',
                status: 'open',
                rewardXp: 25,
                rewardCoins: 50,
                bossType: 'inbox_hydra',
                steps: [
                  QuestwellBossStep(
                      id: 'first', title: 'Reply', position: 0, completed: hit),
                  const QuestwellBossStep(
                      id: 'second',
                      title: 'Archive',
                      position: 1,
                      completed: false),
                ]);
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData.dark(),
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
              child: child!),
          home: BossBattlesPageWidget(
            currentOwner: () => 'owner',
            loadAppearance: () async => QuestwellCosmeticsSnapshot(
                profile:
                    QuestwellProfile.fromJson({'onboarding_completed': true}),
                cosmetics: const []),
            loadBattles: () {
              reads++;
              return reads == 1
                  ? Future.value([battle(false)])
                  : refresh.future;
            },
            completeStep: (_) async {
              writes++;
              return const BossStepCompletionResult(
                  bossCompleted: false,
                  xpAwarded: 5,
                  coinsAwarded: 2,
                  totalXp: 5,
                  coinBalance: 2);
            },
          ),
        ));
        await tester.pumpAndSettle();
        final encounter = find.byType(QuestwellBossEncounter);
        final state = tester.state(encounter);
        final attack = find.widgetWithText(FilledButton, 'Attack');
        await tester.ensureVisible(attack.first);
        await tester.tap(attack.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(reads, 2);
        expect(writes, 1);
        expect(tester.state(encounter), same(state));
        expect(find.text('Updating battle…'), findsOneWidget);
        for (final button in tester.widgetList<FilledButton>(attack)) {
          expect(button.onPressed, isNull);
        }
        await tester.tap(attack.last);
        expect(writes, 1);
        if (fails) {
          refresh.completeError(StateError('private server details'));
          await tester.pumpAndSettle();
          expect(
              find.text('Your battles could not be loaded.'), findsOneWidget);
          expect(find.textContaining('private server'), findsNothing);
          expect(attack, findsNothing);
        } else {
          refresh.complete([battle(true)]);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));
          expect(tester.state(encounter), same(state));
          final meter = find.descendant(
              of: encounter, matching: find.byType(QuestwellPixelMeter));
          final health = tester.widget<QuestwellPixelMeter>(meter).value;
          if (reduced) {
            expect(health, .5);
          } else {
            expect(health, greaterThan(.5));
            expect(health, lessThan(1));
          }
          await tester.pumpAndSettle();
          expect(tester.widget<QuestwellPixelMeter>(meter).value, .5);
          expect(find.text('Updating battle…'), findsNothing);
          expect(attack, findsOneWidget);
          expect(tester.widget<FilledButton>(attack).onPressed, isNotNull);
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
