import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/questwell_pathfinder_boots.dart';
import '../lib/widgets/questwell_pixel_art.dart';

void main() {
  test('Boot replacement removes shoes but preserves upper trousers', () {
    for (final body in ['female', 'male', 'neutral']) {
      final clip = PathfinderBaseClipper(body).getClip(const Size(240, 320));
      expect(clip.contains(const Offset(95, 290)), isFalse);
      expect(clip.contains(const Offset(160, 300)), isFalse);
      expect(clip.contains(const Offset(100, 235)), isTrue);
      expect(clip.contains(const Offset(164, 184)), isTrue);
    }
  });

  testWidgets('Boots load on all bodies, work beneath cloaks, and restore shoes on removal', (tester) async {
    for (final body in ['female', 'male', 'neutral']) {
      for (final cloak in ['', 'moss-green-cloak', 'hearthguard-mantle']) {
        Widget scene(bool worn) => MaterialApp(home: SizedBox(width: 240, height: 320,
          child: QuestwellLayeredAdventurerArt(archetype: 'scout', avatarBodyType: body,
            equippedSlugs: {if (worn) 'feet': 'pathfinder-boots', if (cloak.isNotEmpty) 'chest': cloak})));
        await tester.pumpWidget(scene(true));
        await tester.pumpAndSettle();
        expect(find.byType(QuestwellPathfinderBoots), findsOneWidget);
        expect(tester.takeException(), isNull);
        final names = tester.widgetList<Image>(find.byType(Image)).where((i) => i.image is AssetImage)
          .map((i) => (i.image as AssetImage).assetName);
        expect(names, containsAll([QuestwellPathfinderBoots.leftAsset, QuestwellPathfinderBoots.rightAsset]));
        await tester.pumpWidget(scene(false));
        await tester.pumpAndSettle();
        expect(find.byType(QuestwellPathfinderBoots), findsNothing);
        expect(find.byWidgetPredicate((w) => w is ClipPath && w.clipper is PathfinderBaseClipper), findsNothing);
        expect(tester.takeException(), isNull);
      }
    }
  });
}
