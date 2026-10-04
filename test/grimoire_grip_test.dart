import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/questwell_annotated_grimoire.dart';
import '../lib/widgets/questwell_pixel_art.dart';

void main() {
  test('Belt-mounted book clears the complete relaxed hands on every body', () {
    for (final body in ['female', 'male', 'neutral']) {
      final book = QuestwellAnnotatedGrimoire.bounds(body);
      final pivot = book.topCenter;
      final corners = [book.topLeft, book.topRight, book.bottomLeft, book.bottomRight]
        .map((p) {
          final d = p - pivot;
          return pivot + Offset(
            d.dx * math.cos(QuestwellAnnotatedGrimoire.angle) -
              d.dy * math.sin(QuestwellAnnotatedGrimoire.angle),
            d.dx * math.sin(QuestwellAnnotatedGrimoire.angle) +
              d.dy * math.cos(QuestwellAnnotatedGrimoire.angle));
        }).toList();
      final visual = Rect.fromLTRB(corners.map((p) => p.dx).reduce(math.min),
        corners.map((p) => p.dy).reduce(math.min),
        corners.map((p) => p.dx).reduce(math.max),
        corners.map((p) => p.dy).reduce(math.max));
      final hands = body == 'female'
        ? [const Rect.fromLTRB(62, 169, 88, 198), const Rect.fromLTRB(153, 169, 180, 198)]
        : [const Rect.fromLTRB(57, 173, 89, 202), const Rect.fromLTRB(157, 173, 184, 202)];
      for (final hand in hands) {
        expect(visual.overlaps(hand), isFalse, reason: '$body book clears $hand');
      }
      expect(QuestwellAnnotatedGrimoire.beltAnchor(body).dy, lessThan(book.top));
    }
  });

  testWidgets('Equipping the book adds no anatomy clips or replacement grips', (tester) async {
    for (final body in ['female', 'male', 'neutral']) {
      Widget scene(Map<String, String> equipment) => MaterialApp(home: Center(
        child: SizedBox(width: 240, height: 320, child: QuestwellLayeredAdventurerArt(
          archetype: 'scholar', avatarBodyType: body, equippedSlugs: equipment))));
      List<String> assets() => tester.widgetList<Image>(find.byType(Image))
        .where((image) => image.image is AssetImage)
        .map((image) => (image.image as AssetImage).assetName).toList();
      List<String> clips() => tester.widgetList<ClipPath>(find.byType(ClipPath))
        .map((clip) => clip.clipper.runtimeType.toString()).toList();
      await tester.pumpWidget(scene({}));
      await tester.pumpAndSettle();
      final baselineAssets = assets();
      final baselineClips = clips();
      final saved = {'hands': QuestwellAnnotatedGrimoire.slug};
      await tester.pumpWidget(scene(saved));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(QuestwellAnnotatedGrimoire), findsOneWidget);
      expect(assets(), contains(QuestwellAnnotatedGrimoire.asset));
      expect(assets().where((asset) => asset != QuestwellAnnotatedGrimoire.asset), baselineAssets,
        reason: 'Equipping must keep the existing avatar and garment layers intact');
      expect(assets().any((asset) => asset.contains('grimoire_grip')), isFalse);
      expect(clips(), baselineClips, reason: 'Book attachment cannot clip anatomy');
      expect(saved, {'hands': QuestwellAnnotatedGrimoire.slug});
      await tester.pumpWidget(scene({}));
      await tester.pumpAndSettle();
      expect(assets(), baselineAssets);
      expect(clips(), baselineClips);
      expect(find.byType(QuestwellAnnotatedGrimoire), findsNothing);
      await tester.pumpWidget(scene({'hands': 'annotated-grimoire', 'chest': 'moss-green-cloak'}));
      await tester.pumpAndSettle();
      expect(find.byType(QuestwellAnnotatedGrimoire), findsNothing,
        reason: 'Existing cloak equipment conflict still applies');
      expect(tester.takeException(), isNull);
    }
  });
}
