import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_scholar_cuffs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final body in ['female','male','neutral']) {
    final asset='assets/images/questwell/avatar/harvest_coat_${body}_v2.webp';
    test('$body Harvest coat retains the authored canvas and clear hands/legs',()async{
      final data=await rootBundle.load(asset);
      final codec=await ui.instantiateImageCodec(data.buffer.asUint8List(data.offsetInBytes,data.lengthInBytes));
      final image=(await codec.getNextFrame()).image;
      expect([image.width,image.height],[240,320]);
      final bytes=(await image.toByteData())!;
      int alpha(int x,int y)=>bytes.getUint8((y*240+x)*4+3);
      expect(alpha(120,45),0,reason:'Do not cover head');
      expect(alpha(75,185),0,reason:'Keep left hand visible');
      expect(alpha(165,185),0,reason:'Keep right hand visible');
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
          expect(images.any((s)=>s.contains('/classes/')),isFalse,reason:'No original class garment should leak through');
          expect(find.byType(QuestwellScholarCuffs),findsNothing);
          expect(tester.takeException(),isNull);
        }
        await tester.pumpWidget(MaterialApp(home:SizedBox(width:240,height:320,
          child:QuestwellLayeredAdventurerArt(archetype:archetype,avatarBodyType:body,equippedSlugs:const {}))));
        await tester.pumpAndSettle();
        final images=tester.widgetList<Image>(find.byType(Image)).map((w)=>(w.image as AssetImage).assetName).toList();
        expect(images, isNot(contains(asset)));
        if(body=='female' && archetype=='scout') {
          expect(images,contains('assets/images/questwell/avatar/scout_robe_female_v7.webp'));
          expect(images,contains('assets/images/questwell/avatar/base/paper_doll_female_v1.webp'));
        }else{
          expect(images.any((s)=>s.contains('/classes/$archetype/')),isTrue);
        }
      }
    });
  }
}
