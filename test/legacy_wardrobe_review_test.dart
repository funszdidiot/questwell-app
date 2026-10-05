import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/preview/legacy_wardrobe_review.dart';
import '../lib/widgets/questwell_pixel_art.dart';

void main() {
  testWidgets('focused female coat review retains shared equip and class restoration', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const LegacyWardrobeReviewApp(
      initialBody: 'female', focusGarment: 'midnight-harvest-coat'));
    await tester.pumpAndSettle();
    var renders = tester.widgetList<QuestwellLayeredAdventurerArt>(
      find.byType(QuestwellLayeredAdventurerArt)).toList();
    expect(renders, hasLength(2));
    expect(renders.every((art) => art.avatarBodyType == 'female'), isTrue);
    expect(renders.map((art) => art.equippedSlugs['chest']).toSet(),
      {null, 'midnight-harvest-coat'});
    await tester.tap(find.widgetWithText(ChoiceChip, 'guardian'));
    await tester.tap(find.widgetWithText(FilterChip, 'Garments equipped'));
    await tester.pumpAndSettle();
    renders = tester.widgetList<QuestwellLayeredAdventurerArt>(
      find.byType(QuestwellLayeredAdventurerArt)).toList();
    expect(renders.every((art) => art.equippedSlugs.isEmpty &&
      art.avatarBodyType == 'female' && art.archetype == 'guardian'), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('legacy audit uses shared equipment paths and restores class defaults', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final width in [390.0, 1200.0]) {
      await tester.binding.setSurfaceSize(Size(width, 1000));
      await tester.pumpWidget(const LegacyWardrobeReviewApp());
      await tester.pumpAndSettle();
      for (final body in ['male', 'female', 'neutral']) {
        await tester.tap(find.widgetWithText(ChoiceChip, body));
        await tester.pumpAndSettle();
        final renders = tester.widgetList<QuestwellLayeredAdventurerArt>(
          find.byType(QuestwellLayeredAdventurerArt)).toList();
        expect(renders, hasLength(5));
        expect(renders.every((art) => art.avatarBodyType == body), isTrue);
        expect(renders.map((art) => art.equippedSlugs['chest']).toSet(), {
          null, 'starter-business-suit', 'midnight-harvest-coat',
          'moss-green-cloak', 'hearthguard-mantle',
        });
        await tester.tap(find.widgetWithText(FilterChip, 'Garments equipped'));
        await tester.pumpAndSettle();
        expect(tester.widgetList<QuestwellLayeredAdventurerArt>(
          find.byType(QuestwellLayeredAdventurerArt)).every((art) =>
            art.equippedSlugs.isEmpty && art.avatarBodyType == body), isTrue);
        await tester.tap(find.widgetWithText(FilterChip, 'Garments equipped'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}
