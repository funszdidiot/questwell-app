import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/models/questwell_boss.dart';
import 'package:project_momentum/widgets/questwell_boss_board.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  for (final reduced in [false, true]) {
    testWidgets(
        'Deep mobile attack reveals the arena before submitting ($reduced)',
        (tester) async {
      tester.view.physicalSize = const Size(390, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var writes = 0;
      String? submittedStep;
      Rect? arenaAtSubmission;
      final battle = QuestwellBossBattle(
          id: 'deep',
          title: 'Break the project into useful steps',
          status: 'open',
          rewardXp: 25,
          rewardCoins: 50,
          bossType: 'inbox_hydra',
          steps: [
            for (var i = 0; i < 20; i++)
              QuestwellBossStep(
                  id: 'step-$i',
                  title: 'Action $i: one useful step',
                  position: i,
                  completed: false)
          ]);
      await tester.pumpWidget(MaterialApp(
          home: MediaQuery(
              data: MediaQueryData(
                  disableAnimations: reduced, textScaler: TextScaler.linear(2)),
              child: Scaffold(
                  body: QuestwellBossBoard(
                      battles: [battle],
                      practice: true,
                      onHome: () {},
                      onCreate: () {},
                      onAttack: (_, step) {
                        writes++;
                        submittedStep = step.id;
                        arenaAtSubmission = tester
                            .getRect(find.byKey(const ValueKey('boss-arena')));
                      })))));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Later attacks · 19'), 250);
      await tester.tap(find.text('Later attacks · 19'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
          find.byKey(const ValueKey('attack-step-19')), 400);
      final action = find.descendant(
          of: find.byKey(const ValueKey('attack-step-19')),
          matching: find.byType(FilledButton));
      await tester.ensureVisible(action);
      await tester.pumpAndSettle();
      final callback = tester.widget<FilledButton>(action).onPressed!;
      callback();
      callback();
      expect(writes, 0);
      await tester.pumpAndSettle();
      expect(writes, 1);
      expect(submittedStep, 'step-19');
      expect(arenaAtSubmission!.top, greaterThanOrEqualTo(0));
      expect(arenaAtSubmission!.bottom, lessThanOrEqualTo(740));
      expect(tester.takeException(), isNull);
    });
  }
}
