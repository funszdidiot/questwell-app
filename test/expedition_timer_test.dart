import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/pages/expedition_page/expedition_page_widget.dart';

void main() {
  testWidgets('Expedition timer preserves its visible countdown behavior',
      (tester) async {
    var now = DateTime.utc(2026, 10, 4, 12);
    await tester.pumpWidget(MaterialApp(
      home: ExpeditionPageWidget(clock: () => now),
    ));

    expect(find.text('25:00'), findsOneWidget);
    final begin = find.text('Begin');
    expect(begin, findsOneWidget);

    // The timer controls sit below the scene on the default 800 x 600 view.
    // Reach the actual control through its scroll view before tapping it.
    await tester.ensureVisible(begin);
    await tester.pump();
    expect(begin.hitTestable(), findsOneWidget);
    await tester.tap(begin);
    await tester.pump();
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('STAY WITH THE QUEST'), findsOneWidget);

    now = now.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('24:59'), findsOneWidget);

    final pause = find.text('Pause');
    await tester.ensureVisible(pause);
    await tester.pump();
    expect(pause.hitTestable(), findsOneWidget);
    await tester.tap(pause);
    await tester.pump();
    expect(find.text('Resume'), findsOneWidget);

    now = now.add(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('24:59'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  Future<void> tapControl(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.pump();
    await tester.tap(find.text(label));
    await tester.pump();
  }

  Future<void> resumeApp(WidgetTester tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    // No elapsed test time: lifecycle recovery must not rely on the next tick.
    await tester.pump();
  }

  testWidgets('Returning from background immediately reconciles elapsed time',
      (tester) async {
    var now = DateTime.utc(2026, 10, 10);
    await tester.pumpWidget(MaterialApp(
      home: ExpeditionPageWidget(clock: () => now),
    ));
    expect(find.textContaining('This timer is not saved.'), findsOneWidget);
    await tapControl(tester, 'Begin');
    now = now.add(const Duration(minutes: 3, seconds: 12));
    await resumeApp(tester);
    expect(find.text('21:48'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);
    now = now.add(const Duration(minutes: 22));
    await resumeApp(tester);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('EXPEDITION COMPLETE'), findsOneWidget);
    await resumeApp(tester);
    expect(find.text('EXPEDITION COMPLETE'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('Paused sessions stay frozen and Resume starts a fresh deadline',
      (tester) async {
    var now = DateTime.utc(2026, 10, 10);
    await tester.pumpWidget(MaterialApp(
      home: ExpeditionPageWidget(clock: () => now),
    ));
    await tapControl(tester, 'Begin');
    now = now.add(const Duration(seconds: 30));
    await tapControl(tester, 'Pause');
    expect(find.text('24:30'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('Your timer is paused here.'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Your timer is paused here.'), findsOneWidget);
    expect(find.textContaining('Your progress is safe'), findsNothing);
    now = now.add(const Duration(hours: 2));
    await resumeApp(tester);
    expect(find.text('24:30'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    await tapControl(tester, 'Resume');
    now = now.add(const Duration(seconds: 10));
    await resumeApp(tester);
    expect(find.text('24:20'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Clock rollback cannot exceed the selected session duration',
      (tester) async {
    var now = DateTime.utc(2026, 10, 10);
    await tester.pumpWidget(MaterialApp(
      home: ExpeditionPageWidget(clock: () => now),
    ));
    await tapControl(tester, 'Begin');
    now = now.subtract(const Duration(minutes: 10));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('25:00'), findsOneWidget);
    now = now.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('24:59'), findsOneWidget);
    await resumeApp(tester);
    expect(find.text('24:59'), findsOneWidget);
    await tapControl(tester, 'Pause');
    expect(find.text('24:59'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Reset and page recreation discard the local session',
      (tester) async {
    var now = DateTime.utc(2026, 10, 10);
    Widget page() => MaterialApp(
          home: ExpeditionPageWidget(clock: () => now),
        );
    await tester.pumpWidget(page());
    await tapControl(tester, 'Begin');
    now = now.add(const Duration(seconds: 30));
    await tapControl(tester, 'Pause');
    await tapControl(tester, 'Reset timer');
    now = now.add(const Duration(hours: 1));
    await resumeApp(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Begin'), findsOneWidget);
    await tapControl(tester, 'Begin');
    await tester.pumpWidget(const SizedBox());
    now = now.add(const Duration(hours: 1));
    await resumeApp(tester);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(page());
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Begin'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
