import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_familiar.dart';
import '../lib/widgets/questwell_pet_frame.dart';
import '../lib/widgets/questwell_pet_motion.dart';
import '../lib/services/questwell_equipment_policy.dart';
import '../lib/preview/market_catalog.dart';
import '../lib/widgets/questwell_pixel_art.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  testWidgets('Both candidates use the shared renderer with all three bodies', (
    tester,
  ) async {
    for (final slug in QuestwellPetMotion.names.keys) {
      for (final body in ['female', 'male', 'neutral']) {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Center(
                child: SizedBox(
                  width: 240,
                  height: 320,
                  child: QuestwellLayeredAdventurerArt(
                    archetype: 'scholar',
                    avatarBodyType: body,
                    equippedSlugs: {'familiar': slug},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(QuestwellPetFrame), findsOneWidget);
        expect(tester.takeException(), isNull, reason: '$slug / $body');
      }
    }
  });
  test('Candidate art does not activate shop or account capability', () {
    for (final slug in QuestwellPetMotion.names.keys) {
      expect(QuestwellFamiliarLayer.allNames, contains(slug));
      expect(QuestwellFamiliarLayer.names, isNot(contains(slug)));
      expect(QuestwellEquipmentPolicy.isReady(slug, 'familiar'), isFalse);
      expect(marketReviewCatalog.any((item) => item['slug'] == slug), isFalse);
    }
  });

  test('Loops rest, blink, perform species actions and return to neutral', () {
    for (final slug in QuestwellPetMotion.names.keys) {
      expect(QuestwellPetMotion.frame(slug, 0), 0);
      expect(QuestwellPetMotion.frame(slug, .2), 0);
      expect(QuestwellPetMotion.frame(slug, 1), 0);
      final seen = <int>{};
      for (var i = 0; i <= 1000; i++) {
        final frame = QuestwellPetMotion.frame(slug, i / 1000);
        expect(frame, inInclusiveRange(0, 7));
        seen.add(frame);
      }
      expect(seen, containsAll([0, 1, 2, 4, 5, 6]));
      if (slug == 'hearth-cat') expect(seen, contains(7));
    }
    expect(
      () => QuestwellPetMotion.frame('hearth-cat', double.nan),
      throwsArgumentError,
    );
    expect(() => QuestwellPetMotion.asset('unknown'), throwsArgumentError);
  });

  for (final slug in QuestwellPetMotion.names.keys) {
    testWidgets('$slug advances, pauses, swaps and unequips cleanly', (
      tester,
    ) async {
      Widget scene({
        bool reduced = false,
        bool active = true,
        bool equipped = true,
      }) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: TickerMode(
            enabled: active,
            child: Center(
              child: SizedBox(
                width: 240,
                height: 320,
                child: equipped
                    ? QuestwellFamiliarLayer(slug: slug)
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(scene());
      await tester.pump();
      await tester.pump(
        Duration(milliseconds: slug == 'hearth-cat' ? 3400 : 3050),
      );
      expect(
        tester.widget<QuestwellPetFrame>(find.byType(QuestwellPetFrame)).frame,
        1,
      );
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpWidget(scene(reduced: true));
      await tester.pumpAndSettle();
      expect(
        tester.widget<QuestwellPetFrame>(find.byType(QuestwellPetFrame)).frame,
        0,
      );
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpWidget(scene());
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpWidget(scene(active: false));
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpWidget(scene(equipped: false));
      await tester.pumpAndSettle();
      expect(find.byType(QuestwellPetFrame), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('$slug stays inside its frame at compact and wide sizes', (
      tester,
    ) async {
      for (final width in [160.0, 240.0, 430.0]) {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Center(
                child: SizedBox(
                  width: width,
                  height: 320,
                  child: QuestwellFamiliarLayer(slug: slug),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final bounds = tester.getRect(find.byType(QuestwellFamiliarLayer));
        final frame = tester.getRect(find.byType(QuestwellPetFrame));
        expect(bounds.contains(frame.topLeft), isTrue);
        expect(frame.right, lessThanOrEqualTo(bounds.right));
        expect(frame.bottom, lessThanOrEqualTo(bounds.bottom));
        expect(tester.takeException(), isNull);
      }
    });
  }
}
