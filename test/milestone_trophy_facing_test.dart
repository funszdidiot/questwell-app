import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/widgets/questwell_first_journey.dart';
import 'package:project_momentum/widgets/questwell_pixel_art.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  // Issue #127: keep the authored trophy perspective stable across both room maps.
  testWidgets('milestone facing is stable in both room maps', (tester) async {
    for (final setting in <String?>[null, 'hallowed-hearth']) {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 390,
              child: QuestwellHearthPixelScene(
                height: 342,
                equippedSlugs: {
                  if (setting != null) 'room:setting': setting,
                  'room:mantel': QuestwellFirstJourney.slug,
                },
              ),
            ),
          ),
        ),
      );
      // The Hearth ambient effects loop continuously; only a bounded pump is needed.
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(QuestwellFirstJourney), findsOneWidget);
      expect(
        find.byKey(const ValueKey('hearth-trophy-facing')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('hearth-compass-facing')), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });
}
