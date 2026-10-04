import 'package:flutter/material.dart';
import '../lib/widgets/questwell_setting_motion.dart';
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

  testWidgets('Ambient motion stops for accessibility, hidden views and background apps', (tester) async {
    Future<void> scene({bool reduced = false, bool visible = true}) async {
      await tester.pumpWidget(MaterialApp(home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: TickerMode(enabled: visible, child: const SizedBox(width: 390, height: 310,
          child: QuestwellSettingMotion(astral: true))))));
    }
    double phase() => (tester.widget<CustomPaint>(find.descendant(
      of: find.byType(QuestwellSettingMotion), matching: find.byType(CustomPaint))).painter!
      as QuestwellSettingPainter).clock.value;
    await scene(); await tester.pump(const Duration(seconds: 1));
    final moving = phase();
    await tester.pump(const Duration(seconds: 1)); expect(phase(), isNot(moving));
    await scene(reduced: true); final still = phase();
    await tester.pump(const Duration(seconds: 1)); expect(phase(), still);
    await scene(visible: false); final hidden = phase();
    await tester.pump(const Duration(seconds: 1)); expect(phase(), hidden);
    await scene();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    final paused = phase(); await tester.pump(const Duration(seconds: 1)); expect(phase(), paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(); await tester.pump(const Duration(seconds: 1)); expect(phase(), isNot(paused));
    await tester.pumpWidget(const SizedBox()); expect(tester.takeException(), isNull);
  });

  testWidgets('Settings preserve avatar anchors and original-room galleries at phone widths', (tester) async {
    for (final width in [320.0, 390.0]) {
      for (final body in ['female', 'male', 'neutral']) {
        Rect? avatar;
        Rect? wall;
        for (final setting in QuestwellHearthSetting.values) {
          await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(width: width,
            child: QuestwellHearthPixelScene(height: 310, setting: setting,
              avatarBodyType: body, equippedSlugs: const {
                'room:right': 'walnut-bookshelf', 'room:front': 'burgundy-reading-chair',
                'room:side': 'walnut-reading-table', 'room:floor': 'emerald-wayfarer-rug',
                'wall_art': 'moonlit-woodland',
              }),
          ))));
          await tester.pump(const Duration(milliseconds: 300));
          expect(tester.takeException(), isNull);
          final image = find.byWidgetPredicate((w) => w is Image &&
            w.image is AssetImage && (w.image as AssetImage).assetName == setting.asset);
          expect(image, findsOneWidget);
          final a = tester.getRect(find.byKey(const ValueKey('hearth-avatar-bounds')));
          final w = tester.getRect(find.byKey(const ValueKey('hearth-wall-art-bounds')));
          if (avatar != null) expect(a, avatar);
          if (wall != null && !setting.compactGallery) expect(w, wall);
          avatar = a;
          if (!setting.compactGallery) wall = w;
        }
      }
    }
  });

  testWidgets('Equipped setting restores from inventory and removal restores default', (tester) async {
    for (final slug in ['woodland-cottage', 'midnight-harvest', 'enchanted-library', 'midnight-observatory', 'alchemists-workshop', 'astral-sanctuary', 'emberglass-conservatory', '']) {
      await tester.pumpWidget(MaterialApp(home: SizedBox(width: 390,
        child: QuestwellHearthPixelScene(height: 310, equippedSlugs: {
          if (slug.isNotEmpty) 'room:setting': slug,
          'room:right': 'walnut-bookshelf',
        }))));
      await tester.pump(const Duration(milliseconds: 300));
      final expected = QuestwellHearthSetting.fromSlug(slug).asset;
      expect(find.byWidgetPredicate((w) => w is Image && w.image is AssetImage &&
        (w.image as AssetImage).assetName == expected), findsOneWidget);
      expect(find.byKey(const ValueKey('hearth-avatar-bounds')), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  test('Brooch polish preserves corrected lapel centers', () {
    for (final fit in [
      (body: 'female', center: const Offset(99, 94)),
      (body: 'male', center: const Offset(98, 90)),
      (body: 'neutral', center: const Offset(98.5, 92)),
    ]) {
      final bounds = QuestwellMoonstoneBrooch.bounds(fit.body);
      expect(bounds.center, fit.center);
      expect(bounds.size, const Size(16, 16));
    }
  });

  testWidgets('Approved brooch toggles independently across every class and body', (tester) async {
    expect(QuestwellEquipmentPolicy.isReady(QuestwellMoonstoneBrooch.slug, 'accessory'), true);
    expect(QuestwellEquipmentPolicy.isReady(QuestwellMoonstoneBrooch.slug, 'neck'), true,
      reason: 'Renderer readiness does not duplicate catalog category rules.');
    for (final kind in ['scholar', 'scout', 'alchemist', 'guardian', 'wanderer']) {
      for (final body in ['female', 'male', 'neutral']) {
        for (final enabled in [true, false]) {
          await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(width: 240, height: 320,
            child: QuestwellLayeredAdventurerArt(archetype: kind, avatarBodyType: body,
              equippedSlugs: {'back': QuestwellLeatherSatchel.slug,
                'hands': QuestwellBrassLantern.slug, 'neck': 'emerald-scholar-scarf',
                if (enabled) 'accessory': QuestwellMoonstoneBrooch.slug}),
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
    expect(QuestwellEquipmentPolicy.isReady(QuestwellBrassLantern.slug, 'room'), true,
      reason: 'Renderer readiness does not duplicate catalog category rules.');
    expect(QuestwellEquipmentPolicy.isReady('warding-lantern', 'hands'), true,
      reason: 'A known renderer stays ready independently of the catalog category.');
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
          final frame = tester.getRect(find.byKey(const ValueKey('hearth-room-bounds')));
          expect(avatar.width / avatar.height, closeTo(.75, .001));
          expect(avatar.top, greaterThan(frame.top + 25));
          expect(avatar.bottom, lessThan(frame.bottom));
          // Contact points are authored on the same canvas as the visible boots.
          expect(shadow, avatar);
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
  testWidgets('Satchel removal preserves scarf and unknown renderers remain unavailable', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const EquipmentReviewApp(headwear: true, neckwear: true, satchel: true));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(QuestwellLeatherSatchel), findsNWidgets(2));
    expect(find.byType(QuestwellEmeraldScarf), findsNWidgets(2));
    await tester.tap(find.text('Try on satchel'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(QuestwellLeatherSatchel), findsNothing);
    expect(find.byType(QuestwellEmeraldScarf), findsNWidgets(2));
    expect(QuestwellEquipmentPolicy.isReady(QuestwellLeatherSatchel.slug, 'back'), isTrue);
    expect(QuestwellEquipmentPolicy.isReady(QuestwellLeatherSatchel.slug, 'neck'), isTrue,
      reason: 'Renderer readiness does not duplicate catalog category rules.');
    for (final slug in [ 'preview-leather-satchel']) {
      expect(QuestwellEquipmentPolicy.isReady(slug, 'back'), isFalse);
    }
    expect(tester.takeException(), isNull);
  });

}
