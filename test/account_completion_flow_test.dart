import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/services/questwell_cosmetic_service.dart';
import 'package:project_momentum/services/questwell_milestone_service.dart';
import 'package:project_momentum/widgets/questwell_account_dialog_flow.dart';
import 'package:project_momentum/widgets/questwell_milestone_reward.dart';

QuestwellCosmeticsSnapshot _snapshot({bool occupied = false}) =>
    QuestwellCosmeticsSnapshot(
      profile: QuestwellProfile.fromJson({'onboarding_completed': true}),
      cosmetics: [
        QuestwellCosmetic.fromJson({
          'id': 'trophy',
          'slug': 'first-journey-trophy',
          'name': 'First Journey',
          'category': 'room',
        }, owned: true),
        if (occupied)
          QuestwellCosmetic.fromJson({
            'id': 'old',
            'slug': 'starlit-orrery-trophy',
            'name': 'Old trophy',
            'category': 'room',
          }, owned: true, equipped: true, roomSlot: 'mantel'),
      ],
    );

class _Harness {
  String owner = 'A';
  final changes = ValueNotifier(0);
  final navigator = GlobalKey<NavigatorState>();
  QuestwellAccountDialogFlow? flow;
  Future<bool>? result;
  int loads = 0, writes = 0;
  Future<QuestwellCosmeticsSnapshot> Function() load = () async => _snapshot();
  Future<void> Function() place = () async {};
  late BuildContext pageContext;

  Widget app() => MaterialApp(
      navigatorKey: navigator,
      theme: ThemeData.dark(),
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!),
      home: Builder(builder: (context) {
        pageContext = context;
        return Scaffold(
            body: TextButton(
                onPressed: () {
                  final capturedOwner = owner;
                  flow = QuestwellAccountDialogFlow(
                      isCurrent: () =>
                          context.mounted && owner == capturedOwner,
                      accountChanges: changes);
                  result = showQuestwellMilestones(context,
                      previousLevel: 4,
                      level: 5,
                      xpAwarded: 20,
                      coinsAwarded: 3,
                      flow: flow, loadAppearance: () {
                    loads++;
                    return load();
                  }, placeTrophy: (id, slot, expected) {
                    expect(id, 'trophy');
                    expect(slot, 'mantel');
                    writes++;
                    return place();
                  });
                },
                child: const Text('Celebrate')));
      }));

  void switchAccount() {
    owner = 'B';
    changes.value++;
  }

  void dispose() {
    flow?.cancel();
    changes.dispose();
  }
}

Future<void> _start(WidgetTester tester, _Harness h) async {
  await tester.binding.setSurfaceSize(const Size(1000, 1600));
  addTearDown(() {
    h.dispose();
    return tester.binding.setSurfaceSize(null);
  });
  await tester.pumpWidget(h.app());
  await tester.tap(find.text('Celebrate'));
  await tester.pumpAndSettle();
  expect(find.byType(QuestwellMilestoneUnlockDialog), findsOneWidget);
}

Future<void> _place(WidgetTester tester) async {
  await tester.tap(find.text('Place in Hearth'));
  await tester.pumpAndSettle();
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  for (final stage in ['celebration', 'load', 'picker', 'replacement']) {
    testWidgets('account switch cancels milestone at $stage', (tester) async {
      final h = _Harness();
      final pending = Completer<QuestwellCosmeticsSnapshot>();
      h.load = stage == 'load'
          ? () => pending.future
          : () async => _snapshot(occupied: stage == 'replacement');
      await _start(tester, h);
      if (stage != 'celebration') await _place(tester);
      if (stage == 'replacement') {
        await tester.tap(find.text('Save placement'));
        await tester.pumpAndSettle();
        expect(find.text('Replace Old trophy?'), findsOneWidget);
      }
      final staleButton = stage == 'celebration'
          ? tester
              .widget<FilledButton>(
                  find.widgetWithText(FilledButton, 'Place in Hearth'))
              .onPressed
          : stage == 'picker'
              ? tester
                  .widget<FilledButton>(
                      find.widgetWithText(FilledButton, 'Save placement'))
                  .onPressed
              : stage == 'replacement'
                  ? tester
                      .widget<FilledButton>(
                          find.widgetWithText(FilledButton, 'Replace item'))
                      .onPressed
                  : null;
      h.switchAccount();
      staleButton?.call();
      await tester.pumpAndSettle();
      if (stage == 'load') {
        pending.complete(_snapshot());
        await tester.pumpAndSettle();
      }
      expect(await h.result, isTrue);
      expect(find.byType(Dialog), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
      expect(h.loads, stage == 'celebration' ? 0 : 1);
      expect(h.writes, 0);
      expect(find.textContaining('placed in your Hearth'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('cancellation leaves unrelated routes intact', (tester) async {
    final h = _Harness();
    await _start(tester, h);
    final unrelated = showDialog<void>(
        context: h.pageContext,
        builder: (_) => const AlertDialog(title: Text('Unrelated dialog')));
    await tester.pumpAndSettle();
    h.switchAccount();
    await tester.pumpAndSettle();
    expect(find.text('Unrelated dialog'), findsOneWidget);
    expect(find.byType(QuestwellMilestoneUnlockDialog, skipOffstage: false),
        findsNothing);
    expect(h.loads, 0);
    expect(h.writes, 0);
    h.navigator.currentState!.pop();
    await tester.pumpAndSettle();
    await unrelated;
    expect(tester.takeException(), isNull);
  });

  testWidgets('disposal consumes late cosmetics without opening another route',
      (tester) async {
    final h = _Harness();
    final pending = Completer<QuestwellCosmeticsSnapshot>();
    h.load = () => pending.future;
    await _start(tester, h);
    await _place(tester);
    h.flow!.cancel();
    await tester.pumpWidget(const SizedBox());
    pending.complete(_snapshot());
    await tester.pumpAndSettle();
    expect(await h.result, isTrue);
    expect(h.writes, 0);
    expect(find.byType(Dialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('same account can still place its milestone trophy once',
      (tester) async {
    final h = _Harness();
    await _start(tester, h);
    await _place(tester);
    await tester.tap(find.text('Save placement'));
    await tester.pumpAndSettle();
    expect(await h.result, isTrue);
    expect(h.loads, 1);
    expect(h.writes, 1);
    expect(find.text('First Journey placed in your Hearth.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final fails in [false, true]) {
    testWidgets(
        'late placement ${fails ? 'error' : 'success'} stays with its account',
        (tester) async {
      final h = _Harness();
      final pending = Completer<void>();
      h.place = () => pending.future;
      await _start(tester, h);
      await _place(tester);
      await tester.tap(find.text('Save placement'));
      await tester.pumpAndSettle();
      expect(h.writes, 1);
      h.switchAccount();
      if (fails) {
        pending.completeError(StateError('private old account'));
      } else {
        pending.complete();
      }
      await tester.pumpAndSettle();
      expect(await h.result, isTrue);
      expect(find.byType(SnackBar), findsNothing);
      expect(h.writes, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
