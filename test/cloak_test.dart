import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../lib/widgets/questwell_brass_lantern.dart';
import '../lib/widgets/questwell_leather_satchel.dart';
import '../lib/widgets/questwell_emerald_scarf.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/widgets/questwell_cloak.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_male_paper_doll.dart';
import '../lib/widgets/questwell_neutral_paper_doll.dart';
import '../lib/widgets/questwell_scout_wardrobe.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching=false;
  test('Each individual cloak covers the fixed arms and hands with cloth', () async {
    for (final slug in ['moss-green-cloak', 'hearthguard-mantle']) {
      for (final body in ['male', 'female', 'neutral']) {
        final data = await rootBundle.load(QuestwellCloak.asset(slug, body));
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final image = (await codec.getNextFrame()).image;
        expect(image.width, 240);
        expect(image.height, 320);
        final cloth = (await image.toByteData())!;
        final basePath = body == 'male' ? QuestwellMalePaperDoll.baseAsset
          : body == 'female' ? QuestwellScoutWardrobeFoundation.femaleBaseAsset
          : QuestwellNeutralPaperDoll.baseAsset;
        final baseData = await rootBundle.load(basePath);
        final baseCodec = await ui.instantiateImageCodec(baseData.buffer.asUint8List());
        final baseImage = (await baseCodec.getNextFrame()).image;
        final base = (await baseImage.toByteData())!;
        for (var y = 115; y < 199; y++) {
          for (var x = 50; x < 190; x++) {
            if (x >= 96 && x <= 144) continue;
            final i = (y * 240 + x) * 4;
            if (base.getUint8(i + 3) < 230) continue;
            expect(cloth.getUint8(i + 3), greaterThanOrEqualTo(190),
              reason: '$slug/$body must cover intact arm/hand at $x,$y');
          }
        }
        image.dispose(); codec.dispose(); baseImage.dispose(); baseCodec.dispose();
      }
    }
  });
  test('Foreground neutral hair cannot repaint a rectangle of neck over the clasp', () {
    final path = const QuestwellCloakHairClipper('neutral').getClip(const Size(240,320));
    expect(path.contains(const Offset(120,50)), isTrue);
    expect(path.contains(const Offset(101,79)), isTrue);
    expect(path.contains(const Offset(123,84)), isFalse);
    expect(path.contains(const Offset(123,100)), isFalse);
  });
  testWidgets('Closed cloak hides held art in a stale loadout and works with a satchel',(tester)async{
    await tester.pumpWidget(const MaterialApp(home:SizedBox(width:240,height:320,
      child:QuestwellLayeredAdventurerArt(archetype:'scholar',avatarBodyType:'female',
        equippedSlugs:{'chest':'moss-green-cloak','hands':'brass-lantern','back':'leather-satchel'}))));
    await tester.pumpAndSettle();
    expect(tester.takeException(),isNull);
    expect(find.byType(QuestwellBrassLantern),findsNothing);
    expect(tester.widgetList<ClipPath>(find.byType(ClipPath))
        .where((widget) => widget.clipper is SatchelForearmClipper), isEmpty,
        reason: 'A satchel cannot restore bare arms above closed cloth');
  });
  testWidgets('Full Wanderer outfit keeps the scarf beneath the cloak clasp', (tester) async {
    for (final body in ['male', 'female', 'neutral']) {
      await tester.pumpWidget(MaterialApp(home: SizedBox(width: 240, height: 320,
        child: QuestwellLayeredAdventurerArt(archetype: 'wanderer', avatarBodyType: body,
          equippedSlugs: const {'chest': 'moss-green-cloak', 'neck': 'emerald-scholar-scarf',
            'back': 'leather-satchel', 'accessory': 'moonstone-brooch'}))));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(QuestwellEmeraldScarf), findsOneWidget);
      final layers = tester.widgetList<Stack>(find.byType(Stack)).firstWhere(
        (stack) => stack.children.any((child) => child is QuestwellEmeraldScarf)).children;
      final scarf = layers.indexWhere((child) => child is QuestwellEmeraldScarf);
      final cloak = layers.indexWhere((child) => child is QuestwellCloak);
      expect(scarf, lessThan(cloak), reason: 'The scarf cannot cover the approved leaf clasp');
    }
  });
  testWidgets('Both cloaks load on every supported class and body without hiding base layers', (tester) async {
    for (final slug in ['moss-green-cloak','hearthguard-mantle']) {
      final classes=slug=='hearthguard-mantle'?['guardian']:['scholar','scout','alchemist','guardian','wanderer'];
      for(final archetype in classes) { for(final body in ['female','male','neutral']) {
        await tester.pumpWidget(MaterialApp(home:Center(child:SizedBox(width:240,height:320,
          child:QuestwellLayeredAdventurerArt(archetype:archetype,avatarBodyType:body,equippedSlugs:{'chest':slug})))));
        await tester.pumpAndSettle();
        expect(tester.takeException(),isNull,reason:'$slug/$archetype/$body');
        expect(find.byType(QuestwellCloak),findsOneWidget);
        final assets=tester.widgetList<Image>(find.byType(Image)).map((i)=>i.image).whereType<AssetImage>().map((i)=>i.assetName).toList();
        if (body == 'male') {
          expect(assets, containsAll([
            QuestwellMalePaperDoll.baseAsset,
            QuestwellMalePaperDoll.everydayAsset,
            QuestwellMalePaperDoll.identityAsset,
          ]));
          expect(assets.any((a)=>a.contains('/classes/$archetype/')), isFalse);
        } else {
          expect(assets, contains(body == 'female'
              ? QuestwellScoutWardrobeFoundation.femaleBaseAsset
              : QuestwellNeutralPaperDoll.baseAsset));
          expect(assets.any((a)=>a.contains('/classes/$archetype/')),isFalse);
        }
        expect(assets.where((a)=>a==QuestwellCloak.asset(slug, body)).length,1);
        {
          final base = body == 'male' ? QuestwellMalePaperDoll.baseAsset
              : body == 'female' ? QuestwellScoutWardrobeFoundation.femaleBaseAsset
              : QuestwellNeutralPaperDoll.baseAsset;
          final primaryBody = find.byWidgetPredicate((widget) => widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == base).first;
          expect(find.ancestor(of: primaryBody, matching: find.byType(ClipPath)), findsNothing,
              reason: 'The primary locked body cannot be clipped to fit clothing');
        }
        final cloakWidget = find.byType(QuestwellCloak);
        expect(find.descendant(of: cloakWidget, matching: find.byType(Transform)), findsNothing,
            reason: 'Individual fits must not be stretched or perspective-warped at runtime');
      }}
    }
    await tester.pumpWidget(const MaterialApp(home:SizedBox(width:240,height:320,
      child:QuestwellLayeredAdventurerArt(archetype:'scholar',equippedSlugs:{}))));
    await tester.pumpAndSettle();expect(find.byType(QuestwellCloak),findsNothing);
  });
}
