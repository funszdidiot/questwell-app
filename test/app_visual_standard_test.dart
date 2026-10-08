import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/preview/mobile_review.dart';
import 'package:project_momentum/preview/quest_board_review.dart';
import 'package:project_momentum/add_task_page/add_task_page_widget.dart';
import 'package:project_momentum/widgets/questwell_quest_card.dart';
import 'package:project_momentum/preview/market_catalog.dart';
import 'package:project_momentum/services/questwell_cosmetic_models.dart';
import 'package:project_momentum/widgets/questwell_market_view.dart';
import 'package:project_momentum/widgets/questwell_app_navigation.dart';
import 'package:project_momentum/widgets/questwell_app_style.dart';
import 'package:project_momentum/widgets/questwell_delete_account.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  for (final screen in [
    'Hearth',
    'Quests',
    'New quest',
    'Market',
    'Adventurer',
    'Boss Battles',
    'Chronicle',
    'Expedition'
  ]) {
    for (final setting in [(390.0, 1.0), (320.0, 2.0)]) {
      testWidgets(
          '$screen uses the shared shell at ${setting.$1}/${setting.$2}',
          (tester) async {
        final font = FontLoader('HearthSerif')
          ..addFont(rootBundle.load('assets/fonts/DejaVuSerif-Bold.ttf'));
        await font.load();
        final pixelFont = FontLoader(GoogleFonts.pressStart2p().fontFamily!)
          ..addFont(rootBundle.load('assets/fonts/PressStart2P-Regular.ttf'));
        await pixelFont.load();
        await tester.binding.setSurfaceSize(const Size(1000, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(TickerMode(
            enabled: false,
            child: MobileReviewApp(
                initialScreen: screen,
                initialWidth: setting.$1,
                initialTextScale: setting.$2)));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(QuestwellAppNavigation), findsOneWidget);
        expect(find.text('Hearth'), findsWidgets);
        expect(tester.takeException(), isNull,
            reason: '$screen must preserve layout with the common navigation');
        if (screen == 'Quests' && setting.$2 == 2) {
          final quest = find.byWidgetPredicate((widget) =>
              widget is QuestwellQuestCard &&
              widget.title == 'Send the email you have been putting off');
          final action =
              find.descendant(of: quest, matching: find.text('Complete quest'));
          // The noticeboard is built lazily below the enlarged heading/filters.
          await tester.scrollUntilVisible(action, 200,
              scrollable: find.byType(Scrollable).first);
          await tester.pump();
          final label = tester.renderObject<RenderParagraph>(action);
          for (final range in [(0, 8), (9, 14)]) {
            expect(
                label.getBoxesForSelection(TextSelection(
                    baseOffset: range.$1, extentOffset: range.$2)),
                hasLength(1),
                reason: 'The completion icon must not split enlarged words');
          }
          expect(label.textScaler.scale(17), 34);
          expect(action.hitTestable(), findsOneWidget);
          await tester.tap(action);
          await tester.pump();
          expect(find.text('Send the email you have been putting off'),
              findsNothing);
          final completed =
              find.text('1 quest finished this visit. Keep your momentum.');
          await tester.scrollUntilVisible(completed, -200,
              scrollable: find.byType(Scrollable).first);
          expect(completed, findsOneWidget);
        }
        if (screen == 'Market' && setting.$2 == 2) {
          await tester.scrollUntilVisible(find.text('Business Suit'), 200,
              scrollable: find.byType(Scrollable).first);
          await tester.pump();
          final title =
              tester.renderObject<RenderParagraph>(find.text('Business Suit'));
          for (final range in [(0, 8), (9, 13)]) {
            expect(
                title.getBoxesForSelection(TextSelection(
                    baseOffset: range.$1, extentOffset: range.$2)),
                hasLength(1),
                reason: 'Enlarged item names must wrap between whole words');
          }
          expect(title.textScaler.scale(18), 36);
        }
        if (screen == 'Chronicle') {
          final heading =
              tester.renderObject<RenderParagraph>(find.text('CHRONICLE'));
          expect(
              heading.getBoxesForSelection(
                  const TextSelection(baseOffset: 0, extentOffset: 9)),
              hasLength(1));
          expect(heading.textScaler.scale(12), 12 * setting.$2);
          final back = find.byTooltip('Back to the Hearth');
          expect(
              tester
                  .getRect(find.text('CHRONICLE'))
                  .overlaps(tester.getRect(back)),
              isFalse);
        }
        if (screen == 'Expedition' && setting.$2 == 2) {
          // Overflow exceptions do not catch a single trailing letter wrapping.
          void expectWholeAction(String text) {
            final paragraph =
                tester.renderObject<RenderParagraph>(find.text(text));
            expect(
                paragraph.getBoxesForSelection(
                    TextSelection(baseOffset: 0, extentOffset: text.length)),
                hasLength(1),
                reason: 'The enlarged $text action must stay on one line');
          }

          await tester.ensureVisible(find.text('Begin'));
          await tester.pump();
          expectWholeAction('Begin');
          await tester.tap(find.text('Begin'));
          await tester.pump();
          // Starting changes the panel height; reach its new button position.
          await tester.ensureVisible(find.text('Pause'));
          await tester.pump();
          expect(find.text('Pause').hitTestable(), findsOneWidget);
          await tester.tap(find.text('Pause'));
          await tester.pump();
          expectWholeAction('Resume');
        }
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  testWidgets('Preview retains chosen effort from creation through editing',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
        const QuestBoardReviewApp(openNewQuest: true, initialQuests: []));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Put one book away');
    FocusManager.instance.primaryFocus?.unfocus();
    for (final action in ['Easy', 'Post to Quest Board']) {
      await tester.ensureVisible(find.text(action));
      await tester.pumpAndSettle();
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();
    }
    final createdCard = find.byWidgetPredicate((widget) =>
        widget is QuestwellQuestCard && widget.title == 'Put one book away');
    final card = tester.widget<QuestwellQuestCard>(createdCard);
    expect(card.effort, 'Easy');
    expect((card.xp, card.coins), (10, 5));
    final editAction =
        find.descendant(of: createdCard, matching: find.text('Edit quest'));
    await tester.ensureVisible(editAction);
    await tester.pumpAndSettle();
    await tester.tap(editAction);
    await tester.pumpAndSettle();
    final edit =
        tester.widget<AddTaskPageWidget>(find.byType(AddTaskPageWidget));
    expect(edit.initialTitle, 'Put one book away');
    expect(
        (edit.initialFriction, edit.initialXp, edit.initialCoins), (1, 10, 5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Market preserves whole words with nonlinear enlarged text',
      (tester) async {
    final font = FontLoader('HearthSerif')
      ..addFont(rootBundle.load('assets/fonts/DejaVuSerif-Bold.ttf'));
    await font.load();
    await tester.binding.setSurfaceSize(const Size(340, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
        theme: QuestwellAppStyle.theme(),
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
                textScaler: const _NonlinearLargeText(),
                disableAnimations: true),
            child: child!),
        home: Scaffold(
            body: QuestwellMarketView(
                data: QuestwellCosmeticsSnapshot(
                    profile: QuestwellProfile(
                        level: 4,
                        totalXp: 355,
                        coinBalance: 100,
                        currentEnergyMode: 'normal',
                        onboardingCompleted: true,
                        adventurerArchetype: 'scholar',
                        avatarBodyType: 'male'),
                    cosmetics: [
                      QuestwellCosmetic.fromJson(marketReviewCatalog
                          .firstWhere((row) => row['name'] == 'Business Suit'))
                    ]),
                onPurchase: (_) async {},
                onEquip: (_) async {},
                onUnequip: (_) async {},
                onRefresh: () async {}))));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Business Suit'), 200,
        scrollable: find.byType(Scrollable).first);
    final title =
        tester.renderObject<RenderParagraph>(find.text('Business Suit'));
    expect(title.textScaler.scale(18), 36);
    for (final range in [(0, 8), (9, 13)]) {
      expect(
          title.getBoxesForSelection(
              TextSelection(baseOffset: range.$1, extentOffset: range.$2)),
          hasLength(1));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Deletion keeps its warning color under the shared button theme',
      (tester) async {
    final font = FontLoader('HearthSerif')
      ..addFont(rootBundle.load('assets/fonts/DejaVuSerif-Bold.ttf'));
    await font.load();
    await tester.binding.setSurfaceSize(const Size(320, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
        theme: QuestwellAppStyle.theme(),
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(2)),
            child: child!),
        home: Scaffold(
            body: QuestwellDeleteAccountButton(
                preview: true, onDelete: () async {}, onDeleted: () {}))));
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Delete forever'));
    expect(button.style!.backgroundColor!.resolve({}), const Color(0xFF9E352E));
    // A local red fill must not inherit the theme's emerald painting layer.
    const child = SizedBox(width: 4, height: 4);
    expect(
        button.style!.backgroundBuilder!(
            tester.element(find.byType(AlertDialog)), {}, child),
        same(child));
    expect(button.onPressed, isNull);
    final label =
        tester.renderObject<RenderParagraph>(find.text('Delete forever'));
    for (final range in [(0, 6), (7, 14)]) {
      expect(
          label.getBoxesForSelection(
              TextSelection(baseOffset: range.$1, extentOffset: range.$2)),
          hasLength(1),
          reason: 'Deletion warning action must wrap only between whole words');
    }
    expect(tester.takeException(), isNull);
  });
}

// Model the nonlinear case: body-sized text doubles while very large text
// receives much less scaling. Layout must use the actual title font size.
class _NonlinearLargeText extends TextScaler {
  const _NonlinearLargeText();
  @override
  double scale(double fontSize) =>
      fontSize <= 20 ? fontSize * 2 : fontSize + 20;
  @override
  double get textScaleFactor => 2;
}
