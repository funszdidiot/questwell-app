import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/widgets/questwell_pixel_art.dart';
import 'package:project_momentum/preview/hearth_review.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('All Hearth fits keep boots on the shadow at phone and tablet widths', (tester) async {
    for (final width in [320.0, 390.0, 430.0, 768.0]) {
      for (final kind in ['scholar', 'scout', 'alchemist', 'guardian', 'wanderer']) {
        for (final body in ['male', 'female', 'neutral']) {
          await tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(
            child: SizedBox(width: width - 36, child: QuestwellHearthPixelScene(
              height: width < 430 ? 342 : 392, archetype: kind, avatarBodyType: body,
            )),
          ))));
          await tester.pump();
          final avatar = tester.getRect(find.byKey(const ValueKey('hearth-avatar-bounds')));
          final shadow = tester.getRect(find.byKey(const ValueKey('hearth-contact-shadow')));
          final frame = tester.getRect(find.byType(QuestwellHearthPixelScene));
          expect(avatar.width / avatar.height, closeTo(.75, .001));
          expect(avatar.top, greaterThan(frame.top + 25));
          expect(avatar.bottom, lessThan(frame.bottom));
          expect(avatar.top + avatar.height * 310 / 320, closeTo(shadow.center.dy, .1));
          final art = tester.widget<QuestwellLayeredAdventurerArt>(find.byType(QuestwellLayeredAdventurerArt));
          expect(art.archetype, kind);
          expect(art.avatarBodyType, body);
          // Floor painting must precede the avatar in the scene stack.
          final sceneStack = tester.widgetList<Stack>(find.byType(Stack)).firstWhere(
            (stack) => stack.children.any((child) => child.key == const ValueKey('hearth-avatar-bounds')),
          );
          final avatarIndex = sceneStack.children.indexWhere((child) => child.key == const ValueKey('hearth-avatar-bounds'));
          final shadowIndex = sceneStack.children.indexWhere((child) => child.key == const ValueKey('hearth-contact-shadow'));
          expect(shadowIndex, lessThan(avatarIndex));
          final paint = find.byWidgetPredicate((w) => w is CustomPaint && w.painter.runtimeType.toString() == '_HearthAtmospherePainter');
          expect(paint, findsOneWidget);
          final positioned = tester.widget<Positioned>(find.ancestor(of: paint, matching: find.byType(Positioned)).first);
          expect(sceneStack.children.indexOf(positioned), lessThan(shadowIndex));
          expect(tester.takeException(), isNull, reason: '$kind / $body at $width');
        }
      }
    }
  });

  testWidgets('Review changes keep Hearth and Adventurer on the same selected body', (tester) async {
    await tester.pumpWidget(const HearthReviewApp());
    await tester.pump();
    final bodyChoice = tester.widget<DropdownButton<String>>(find.byKey(const ValueKey('Body')));
    bodyChoice.onChanged!('female');
    await tester.pump();
    final classChoice = tester.widget<DropdownButton<String>>(find.byKey(const ValueKey('Class')));
    classChoice.onChanged!('guardian');
    await tester.pump();
    final scene = tester.widget<QuestwellHearthPixelScene>(find.byType(QuestwellHearthPixelScene));
    final portrait = tester.widget<QuestwellEquippedAvatar>(find.byType(QuestwellEquippedAvatar));
    expect([scene.avatarBodyType, portrait.avatarBodyType], ['female', 'female']);
    expect([scene.archetype, portrait.archetype], ['guardian', 'guardian']);
    expect(tester.takeException(), isNull);
  });
}
