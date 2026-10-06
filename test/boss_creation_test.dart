import 'dart:async';

import 'package:project_momentum/backend/supabase/questwell_network.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/pages/boss_battles_page/boss_battles_page_widget.dart';
import 'package:project_momentum/models/questwell_boss.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  Future<void> open(
    WidgetTester tester,
    Future<String> Function({
      required String title,
      required List<String> steps,
      String bossType,
    })
    create,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: BossBattlesPageWidget(
          loadBattles: () async => <QuestwellBossBattle>[],
          loadAppearance: () async => throw StateError('Profile unavailable'),
          createBattle: create,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start a battle'));
    await tester.pumpAndSettle();
  }

  Future<void> fill(WidgetTester tester, int count) async {
    for (var i = 3; i < count; i++) {
      await tester.ensureVisible(find.text('Add step'));
      await tester.tap(find.text('Add step'));
      await tester.pump();
    }
    await tester.enterText(find.byType(TextField).at(0), '  Test project  ');
    for (var i = 0; i < count; i++) {
      await tester.enterText(
        find.byType(TextField).at(i + 1),
        '  Attack ${i + 1}  ',
      );
    }
    await tester.ensureVisible(find.text('Start Boss Battle'));
  }

  for (final count in [2, 3, 5]) {
    testWidgets('submits $count trimmed steps and closes the creation form', (
      tester,
    ) async {
      var calls = 0;
      await open(tester, ({
        required title,
        required steps,
        bossType = 'inbox_hydra',
      }) async {
        calls++;
        expect(title, 'Test project');
        expect(steps, List.generate(count, (i) => 'Attack ${i + 1}'));
        expect(bossType, 'inbox_hydra');
        return 'created-battle';
      });
      await fill(tester, count);
      await tester.tap(find.text('Start Boss Battle'));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(find.text('Summon a Boss Battle'), findsNothing);
    });
  }
  testWidgets('a second tap cannot submit while the first request is pending', (
    tester,
  ) async {
    final pending = Completer<String>();
    var calls = 0;
    await open(tester, ({
      required title,
      required steps,
      bossType = 'inbox_hydra',
    }) {
      calls++;
      return pending.future;
    });
    await fill(tester, 2);
    await tester.tap(find.text('Start Boss Battle'));
    await tester.tap(find.text('Start Boss Battle'));
    expect(calls, 1);
    pending.complete('created-battle');
    await tester.pumpAndSettle();
  });
  testWidgets('failure stays visible inside the sheet and retains the draft', (
    tester,
  ) async {
    await open(tester, ({
      required title,
      required steps,
      bossType = 'inbox_hydra',
    }) async {
      throw StateError('private server details');
    });
    await fill(tester, 2);
    await tester.tap(find.text('Start Boss Battle'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text(
          'Could not start this Boss Battle. Your draft is saved here. Please try again.',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('  Test project  '), findsOneWidget);
    expect(find.textContaining('private server details'), findsNothing);
  });
  testWidgets('uncertain write keeps the refresh warning visible', (
    tester,
  ) async {
    const warning =
        'Your change may have been received; refresh before trying again.';
    await open(tester, ({
      required title,
      required steps,
      bossType = 'inbox_hydra',
    }) async {
      throw const QuestwellNetworkException(warning);
    });
    await fill(tester, 2);
    await tester.tap(find.text('Start Boss Battle'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text(warning),
      ),
      findsOneWidget,
    );
  });
  testWidgets('validation appears in the form without sending a request', (
    tester,
  ) async {
    var calls = 0;
    await open(tester, ({
      required title,
      required steps,
      bossType = 'inbox_hydra',
    }) async {
      calls++;
      return 'created-battle';
    });
    await tester.ensureVisible(find.text('Start Boss Battle'));
    await tester.tap(find.text('Start Boss Battle'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Add a boss title and at least two attack steps.'),
      ),
      findsOneWidget,
    );
  });
}
