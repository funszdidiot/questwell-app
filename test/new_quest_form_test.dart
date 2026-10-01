import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/add_task_page/add_task_page_widget.dart';
import 'package:project_momentum/preview/quest_board_review.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  Future<void> mount(WidgetTester tester, AddTaskPageWidget form) async {
    await tester.binding.setSurfaceSize(const Size(430, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(theme: ThemeData.dark(), home: form));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pump();
  }

  testWidgets('Validation, selected rewards, and duplicate submission guard', (tester) async {
    var calls = 0;
    var closed = 0;
    final pending = Completer<void>();
    await mount(tester, AddTaskPageWidget(onClose: () => closed++,
      onCreate: (title, friction, xp, coins) {
        calls++;
        expect(title, 'Write one paragraph');
        expect((friction, xp, coins), (3, 35, 18));
        return pending.future;
      }));
    await tap(tester, 'Post to Quest Board');
    expect(calls, 0);
    expect(find.text('Give this quest a name first.'), findsOneWidget);
    await tester.ensureVisible(find.byType(TextFormField));
    await tester.enterText(find.byType(TextFormField), '  Write one paragraph  ');
    FocusManager.instance.primaryFocus?.unfocus();
    await tap(tester, 'Post to Quest Board');
    expect(calls, 0);
    await tap(tester, 'Hard to Start');
    await tap(tester, 'Post to Quest Board');
    expect(calls, 1);
    await tester.tap(find.text('Posting quest…'));
    await tester.pump();
    expect(calls, 1);
    pending.complete();
    await tester.pumpAndSettle();
    expect(closed, 1);
  });

  testWidgets('Failed save keeps draft and allows retry', (tester) async {
    var attempts = 0;
    var closed = 0;
    await mount(tester, AddTaskPageWidget(onClose: () => closed++,
      onCreate: (title, friction, xp, coins) async {
        if (++attempts == 1) throw StateError('sample failure');
      }));
    await tester.enterText(find.byType(TextFormField), 'A small step');
    FocusManager.instance.primaryFocus?.unfocus();
    await tap(tester, 'Easy');
    await tap(tester, 'Post to Quest Board');
    await tester.pumpAndSettle();
    expect(closed, 0);
    expect(find.text('Could not add this quest. Please try again.'), findsOneWidget);
    expect(tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text, 'A small step');
    await tap(tester, 'Post to Quest Board');
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(closed, 1);
  });

  testWidgets('Back and Quests protect the entered draft', (tester) async {
    var closed = 0;
    await mount(tester, AddTaskPageWidget(onClose: () => closed++));
    await tester.enterText(find.byType(TextFormField), 'Keep this draft');
    FocusManager.instance.primaryFocus?.unfocus();
    await tap(tester, 'Back to quests');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep editing')); await tester.pumpAndSettle();
    expect(closed, 0);
    expect(tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text, 'Keep this draft');
    await tester.tap(find.text('Quests')); await tester.pumpAndSettle();
    expect(find.text('Leave this quest draft?'), findsOneWidget);
    await tester.tap(find.text('Discard draft')); await tester.pumpAndSettle();
    expect(closed, 1);
  });

  testWidgets('Direct new quest preview returns to the board', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const QuestBoardReviewApp(openNewQuest: true));
    await tester.pumpAndSettle();
    expect(find.text('NEW QUEST'), findsOneWidget);
    await tester.tap(find.text('Back to quests')); await tester.pumpAndSettle();
    expect(find.text('QUEST BOARD'), findsOneWidget);
    expect(find.text('NEW QUEST'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
