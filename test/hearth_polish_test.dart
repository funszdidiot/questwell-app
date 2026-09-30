import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_class_emblem.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  testWidgets('Full wall frames clear the smaller bookcase on either wall', (tester) async {
    for (final width in [284.0,354.0]) {
      for (final side in ['left','right']) {
        await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(width: width,
          child: QuestwellHearthPixelScene(height: 342, archetype: 'guardian', avatarBodyType: 'male',
            equippedSlugs: {'room:$side':'walnut-bookshelf', 'wall_art':'moonlit-woodland',
              'wall_art:wall_left':'fern-study', 'wall_art:wall_right':'celestial-study'})))));
        await tester.pump();
        final shelf = tester.getRect(find.byKey(const ValueKey('hearth-bookshelf-bounds')));
        final art = tester.getRect(find.byKey(ValueKey('hearth-wall_${side}-art-bounds')));
        final frame = tester.getRect(find.byKey(const ValueKey('hearth-room-bounds')));
        final center = tester.getRect(find.byKey(const ValueKey('hearth-wall-art-bounds')));
        final avatar = tester.getRect(find.byKey(const ValueKey('hearth-avatar-bounds')));
        expect(art.bottom, lessThan(shelf.top));
        expect(art.top, greaterThan(frame.top));
        expect(art.overlaps(center), false);
        expect((center.center.dx - avatar.center.dx).abs(), greaterThan(20));
        expect(find.byType(QuestwellClassEmblem), findsOneWidget);
        final emblem = tester.getRect(find.byType(QuestwellClassEmblem));
        expect(emblem.bottom, lessThan(frame.top));
        expect(emblem.width, 22);
        expect(tester.takeException(), isNull);
      }
    }
  });
}
