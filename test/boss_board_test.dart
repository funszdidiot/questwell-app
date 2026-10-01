import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/models/questwell_boss.dart';
import '../lib/widgets/questwell_boss_board.dart';
import '../lib/widgets/questwell_boss_encounter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  QuestwellBossBattle battle(String id, {bool won = false}) => QuestwellBossBattle(id: id,
    title: 'Challenge $id', bossType: id == 'a' ? 'inbox_hydra' : 'meeting_mimic',
    status: won ? 'completed' : 'open', rewardXp: 100, rewardCoins: 50,
    steps: [QuestwellBossStep(id: '$id-1', title: 'Finish the first action', position: 0, completed: won),
      QuestwellBossStep(id: '$id-2', title: 'Close the loop', position: 1, completed: won)]);
  int homes = 0, attacks = 0, creates = 0;
  Widget page(List<QuestwellBossBattle> data, {bool failed = false, bool loading = false, String? busy}) => MaterialApp(
    home: MediaQuery(data: const MediaQueryData(disableAnimations: true), child: Scaffold(
      body: QuestwellBossBoard(battles: data, practice: true, failed: failed, loading: loading,
        busyStepId: busy, onHome: () => homes++, onCreate: () => creates++,
        onAttack: (_, __) => attacks++, onRetry: () {}))));
  testWidgets('Only selected battle owns an arena; queue selection changes focus', (tester) async {
    tester.view.physicalSize = const Size(390, 1700); tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(page([battle('a'), battle('b')])); await tester.pumpAndSettle();
    expect(find.byType(QuestwellBossEncounter), findsOneWidget);
    expect(tester.widget<QuestwellBossEncounter>(find.byType(QuestwellBossEncounter)).encounterId, 'a');
    await tester.ensureVisible(find.byKey(const ValueKey('select-b')));
    await tester.tap(find.byKey(const ValueKey('select-b'))); await tester.pumpAndSettle();
    expect(tester.widget<QuestwellBossEncounter>(find.byType(QuestwellBossEncounter)).encounterId, 'b');
    await tester.pumpWidget(page([battle('a'), battle('b', won: true)])); await tester.pumpAndSettle();
    expect(tester.widget<QuestwellBossEncounter>(find.byType(QuestwellBossEncounter)).encounterId, 'b');
    expect(find.byType(QuestwellBossVictoryPanel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Home and create remain reachable in empty, loading and error states', (tester) async {
    for (final state in ['empty', 'loading', 'error']) {
      await tester.pumpWidget(page([], loading: state == 'loading', failed: state == 'error'));
      await tester.pump();
      await tester.tap(find.byTooltip('Back to the Hearth'));
      await tester.tap(find.text('Start a battle'));
      expect(tester.takeException(), isNull);
    }
    expect(homes, 3); expect(creates, 3);
  });
  testWidgets('Busy attack disables every other attack and preserves completed rows', (tester) async {
    tester.view.physicalSize = const Size(390, 1700); tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(page([battle('a')], busy: 'a-1')); await tester.pump();
    final attack = find.widgetWithText(FilledButton, 'Attack');
    expect(tester.widget<FilledButton>(attack).onPressed, isNull);
    expect(attacks, 0);
    await tester.pumpWidget(page([battle('a')])); await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Attack').first); await tester.pump();
    expect(attacks, 1); expect(tester.takeException(), isNull);
  });
}
