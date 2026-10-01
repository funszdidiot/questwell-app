import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_wanderer_cuffs.dart';

void main() {
  test('Wanderer cuff mask leaves hands, face and coat front intact', () {
    for (final body in ['female', 'male', 'neutral']) {
      final mask = WandererCuffReplacementClipper(body).getClip(const Size(240, 320));
      expect(mask.contains(const Offset(164, 184)), isTrue);
      expect(mask.contains(const Offset(70, 184)), isTrue);
      expect(mask.contains(const Offset(120, 50)), isTrue);
      expect(mask.contains(const Offset(120, 170)), isTrue);
      expect(mask.contains(Offset(163, body == 'female' ? 164 : 169)), isFalse);
    }
  });
  testWidgets('Fitted cuffs survive satchel restoration and hide with replacement outfits', (tester) async {
    for (final body in ['female', 'male', 'neutral']) {
      Widget scene(String? chest) => MaterialApp(home: SizedBox(width: 240, height: 320,
        child: QuestwellLayeredAdventurerArt(archetype: 'wanderer', avatarBodyType: body,
          equippedSlugs: {'back': 'wayfarer-satchel', if (chest != null) 'chest': chest})));
      await tester.pumpWidget(scene(null));
      await tester.pumpAndSettle();
      expect(find.byType(QuestwellWandererCuffs), findsOneWidget);
      expect(tester.takeException(), isNull);
      for (final chest in ['moss-green-cloak', 'hearthguard-mantle', 'starter-business-suit']) {
        await tester.pumpWidget(scene(chest));
        await tester.pumpAndSettle();
        expect(find.byType(QuestwellWandererCuffs), findsNothing);
        expect(tester.takeException(), isNull);
      }
    }
  });
}
