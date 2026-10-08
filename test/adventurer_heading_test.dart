import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../lib/widgets/questwell_adventurer_view.dart';

void main() {
  for (final width in [320.0, 390.0, 430.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Adventurer heading stays whole at $width px / ${scale}x',
          (tester) async {
        GoogleFonts.config.allowRuntimeFetching = false;
        await tester.binding.setSurfaceSize(Size(width, 740));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        var returnedHome = false;
        await tester.pumpWidget(MaterialApp(
            home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: Scaffold(
              body: QuestwellAdventurerView(
            archetype: 'scout',
            bodyType: 'neutral',
            level: 3,
            xp: 95,
            coins: 49,
            description: '',
            items: const [],
            mastered: false,
            collectionOwned: 0,
            collectionTotal: 0,
            relicName: '',
            canClaim: false,
            onClaim: () {},
            onBody: (_) {},
            onClass: (_) {},
            onEquip: (_) {},
            onUnequip: (_) {},
            onMarket: () {},
            onBack: () => returnedHome = true,
          )),
        )));
        await tester.pump(const Duration(milliseconds: 300));

        final title =
            tester.renderObject<RenderParagraph>(find.text('ADVENTURER'));
        // A split final letter is legal layout, so exception checks miss it.
        expect(
            title.getBoxesForSelection(
                const TextSelection(baseOffset: 0, extentOffset: 10)),
            hasLength(1));
        expect(title.textScaler.scale(12), 12 * scale);
        final titleRect = tester.getRect(find.text('ADVENTURER'));
        expect(titleRect.left, greaterThanOrEqualTo(18));
        expect(titleRect.right, lessThanOrEqualTo(width - 18));
        // Measure the outer tap target, not the smaller visual inside Tooltip.
        final back = find.byTooltip('Back to the Hearth');
        final backRect = tester.getRect(back);
        expect(backRect.width, greaterThanOrEqualTo(48));
        expect(backRect.height, greaterThanOrEqualTo(48));
        expect(titleRect.overlaps(backRect), isFalse);
        final subtitle = tester
            .renderObject<RenderParagraph>(find.text('Make yourself at home.'));
        expect(subtitle.textScaler.scale(14), 14 * scale);
        await tester.tapAt(backRect.topLeft + const Offset(1, 1));
        expect(returnedHome, isTrue);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
