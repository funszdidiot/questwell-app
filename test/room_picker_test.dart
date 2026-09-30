import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_room_picker.dart';
void main() {
  testWidgets('item-specific choices and legacy selection are safe', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.binding.setSurfaceSize(const Size(390, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final slug in ['walnut-bookshelf', 'burgundy-reading-chair', 'hearth-fern']) {
      RoomPlacement? result;
      await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) => Scaffold(
        body: TextButton(child: const Text('Open'), onPressed: () async {
          result = await showRoomPicker(context, name: 'Item', id: 'item', slug: slug,
            archetype: 'wanderer', bodyType: 'neutral',
            currentSlot: slug == 'walnut-bookshelf' ? 'front' : null,
            equippedSlugs: const {},
            occupants: {'right': const RoomOccupant('other','Other item')});
        })))));
      await tester.tap(find.text('Open')); await tester.pumpAndSettle();
      expect(find.byType(RadioListTile<String>), findsNWidgets(slug == 'hearth-fern' ? 3 : 2));
      if (slug == 'walnut-bookshelf') {
        expect(find.text('Left wall · Empty'), findsOneWidget);
        expect(find.textContaining('updated placement choices'), findsOneWidget);
        await tester.tap(find.text('Save placement')); await tester.pumpAndSettle();
        expect(result?.slot, 'left');
        expect(result?.expectedOccupant, isNull);
      } else {
        if (slug == 'burgundy-reading-chair') {
          expect(find.text('Left floor · Empty'), findsOneWidget);
          expect(find.text('Right floor · Other item'), findsOneWidget);
        }
        await tester.tap(find.text('Cancel')); await tester.pumpAndSettle();
        expect(result, isNull);
      }
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets('occupied spot requires confirmation and cancel never saves', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.binding.setSurfaceSize(const Size(390, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    RoomPlacement? result;
    await tester.pumpWidget(MaterialApp(theme: ThemeData.dark(), home: Builder(builder: (context) => Scaffold(
      body: TextButton(child: const Text('Open'), onPressed: () async {
        result = await showRoomPicker(context, name: 'Hearth Fern', id: 'fern', slug: 'hearth-fern',
          archetype: 'wanderer', bodyType: 'neutral', equippedSlugs: {'room:right':'walnut-bookshelf'},
          occupants: {'right': const RoomOccupant('shelf','Walnut Bookshelf')});
      })))));
    await tester.tap(find.text('Open')); await tester.pumpAndSettle();
    await tester.tap(find.text('Save placement')); await tester.pumpAndSettle();
    expect(find.text('Replace Walnut Bookshelf?'), findsOneWidget);
    await tester.tap(find.text('Keep current item')); await tester.pumpAndSettle();
    expect(result, isNull);
    await tester.tap(find.text('Cancel')); await tester.pumpAndSettle();
    expect(result, isNull);
    await tester.tap(find.text('Open')); await tester.pumpAndSettle();
    await tester.tap(find.text('Save placement')); await tester.pumpAndSettle();
    await tester.tap(find.text('Replace item')); await tester.pumpAndSettle();
    expect(result?.slot, 'right'); expect(result?.expectedOccupant, 'shelf');
    expect(tester.takeException(), isNull);
  });
}
