import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_woven_rug.dart';
import '../lib/widgets/questwell_room_picker.dart';
import '../lib/widgets/questwell_warding_lantern.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  testWidgets('Floor rug swaps and restores without displacing furniture', (tester) async {
    for (final width in [320.0, 390.0]) {
      for (final body in ['female', 'male', 'neutral']) {
        for (final placed in [false, true, false]) {
          await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(width: width,
            child: QuestwellHearthPixelScene(height: 310, avatarBodyType: body,
              equippedSlugs: {
                if (placed) 'room:floor': QuestwellWovenRugPainter.slug,
                'room:right': 'walnut-bookshelf',
                'room:front': 'burgundy-reading-chair',
                'room:side': 'walnut-reading-table',
              })))));
          await tester.pump();
          final paint = tester.widget<CustomPaint>(find.descendant(
            of: find.byKey(const ValueKey('hearth-woven-rug')),
            matching: find.byType(CustomPaint)));
          expect((paint.painter! as QuestwellWovenRugPainter).emerald, placed);
          for (final item in ['bookshelf', 'chair', 'table', 'avatar']) {
            expect(find.byKey(ValueKey('hearth-$item-bounds')), findsOneWidget);
          }
          expect(tester.takeException(), isNull);
        }
      }
    }
  });

  test('Both rug variants stay within the accepted floor footprint', () async {
    final fingerprints = <String>{};
    for (final emerald in [false, true]) {
      final recorder = ui.PictureRecorder();
      QuestwellWovenRugPainter(emerald: emerald).paint(Canvas(recorder), const Size(320, 400));
      final picture = recorder.endRecording();
      final image = await picture.toImage(320, 400);
      final data = (await image.toByteData())!.buffer.asUint8List();
      expect(fingerprints.add(data.join(',')), isTrue);
      for (var y = 0; y < 400; y++) {
        for (var x = 0; x < 320; x++) {
          if (data[(y * 320 + x) * 4 + 3] != 0) {
            expect(y, inInclusiveRange(275, 380));
            expect(x, inInclusiveRange(70, 250));
          }
        }
      }
      image.dispose(); picture.dispose();
    }
  });

  testWidgets('Warding Lantern and emerald rug coexist without replacing furniture', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox(width: 390,
      child: QuestwellHearthPixelScene(height: 342, archetype: 'guardian',
        avatarBodyType: 'neutral', equippedSlugs: const {
          'room:floor': QuestwellWovenRugPainter.slug,
          'room:left': 'walnut-bookshelf',
          'room:right': QuestwellWardingLantern.slug,
          'room:front': 'burgundy-reading-chair',
          'room:side': 'walnut-reading-table',
        })))));
    await tester.pump();
    expect(find.byKey(const ValueKey('hearth-warding-lantern-bounds')), findsOneWidget);
    final lantern = find.byType(QuestwellWardingLantern);
    expect(lantern, findsOneWidget);
    final paint = tester.widget<CustomPaint>(find.descendant(
      of: find.byKey(const ValueKey('hearth-woven-rug')),
      matching: find.byType(CustomPaint)));
    expect((paint.painter! as QuestwellWovenRugPainter).emerald, isTrue);
    for (final item in ['bookshelf', 'chair', 'table', 'avatar']) {
      expect(find.byKey(ValueKey('hearth-$item-bounds')), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Rug placement saves the floor slot on a small enlarged-text screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    RoomPlacement? result;
    await tester.pumpWidget(MaterialApp(builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.6)),
      child: child!), home: Scaffold(body: Builder(builder: (context) => TextButton(
        onPressed: () async { result = await showRoomPicker(context,
          name: 'Emerald Wayfarer Rug', id: 'rug', slug: QuestwellWovenRugPainter.slug,
          archetype: 'wanderer', bodyType: 'female',
          equippedSlugs: const {'room:right': 'walnut-bookshelf'},
          occupants: const {'right': RoomOccupant('shelf', 'Walnut Bookshelf')}); },
        child: const Text('Place rug'))))));
    await tester.tap(find.text('Place rug')); await tester.pumpAndSettle();
    expect(find.text('Beneath the adventurer'), findsOneWidget);
    expect(find.text('Replaces Walnut Bookshelf'), findsNothing);
    await tester.tap(find.text('Save placement')); await tester.pumpAndSettle();
    expect(result?.slot, 'floor'); expect(result?.expectedOccupant, isNull);
    expect(tester.takeException(), isNull);
  });
}
