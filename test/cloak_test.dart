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
  test('Registered opaque cloak cloth stays inside the paper-doll canvas', () async {
    for (final slug in ['moss-green-cloak', 'hearthguard-mantle']) {
      final data = await rootBundle.load(QuestwellCloak.asset(slug));
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final image = (await codec.getNextFrame()).image;
      final bytes = (await image.toByteData())!;
      for (final body in ['male', 'female', 'neutral']) {
        final fit = QuestwellCloak.bounds(body, slug);
        final transform = QuestwellCloak.drapeTransform(fit.width, fit.height,
            slug == 'hearthguard-mantle' ? -1.2 : 1.2);
        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            if (bytes.getUint8((y * image.width + x) * 4 + 3) < 200) continue;
            final point = MatrixUtils.transformPoint(transform,
                Offset(x * fit.width / image.width, y * fit.height / image.height)) + fit.topLeft;
            expect(point.dx, inInclusiveRange(0, 240), reason: '$slug/$body visible hem must not clip');
            expect(point.dy, inInclusiveRange(0, 320));
          }
        }
      }
      image.dispose();
      codec.dispose();
    }
  });
  test('Closed cloak keeps faces in front and hands inside', () {
    for (final body in ['female','male','neutral']) {
      final path=QuestwellCloakForegroundClipper(body).getClip(const Size(240,320));
      expect(path.contains(const Offset(120,50)),isTrue);
      expect(path.contains(Offset(body=='female'?77:70,184)),isFalse);
      expect(path.contains(const Offset(168,184)),isFalse);
      expect(path.contains(const Offset(120,100)),isFalse,reason:'Keep clasp visible');
      expect(path.contains(const Offset(101,155)),isFalse,reason:'Keep front drapes continuous');
      expect(path.contains(const Offset(90,250)),isFalse,reason:'Keep lower cloak over outfit');
    }
  });
  test('Cloaks occlude class collar, sleeves, hands and epaulettes while keeping torso', () {
    for (final body in ['female','male','neutral']) {
      final path = QuestwellCloakUnderlayerClipper(body).getClip(const Size(240,320));
      expect(path.contains(const Offset(120,82)),isFalse,reason:'No competing class collar');
      expect(path.contains(const Offset(80,103)),isFalse,reason:'Left shoulder trim stays tucked');
      expect(path.contains(const Offset(160,103)),isFalse,reason:'Right shoulder trim stays tucked');
      expect(path.contains(const Offset(120,150)),isTrue);
      expect(path.contains(const Offset(70,180)),isFalse);
      expect(path.contains(const Offset(170,180)),isFalse);
      final front = QuestwellCloakForegroundClipper(body).getClip(const Size(240,320));
      expect(front.contains(const Offset(120,81)),isTrue,reason:'Restore the curved skin neckline');
      expect(front.contains(const Offset(106,81)),isFalse,reason:'No restored shirt collar');
      expect(front.contains(const Offset(133,81)),isFalse,reason:'No restored shirt collar');
      expect(front.contains(const Offset(82,128)),isFalse,reason:'Upper sleeves remain beneath capelet');
      expect(path.contains(const Offset(85,281)),isFalse,reason:'No outer gold undercoat hem');
      expect(path.contains(const Offset(150,281)),isFalse,reason:'No outer gold undercoat hem');
      expect(path.contains(const Offset(120,255)),isTrue,reason:'Keep the central undercoat');
    }
  });
  test('Closed cloak base mask hides both hands but preserves face and boots',(){
    for(final body in ['female','male','neutral']) {
      final path=QuestwellClosedCloakBodyClipper(body).getClip(const Size(240,320));
      expect(path.contains(const Offset(70,185)),isFalse);
      expect(path.contains(const Offset(169,185)),isFalse);
      expect(path.contains(const Offset(120,50)),isTrue);
      expect(path.contains(const Offset(99,298)),isTrue);
    }
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
      final cloak = layers.indexWhere((child) => child is QuestwellCloak && !child.rear);
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
        expect(find.byType(QuestwellCloak),findsNWidgets(2));
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
        expect(assets.where((a)=>a==QuestwellCloak.asset(slug)).length,2);
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
        final fit=QuestwellCloak.bounds(body,slug);
        expect(fit.center.dx, 120, reason: 'Keep neckline centered on locked canvas');
        expect(fit.width, greaterThan(0));
        expect(fit.bottom,lessThan(300),reason:'Hem clears the boots');
      }}
    }
    await tester.pumpWidget(const MaterialApp(home:SizedBox(width:240,height:320,
      child:QuestwellLayeredAdventurerArt(archetype:'scholar',equippedSlugs:{}))));
    await tester.pumpAndSettle();expect(find.byType(QuestwellCloak),findsNothing);
  });
}
