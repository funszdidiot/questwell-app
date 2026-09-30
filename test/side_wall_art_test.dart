import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_room_picker.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_wall_art.dart';
import '../lib/widgets/questwell_adventurer_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  testWidgets('Side paintings render with the center painting at phone sizes', (tester) async {
    for (final width in [320.0,390.0]) {
      await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(width: width,
        child: const QuestwellHearthPixelScene(height: 310, equippedSlugs: {
          'wall_art': 'moonlit-woodland', 'wall_art:wall_left': 'fern-study',
          'wall_art:wall_right': 'celestial-study', 'room:side': 'walnut-reading-table'})))));
      await tester.pump();
      expect(find.byType(QuestwellWallArt), findsNWidgets(3));
      final left = tester.getRect(find.byKey(const ValueKey('hearth-wall_left-art-bounds')));
      final right = tester.getRect(find.byKey(const ValueKey('hearth-wall_right-art-bounds')));
      final avatar = tester.getRect(find.byKey(const ValueKey('hearth-avatar-bounds')));
      expect(left.center.dx, lessThan(avatar.center.dx));
      expect(right.center.dx, greaterThan(avatar.center.dx));
      expect(left.bottom, lessThan(avatar.center.dy));
      expect(tester.takeException(), isNull);
    }
    const item = AdventurerInventoryItem(id: 'fern', name: 'Fern Study', slug: 'fern-study',
      category: 'wall_art', description: '', owned: true, equipped: true,
      classLocked: false, shop: true, roomSlot: 'wall_left');
    expect(item.renderKey, 'wall_art:wall_left');
  });
  testWidgets('Side art picker preserves center and confirms occupied wall replacement', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    RoomPlacement? result;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) => Scaffold(
      body: TextButton(child: const Text('Open'), onPressed: () async {
        result = await showRoomPicker(context, name: 'Fern Study', id: 'fern', slug: 'fern-study',
          archetype: 'alchemist', bodyType: 'female', currentSlot: 'wall_left',
          equippedSlugs: {'wall_art':'moonlit-woodland','wall_art:wall_left':'fern-study',
            'wall_art:wall_right':'celestial-study','room:right':'walnut-bookshelf'},
          occupants: {'wall_left': const RoomOccupant('fern','Fern Study'),
            'wall_right': const RoomOccupant('stars','Celestial Study')});
      })))));
    await tester.tap(find.text('Open')); await tester.pumpAndSettle();
    expect(find.byType(RadioListTile<String>), findsNWidgets(2));
    expect(find.byType(QuestwellWallArt), findsNWidgets(3));
    await tester.tap(find.text('Right wall · Celestial Study')); await tester.pumpAndSettle();
    expect(find.byType(QuestwellWallArt), findsNWidgets(2));
    expect(find.textContaining('bookshelf may cover'), findsOneWidget);
    await tester.tap(find.text('Save placement')); await tester.pumpAndSettle();
    expect(find.text('Replace Celestial Study?'), findsOneWidget);
    await tester.tap(find.text('Keep current item')); await tester.pumpAndSettle();
    expect(result, isNull);
    await tester.tap(find.text('Save placement')); await tester.pumpAndSettle();
    await tester.tap(find.text('Replace item')); await tester.pumpAndSettle();
    expect(result?.slot, 'wall_right');
    expect(result?.expectedOccupant, 'stars');
    expect(tester.takeException(), isNull);
  });
}
