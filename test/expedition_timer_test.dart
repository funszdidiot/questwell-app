import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/pages/expedition_page/expedition_page_widget.dart';

void main() {
  testWidgets('Expedition timer preserves its visible countdown behavior',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExpeditionPageWidget()));

    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Begin Expedition'), findsOneWidget);

    await tester.tap(find.text('Begin Expedition'));
    await tester.pump();
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('STAY WITH THE QUEST'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('24:59'), findsOneWidget);

    await tester.tap(find.text('Pause'));
    await tester.pump();
    expect(find.text('Begin Expedition'), findsOneWidget);
  });
}
