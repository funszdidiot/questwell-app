import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/preview/market_catalog.dart';
import '../lib/services/questwell_cosmetic_models.dart';
import '../lib/services/questwell_equipment_policy.dart';
import '../lib/widgets/questwell_market_view.dart';
import '../lib/widgets/questwell_item_icon.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_hearth_decor.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching=false;
  final items=marketReviewCatalog.map((r)=>QuestwellCosmetic.fromJson(r)).toList();
  test('All 29 current shop entries have distinct, nonempty 16-bit icons and equipment routes',()async{
    expect(items.length,29);
    final fingerprints=<String>{};
    for(final item in items){
      expect(QuestwellEquipmentPolicy.isReady(item.slug,item.category),isTrue,reason:item.slug);
      final recorder=ui.PictureRecorder();
      QuestwellItemIconPainter(item.slug).paint(Canvas(recorder),const Size(32,32));
      final picture=recorder.endRecording();final image=await picture.toImage(32,32);
      final bytes=await image.toByteData();
      expect(bytes!.buffer.asUint8List().any((b)=>b!=0),isTrue);
      expect(fingerprints.add(bytes.buffer.asUint8List().join(',')),isTrue,reason:'Duplicate icon: ${item.slug}');
      image.dispose();picture.dispose();
    }
    expect(QuestwellEquipmentPolicy.isReady('not-a-real-item','chest'),isFalse);
    expect(QuestwellHearthDecor.choices('rainy-window'),{'window':'Window alcove'});
  });
  testWidgets('Each shop item renders on every body without layout errors',(tester)async{
    for(final item in items){for(final body in ['male','female','neutral']){
      final key=item.category=='room'?'room:${QuestwellHearthDecor.choices(item.slug).keys.first}':item.category=='wall_art'&&item.slug!='moonlit-woodland'?'wall_art:wall_left':item.category;
      await tester.pumpWidget(MaterialApp(home:SizedBox(width:320,child:QuestwellHearthPixelScene(
        height:310,avatarBodyType:body,archetype:item.requiredArchetype??'scholar',equippedSlugs:{key:item.slug}))));
      await tester.pump();expect(tester.takeException(),isNull,reason:'${item.slug}/$body');
    }}
  });
  testWidgets('Market supports small screens, class filters and purchase confirmation',(tester)async{
    await tester.binding.setSurfaceSize(const Size(320,1000));addTearDown(()=>tester.binding.setSurfaceSize(null));
    var purchased=0;
    final data=QuestwellCosmeticsSnapshot(profile:const QuestwellProfile(level:4,totalXp:355,coinBalance:650,currentEnergyMode:'normal',onboardingCompleted:true,adventurerArchetype:'scholar',avatarBodyType:'male'),cosmetics:items);
    await tester.pumpWidget(MaterialApp(theme:ThemeData.dark(),home:Scaffold(body:MediaQuery(data:const MediaQueryData(textScaler:TextScaler.linear(1.3)),child:QuestwellMarketView(data:data,onPurchase:(_)async{purchased++;},onEquip:(_)async{},onUnequip:(_)async{},onRefresh:()async{})))));
    await tester.pumpAndSettle();expect(tester.takeException(),isNull);
    await tester.enterText(find.byType(TextField),'moss-green');await tester.pumpAndSettle();
    final buy=find.widgetWithText(FilledButton,'Buy · 90 coins');await tester.scrollUntilVisible(buy,180,scrollable:find.byType(Scrollable).first);await tester.tap(buy);await tester.pumpAndSettle();
    expect(find.text('Buy Moss-Green Cloak?'),findsOneWidget);expect(purchased,0);
    await tester.tap(find.text('Cancel'));await tester.pumpAndSettle();expect(purchased,0);
    await tester.tap(buy);await tester.pumpAndSettle();await tester.tap(find.text('Buy item'));await tester.pumpAndSettle();expect(purchased,1);
    expect(tester.takeException(),isNull);
  });
}
