import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/add_task_page/add_task_page_widget.dart';
import 'package:project_momentum/preview/market_catalog.dart';
import 'package:project_momentum/preview/mobile_review.dart';
import 'package:project_momentum/services/questwell_cosmetic_models.dart';
import 'package:project_momentum/widgets/questwell_market_view.dart';
import 'package:project_momentum/preview/home_sections_review.dart';
import 'package:project_momentum/preview/quest_board_review.dart';
import 'package:project_momentum/preview/adventurer_review.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  Widget phone(Widget child) => MaterialApp(
    theme: ThemeData.dark(),
    builder: (context, navigator) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(2), disableAnimations: true),
      child: navigator!),
    home: child,
  );

  Future<void> smallPhone(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('Quest form remains reachable with large text and keyboard', (tester) async {
    await smallPhone(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(phone(const AddTaskPageWidget()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byType(TextFormField));
    await tester.enterText(find.byType(TextFormField), 'Write the first three steps for the project');
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(find.text('Hard to Start').hitTestable(),
      find.byType(SingleChildScrollView).first, const Offset(0, -180), maxIteration: 40);
    await tester.tap(find.text('Hard to Start'));
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    final post = find.ancestor(of: find.text('Post to Quest Board'),
      matching: find.byWidgetPredicate((widget) => widget is FilledButton));
    await tester.ensureVisible(post);
    await tester.pumpAndSettle();
    expect(post.hitTestable(), findsOneWidget);
    expect(tester.widget<FilledButton>(post).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
    // Do not submit: this is the real form, with no account fixture.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Market purchase can be cancelled on a short phone at 200% text', (tester) async {
    await smallPhone(tester);
    var purchases = 0;
    final data = QuestwellCosmeticsSnapshot(
      profile: const QuestwellProfile(level: 4, totalXp: 355, coinBalance: 650,
        currentEnergyMode: 'normal', onboardingCompleted: true,
        adventurerArchetype: 'scholar', avatarBodyType: 'female'),
      cosmetics: marketReviewCatalog.map((r) => QuestwellCosmetic.fromJson(r)).toList());
    await tester.pumpWidget(phone(Scaffold(body: QuestwellMarketView(
      data: data, onPurchase: (_) async { purchases++; }, onEquip: (_) async {},
      onUnequip: (_) async {}, onRefresh: () async {}))));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'moss-green');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final category = find.widgetWithText(TextButton, 'All');
    final filter = find.widgetWithText(OutlinedButton, 'My class');
    expect(tester.getSize(category).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(filter).height, greaterThanOrEqualTo(48));
    final buy = find.widgetWithText(FilledButton, 'Buy · 90 coins');
    await tester.dragUntilVisible(buy.hitTestable(), find.byType(ListView),
      const Offset(0, -160), maxIteration: 30);
    await tester.tap(buy);
    await tester.pumpAndSettle();
    expect(find.text('Buy Moss-Green Cloak?'), findsOneWidget);
    expect(MediaQuery.textScalerOf(tester.element(find.byType(AlertDialog))).scale(14), 28);
    expect(find.text('Cancel').hitTestable(), findsOneWidget);
    expect(find.text('Buy item').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(purchases, 0);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Mobile preview applies phone size and text scale to dialogs', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 850));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MediaQuery(
      data: MediaQueryData(size: Size(1000, 850), disableAnimations: true),
      child: MobileReviewApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('390 px')); await tester.pumpAndSettle();
    await tester.tap(find.text('430 px')); await tester.pumpAndSettle();
    await tester.tap(find.text('100% text')); await tester.pumpAndSettle();
    await tester.tap(find.text('160% text')); await tester.pumpAndSettle();
    final claim = find.descendant(
      of: find.byKey(const ValueKey('market-everyday-adventurer-outfit')),
      matching: find.widgetWithText(FilledButton, 'Buy · 40 coins'));
    await tester.dragUntilVisible(claim.hitTestable(), find.byType(ListView),
      const Offset(0, -200), maxIteration: 30);
    await tester.tap(claim); await tester.pumpAndSettle();
    final context = tester.element(find.byType(AlertDialog));
    expect(MediaQuery.sizeOf(context), const Size(320, 568));
    expect(MediaQuery.textScalerOf(context).scale(14), 28);
    expect(find.text('Cancel').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Cancel')); await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
  });

  for (final entry in <String, Widget>{
    'Hearth': const HomeSectionsReviewApp(),
    'Quest Board': const QuestBoardReviewApp(),
    'Adventurer': const AdventurerReviewApp(),
  }.entries) {
    testWidgets('${entry.key} scrolls on a short phone at 200% text', (tester) async {
      await smallPhone(tester);
      await tester.pumpWidget(phone(entry.value));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final list = find.byType(ListView).first;
      for (var i = 0; i < 16; i++) {
        await tester.drag(list, const Offset(0, -300));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '${entry.key}, scroll $i');
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
}
