import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_scholar_cuffs.dart';
import '../lib/widgets/questwell_male_paper_doll.dart';
import '../lib/widgets/questwell_legacy_chest.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final body in ['female','male','neutral']) {
    final asset='assets/images/questwell/avatar/harvest_coat_${body}_v6.webp';
    final rearAsset='assets/images/questwell/avatar/harvest_coat_rear_${body}_v6.webp';
    test('$body Harvest coat retains the authored canvas and clear hands/legs',()async{
      final data=await rootBundle.load(asset);
      final codec=await ui.instantiateImageCodec(data.buffer.asUint8List(data.offsetInBytes,data.lengthInBytes));
      final image=(await codec.getNextFrame()).image;
      expect([image.width,image.height],[240,320]);
      final bytes=(await image.toByteData())!;
      int alpha(int x,int y)=>bytes.getUint8((y*240+x)*4+3);
      expect(alpha(120,45),0,reason:'Do not cover head');
      final hands = HarvestCoatHandsClipper(body).getClip(const Size(240,320));
      expect(hands.contains(const Offset(75,185)), isTrue);
      expect(hands.contains(const Offset(165,185)), isTrue);
      expect(hands.contains(const Offset(120,185)), isFalse, reason:'Restore hands only, never trouser strips');
      final wristY = body == 'female' ? 169.0 : 176.0;
      final wristXs = body == 'male' ? [68.0,172.0] : body == 'female' ? [76.0,162.0] : [76.0,167.0];
      for (final x in wristXs) {
        expect(hands.contains(Offset(x,wristY)),isTrue,
            reason:'Original wrist must continue through the cuff to the hand');
        expect(hands.contains(Offset(x,wristY-3)),isFalse,
            reason:'Do not put forearm skin over the sleeve');
      }
      expect(alpha(110,250),0,reason:'Keep trousers visible');
      for (final x in [115,120,125]) {
        for (final y in [180,190,200]) {
          expect(alpha(x,y),lessThan(5),reason:'Open coat front must reveal trousers');
        }
      }
      expect(alpha(120,130),greaterThan(128),reason:'Waistcoat covers original tie');
      image.dispose();codec.dispose();
    });
    testWidgets('$body Harvest coat replaces each class garment and restores it on removal',(tester)async{
      for(final archetype in ['scholar','scout','alchemist','guardian','wanderer']) {
        for(final held in ['brass-lantern','annotated-grimoire']) {
          await tester.pumpWidget(MaterialApp(home:SizedBox(width:240,height:320,
            child:QuestwellLayeredAdventurerArt(archetype:archetype,avatarBodyType:body,
              equippedSlugs:{'chest':'midnight-harvest-coat','hands':held,'back':'leather-satchel','neck':'emerald-scholar-scarf'}))));
          await tester.pumpAndSettle();
          final images=tester.widgetList<Image>(find.byType(Image)).map((w)=>(w.image as AssetImage).assetName).toList();
          expect(images,contains(asset));
          expect(images,contains(rearAsset));
          expect(images.indexOf(rearAsset),lessThan(images.indexOf(asset)),
              reason:'Cuff cavity cloth belongs behind the wrist, not on top of it');
          final handLayers = tester.widgetList<ClipPath>(find.byType(ClipPath))
              .where((widget) => widget.clipper is HarvestCoatHandsClipper);
          expect(handLayers.length, 1, reason:'Original hands remain in front of side panels');
          expect(images.any((s)=>s.contains('/classes/')),isFalse,reason:'No original class garment should leak through');
          if (body == 'male') {
            expect(images, containsAll([
              QuestwellMalePaperDoll.baseAsset,
              QuestwellMalePaperDoll.everydayAsset,
              QuestwellMalePaperDoll.identityAsset,
            ]));
          }
          expect(find.byType(QuestwellScholarCuffs),findsNothing);
          expect(tester.takeException(),isNull);
        }
        await tester.pumpWidget(MaterialApp(home:SizedBox(width:240,height:320,
          child:QuestwellLayeredAdventurerArt(archetype:archetype,avatarBodyType:body,equippedSlugs:const {}))));
        await tester.pumpAndSettle();
        final images=tester.widgetList<Image>(find.byType(Image)).map((w)=>(w.image as AssetImage).assetName).toList();
        expect(images, isNot(contains(asset)));
        if(body=='female' && archetype=='scout') {
          expect(images,contains('assets/images/questwell/avatar/scout_robe_female_v8.webp'));
          expect(images,contains('assets/images/questwell/avatar/base/paper_doll_female_v1.webp'));
        }else{
          expect(images.any((s)=>s.contains('/classes/$archetype/')),isTrue);
        }
      }
    });
  }
}
