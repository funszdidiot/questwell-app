import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/widgets/questwell_app_style.dart';
import 'package:project_momentum/widgets/questwell_quest_completion.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  for (final reduced in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
          'Quest celebration supports narrow large text and motion ($reduced/$scale)',
          (tester) async {
        tester.view.physicalSize = const Size(320, 740);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        String? result;
        await tester.pumpWidget(MaterialApp(
            theme: QuestwellAppStyle.theme(),
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                    disableAnimations: reduced,
                    textScaler: TextScaler.linear(scale)),
                child: child!),
            home: Scaffold(
                body: Builder(
                    builder: (context) => TextButton(
                        onPressed: () async {
                          result = await showDialog<String>(
                              context: context,
                              builder: (_) =>
                                  const QuestwellQuestCompletionDialog(
                                      questTitle: 'Make room for what matters',
                                      xpAwarded: 17,
                                      coinsAwarded: 3,
                                      totalXp: 117,
                                      coinBalance: 53,
                                      level: 3));
                        },
                        child: const Text('Open'))))));
        await tester.tap(find.text('Open'));
        await tester.pump();
        final reveal = find.byKey(const ValueKey('quest-victory-reveal'));
        expect(tester.widget<Transform>(reveal).transform.storage[0],
            reduced ? 1 : lessThan(1));
        await tester.pumpAndSettle();
        expect(tester.widget<Transform>(reveal).transform.storage[0], 1);
        expect(find.text('Make room for what matters'), findsOneWidget);
        expect(find.text('+17 XP'), findsOneWidget);
        expect(find.text('+3 coins'), findsOneWidget);
        expect(find.text('Balance: 53 coins • 117 total XP'), findsOneWidget);
        expect(tester.binding.hasScheduledFrame, isFalse);
        for (final label in ['See Chronicle', 'Add Next Quest', 'Keep Going']) {
          await tester.ensureVisible(find.text(label));
          expect(tester.takeException(), isNull);
        }
        await tester.tap(find.text('Keep Going'));
        await tester.pumpAndSettle();
        expect(result, 'continue');
        expect(find.byType(QuestwellQuestCompletionDialog), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
