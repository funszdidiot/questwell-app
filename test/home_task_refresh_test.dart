import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/backend/supabase/supabase.dart';
import 'package:project_momentum/pages/home_page/home_page_widget.dart';
import 'package:project_momentum/services/questwell_chronicle_service.dart';
import 'package:project_momentum/services/questwell_cosmetic_service.dart';
import 'package:project_momentum/services/questwell_task_service.dart';
import 'package:project_momentum/widgets/questwell_home_sections.dart';
import 'package:project_momentum/widgets/questwell_home_overview.dart';
import 'package:project_momentum/widgets/questwell_onboarding_panel.dart';
import 'package:project_momentum/widgets/questwell_quest_completion.dart';

class _AccountChanges extends ChangeNotifier {
  bool get listening => hasListeners;
  void change() => notifyListeners();
}

TasksRow _task(String id) => TasksRow({
      'id': id,
      'title': '$id quest',
      'status': 'open',
      'friction_level': 1,
      'created_at': '2026-01-01T00:00:00Z',
    });

QuestwellCosmeticsSnapshot _appearance({bool onboarded = true}) =>
    QuestwellCosmeticsSnapshot(
      profile: QuestwellProfile.fromJson({
        'onboarding_completed': onboarded,
        'total_xp': 100,
      }),
      cosmetics: const [],
    );

const _reward = QuestwellTaskCompletionResult(
  taskId: 'A',
  xpAwarded: 17,
  coinsAwarded: 3,
  totalXp: 117,
  coinBalance: 53,
);

class _HomeHarness {
  String? owner = 'A';
  var accounts = _AccountChanges();
  int reads = 0, appearances = 0, writes = 0;
  Future<List<TasksRow>> Function() tasks = () async => [_task('A')];
  Future<QuestwellCosmeticsSnapshot> Function() appearance =
      () async => _appearance();
  Future<QuestwellTaskCompletionResult> Function(String) completion =
      (_) async => _reward;

  HomePageWidget page() => HomePageWidget(
        currentOwner: () => owner,
        accountChanges: accounts,
        loadTasks: () {
          reads++;
          return tasks();
        },
        loadAppearance: () {
          appearances++;
          return appearance();
        },
        loadMomentum: () async => const ChronicleSnapshot(
          wins: [],
          totalXpEarned: 0,
          totalCoinsEarned: 0,
          weekWins: 0,
          bossesDefeated: 0,
        ),
        completeTask: (id) {
          writes++;
          return completion(id);
        },
      );

  Widget app() =>
      MaterialApp(theme: ThemeData.dark(), builder: _builder, home: page());
}

Widget _builder(BuildContext context, Widget? child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: child!,
    );

Future<void> _frames(WidgetTester tester) async {
  // Bounded frames also work with deliberately unresolved appearance requests.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _mount(WidgetTester tester, Widget app) async {
  await tester.binding.setSurfaceSize(const Size(1000, 1500));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(app);
  await _frames(tester);
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  for (final failure in [false, true]) {
    testWidgets(
        'cosmetic ${failure ? 'failure' : 'pending'} and rebuild reuse quests',
        (tester) async {
      final h = _HomeHarness();
      await _mount(tester, h.app());
      expect(h.reads, 1);
      h.appearance = failure
          ? () async => throw StateError('private appearance error')
          : () => Completer<QuestwellCosmeticsSnapshot>().future;
      // Local sync notification only: this fixture writes no account data.
      await QuestwellCosmeticService.changes.write(() async {});
      await _frames(tester);
      await tester.pumpWidget(h.app());
      await _frames(tester);
      expect(h.appearances, 2);
      expect(h.reads, 1);
      expect(find.text('A quest'), findsOneWidget);
      expect(find.text('Complete quest'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('quest retry reloads only tasks and never writes',
      (tester) async {
    final h = _HomeHarness()
      ..tasks = () async => throw StateError('private tasks');
    await _mount(tester, h.app());
    expect(find.text('Retry quests'), findsOneWidget);
    h.tasks = () async => [_task('A')];
    await tester.ensureVisible(find.text('Retry quests'));
    await tester.tap(find.text('Retry quests'));
    await _frames(tester);
    expect(h.reads, 2);
    expect(h.appearances, 1);
    expect(h.writes, 0);
    expect(find.text('A quest'), findsOneWidget);
    expect(find.textContaining('private tasks'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uncertain completion invalidates controls and retry only reads',
      (tester) async {
    final h = _HomeHarness();
    final refresh = Completer<List<TasksRow>>();
    h.completion = (_) async => throw StateError('uncertain reply');
    await _mount(tester, h.app());
    final oldAction = tester
        .widget<QuestwellHomeQuestCard>(find.byType(QuestwellHomeQuestCard))
        .onComplete;
    h.tasks = () => refresh.future;
    oldAction();
    await _frames(tester);
    expect(h.reads, 2);
    expect(h.writes, 1);
    expect(find.byType(QuestwellHomeQuestCard), findsNothing);
    oldAction(); // A retained callback must not replay the old row.
    expect(h.writes, 1);
    refresh.completeError(StateError('private refresh'));
    await _frames(tester);
    expect(find.text('Retry quests'), findsOneWidget);
    expect(find.byType(QuestwellHomeQuestCard), findsNothing);
    h.tasks = () async => [];
    await tester.ensureVisible(find.text('Retry quests'));
    await tester.tap(find.text('Retry quests'));
    await _frames(tester);
    expect(h.reads, 3);
    expect(h.writes, 1);
    expect(find.byType(QuestwellQuestCompletionDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'account change drops loaded rows and rejects their old callbacks',
      (tester) async {
    final h = _HomeHarness();
    await _mount(tester, h.app());
    final oldAction = tester
        .widget<QuestwellHomeQuestCard>(find.byType(QuestwellHomeQuestCard))
        .onComplete;
    final next = Completer<List<TasksRow>>();
    h.owner = 'B';
    h.tasks = () => next.future;
    h.accounts.change();
    await _frames(tester);
    expect(find.text('A quest'), findsNothing);
    oldAction();
    expect(h.writes, 0);
    next.complete([_task('B')]);
    await _frames(tester);
    expect(find.text('B quest'), findsOneWidget);
    expect(h.reads, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('late old-account read cannot replace the new list',
      (tester) async {
    final old = Completer<List<TasksRow>>();
    final h = _HomeHarness()..tasks = () => old.future;
    await _mount(tester, h.app());
    h.owner = 'B';
    h.tasks = () async => [_task('B')];
    h.accounts.change();
    await _frames(tester);
    old.complete([_task('A')]);
    await _frames(tester);
    expect(find.text('A quest'), findsNothing);
    expect(find.text('B quest'), findsOneWidget);
    expect(h.reads, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('late read recovers a silently changed account', (tester) async {
    final old = Completer<List<TasksRow>>();
    final h = _HomeHarness()..tasks = () => old.future;
    await _mount(tester, h.app());
    h.owner = 'B';
    h.tasks = () async => [_task('B')];
    old.complete([_task('A')]);
    await _frames(tester);
    await _frames(tester);
    expect(find.text('A quest'), findsNothing);
    expect(find.text('B quest'), findsOneWidget);
    expect(h.reads, 2);
    expect(tester.takeException(), isNull);
  });

  for (final rejected in [false, true]) {
    testWidgets(
        'old account ${rejected ? 'error' : 'success'} cannot release a new completion',
        (tester) async {
      final old = Completer<QuestwellTaskCompletionResult>();
      final next = Completer<QuestwellTaskCompletionResult>();
      final h = _HomeHarness()
        ..appearance = () => Completer<QuestwellCosmeticsSnapshot>().future;
      h.completion = (id) => id == 'A' ? old.future : next.future;
      await _mount(tester, h.app());
      tester
          .widget<QuestwellHomeQuestCard>(find.byType(QuestwellHomeQuestCard))
          .onComplete();
      await _frames(tester);
      expect(h.reads, 1); // Busy-state redraw must not refetch.
      h.owner = 'B';
      h.tasks = () async => [_task('B')];
      h.accounts.change();
      await _frames(tester);
      final actionB = tester
          .widget<QuestwellHomeQuestCard>(find.byType(QuestwellHomeQuestCard))
          .onComplete;
      actionB();
      await _frames(tester);
      if (rejected) {
        old.completeError(StateError('private old account'));
      } else {
        old.complete(_reward);
      }
      await _frames(tester);
      actionB();
      expect(h.writes, 2);
      expect(h.reads, 2);
      expect(
          tester
              .widget<QuestwellHomeQuestCard>(
                  find.byType(QuestwellHomeQuestCard))
              .completing,
          isTrue);
      expect(
          find.textContaining('Completion was not confirmed.'), findsNothing);
      expect(find.textContaining('Quest complete.'), findsNothing);
      h.tasks = () async => [];
      next.complete(const QuestwellTaskCompletionResult(
          taskId: 'B',
          xpAwarded: 5,
          coinsAwarded: 1,
          totalXp: 105,
          coinBalance: 51));
      await _frames(tester);
      expect(h.reads, 3);
      expect(find.text('Quest complete. +5 XP · +1 coins.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'widget owner update works without a notification and listeners detach',
      (tester) async {
    final h = _HomeHarness();
    await _mount(tester, h.app());
    final oldNotifier = h.accounts;
    expect(oldNotifier.listening, isTrue);
    h.accounts = _AccountChanges();
    h.owner = 'B';
    h.tasks = () async => [_task('B')];
    await tester.pumpWidget(h.app());
    await _frames(tester);
    expect(find.text('A quest'), findsNothing);
    expect(find.text('B quest'), findsOneWidget);
    expect(h.reads, 2);
    expect(oldNotifier.listening, isFalse);
    expect(h.accounts.listening, isTrue);
    await tester.pumpWidget(const SizedBox());
    expect(h.accounts.listening, isFalse);
    h.accounts.change();
    expect(h.reads, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('internal rebuild recovers a suppressed account notification',
      (tester) async {
    final h = _HomeHarness();
    await _mount(tester, h.app());
    final next = Completer<List<TasksRow>>();
    h.owner = 'B';
    h.tasks = () => next.future;
    await QuestwellCosmeticService.changes.write(() async {});
    await _frames(tester);
    expect(find.text('A quest'), findsNothing);
    expect(h.reads, 2);
    next.complete([_task('B')]);
    await _frames(tester);
    expect(find.text('B quest'), findsOneWidget);
    expect(h.reads, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('onboarding refreshes tasks after a starter quest can be created',
      (tester) async {
    final h = _HomeHarness()
      ..appearance = () async => _appearance(onboarded: false);
    await _mount(tester, h.app());
    h.appearance = () async => _appearance();
    h.tasks = () async => [_task('Starter')];
    tester
        .widget<QuestwellOnboardingPanel>(find.byType(QuestwellOnboardingPanel))
        .onCompleted();
    await _frames(tester);
    expect(h.reads, 2);
    expect(find.text('Starter quest'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final destination in ['quests', 'chronicle', 'expedition']) {
    testWidgets('return from $destination refreshes only when tasks can change',
        (tester) async {
      final h = _HomeHarness();
      final router = GoRouter(routes: [
        GoRoute(path: '/', builder: (_, __) => h.page()),
        GoRoute(
            path: '/quests',
            name: 'QuestBoardPage',
            builder: (_, __) => const Scaffold(body: Text('Task route'))),
        GoRoute(
            path: '/chronicle',
            name: 'ChroniclePage',
            builder: (_, __) => const Scaffold(body: Text('Task route'))),
        GoRoute(
            path: '/expedition',
            name: 'ExpeditionPage',
            builder: (_, __) => const Scaffold(body: Text('Task route'))),
      ]);
      addTearDown(router.dispose);
      await _mount(
          tester,
          MaterialApp.router(
              theme: ThemeData.dark(),
              builder: _builder,
              routerConfig: router));
      if (destination == 'chronicle') {
        tester
            .widget<QuestwellHomeMomentum>(find.byType(QuestwellHomeMomentum))
            .onOpen();
      } else {
        tester
            .widget<QuestwellHomeFocusLayout>(
                find.byType(QuestwellHomeFocusLayout))
            .onOpen(destination);
      }
      await tester.pumpAndSettle();
      expect(find.text('Task route'), findsOneWidget);
      expect(h.reads, 1);
      h.tasks = () async => [_task('Updated')];
      router.pop();
      await tester.pumpAndSettle();
      expect(h.reads, destination == 'expedition' ? 1 : 2);
      expect(
          find.text(destination == 'expedition' ? 'A quest' : 'Updated quest'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
