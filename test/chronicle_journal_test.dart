import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/pages/chronicle_page/chronicle_page_widget.dart';
import 'package:project_momentum/services/questwell_chronicle_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('journal wraps long titles at 320 px with enlarged text and keeps filters usable', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final date = DateTime(2026, 9, 30, 18);
    await tester.pumpWidget(MaterialApp(theme: ThemeData.dark(),
      builder: (_, child) => MediaQuery(data: const MediaQueryData(textScaler: TextScaler.linear(1.6)), child: child!),
      home: ChroniclePageWidget(previewData: ChronicleSnapshot.fromWins([
        ChronicleWin(kind:'quest',title:'Finish the first paragraph of the project that has been difficult to start',
          completedAt:date,xp:20,coins:10),
        ChronicleWin(kind:'milestone_reward',title:'Starlit Orrery',completedAt:date,xp:0,coins:0,
          cosmeticSlug:'starlit-orrery',source:'level_milestone',level:10),
      ],now:date))));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Milestones'));
    await tester.tap(find.text('Milestones')); await tester.pumpAndSettle();
    expect(find.text('Starlit Orrery'), findsOneWidget);
    expect(find.text('+20 XP'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Bosses')); await tester.pumpAndSettle();
    expect(find.text('A victory worth a page.'), findsOneWidget);
    expect(find.byTooltip('Back to the Hearth'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('history after the first 30 entries remains reachable', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final date = DateTime(2026, 9, 30, 18);
    await tester.pumpWidget(MaterialApp(theme:ThemeData.dark(),home:ChroniclePageWidget(
      previewData:ChronicleSnapshot.fromWins(List.generate(31,(i)=>ChronicleWin(
        kind:'quest',title:'Recorded win $i',completedAt:date.subtract(Duration(minutes:i)),xp:10,coins:5)),now:date))));
    await tester.pumpAndSettle();
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Show earlier pages'), 650, scrollable:scrollable, maxScrolls:30);
    await tester.tap(find.text('Show earlier pages')); await tester.pumpAndSettle();
    expect(find.text('Recorded win 30'), findsOneWidget);
    expect(find.text('Show earlier pages'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
