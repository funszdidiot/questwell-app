import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/preview/mobile_review.dart';
import 'package:project_momentum/widgets/questwell_app_navigation.dart';
import 'package:project_momentum/widgets/questwell_adventurer_view.dart';
import 'package:project_momentum/widgets/questwell_mastery_relic.dart';
import 'package:project_momentum/widgets/questwell_pixel_art.dart';
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
    await tester.pumpWidget(const MobileReviewApp(initialScreen: 'Adventurer'));
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
    await tester.pumpWidget(const MobileReviewApp(initialScreen: 'Adventurer', masteryPreview: true));
    await tester.pumpAndSettle();
    await reveal(tester, 'Guardian');
    await tester.tap(find.widgetWithText(ChoiceChip,'Guardian')); await tester.pumpAndSettle();
    await reveal(tester, 'Claim mastery relic');
    await tester.tap(find.text('Claim mastery relic')); await tester.pumpAndSettle();
    await reveal(tester, 'Place relic in Hearth');
    await tester.tap(find.text('Place relic in Hearth')); await tester.pumpAndSettle();
    expect(find.text('Place Guardian Crest'), findsOneWidget);
    await tester.ensureVisible(find.text('Save placement')); await tester.pumpAndSettle();
    await tester.tap(find.text('Save placement')); await tester.pumpAndSettle();
    expect(tester.widget<QuestwellAdventurerView>(find.byType(QuestwellAdventurerView))
      .items.singleWhere((i) => i.slug == 'guardian-crest').equipped, isTrue);
    await tester.tap(nav('Hearth')); await tester.pumpAndSettle();
    expect(tester.widget<QuestwellHearthPixelScene>(find.byType(QuestwellHearthPixelScene))
      .equippedSlugs['room:right'], 'guardian-crest');
    expect(find.byType(QuestwellMasteryDisplay), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('All five earned collectibles render in every floor slot', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final entry in QuestwellMasteryRelic.slugs.entries) {
      expect(QuestwellEquipmentPolicy.isReady(entry.value,'room'), isTrue);
      expect(QuestwellEquipmentPolicy.isReady(entry.value,'hands'), isFalse);
      for (final slot in ['left','right','front']) {
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: QuestwellHearthPixelScene(
          archetype: entry.key, height: 342, equippedSlugs: {'room:$slot':entry.value}))));
        await tester.pumpAndSettle();
        expect(find.byType(QuestwellMasteryDisplay), findsOneWidget);
        final bounds = tester.getRect(find.byKey(ValueKey('hearth-${entry.value}-bounds')));
        final room = tester.getRect(find.byKey(const ValueKey('hearth-room-bounds')));
        expect(bounds.left, greaterThanOrEqualTo(room.left));
        expect(bounds.right, lessThanOrEqualTo(room.right));
        expect(bounds.bottom, lessThanOrEqualTo(room.bottom));
        expect(tester.takeException(), isNull);
      }
    }
  });
}
