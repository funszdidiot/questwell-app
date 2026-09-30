import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/widgets/questwell_pixel_art.dart';

void inventoryIconTests() {
  testWidgets('Inventory icons share a square painted treatment, never avatar assets', (tester) async {
    for (final slug in ['tiny-wizard-hat', 'emerald-scholar-scarf',
      'round-scholar-glasses', 'leather-satchel', 'wayfarer-satchel', 'lantern']) {
      for (final locked in [false, true]) {
        await tester.pumpWidget(MaterialApp(home: Center(child:
          QuestwellItemPixelArt(slug: slug, category: 'back', size: 48, locked: locked),
        )));
        final icon = find.byType(QuestwellItemPixelArt);
        expect(tester.getSize(icon), const Size(48, 48));
        expect(find.descendant(of: icon, matching: find.byType(Image)), findsNothing);
        expect(find.descendant(of: icon, matching: find.byType(CustomPaint)), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
  });
}

void main() => inventoryIconTests();
