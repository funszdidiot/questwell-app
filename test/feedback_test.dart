import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/services/questwell_feedback_draft.dart';
import '../lib/widgets/questwell_feedback.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  QuestwellFeedbackDraft draft() => QuestwellFeedbackDraft(screen: 'Quests',
    build: 'test-build', platform: 'web-ios');
  Finder field(String label) => find.widgetWithText(TextFormField, label);
  Finder send() => find.widgetWithText(FilledButton, 'Send feedback');

  test('Draft storage is account-scoped, serialized, and cleared after send', () async {
    SharedPreferences.setMockInitialValues({});
    final first = QuestwellFeedbackDraftStore('first');
    final second = QuestwellFeedbackDraftStore('second');
    final pending = draft().copyWith(goal: 'Find a quest', message: 'Lost the button', attempted: true);
    final save = first.save(pending);
    final clear = first.clear();
    await Future.wait([save, clear]);
    expect(await first.load(), isNull);
    await first.save(pending);
    expect(await second.load(), isNull);
    final restored = await first.load();
    expect(restored!.id, pending.id);
    expect(restored.attempted, isTrue);
    expect(restored.message, pending.message);
    await first.clear();
    expect(await first.load(), isNull);
  });

  testWidgets('Failed send retains text and request ID across close/reopen; retry sends once', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(390, 850));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    QuestwellFeedbackDraft? saved;
    Future<void> save(QuestwellFeedbackDraft value) async { saved = value; }
    Future<void> clear() async { saved = null; }
    final submitted = <String>[];
    var attempts = 0;
    Future<void> submit(QuestwellFeedbackDraft value) async {
      submitted.add(value.id);
      if (attempts++ == 0) throw TimeoutException('simulated lost response');
    }
    Widget app(QuestwellFeedbackDraft value, String key) => MaterialApp(
      home: Scaffold(body: QuestwellFeedbackForm(key: ValueKey(key), initialDraft: value,
        onSave: save, onClear: clear, onSubmit: submit, onClose: () {})));
    await tester.pumpWidget(app(draft(), 'first'));
    await tester.enterText(field('What were you trying to do?'), 'Complete a quest');
    await tester.enterText(field('What happened?'), 'The button did not respond.');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(send()); await tester.pumpAndSettle(); await tester.tap(send()); await tester.pumpAndSettle();
    expect(find.textContaining('We could not confirm delivery.'), findsOneWidget);
    expect(find.text('The button did not respond.'), findsOneWidget);
    final restored = saved!;
    await tester.pumpWidget(app(restored, 'reopened')); await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(send()); await tester.pumpAndSettle(); await tester.tap(send()); await tester.pumpAndSettle();
    expect(submitted, [restored.id, restored.id]);
    expect(find.text('Thanks, adventurer. Your note is in our journal.'), findsOneWidget);
    expect(saved, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Empty submissions are blocked; busy form prevents repeat sends and closing', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 850));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final completion = Completer<void>();
    var sends = 0, closes = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: QuestwellFeedbackForm(
      initialDraft: draft(), onSave: (_) async {}, onClear: () async {},
      onSubmit: (_) { sends++; return completion.future; }, onClose: () => closes++))));
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(send()); await tester.pumpAndSettle(); await tester.tap(send()); await tester.pumpAndSettle();
    expect(sends, 0);
    expect(find.text('Please add a few words.'), findsNWidgets(2));
    await tester.enterText(field('What were you trying to do?'), 'Find my last quest');
    await tester.enterText(field('What happened?'), 'I found it in Chronicle.');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(send()); await tester.pumpAndSettle(); await tester.tap(send()); await tester.pump();
    expect(sends, 1);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Sending…')).onPressed, isNull);
    expect(tester.widget<IconButton>(find.byWidgetPredicate((w) => w is IconButton && w.tooltip == 'Close feedback')).onPressed, isNull);
    expect(closes, 0);
    completion.complete(); await tester.pumpAndSettle();
    expect(find.text('NOTE RECEIVED'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Small screen and enlarged text keep form and keyboard content scrollable', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(home: MediaQuery(
      data: const MediaQueryData(size: Size(320, 568), textScaler: TextScaler.linear(2)),
      child: Scaffold(body: SizedBox(height: 320, child: QuestwellFeedbackForm(
        initialDraft: draft(), preview: true, onSave: (_) async {}, onClear: () async {},
        onSubmit: (_) async {}, onClose: () {}))))));
    await tester.pumpAndSettle();
    await tester.ensureVisible(field('What happened?')); await tester.pumpAndSettle();
    await tester.enterText(field('What happened?'), 'A longer observation on a small phone.');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(send()); await tester.pumpAndSettle(); await tester.pumpAndSettle();
    expect(send().hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
