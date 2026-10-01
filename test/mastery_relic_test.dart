import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/preview/mobile_review.dart';
import 'package:project_momentum/widgets/questwell_app_navigation.dart';
import 'package:project_momentum/widgets/questwell_adventurer_view.dart';
import 'package:project_momentum/widgets/questwell_mastery_relic.dart';
import 'package:project_momentum/widgets/questwell_pixel_art.dart';
import 'package:project_momentum/widgets/questwell_room_picker.dart';
import 'package:project_momentum/services/questwell_equipment_policy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  Finder nav(String label) => find.descendant(of: find.byType(QuestwellAppNavigation),
    matching: find.widgetWithText(TextButton, label));
  Future<void> reveal(WidgetTester tester, String label) async {
    await tester.dragUntilVisible(find.text(label).hitTestable(), find.byType(ListView).first,
      const Offset(0,-180), maxIteration: 60);
    await tester.pumpAndSettle();
  }

  testWidgets('Immediate Adventurer to Hearth uses the selected class and body', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MediaQuery(data: MediaQueryData(disableAnimations: true),
      child: MobileReviewApp(initialScreen: 'Adventurer')));
    await tester.pumpAndSettle();
    await reveal(tester, 'Male');
    await tester.tap(find.widgetWithText(ChoiceChip,'Male')); await tester.pumpAndSettle();
    await reveal(tester, 'Guardian');
    await tester.tap(find.widgetWithText(ChoiceChip,'Guardian')); await tester.pumpAndSettle();
    await tester.tap(nav('Hearth')); await tester.pumpAndSettle();
    final scene = tester.widget<QuestwellHearthPixelScene>(find.byType(QuestwellHearthPixelScene));
    expect(scene.archetype, 'guardian'); expect(scene.avatarBodyType, 'male');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Mastery claim, placement, and first return to Hearth share one relic', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MediaQuery(data: MediaQueryData(disableAnimations: true),
      child: MobileReviewApp(initialScreen: 'Adventurer', masteryPreview: true)));
    await tester.pumpAndSettle();
    await reveal(tester, 'Guardian');
    await tester.tap(find.widgetWithText(ChoiceChip,'Guardian')); await tester.pumpAndSettle();
    await reveal(tester, 'Claim mastery relic');
    await tester.tap(find.text('Claim mastery relic')); await tester.pumpAndSettle();
    await reveal(tester, 'Place relic in Hearth');
    await tester.tap(find.text('Place relic in Hearth')); await tester.pumpAndSettle();
    expect(find.text('Place Guardian Crest'), findsOneWidget);
    expect(find.text('On the fireplace mantel'), findsOneWidget);
    expect(find.text('On the bookcase'), findsNothing);
    expect(find.text('Foreground'), findsNothing);
    expect(find.text('Front left pedestal'), findsOneWidget);
    await tester.ensureVisible(find.text('Save placement')); await tester.pumpAndSettle();
    await tester.tap(find.text('Save placement')); await tester.pumpAndSettle();
    expect(tester.widget<QuestwellAdventurerView>(find.byType(QuestwellAdventurerView))
      .items.singleWhere((i) => i.slug == 'guardian-crest').equipped, isTrue);
    await tester.tap(nav('Hearth')); await tester.pumpAndSettle();
    expect(tester.widget<QuestwellHearthPixelScene>(find.byType(QuestwellHearthPixelScene))
      .equippedSlugs['room:mantel'], 'guardian-crest');
    expect(find.byType(QuestwellMasteryDisplay), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('All five relics render on surfaces and three marked pedestal spots', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final entry in QuestwellMasteryRelic.slugs.entries) {
      expect(QuestwellEquipmentPolicy.isReady(entry.value,'room'), isTrue);
      expect(QuestwellEquipmentPolicy.isReady(entry.value,'hands'), isFalse);
      for (final slot in ['left','right','front','mantel','bookshelf_top']) {
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: QuestwellHearthPixelScene(
          archetype: entry.key, height: 342, equippedSlugs: {'room:$slot':entry.value, if (slot == 'bookshelf_top') 'room:left':'walnut-bookshelf'}))));
        await tester.pumpAndSettle();
        expect(find.byType(QuestwellMasteryDisplay), findsOneWidget);
        final bounds = tester.getRect(find.byKey(ValueKey(slot == 'mantel' || slot == 'bookshelf_top'
          ? 'hearth-${entry.value}-surface-bounds' : 'hearth-${entry.value}-bounds')));
        final room = tester.getRect(find.byKey(const ValueKey('hearth-room-bounds')));
        expect(bounds.left, greaterThanOrEqualTo(room.left));
        expect(bounds.right, lessThanOrEqualTo(room.right));
        expect(bounds.bottom, lessThanOrEqualTo(room.bottom));
        if (['left','right','front'].contains(slot)) {
          final facing = tester.widget<Transform>(find.byKey(ValueKey('hearth-${entry.value}-facing')));
          expect(facing.transform.storage[0], slot == 'right' ? 1 : -1);
          expect(bounds.center.dx, slot == 'right' ? greaterThan(room.center.dx) : lessThan(room.center.dx));
          final depth = (bounds.bottom - room.top) / room.height;
          expect(depth, slot == 'front' ? greaterThan(.85) : lessThan(.65));
        }
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('Bookcase unlocks its surface and an occupied spot requires confirmation', (tester) async {
    RoomPlacement? saved;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Builder(builder: (context) =>
      TextButton(onPressed: () async { saved = await showRoomPicker(context,
        name: 'Scholar Seal', id: 'seal', slug: 'scholar-seal', archetype: 'scholar', bodyType: 'female',
        equippedSlugs: const {'room:left':'walnut-bookshelf'},
        occupants: const {'mantel':RoomOccupant('other','First Journey'),
          'left':RoomOccupant('shelf','Walnut Bookshelf')}); }, child: const Text('Place'))))));
    await tester.tap(find.text('Place')); await tester.pumpAndSettle();
    expect(find.text('On the bookcase'), findsOneWidget);
    // Prefer an available surface rather than defaulting to an occupied spot.
    expect(tester.widget<RadioListTile<String>>(find.widgetWithText(RadioListTile<String>, 'On the bookcase')).groupValue,
      'bookshelf_top');
    await tester.ensureVisible(find.text('On the fireplace mantel'));
    await tester.tap(find.text('On the fireplace mantel')); await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save placement'));
    await tester.tap(find.text('Save placement')); await tester.pumpAndSettle();
    expect(find.text('Replace First Journey?'), findsOneWidget);
    await tester.tap(find.text('Keep current item')); await tester.pumpAndSettle();
    expect(saved, isNull);
    expect(find.text('Place Scholar Seal'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

}
