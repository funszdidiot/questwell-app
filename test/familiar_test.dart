import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_familiar.dart';
import '../lib/widgets/questwell_pixel_art.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  testWidgets('Every familiar, including dragon, fits all three avatar bodies', (tester) async {
    for (final slug in QuestwellFamiliarLayer.names.keys) {
      for (final body in ['female', 'male', 'neutral']) {
        await tester.pumpWidget(MaterialApp(home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Center(child: SizedBox(width: 240, height: 320,
            child: QuestwellLayeredAdventurerArt(archetype: 'scholar',
              avatarBodyType: body, equippedSlugs: {'familiar': slug}))))));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$slug / $body');
        final image = find.byWidgetPredicate((w) => w is Image &&
          w.image is AssetImage && (w.image as AssetImage).assetName == QuestwellFamiliarLayer.asset(slug));
        expect(image, findsOneWidget);
        final art = tester.getRect(find.byType(QuestwellLayeredAdventurerArt));
        final sprite = tester.getRect(image);
        expect(sprite.left, greaterThanOrEqualTo(art.left));
        expect(sprite.right, lessThanOrEqualTo(art.right));
        expect(sprite.bottom, lessThanOrEqualTo(art.bottom));
      }
    }
  });
  testWidgets('Idle movement runs, then settles for reduced motion and hidden screens', (tester) async {
    Widget scene({bool reduced = false, bool active = true}) => MaterialApp(home:
      MediaQuery(data: MediaQueryData(disableAnimations: reduced), child:
        TickerMode(enabled: active, child: const SizedBox(width: 240, height: 320,
          child: QuestwellFamiliarLayer(slug: 'emerald-dragon')))));
    await tester.pumpWidget(scene());
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(scene(reduced: true));
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
    await tester.pumpWidget(scene());
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(scene(active: false));
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
  });
}
