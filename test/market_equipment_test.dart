import '../lib/widgets/questwell_equipment_swap.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import '../lib/preview/market_catalog.dart';
import '../lib/services/questwell_cosmetic_models.dart';
import '../lib/services/questwell_equipment_policy.dart';
import '../lib/widgets/questwell_market_view.dart';
import '../lib/widgets/questwell_market_motion.dart';
import '../lib/widgets/questwell_item_icon.dart';
import '../lib/widgets/questwell_pixel_art.dart';
import '../lib/widgets/questwell_neutral_paper_doll.dart';
import '../lib/widgets/questwell_hearth_decor.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching=false;
  final items=marketReviewCatalog.map((r)=>QuestwellCosmetic.fromJson(r)).toList();
  test('Closed cloaks conflict with held items in both directions only',(){
    for(final cloak in ['moss-green-cloak','hearthguard-mantle']) {
      expect(QuestwellEquipmentPolicy.conflicts(cloak,'chest','brass-lantern','hands'),isTrue);
      expect(QuestwellEquipmentPolicy.conflicts('annotated-grimoire','hands',cloak,'chest'),isTrue);
      expect(QuestwellEquipmentPolicy.conflicts(cloak,'chest','leather-satchel','back'),isFalse);
      expect(QuestwellEquipmentPolicy.conflicts(cloak,'chest','tiny-owl-familiar','familiar'),isFalse);
    }
    expect(QuestwellEquipmentPolicy.conflicts('starter-business-suit','chest','brass-lantern','hands'),isFalse);
  });
  test('production eligibility enables approved Everyday and keeps unaccepted Woodland gated', () {
    for (final body in ['female', 'neutral', 'male']) {
      expect(QuestwellEquipmentPolicy.supportsBody('everyday-adventurer-outfit', body), isTrue);
      expect(QuestwellEquipmentPolicy.supportsBody('woodland-scout-outfit', body), body == 'female');
    }
    final woodland = items.firstWhere((item) => item.slug == 'woodland-scout-outfit');
    expect(woodland.requiredArchetype, 'scout');
    expect(woodland.collectionKey, 'woodland-scout');
    expect(items.firstWhere((item) => item.slug == 'everyday-adventurer-outfit').requiredArchetype, isNull);
  });
  testWidgets('Woodland body restrictions show available fits and block unsupported equip', (tester) async {
    final outfit=items.firstWhere((i)=>i.slug=='woodland-scout-outfit').copyWith(owned:true);
    for(final body in ['male','neutral','female']) {
      expect(QuestwellEquipmentPolicy.supportsBody(outfit.slug,body),body=='female');
      await tester.pumpWidget(MaterialApp(builder:(context,child)=>MediaQuery(
        data:MediaQuery.of(context).copyWith(disableAnimations:true),child:child!),home:Scaffold(body:QuestwellMarketView(
        key:ValueKey(body),data:QuestwellCosmeticsSnapshot(profile:QuestwellProfile(
          level:4,totalXp:355,coinBalance:650,currentEnergyMode:'normal',onboardingCompleted:true,
          adventurerArchetype:'scout',avatarBodyType:body),cosmetics:[outfit]),
        onPurchase:(_)async{},onEquip:(_)async{},onUnequip:(_)async{},onRefresh:()async{}))));
      await tester.pumpAndSettle();
      if(body!='female') {
        final button=find.widgetWithText(FilledButton,'Fit unavailable');
        await tester.dragUntilVisible(button,find.byType(ListView),const Offset(0,-180),maxIteration:20);
        await tester.pumpAndSettle();
        expect(tester.widget<FilledButton>(button).onPressed,isNull);
        expect(find.text('Available for the female body.'),findsOneWidget);
      }else{
        final button=find.widgetWithText(FilledButton,'Equip');
        await tester.dragUntilVisible(button.hitTestable(),find.byType(ListView),const Offset(0,-180),maxIteration:20);
        await tester.pumpAndSettle();
        expect(tester.widget<FilledButton>(button).onPressed,isNotNull);
      }
      expect(tester.takeException(),isNull);
    }
  });
  testWidgets('owned legacy male chest items preserve availability and equip actions', (tester) async {
    var actions = 0;
    for (final slug in QuestwellEquipmentPolicy.legacyMaleChestFits) {
      final outfit = QuestwellCosmetic.fromJson({
        'id': 'review-$slug', 'slug': slug, 'name': slug, 'category': 'chest',
        'rarity': 'common', 'description': 'Legacy fit', 'price': 0,
        'premium': false, 'unlock_method': 'shop',
      }, owned: true);
      await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
        home: Scaffold(body: QuestwellMarketView(
        key: ValueKey(slug),
        data: QuestwellCosmeticsSnapshot(profile: const QuestwellProfile(
          level: 4, totalXp: 355, coinBalance: 650, currentEnergyMode: 'normal',
          onboardingCompleted: true, adventurerArchetype: 'scout', avatarBodyType: 'male'),
          cosmetics: [outfit]),
        onPurchase: (_) async { actions++; }, onEquip: (_) async { actions++; },
        onUnequip: (_) async { actions++; }, onRefresh: () async {},
      ))));
      await tester.pumpAndSettle();
      final action = find.widgetWithText(FilledButton, 'Equip');
      await tester.dragUntilVisible(action, find.byType(ListView), const Offset(0, -180), maxIteration: 20);
      expect(tester.widget<FilledButton>(action).onPressed, isNotNull);
      expect(outfit.owned, isTrue);
      final before = actions;
      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(actions, before + 1);
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets('neutral Everyday Market preview uses the approved fit and allows equip', (tester) async {
    final outfit = items.firstWhere((item) => item.slug == 'everyday-adventurer-outfit')
        .copyWith(owned: true);
    String? equipped;
    await tester.pumpWidget(MaterialApp(builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
      home: Scaffold(body: QuestwellMarketView(
        data: QuestwellCosmeticsSnapshot(profile: const QuestwellProfile(
          level: 4, totalXp: 355, coinBalance: 650, currentEnergyMode: 'normal',
          onboardingCompleted: true, adventurerArchetype: 'scholar', avatarBodyType: 'neutral'),
          cosmetics: [outfit]),
        onPurchase: (_) async {}, onEquip: (item) async { equipped = item.slug; },
        onUnequip: (_) async {}, onRefresh: () async {},
      )),
    ));
    await tester.pumpAndSettle();
    final preview = find.widgetWithText(TextButton, 'Preview');
    await tester.dragUntilVisible(preview.hitTestable(),find.byType(ListView),const Offset(0,-180),maxIteration:20);
    await tester.pumpAndSettle();
    await tester.tap(preview);
    await tester.pumpAndSettle();
    expect(find.byType(QuestwellNeutralPaperDoll), findsOneWidget);
    expect(find.text('Try-on preview'), findsOneWidget);
    final equip = find.widgetWithText(FilledButton, 'Equip').last;
    final sheetScroll = find.descendant(of: find.byType(BottomSheet),
        matching: find.byType(SingleChildScrollView));
    await tester.dragUntilVisible(equip.hitTestable(), sheetScroll,
        const Offset(0, -150), maxIteration: 20);
    await tester.pumpAndSettle();
    expect(equip.hitTestable(), findsOneWidget);
    await tester.tap(equip);
    await tester.pumpAndSettle();
    expect(equipped, outfit.slug);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Equipment swap clearly offers cancel and confirm',(tester)async{
    final cloak=items.firstWhere((i)=>i.slug=='moss-green-cloak');
    final held=items.firstWhere((i)=>i.slug=='brass-lantern');
    bool? result;
    await tester.pumpWidget(MaterialApp(home:Builder(builder:(context)=>TextButton(
      onPressed:()async{result=await confirmCloakSwap(context,cloak,held);},child:const Text('Try swap')))));
    await tester.tap(find.text('Try swap'));await tester.pumpAndSettle();
    expect(find.textContaining('Closed cloaks cover your hands.'),findsOneWidget);
    await tester.tap(find.text('Keep current'));await tester.pumpAndSettle();expect(result,isFalse);
    await tester.tap(find.text('Try swap'));await tester.pumpAndSettle();
    await tester.tap(find.text('Swap equipment'));await tester.pumpAndSettle();expect(result,isTrue);
  });
  test('All 44 shop entries have distinct artwork and equipment routes',()async{
    expect(items.length,44);
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
    final data=QuestwellCosmeticsSnapshot(profile:const QuestwellProfile(level:4,totalXp:355,coinBalance:650,currentEnergyMode:'normal',onboardingCompleted:true,adventurerArchetype:'scholar',avatarBodyType:'female'),cosmetics:items);
    await tester.pumpWidget(MaterialApp(theme:ThemeData.dark(),home:Scaffold(body:MediaQuery(data:const MediaQueryData(disableAnimations:true,textScaler:TextScaler.linear(1.6)),child:QuestwellMarketView(data:data,onPurchase:(_)async{purchased++;},onEquip:(_)async{},onUnequip:(_)async{},onRefresh:()async{})))));
    await tester.pumpAndSettle();expect(tester.takeException(),isNull);
    final categories=find.byType(SingleChildScrollView);
    final effects=find.widgetWithText(TextButton,'Effects');
    await tester.dragUntilVisible(effects.hitTestable(),categories,const Offset(-160,0));
    await tester.tap(effects);await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('market-starter-business-suit')),findsNothing);
    final all=find.widgetWithText(TextButton,'All');
    await tester.dragUntilVisible(all.hitTestable(),categories,const Offset(160,0));
    await tester.tap(all);await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('market-starter-business-suit')),findsOneWidget);
    await tester.enterText(find.byType(TextField),'moss-green');await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();await tester.pumpAndSettle();
    final buy=find.widgetWithText(FilledButton,'Buy · 90 coins');await tester.dragUntilVisible(buy.hitTestable(),find.byType(ListView),const Offset(0,-180),maxIteration:20);await tester.pumpAndSettle();await tester.tap(buy);await tester.pumpAndSettle();
    expect(find.text('Buy Moss-Green Cloak?'),findsOneWidget);expect(purchased,0);
    await tester.tap(find.text('Cancel'));await tester.pumpAndSettle();expect(purchased,0);
    await tester.tap(buy);await tester.pumpAndSettle();await tester.tap(find.text('Buy item'));await tester.pumpAndSettle();expect(purchased,1);
    expect(tester.takeException(),isNull);
  });
  testWidgets('Ambient motion stops for reduced motion and muted routes',(tester)async{
    Widget scene({bool reduced=false,bool active=true})=>MaterialApp(home:MediaQuery(
      data:MediaQueryData(disableAnimations:reduced),
      child:TickerMode(enabled:active,child:const SizedBox(width:350,height:175,
        child:QuestwellMarketAmbience()))));
    await tester.pumpWidget(scene());await tester.pump(const Duration(milliseconds:100));
    expect(tester.binding.hasScheduledFrame,isTrue);
    await tester.pumpWidget(scene(reduced:true));await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame,isFalse);
    await tester.pumpWidget(scene());await tester.pump(const Duration(milliseconds:100));
    expect(tester.binding.hasScheduledFrame,isTrue);
    await tester.pumpWidget(scene(active:false));await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame,isFalse);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('Coins and purchase glow follow confirmed data and respect reduced motion',(tester)async{
    Widget scene(int coins,bool owned,{bool reduced=false})=>MaterialApp(home:MediaQuery(
      data:MediaQueryData(disableAnimations:reduced),child:Column(children:[
        QuestwellCoinBalance(coins:coins),
        QuestwellPurchaseGlow(owned:owned,child:const Text('Item')),
      ])));
    double glow()=>tester.widget<DecoratedBox>(find.descendant(
      of:find.byType(QuestwellPurchaseGlow),matching:find.byType(DecoratedBox)))
        .decoration is BoxDecoration ? (tester.widget<DecoratedBox>(find.descendant(
          of:find.byType(QuestwellPurchaseGlow),matching:find.byType(DecoratedBox)))
          .decoration as BoxDecoration).boxShadow!.single.color.a : -1;
    await tester.pumpWidget(scene(650,false));await tester.pumpAndSettle();
    expect(find.text('◈  650 coins'),findsOneWidget);expect(glow(),0);
    // No changed ownership means no success animation (e.g. canceled/failed buy).
    await tester.pumpWidget(scene(650,false));await tester.pumpAndSettle();expect(glow(),0);
    await tester.pumpWidget(scene(560,true));await tester.pump(const Duration(milliseconds:150));
    final label=tester.widget<Text>(find.descendant(of:find.byType(QuestwellCoinBalance),matching:find.byType(Text))).data!;
    final value=int.parse(RegExp(r'\d+').firstMatch(label)!.group(0)!);
    expect(value,greaterThan(560));expect(value,lessThan(650));expect(glow(),greaterThan(0));
    await tester.pumpAndSettle();expect(find.text('◈  560 coins'),findsOneWidget);
    expect(glow(),closeTo(0,.001));
    await tester.pumpWidget(scene(560,false,reduced:true));await tester.pumpAndSettle();
    await tester.pumpWidget(scene(470,true,reduced:true));await tester.pumpAndSettle();
    expect(find.text('◈  470 coins'),findsOneWidget);expect(glow(),0);
    expect(tester.binding.hasScheduledFrame,isFalse);
  });

}
