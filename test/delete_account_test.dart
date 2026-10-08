import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/widgets/questwell_delete_account.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  Future<void> mount(
    WidgetTester tester,
    Future<void> Function() remove,
    VoidCallback done,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: QuestwellDeleteAccountButton(onDelete: remove, onDeleted: done),
        ),
      ),
    );
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
  }

  testWidgets('requires explicit confirmation and cancel never deletes', (
    tester,
  ) async {
    var calls = 0;
    await mount(tester, () async {
      calls++;
    }, () {});
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.enterText(find.byType(TextField), 'delete');
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.tap(find.text('Keep my account'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.text('Hang up your boots?'), findsNothing);
  });
  testWidgets('only confirmed deletion succeeds once', (tester) async {
    var calls = 0;
    var done = 0;
    final pending = Completer<void>();
    await mount(
      tester,
      () {
        calls++;
        return pending.future;
      },
      () {
        done++;
      },
    );
    await tester.enterText(find.byType(TextField), 'DELETE');
    await tester.pump();
    await tester.tap(find.text('Delete forever'));
    await tester.pump();
    await tester.tap(find.text('Deleting account…'));
    await tester.pump();
    expect(calls, 1);
    expect(done, 0);
    expect(
      tester
          .widget<TextButton>(
            find.widgetWithText(TextButton, 'Keep my account'),
          )
          .onPressed,
      isNull,
    );
    pending.complete();
    await tester.pumpAndSettle();
    expect(done, 1);
    expect(find.text('Hang up your boots?'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('partial cleanup error can close without reporting deletion', (
    tester,
  ) async {
    var done = 0;
    await mount(
      tester,
      () async {
        throw StateError('storage interrupted');
      },
      () {
        done++;
      },
    );
    await tester.enterText(find.byType(TextField), 'DELETE');
    await tester.pump();
    await tester.tap(find.text('Delete forever'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Some files may already be deleted.'),
      findsOneWidget,
    );
    expect(done, 0);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Hang up your boots?'), findsNothing);
    expect(done, 0);
    expect(tester.takeException(), isNull);
  });
  testWidgets('server failure never shows successful deletion', (tester) async {
    var done = false;
    await mount(
      tester,
      () async {
        throw StateError('offline');
      },
      () {
        done = true;
      },
    );
    await tester.enterText(find.byType(TextField), 'DELETE');
    await tester.pump();
    await tester.tap(find.text('Delete forever'));
    await tester.pumpAndSettle();
    expect(done, isFalse);
    expect(
      find.text(
        'Deletion was not confirmed. Some files may already be deleted. Check your connection and sign in again before retrying.',
      ),
      findsOneWidget,
    );
    expect(find.text('Close'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
