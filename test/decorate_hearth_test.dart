import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/services/questwell_cosmetic_models.dart';
import '../lib/services/questwell_hearth_draft.dart';
import '../lib/widgets/questwell_decorate_hearth.dart';
import '../lib/widgets/questwell_app_style.dart';

QuestwellCosmetic decor(
        String id, String slug, String profile, List<String> slots) =>
    QuestwellCosmetic.fromJson(
        {
          'id': id,
          'slug': slug,
          'name': slug.replaceAll('-', ' '),
          'category': 'room',
          'hearth_profile_key': profile
        },
        owned: true,
        hearthPlacements: [
          for (final slot in slots)
            QuestwellHearthPlacementOption(
                slot: slot, label: slot, sortOrder: 0)
        ]);
final decorations = [
  decor('chair', 'burgundy-reading-chair', 'seating', ['front', 'right']),
  decor('shelf', 'walnut-bookshelf', 'large_furniture', ['left', 'right']),
  decor('table', 'walnut-reading-table', 'side_table', ['side']),
  decor('cabinet', 'copper-potion-workbench', 'large_furniture',
      ['left', 'right']),
  decor('astral', 'astral-sanctuary', 'hearth_setting', ['setting']),
];

void main() {
  final capture = GlobalKey();
  GoogleFonts.config.allowRuntimeFetching = false;
  test('undo restores room memory as well as current arrangement', () {
    final draft = QuestwellHearthDraft({});
    draft.switchRoom('astral');
    draft.place('chair', 'front');
    draft.switchRoom(null);
    draft.undo();
    draft.undo();
    draft.undo();
    expect(draft.dirty, false);
    draft.switchRoom('astral');
    expect(draft.layout, {'setting': 'astral'});
  });
  test('room recall, replacement and cancel leave saved input untouched', () {
    final saved = {'left': 'shelf'};
    final draft = QuestwellHearthDraft(saved, rooms: {
      'astral': {'setting': 'astral', 'right': 'cabinet'}
    });
    draft.switchRoom('astral');
    expect(draft.layout['right'], 'cabinet');
    draft.place('shelf', 'right');
    expect(draft.layout.values.where((i) => i == 'shelf').length, 1);
    draft.undo();
    expect(draft.layout['right'], 'cabinet');
    expect(saved, {'left': 'shelf'});
    draft.switchRoom(null);
    expect(draft.layout, saved);
  });
  test('crowded furniture and unsupported surface cannot be saved', () {
    expect(
        QuestwellHearthDraft({'left': 'shelf', 'front': 'chair'})
            .problems(decorations),
        isNotEmpty);
    expect(
        QuestwellHearthDraft({'bookshelf_top': 'trophy'}).problems(decorations),
        isNotEmpty);
    expect(
        QuestwellHearthDraft({'right': 'shelf', 'front': 'chair'})
            .problems(decorations),
        isEmpty);
  });

  Future<void> open(
      WidgetTester tester, Future<void> Function(Map<String, String>) save,
      {bool themed = false,
      double width = 390,
      double scale = 1,
      Map<String, String> current = const {}}) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(RepaintBoundary(
        key: capture,
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themed
                ? QuestwellAppStyle.theme()
                : QuestwellAppStyle.fallbackTheme(),
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                    disableAnimations: true,
                    textScaler: TextScaler.linear(scale)),
                child: child!),
            home: Scaffold(
                body: Builder(
                    builder: (context) => TextButton(
                        child: const Text('Open'),
                        onPressed: () => showDialog<bool>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => QuestwellDecorateHearth(
                                snapshot: QuestwellCosmeticsSnapshot(
                                    profile: QuestwellProfile.fromJson({}),
                                    cosmetics: decorations),
                                layouts: QuestwellHearthLayouts(
                                    current, const {}, 0),
                                onSave: save))))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  Future<void> selectChair(WidgetTester tester) async {
    final picker = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(picker);
    await tester.pumpAndSettle();
    await tester.tap(picker);
    await tester.pumpAndSettle();
    await tester.tap(find.text('burgundy reading chair').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('front · Available'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('front · Available'));
    await tester.pumpAndSettle();
  }

  testWidgets('draft changes write only on save; duplicate save is disabled',
      (tester) async {
    var writes = 0;
    final complete = Completer<void>();
    Map<String, String>? submitted;
    await open(tester, (layout) {
      writes++;
      submitted = layout;
      return complete.future;
    });
    await selectChair(tester);
    expect(writes, 0);
    await tester.tap(find.text('Save room'));
    await tester.pump();
    expect(writes, 1);
    expect(submitted, {'front': 'chair'});
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Saving room…'))
            .onPressed,
        isNull);
    complete.complete();
    await tester.pumpAndSettle();
    expect(find.text('Decorate Hearth'), findsNothing);
  });
  testWidgets('save failure retains preview and requires reopening',
      (tester) async {
    await open(tester, (_) async => throw StateError('unknown outcome'));
    await selectChair(tester);
    await tester.tap(find.text('Save room'));
    await tester.pumpAndSettle();
    expect(find.textContaining('could not confirm'), findsOneWidget);
    await tester.tap(find.text('Undo change'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Save room'))
            .onPressed,
        isNull);
    expect(find.text('Decorate Hearth'), findsOneWidget);
  });
  testWidgets('Cancel confirms discard and never writes at enlarged text',
      (tester) async {
    var writes = 0;
    await open(tester, (_) async {
      writes++;
    }, width: 320, scale: 2);
    await selectChair(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Discard this preview?'), findsOneWidget);
    await tester.tap(find.text('Discard changes'));
    await tester.pumpAndSettle();
    expect(writes, 0);
    expect(tester.takeException(), isNull);
  });
  testWidgets('render decorator on phone and enlarged phone', (tester) async {
    for (final entry in {
      'Roboto': 'assets/fonts/Roboto-Regular.ttf',
      'HearthSerif': 'assets/fonts/DejaVuSerif-Bold.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf'
    }.entries) {
      await (FontLoader(entry.key)..addFont(rootBundle.load(entry.value)))
          .load();
    }
    await (FontLoader(GoogleFonts.pressStart2p().fontFamily!)
          ..addFont(rootBundle.load('assets/fonts/PressStart2P-Regular.ttf')))
        .load();
    for (final entry in {
      FontWeight.w400: 'Roboto-Regular.ttf',
      FontWeight.w500: 'Roboto-Medium.ttf',
      FontWeight.w700: 'Roboto-Bold.ttf',
      FontWeight.w800: 'Roboto-Bold.ttf'
    }.entries) {
      await (FontLoader(GoogleFonts.roboto(fontWeight: entry.key).fontFamily!)
            ..addFont(rootBundle.load('assets/fonts/${entry.value}')))
          .load();
    }
    for (final width in [390.0, 320.0]) {
      await open(tester, (_) async {},
          themed: true,
          width: width,
          scale: width == 320 ? 2 : 1,
          current: const {
            'front': 'chair',
            'side': 'table',
            'right': 'cabinet',
            'setting': 'astral'
          });
      await tester.runAsync(() async {
        await Future.wait(tester.widgetList<Image>(find.byType(Image)).map(
            (i) =>
                precacheImage(i.image, tester.element(find.byType(Dialog)))));
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final phase in ['overview', 'spots']) {
        if (phase == 'spots') {
          final picker = find.byType(DropdownButtonFormField<String>);
          await tester.ensureVisible(picker);
          await tester.pumpAndSettle();
          await tester.tap(picker);
          await tester.pumpAndSettle();
          await tester.tap(find.text('walnut bookshelf').last);
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text('Decorate Hearth'));
          await tester.pumpAndSettle();
        }
        final boundary =
            tester.renderObject<RenderRepaintBoundary>(find.byKey(capture));
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
              'build/decorate-hearth/decorator-${width.toInt()}-$phase.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    }
  });
}
