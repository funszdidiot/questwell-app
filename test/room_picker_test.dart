import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_room_picker.dart';
void main() {
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
