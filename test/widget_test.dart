import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/startup/questwell_startup.dart';

Widget startup(Future<void> Function() initialize) => QuestwellStartup(
  initialize: initialize,
  appBuilder: (_) => const MaterialApp(home: Text('Ready adventure')),
);

void main() {
  testWidgets('draws loading before initialization finishes, then opens app', (
    tester,
  ) async {
    final pending = Completer<void>();
    await tester.pumpWidget(startup(() => pending.future));
    expect(find.text('Opening Questwell…'), findsOneWidget);
    expect(find.text('Ready adventure'), findsNothing);
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.text('Ready adventure'), findsOneWidget);
    expect(find.text('Opening Questwell…'), findsNothing);
  });

  testWidgets('safe failure can retry without duplicate concurrent attempts', (
    tester,
  ) async {
    var attempts = 0;
    final retry = Completer<void>();
    await tester.pumpWidget(
      startup(() {
        attempts++;
        if (attempts == 1) throw const StartupFailure(restartRequired: false);
        return retry.future;
      }),
    );
    await tester.pumpAndSettle();
    expect(find.text('Questwell couldn’t open'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(attempts, 2);
    expect(find.text('Try again'), findsNothing);
    retry.complete();
    await tester.pumpAndSettle();
    expect(find.text('Ready adventure'), findsOneWidget);
  });

  testWidgets('unknown failure stays private and requires a fresh app start', (
    tester,
  ) async {
    await tester.pumpWidget(
      startup(() async {
        throw StateError('secret-token tester@example.test');
      }),
    );
    await tester.pumpAndSettle();
    expect(find.text('Questwell couldn’t open'), findsOneWidget);
    expect(find.textContaining('Close and reopen'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
    expect(find.textContaining('secret-token'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('slow startup offers guidance and still accepts late success', (
    tester,
  ) async {
    final pending = Completer<void>();
    var attempts = 0;
    await tester.pumpWidget(
      startup(() {
        attempts++;
        return pending.future;
      }),
    );
    await tester.pump(const Duration(seconds: 15));
    expect(find.text('Taking longer than expected'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Try again'), findsNothing);
    expect(attempts, 1);
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.text('Ready adventure'), findsOneWidget);
  });

  testWidgets(
    'late failure after disposal is consumed without updating state',
    (tester) async {
      final pending = Completer<void>();
      await tester.pumpWidget(startup(() => pending.future));
      await tester.pumpWidget(const SizedBox());
      pending.completeError(StateError('private error'));
      await tester.pump(const Duration(seconds: 20));
      expect(tester.takeException(), isNull);
      expect(find.text('Ready adventure'), findsNothing);
    },
  );

  testWidgets('late success after disposal cannot mount the app', (
    tester,
  ) async {
    final pending = Completer<void>();
    await tester.pumpWidget(startup(() => pending.future));
    await tester.pumpWidget(const SizedBox());
    pending.complete();
    await tester.pump(const Duration(seconds: 20));
    expect(tester.takeException(), isNull);
    expect(find.text('Ready adventure'), findsNothing);
  });

  testWidgets('recovery text fits a narrow screen with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      startup(() async {
        throw const StartupFailure(restartRequired: false);
      }),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Try again'));
    expect(tester.takeException(), isNull);
  });
}
