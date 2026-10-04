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
    final begin = find.text('Begin Expedition');
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
    expect(find.text('Resume Expedition'), findsOneWidget);

    now = now.add(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('24:59'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
