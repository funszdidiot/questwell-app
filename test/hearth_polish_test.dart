import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_class_emblem.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  testWidgets('Balanced gallery stays stable on either bookcase wall',
      (tester) async {
    for (final width in [284.0, 354.0]) {
      for (final side in ['left', 'right']) {
        await tester.pumpWidget(MaterialApp(
            home: Center(
                child: SizedBox(
                    width: width,
                    child: QuestwellHearthPixelScene(
                        height: 342,
                        archetype: 'guardian',
                        avatarBodyType: 'male',
                        equippedSlugs: {
                          'room:$side': 'walnut-bookshelf',
                          'wall_art': 'moonlit-woodland',
                          'wall_art:wall_left': 'fern-study',
                          'wall_art:wall_right': 'celestial-study'
                        })))));
        await tester.pump();
        final shelf = tester
            .getRect(find.byKey(const ValueKey('hearth-bookshelf-bounds')));
        final art = tester
            .getRect(find.byKey(ValueKey('hearth-wall_${side}-art-bounds')));
        final frame =
            tester.getRect(find.byKey(const ValueKey('hearth-room-bounds')));
        final center = tester
            .getRect(find.byKey(const ValueKey('hearth-wall-art-bounds')));
        final avatar =
            tester.getRect(find.byKey(const ValueKey('hearth-avatar-bounds')));
        // Solid shelf artwork starts 87 px down its 1284 px transparent canvas.
        expect(art.bottom, lessThan(shelf.top + shelf.height * 87 / 1284));
        expect(art.top, greaterThan(frame.top));
        expect(art.overlaps(center), false);
        final otherArt = tester.getRect(find.byKey(ValueKey(
            'hearth-wall_${side == 'left' ? 'right' : 'left'}-art-bounds')));
        expect(otherArt.overlaps(center), false);
        final leftArt = tester
            .getRect(find.byKey(const ValueKey('hearth-wall_left-art-bounds')));
        final rightArt = tester.getRect(
            find.byKey(const ValueKey('hearth-wall_right-art-bounds')));
        expect(leftArt.width, closeTo(rightArt.width, .01));
        expect(leftArt.height, closeTo(rightArt.height, .01));
        expect(leftArt.center.dy, closeTo(rightArt.center.dy, .01));
        expect(center.left - leftArt.right,
            closeTo(rightArt.left - center.right, .01));
        // Locked male silhouette starts at row 9 in the 320px avatar canvas.
        expect(center.bottom, lessThan(avatar.top + avatar.height * 9 / 320));
        expect(find.byType(QuestwellClassEmblem), findsOneWidget);
        final emblem = tester.getRect(find.byType(QuestwellClassEmblem));
        expect(emblem.bottom, lessThan(frame.top));
        expect(emblem.width, 22);
        expect(tester.takeException(), isNull);
      }
    }
  });
}
