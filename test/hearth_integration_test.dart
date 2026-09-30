import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/widgets/questwell_pixel_art.dart';
import 'package:project_momentum/preview/hearth_review.dart';
import 'package:project_momentum/preview/equipment_review.dart';
import 'package:project_momentum/widgets/questwell_leather_satchel.dart';
import 'package:project_momentum/widgets/questwell_emerald_scarf.dart';
import 'package:project_momentum/widgets/questwell_brass_lantern.dart';
import 'package:project_momentum/widgets/questwell_moonstone_brooch.dart';
import 'package:project_momentum/services/questwell_equipment_policy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('Brooch review toggles independently across every class and body', (tester) async {
    expect(QuestwellEquipmentPolicy.isReady(QuestwellMoonstoneBrooch.previewSlug, 'accessory'), false);
    for (final kind in ['scholar', 'scout', 'alchemist', 'guardian', 'wanderer']) {
      for (final body in ['female', 'male', 'neutral']) {
        for (final enabled in [true, false]) {
          await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(width: 240, height: 320,
            child: QuestwellLayeredAdventurerArt(archetype: kind, avatarBodyType: body,
              equippedSlugs: {'back': QuestwellLeatherSatchel.slug,
                'hands': QuestwellBrassLantern.slug, 'neck': 'emerald-scholar-scarf',
                if (enabled) 'accessory': QuestwellMoonstoneBrooch.previewSlug}),
          ))));
          await tester.pump();
          expect(find.byType(QuestwellMoonstoneBrooch), enabled ? findsOneWidget : findsNothing);
          expect(find.byType(QuestwellLeatherSatchel), findsOneWidget);
          expect(find.byType(QuestwellBrassLantern), findsOneWidget);
          expect(find.byType(QuestwellEmeraldScarf), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      }
    }
  });

  testWidgets('Approved lantern can be removed independently across fits', (tester) async {
    expect(QuestwellEquipmentPolicy.isReady(QuestwellBrassLantern.slug, 'hands'), true);
    expect(QuestwellEquipmentPolicy.isReady(QuestwellBrassLantern.slug, 'room'), false);
    expect(QuestwellEquipmentPolicy.isReady('warding-lantern', 'hands'), false);
    for (final kind in ['scholar', 'scout', 'alchemist', 'guardian', 'wanderer']) {
      for (final body in ['female', 'male', 'neutral']) {
        for (final enabled in [true, false]) {
          await tester.pumpWidget(MaterialApp(home: SizedBox(width: 240, height: 320,
            child: QuestwellLayeredAdventurerArt(archetype: kind, avatarBodyType: body,
              equippedSlugs: {'back': QuestwellLeatherSatchel.slug,
                if (enabled) 'hands': QuestwellBrassLantern.slug}),
          )));
          await tester.pump();
          expect(find.byType(QuestwellBrassLantern), enabled ? findsOneWidget : findsNothing);
          expect(find.byType(QuestwellLeatherSatchel), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      }
    }
  });

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
          expect(avatar.top + avatar.height * 302 / 320, closeTo(shadow.center.dy, .1));
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
  testWidgets('Satchel removal preserves scarf and only approved back-slot satchel is available', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const EquipmentReviewApp(headwear: true, neckwear: true, satchel: true));
    await tester.pumpAndSettle();
    expect(find.byType(QuestwellLeatherSatchel), findsNWidgets(2));
    expect(find.byType(QuestwellEmeraldScarf), findsNWidgets(2));
    await tester.tap(find.text('Try on satchel'));
    await tester.pumpAndSettle();
    expect(find.byType(QuestwellLeatherSatchel), findsNothing);
    expect(find.byType(QuestwellEmeraldScarf), findsNWidgets(2));
    expect(QuestwellEquipmentPolicy.isReady(QuestwellLeatherSatchel.slug, 'back'), isTrue);
    expect(QuestwellEquipmentPolicy.isReady(QuestwellLeatherSatchel.slug, 'neck'), isFalse);
    for (final slug in ['wayfarer-satchel', 'preview-leather-satchel']) {
      expect(QuestwellEquipmentPolicy.isReady(slug, 'back'), isFalse);
    }
    expect(tester.takeException(), isNull);
  });

}
