import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_home_sections.dart';

void main() {
  testWidgets('Home actions remain readable and route correctly on narrow screens', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.binding.setSurfaceSize(const Size(320, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    String? destination;
    await tester.pumpWidget(MaterialApp(home: MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
      child: Scaffold(body: ListView(padding: const EdgeInsets.all(16), children: [
        const QuestwellHomeEmptyBoard(),
        QuestwellHomeActions(onOpen: (value) => destination = value),
      ])),
    )));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Add quest'), findsOneWidget);
    expect(tester.widget<Text>(find.text('A little room to breathe.')).style?.fontFamily,
      GoogleFonts.pressStart2p().fontFamily);
    for (final entry in {'Add quest': 'quests', 'Start an expedition': 'expedition',
      }.entries) {
      await tester.ensureVisible(find.text(entry.key));
      await tester.pumpAndSettle();
      await tester.tap(find.text(entry.key));
      expect(destination, entry.value);
    }
  });
}
