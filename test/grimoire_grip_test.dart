import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/questwell_annotated_grimoire.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_scholar_cuffs.dart';

void main() {
  test('Grip mask removes only the relaxed hand and keeps cuff and other body parts', () {
    for (final body in ['female', 'male', 'neutral']) {
      final mask = GrimoireHandUnderlayerClipper(body).getClip(const Size(240, 320));
      expect(mask.contains(const Offset(164, 184)), isFalse);
      for (final point in [const Offset(70, 184), const Offset(120, 50),
          const Offset(164, 163), const Offset(100, 298)]) {
        expect(mask.contains(point), isTrue, reason: '$body keeps $point');
      }
      final cuff = GrimoireCuffClipper(body).getClip(const Size(240, 320));
      expect(cuff.contains(const Offset(164, 184)), isFalse,
        reason: 'The old hand must never be restored over the new grip');
    }
  });
  test('Left-hand grip registers its mirrored wrist on every body', () {
    for (final body in ['female', 'male', 'neutral']) {
      final bounds = QuestwellAnnotatedGrimoire.bounds(body);
      final expectedX = body == 'female' ? 162.0 : body == 'male' ? 166.5 : 164.8;
      expect(bounds.left + bounds.width * 766 / 1062, closeTo(expectedX, .001));
    }
  });
  testWidgets('Each body loads the integrated grip and unequipping restores its normal hand', (tester) async {
    final mask = find.byWidgetPredicate((w) => w is ClipPath && w.clipper is GrimoireHandUnderlayerClipper);
    for (final body in ['female', 'male', 'neutral']) {
      Widget scene(Map<String, String> equipment) => MaterialApp(home: Center(
        child: SizedBox(width: 240, height: 320, child: QuestwellLayeredAdventurerArt(
          archetype: 'scholar', avatarBodyType: body, equippedSlugs: equipment))));
      await tester.pumpWidget(scene({'hands': 'annotated-grimoire'}));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(QuestwellAnnotatedGrimoire), findsOneWidget);
      expect(mask, findsOneWidget);
      expect(find.byType(QuestwellScholarCuffs), body == 'female' ? findsNothing : findsOneWidget);
      if (body == 'female') {
        expect(tester.widgetList<Image>(find.byType(Image)).any((image) =>
          image.image is AssetImage && (image.image as AssetImage).assetName ==
            'assets/images/questwell/avatar/classes/scholar/scholar_robe_cuff_front_female_v3.webp'), isTrue);
      }
      final images = tester.widgetList<Image>(find.byType(Image));
      expect(images.any((image) => image.image is AssetImage &&
        (image.image as AssetImage).assetName == QuestwellAnnotatedGrimoire.asset), isTrue);
      await tester.pumpWidget(scene({}));
      await tester.pumpAndSettle();
      expect(mask, findsNothing);
      expect(find.byType(QuestwellScholarCuffs), body == 'female' ? findsNothing : findsOneWidget);
      expect(find.byType(QuestwellAnnotatedGrimoire), findsNothing);
      await tester.pumpWidget(scene({'hands': 'annotated-grimoire', 'chest': 'moss-green-cloak'}));
      await tester.pumpAndSettle();
      expect(find.byType(QuestwellScholarCuffs), findsNothing);
      expect(mask, findsNothing, reason: 'Stale held gear cannot replace hands under a cloak');
      expect(find.byType(QuestwellAnnotatedGrimoire), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });
}
