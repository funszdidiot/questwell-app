import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/models/questwell_boss.dart';
import '../lib/models/questwell_boss_unlocks.dart';
import '../lib/widgets/questwell_boss_picker.dart';
import '../lib/services/questwell_progression.dart';
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
  Widget page(List<QuestwellBossBattle> data, {bool failed = false, bool loading = false, String? busy, String? selected}) => MaterialApp(
    home: MediaQuery(data: const MediaQueryData(disableAnimations: true), child: Scaffold(
      body: QuestwellBossBoard(battles: data, practice: true, failed: failed, loading: loading,
        busyStepId: busy, initialBattleId: selected, onHome: () => homes++, onCreate: () => creates++,
        onAttack: (_, __) => attacks++, onRetry: () {}))));
  testWidgets('Mailroom is bundled and exclusive to Hydra at narrow width', (tester) async {
    tester.view.physicalSize = const Size(320, 1700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(page([battle('a'), battle('b')]));
    await tester.pumpAndSettle();
    final background = find.byKey(const ValueKey('hydra-mailroom-arena'));
    expect(background, findsOneWidget);
    expect(tester.widget<Image>(background).image,
      isA<AssetImage>().having((asset) => asset.assetName, 'asset',
        'assets/images/questwell_hydra_mailroom_v1.webp'));
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(const ValueKey('select-b')));
    await tester.tap(find.byKey(const ValueKey('select-b')));
    await tester.pumpAndSettle();
    expect(background, findsNothing);
    expect(tester.takeException(), isNull);
  });
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
    await tester.ensureVisible(find.text('Choose next battle'));
    await tester.tap(find.text('Choose next battle')); await tester.pumpAndSettle();
    expect(tester.widget<QuestwellBossEncounter>(find.byType(QuestwellBossEncounter)).encounterId, 'a');
    expect(tester.takeException(), isNull);
  });
  testWidgets('Newly created battle opens after refresh and returns to the arena', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(page([battle('a'), battle('b')]));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const ValueKey('select-b')), 200);
    await tester.tap(find.byKey(const ValueKey('select-b')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    // FutureBuilder may retain the old list while the create refresh is pending.
    await tester.pumpWidget(page([battle('a'), battle('b')], selected: 'c'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(page([battle('a'), battle('b'), battle('c')], selected: 'c'));
    await tester.pumpAndSettle();
    expect(tester.widget<QuestwellBossEncounter>(find.byType(QuestwellBossEncounter)).encounterId, 'c');
    expect(tester.getTopLeft(find.byType(QuestwellBossEncounter)).dy, greaterThanOrEqualTo(0));
    expect(tester.getBottomRight(find.byType(QuestwellBossEncounter)).dy, lessThan(844));

    // A later refresh must respect a manual selection, not reopen the created battle.
    await tester.scrollUntilVisible(find.byKey(const ValueKey('select-a')), 200);
    await tester.tap(find.byKey(const ValueKey('select-a')));
    await tester.pumpAndSettle();
    await tester.pumpWidget(page([battle('a'), battle('b'), battle('c')], selected: 'c'));
    await tester.pumpAndSettle();
    expect(tester.widget<QuestwellBossEncounter>(find.byType(QuestwellBossEncounter)).encounterId, 'a');
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

  test('Boss XP is 25 per victory and does not grow with step count', () {
    expect(QuestwellBossRewards.victoryXp, 25);
    expect(QuestwellBossRewards.victoryCoins, 50);
    expect(QuestwellProgression.levelForXp(25 * 3), 1);
    expect(QuestwellProgression.levelForXp(25 * 4), 2);
    for (final count in [2, 3, 20]) {
      final b = QuestwellBossBattle.fromJson({'id': 'test'}, [
        for (var i = 0; i < count; i++)
          QuestwellBossStep(id: '$i', title: 'Step', position: i, completed: false),
      ]);
      expect(b.rewardXp, 25);
    }
    // Historical server-recorded rewards remain truthful until an approved rollout.
    expect(QuestwellBossBattle.fromJson({'reward_xp': 100}, []).rewardXp, 100);
  });
  test('Every boss unlocks exactly at its approved level', () {
    expect(QuestwellBossUnlocks.levels.values.toList(), [1, 3, 5, 7, 10, 13, 16, 20]);
    for (final entry in QuestwellBossUnlocks.levels.entries) {
      expect(QuestwellBossUnlocks.available(entry.key, entry.value - 1), isFalse);
      expect(QuestwellBossUnlocks.available(entry.key, entry.value), isTrue);
      expect(QuestwellBossUnlocks.xpRemaining(entry.key,
        QuestwellProgression.totalAtLevel(entry.value), 0), 0);
    }
    expect(QuestwellBossUnlocks.available('unknown', 100), isFalse);
    expect(QuestwellBossUnlocks.next(1), 'meeting_mimic');
    expect(QuestwellBossUnlocks.next(20), isNull);
    expect(QuestwellBossUnlocks.xpRemaining('meeting_mimic', 0, 100), 115);
    expect(QuestwellBossUnlocks.progress('meeting_mimic', 0, 100), closeTo(100 / 215, .001));
  });
  testWidgets('Picker exposes locked bosses but rejects selecting them', (tester) async {
    String selected = 'inbox_hydra';
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: QuestwellBossPicker(
      value: selected, level: 1, onChanged: (value) => selected = value))));
    final picker = tester.widget<DropdownButtonFormField<String>>(find.byType(DropdownButtonFormField<String>));
    final menu = tester.widget<DropdownButton<String>>(find.byType(DropdownButton<String>));
    expect(menu.items!.length, 8);
    expect(menu.items!.where((item) => item.enabled).map((item) => item.value), ['inbox_hydra']);
    picker.onChanged!('update_dragon');
    expect(selected, 'inbox_hydra');
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: QuestwellBossPicker(
      value: selected, level: 3, onChanged: (value) => selected = value))));
    final unlocked = tester.widget<DropdownButtonFormField<String>>(find.byType(DropdownButtonFormField<String>));
    final updatedMenu = tester.widget<DropdownButton<String>>(find.byType(DropdownButton<String>));
    expect(updatedMenu.items!.where((item) => item.enabled).length, 2);
    unlocked.onChanged!('meeting_mimic');
    expect(selected, 'meeting_mimic');
    expect(tester.takeException(), isNull);
  });
  testWidgets('Unlock progress fits narrow screens and honors legacy XP', (tester) async {
    tester.view.physicalSize = const Size(320, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
      child: const Scaffold(body: Padding(padding: EdgeInsets.all(18),
        child: QuestwellBossUnlockProgress(level: 2, totalXp: 0, offset: 100))))));
    expect(find.text('115 XP to unlock'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const MaterialApp(home: Scaffold(
      body: QuestwellBossUnlockProgress(level: 20, totalXp: 4465))));
    expect(find.text('Level 20 · All eight bosses unlocked'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}
