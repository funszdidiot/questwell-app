import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/services/questwell_onboarding_session.dart';
import 'package:project_momentum/widgets/questwell_onboarding_panel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  Future<void> mount(
    WidgetTester tester,
    Future<QuestwellOnboardingResult> Function(String?) finish,
    VoidCallback completed, {
    Key? key,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestwellOnboardingPanel(
            key: key,
            finish: finish,
            onCompleted: completed,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('starter and skip cannot race while a request is pending', (
    tester,
  ) async {
    final pending = Completer<QuestwellOnboardingResult>();
    var calls = 0, finished = 0;
    await mount(tester, (key) {
      calls++;
      expect(key, 'email');
      return pending.future;
    }, () => finished++);
    await tester.tap(find.text('Reply to one email'));
    await tester.tap(find.text('I already know what I want to do'));
    expect(calls, 1);
    pending.complete(
      const QuestwellOnboardingResult(completed: true, taskId: 'task'),
    );
    await tester.pumpAndSettle();
    expect(finished, 1);
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Reply to one email'),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('skip locks every starter action too', (tester) async {
    final pending = Completer<QuestwellOnboardingResult>();
    var calls = 0;
    await mount(tester, (key) {
      calls++;
      expect(key, isNull);
      return pending.future;
    }, () {});
    await tester.tap(find.text('I already know what I want to do'));
    await tester.tap(find.text('Clear five files'));
    expect(calls, 1);
    pending.complete(const QuestwellOnboardingResult(completed: true));
    await tester.pumpAndSettle();
  });

  testWidgets(
    'a lost response keeps setup visible and a retry can complete it',
    (tester) async {
      var calls = 0, finished = 0;
      await mount(tester, (key) async {
        if (++calls == 1) throw TimeoutException('sensitive transport details');
        return const QuestwellOnboardingResult(
          completed: true,
          taskId: 'original',
        );
      }, () => finished++);
      await tester.tap(find.text('Do the avoided thing'));
      await tester.pumpAndSettle();
      expect(finished, 0);
      expect(find.textContaining('You can retry safely.'), findsOneWidget);
      expect(find.textContaining('sensitive transport'), findsNothing);
      await tester.tap(find.text('Do the avoided thing'));
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(finished, 1);
    },
  );

  testWidgets('existing progress needs explicit finish confirmation', (
    tester,
  ) async {
    final choices = <String?>[];
    var finished = 0;
    await mount(tester, (key) async {
      choices.add(key);
      return QuestwellOnboardingResult(completed: key == null);
    }, () => finished++);
    await tester.tap(find.text('Reply to one email'));
    await tester.pumpAndSettle();
    expect(finished, 0);
    expect(find.textContaining('already has quest progress'), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Clear five files'),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('Finish setup with my current progress'));
    await tester.pumpAndSettle();
    expect(choices, ['email', null]);
    expect(finished, 1);
  });

  testWidgets(
    'a new account panel discards the old result and can finish independently',
    (tester) async {
      final pending = Completer<QuestwellOnboardingResult>();
      var finished = 0;
      await mount(
        tester,
        (_) => pending.future,
        () => finished++,
        key: const ValueKey('account-a'),
      );
      await tester.tap(find.text('Reply to one email'));
      await tester.pump();
      await mount(
        tester,
        (_) async => const QuestwellOnboardingResult(completed: true),
        () => finished++,
        key: const ValueKey('account-b'),
      );
      pending.complete(const QuestwellOnboardingResult(completed: true));
      await tester.pumpAndSettle();
      expect(finished, 0);
      await tester.tap(find.text('Clear five files'));
      await tester.pumpAndSettle();
      expect(finished, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
