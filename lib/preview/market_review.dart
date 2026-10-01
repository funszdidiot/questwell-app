import '../widgets/questwell_equipment_swap.dart';
import 'package:flutter/material.dart';
import '../services/questwell_cosmetic_models.dart';
import '../widgets/questwell_market_view.dart';
import '../widgets/questwell_room_picker.dart';
import '../widgets/questwell_wall_art.dart';
import 'market_catalog.dart';
import 'home_sections_review.dart';
import '../widgets/questwell_market_home_button.dart';

/// Interactive sample shop; never connects to an account or spends real coins.
class MarketReviewApp extends StatefulWidget {
  const MarketReviewApp({super.key});
  @override
  State<MarketReviewApp> createState()=>_MarketReviewAppState();
}
class _MarketReviewAppState extends State<MarketReviewApp> {
  String archetype='scholar',body='male';
  double width=390;
  int coins=650;
  final owned=<String>{'starter-business-suit','round-scholar-glasses'};
  final equipped=<String,String>{};
  final slots=<String,String>{};
  List<QuestwellCosmetic> get items=>marketReviewCatalog.map((row)=>QuestwellCosmetic.fromJson(row,
    owned:owned.contains(row['slug']),equipped:equipped.containsValue(row['slug']),roomSlot:slots[row['slug']])).toList();
  Future<void> equip(BuildContext context,QuestwellCosmetic i) async {
    if(i.category=='room'||QuestwellWallArt.isSide(i.slug)) {
      final pick=await showRoomPicker(context,name:i.name,id:i.id,slug:i.slug,
        archetype:archetype,bodyType:body,equippedSlugs:equipped,currentSlot:slots[i.slug],
        occupants:{for(final item in items.where((j)=>j.equipped&&j.roomSlot!=null))item.roomSlot!:RoomOccupant(item.id,item.name)});
      if(pick==null||!mounted)return;
      setState((){equipped.removeWhere((k,v)=>v==i.slug);equipped['${i.category}:${pick.slot}']=i.slug;slots[i.slug]=pick.slot;});
    }else{
      final conflict=cloakConflict(i,items);
      if(conflict!=null&&!await confirmCloakSwap(context,i,conflict))return;
      if(!mounted)return;
      setState((){if(conflict!=null)equipped.remove(conflict.category);equipped[i.category]=i.slug;});
    }
  }
  @override
  Widget build(BuildContext context)=>MaterialApp(debugShowCheckedModeBanner:false,
    theme:ThemeData.dark(useMaterial3:true).copyWith(colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xFFDABB7C),brightness:Brightness.dark)),
    home:Scaffold(backgroundColor:const Color(0xFF0A1419),body:SafeArea(child:Column(children:[
      Padding(padding:const EdgeInsets.all(6),child:Wrap(spacing:14,crossAxisAlignment:WrapCrossAlignment.center,children:[
        const Text('Market · sample coins & inventory'),
        DropdownButton<String>(value:archetype,items:['scholar','scout','alchemist','guardian','wanderer'].map((s)=>DropdownMenuItem(value:s,child:Text(s))).toList(),onChanged:(s)=>setState((){archetype=s!;equipped.clear();})),
        DropdownButton<String>(value:body,items:['male','female','neutral'].map((s)=>DropdownMenuItem(value:s,child:Text(s))).toList(),onChanged:(s)=>setState(()=>body=s!)),
        TextButton(onPressed:()=>setState(()=>width=width==390?320:390),child:Text('${width.toInt()} px')),
        TextButton(onPressed:()=>setState(()=>coins=coins==0?650:0),child:const Text('Toggle coin balance')),
      ])),
      SizedBox(width:width,child:Align(alignment:Alignment.centerLeft,
        child:Builder(builder:(context)=>QuestwellMarketHomeButton(onHome:()=>
          Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
            builder:(_)=>const HomeSectionsReviewApp())))))),
      Expanded(child:Center(child:SizedBox(width:width,child:Builder(builder:(ctx)=>QuestwellMarketView(
        data:QuestwellCosmeticsSnapshot(profile:QuestwellProfile(level:4,totalXp:355,coinBalance:coins,
          currentEnergyMode:'normal',onboardingCompleted:true,adventurerArchetype:archetype,avatarBodyType:body),cosmetics:items),
        onRefresh:()async{},onPurchase:(i)async{setState((){if(owned.add(i.slug))coins-=i.price;});},
        onEquip:(i)=>equip(ctx,i),onUnequip:(i)async{setState((){equipped.removeWhere((k,v)=>v==i.slug);slots.remove(i.slug);});},
      ))))),
    ]))));
}
