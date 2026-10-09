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
import '../lib/widgets/questwell_pixel_art.dart';
import 'package:go_router/go_router.dart';

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
  for (final slug in [
    'hallowed-hearth',
    'woodland-cottage',
    'midnight-harvest',
    'enchanted-library',
    'midnight-observatory',
    'alchemists-workshop',
    'emberglass-conservatory'
  ])
    decor(slug, slug, 'hearth_setting', ['setting'])
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
      Map<String, String> current = const {},
      Map<String, Map<String, String>> rooms = const {},
      bool routed = false}) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Widget home(BuildContext context) => Scaffold(
        body: TextButton(
            child: const Text('Open'),
            onPressed: () => showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (_) => QuestwellDecorateHearth(
                    snapshot: QuestwellCosmeticsSnapshot(
                        profile: QuestwellProfile.fromJson({}),
                        cosmetics: decorations),
                    layouts: QuestwellHearthLayouts(current, rooms, 0),
                    onSave: save))));
    final theme =
        themed ? QuestwellAppStyle.theme() : QuestwellAppStyle.fallbackTheme();
    Widget builder(BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
            disableAnimations: true, textScaler: TextScaler.linear(scale)),
        child: child!);
    final router = routed
        ? GoRouter(routes: [
            GoRoute(path: '/', builder: (context, _) => home(context))
          ])
        : null;
    if (router != null) addTearDown(router.dispose);
    await tester.pumpWidget(RepaintBoundary(
        key: capture,
        child: router != null
            ? MaterialApp.router(
                debugShowCheckedModeBanner: false,
                theme: theme,
                builder: builder,
                routerConfig: router)
            : MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: theme,
                builder: builder,
                home: Builder(builder: home))));
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

  Future<void> selectRoom(WidgetTester tester, String name) async {
    final picker = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(picker);
    await tester.pumpAndSettle();
    await tester.tap(picker);
    await tester.pumpAndSettle();
    final option = find.text(name).last;
    await tester.ensureVisible(option);
    await tester.pumpAndSettle();
    await tester.tap(option);
    await tester.pumpAndSettle();
  }

  Map<String, String> preview(WidgetTester tester) => tester
      .widget<QuestwellHearthPixelScene>(find.byType(QuestwellHearthPixelScene))
      .equippedSlugs;

  testWidgets(
      'room selection renders immediately, recalls rooms and never writes',
      (tester) async {
    var writes = 0;
    await open(tester, (_) async {
      writes++;
    }, current: {
      'left': 'shelf'
    }, rooms: {
      'midnight-observatory': {
        'setting': 'midnight-observatory',
        'right': 'cabinet'
      }
    });
    await selectRoom(tester, 'midnight observatory');
    expect(preview(tester), {
      'room:setting': 'midnight-observatory',
      'room:right': 'copper-potion-workbench'
    });
    expect(
        find.byWidgetPredicate((w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName ==
                QuestwellHearthSetting.fromSlug('midnight-observatory').asset),
        findsOneWidget);
    expect(writes, 0);
    await selectChair(tester);
    await selectRoom(tester, 'midnight harvest');
    await selectRoom(tester, 'midnight observatory');
    expect(preview(tester)['room:front'], 'burgundy-reading-chair');
    final original = find.byTooltip('Use Original Hearth');
    await tester.ensureVisible(original);
    await tester.pumpAndSettle();
    await tester.tap(original);
    await tester.pumpAndSettle();
    expect(preview(tester), {'room:left': 'walnut-bookshelf'});
    await tester.tap(find.text('Undo change'));
    await tester.pumpAndSettle();
    expect(preview(tester)['room:setting'], 'midnight-observatory');
    expect(
        tester
            .widget<DropdownButtonFormField<String>>(
                find.byType(DropdownButtonFormField<String>))
            .initialValue,
        'midnight-observatory');
    await tester.ensureVisible(original);
    await tester.pumpAndSettle();
    await tester.tap(original);
    await tester.pumpAndSettle();
    expect(writes, 0);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Discard this preview?'), findsNothing);
    expect(find.text('Decorate Hearth'), findsNothing);
  });

  for (final exit in ['Close', 'X', 'Back']) {
    testWidgets('$exit exits a clean room and guards an unsaved room',
        (tester) async {
      var writes = 0;
      Future<void> leave() async {
        if (exit == 'Back') {
          final context = tester.element(find.byType(QuestwellDecorateHearth));
          unawaited(Navigator.of(context).maybePop());
        } else {
          final target = exit == 'X'
              ? find.byTooltip('Close room editor')
              : find.text('Close');
          await tester.ensureVisible(target);
          await tester.pumpAndSettle();
          await tester.tap(target);
        }
        await tester.pumpAndSettle();
      }

      await open(tester, (_) async {
        writes++;
      });
      await leave();
      expect(find.text('Decorate Hearth'), findsNothing);
      expect(find.text('Discard this preview?'), findsNothing);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await selectRoom(tester, 'midnight observatory');
      await leave();
      expect(find.text('Discard this preview?'), findsOneWidget);
      await tester.tap(find.text('Keep decorating'));
      await tester.pumpAndSettle();
      expect(preview(tester)['room:setting'], 'midnight-observatory');
      await leave();
      await tester.tap(find.text('Discard changes'));
      await tester.pumpAndSettle();
      expect(find.text('Decorate Hearth'), findsNothing);
      expect(writes, 0);
    });
  }

  testWidgets('router save acknowledges once, closes, and reopens cleanly',
      (tester) async {
    final complete = Completer<void>();
    final current = <String, String>{};
    var writes = 0;
    await open(tester, (layout) async {
      writes++;
      await complete.future;
      current.addAll(layout);
    }, routed: true, current: current);
    await selectRoom(tester, 'midnight observatory');
    await tester.tap(find.text('Save and close'));
    await tester.pump();
    expect(writes, 1);
    expect(find.text('Decorate Hearth'), findsOneWidget);
    expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Close'))
            .onPressed,
        isNull);
    complete.complete();
    await tester.pumpAndSettle();
    expect(find.text('Decorate Hearth'), findsNothing);
    expect(find.text('Discard this preview?'), findsNothing);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(preview(tester)['room:setting'], 'midnight-observatory');
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Save and close'))
            .onPressed,
        isNull);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Decorate Hearth'), findsNothing);
    expect(find.text('Discard this preview?'), findsNothing);
    expect(writes, 1);
  });

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
    await tester.tap(find.text('Save and close'));
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
    await tester.tap(find.text('Save and close'));
    await tester.pumpAndSettle();
    expect(find.textContaining('could not confirm'), findsOneWidget);
    await tester.tap(find.text('Undo change'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Save and close'))
            .onPressed,
        isNull);
    expect(find.text('Decorate Hearth'), findsOneWidget);
  });
  testWidgets('Close confirms discard and never writes at enlarged text',
      (tester) async {
    var writes = 0;
    await open(tester, (_) async {
      writes++;
    }, width: 320, scale: 2);
    await selectChair(tester);
    await tester.tap(find.text('Close'));
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
    final captures = [
      for (final room in [
        'astral',
        'original',
        'hallowed-hearth',
        'woodland-cottage',
        'midnight-harvest',
        'enchanted-library',
        'midnight-observatory',
        'alchemists-workshop',
        'emberglass-conservatory'
      ])
        (390.0, room),
      (320.0, 'astral')
    ];
    for (final (width, room) in captures) {
      await open(tester, (_) async {},
          themed: true,
          width: width,
          scale: width == 320 ? 2 : 1,
          current: {
            'front': 'chair',
            'side': 'table',
            'right': 'cabinet',
            if (room != 'original') 'setting': room
          });
      await tester.runAsync(() async {
        await Future.wait(tester.widgetList<Image>(find.byType(Image)).map(
            (i) =>
                precacheImage(i.image, tester.element(find.byType(Dialog)))));
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final phase in ['overview', if (room == 'astral') 'spots']) {
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
              'build/decorate-hearth/decorator-${width.toInt()}-${room == 'astral' ? '' : '$room-'}$phase.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    }
  });
}
