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
    final asset=QuestwellLegacyChestFoundation.harvestAsset(body);
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

  test('Female coat covers both fitted arms without oversized wrist cuffs', () async {
    final data = await rootBundle.load(QuestwellLegacyChestFoundation.harvestAsset('female'));
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    final image = (await codec.getNextFrame()).image;
    final bytes = (await image.toByteData())!;
    int alpha(int x, int y) => bytes.getUint8((y * 240 + x) * 4 + 3);
    // Locked female arm cross-sections, including the previously exposed
    // left upper arm and right inner elbow. Hair hides the shoulder edge.
    const sections = {
      90: [[87, 99], [140, 151]],
      105: [[84, 95], [143, 153]],
      120: [[82, 94], [141, 154]],
      132: [[78, 91], [145, 158]],
      145: [[75, 88], [147, 161]],
      158: [[74, 81], [155, 163]],
    };
    for (final section in sections.entries) {
      for (final span in section.value) {
        for (var x = span[0]; x <= span[1]; x++) {
          expect(alpha(x, section.key), greaterThanOrEqualTo(240),
            reason: 'Sleeve must cover fixed arm at ($x, ${section.key})');
        }
      }
    }
    for (final span in [[60, 90], [156, 179]]) {
      var cuffPixels = 0;
      for (var x = span[0]; x <= span[1]; x++) {
        if (alpha(x, 165) > 128) {
          cuffPixels++;
        } else if (cuffPixels > 0) {
          break;
        }
      }
      expect(cuffPixels, lessThanOrEqualTo(15),
        reason: 'Cuffs taper to the wrist instead of flaring outward');
    }
    image.dispose();
    codec.dispose();
  });
}
