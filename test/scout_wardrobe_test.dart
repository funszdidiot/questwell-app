import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_clean_base.dart';
import '../lib/widgets/questwell_scout_wardrobe.dart';

void main() {
  for (final body in ['female', 'male', 'neutral']) {
    testWidgets('$body modular clothing never restores suit trousers', (tester) async {
      Future<void> render(Set<String> layers) => tester.pumpWidget(MaterialApp(home:
        SizedBox(width: 240, height: 320, child: QuestwellLayeredAdventurerArt(
          archetype: 'scout', avatarBodyType: body, equippedSlugs: const {},
          previewScoutLayers: layers))));
      await render({'top', 'trousers', 'robe'});
      expect(tester.widgetList<QuestwellCleanBase>(find.byType(QuestwellCleanBase))
        .every((base) => !base.withTrousers), isTrue);
      List<String> assets() => tester.widgetList<Image>(find.byType(Image))
        .map((im) => im.image).whereType<AssetImage>().map((im) => im.assetName).toList();
      expect(assets(), contains(QuestwellScoutWardrobeFoundation.asset(body, 'trousers')));
      await render({'top', 'trousers'});
      expect(assets(), isNot(contains(QuestwellScoutWardrobeFoundation.asset(body, 'robe'))));
      expect(assets(), contains(QuestwellScoutWardrobeFoundation.asset(body, 'top')));
      await render({});
      expect(assets().any((path) => path.contains('/scout_')), isFalse);
      expect(find.byType(QuestwellCleanBase), findsWidgets);
    });
  }
  test('robe hides protruding sleeves but retains open front and hands', () {
    final clip = ScoutWardrobeClipper('male', 'robeUnder').getClip(const Size(240, 320));
    expect(clip.contains(const Offset(120, 120)), isTrue);
    expect(clip.contains(const Offset(70, 187)), isTrue);
    expect(clip.contains(const Offset(70, 125)), isFalse);
  });
}
