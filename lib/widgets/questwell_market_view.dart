import 'package:flutter/material.dart';
import '../services/questwell_cosmetic_models.dart';
import '../services/questwell_equipment_policy.dart';
import 'questwell_pixel_art.dart';
import 'questwell_hearth_decor.dart';
import 'questwell_typography.dart';

class QuestwellMarketView extends StatefulWidget {
  const QuestwellMarketView({super.key,required this.data,required this.onPurchase,
    required this.onEquip,required this.onUnequip,required this.onRefresh,this.busyId});
  final QuestwellCosmeticsSnapshot data;
  final Future<void> Function(QuestwellCosmetic) onPurchase,onEquip,onUnequip;
  final Future<void> Function() onRefresh;
  final String? busyId;
  @override
  State<QuestwellMarketView> createState()=>_QuestwellMarketViewState();
}
class _QuestwellMarketViewState extends State<QuestwellMarketView> {
  String category='All',query='';
  final searchController=TextEditingController();
  @override
  void dispose(){searchController.dispose();super.dispose();}
  bool affordable=false,owned=false,myClass=true;
  static const cream=Color(0xFFF1E4C9),muted=Color(0xFFA9BEB8),gold=Color(0xFFE0BF79),ink=Color(0xFF253E3D);
  bool room(QuestwellCosmetic item)=>['room','wall_art'].contains(item.category);
  bool restricted(QuestwellCosmetic i)=>i.requiredArchetype!=null&&i.requiredArchetype!=widget.data.profile.adventurerArchetype;
  String group(QuestwellCosmetic i)=>room(i)?'Hearth':i.category=='familiar'?'Companions':i.category=='effect'?'Effects':'Wearables';
  String title(String text)=>text.isEmpty?text:'${text[0].toUpperCase()}${text.substring(1)}';
  String action(QuestwellCosmetic i) {
    if(widget.busyId==i.id)return 'Saving…';
    if(restricted(i))return '${title(i.requiredArchetype!)} only';
    if(!QuestwellEquipmentPolicy.isReady(i.slug,i.category))return 'Coming soon';
    if(i.equipped)return room(i)?'Placed in Hearth':'Equipped';
    if(i.owned)return room(i)?'Place in Hearth':'Equip';
    if(i.price>widget.data.profile.coinBalance)return '${i.price-widget.data.profile.coinBalance} more coins';
    return i.price==0?'Claim free':'Buy · ${i.price} coins';
  }
  bool canAct(QuestwellCosmetic i)=>widget.busyId==null&&!restricted(i)&&!i.equipped&&
    QuestwellEquipmentPolicy.isReady(i.slug,i.category)&&(i.owned||i.price<=widget.data.profile.coinBalance);
  Future<void> _activateItem(QuestwellCosmetic i) async {
    if(!canAct(i))return;
    if(i.owned){await widget.onEquip(i);return;}
    final confirmed=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
      titleTextStyle:QuestwellTypography.body(fontSize:20,fontWeight:FontWeight.w700,color:cream),
      contentTextStyle:QuestwellTypography.body(color:cream),
      title:Text(i.price==0?'Claim ${i.name}?':'Buy ${i.name}?'),
      content:Text(i.price==0?'Add this item to your inventory for free.':'${i.price} coins · ${widget.data.profile.coinBalance-i.price} coins will remain.\n\nYou can equip or place it from your inventory.'),
      actions:[TextButton(style:TextButton.styleFrom(textStyle:QuestwellTypography.control()),onPressed:()=>Navigator.pop(ctx,false),child:Text('Cancel')),
        FilledButton(style:FilledButton.styleFrom(textStyle:QuestwellTypography.control()),onPressed:()=>Navigator.pop(ctx,true),child:Text(i.price==0?'Claim item':'Buy item'))]));
    if(confirmed==true&&mounted)await widget.onPurchase(i);
  }
  Map<String,String> preview(QuestwellCosmetic item) {
    final result={for(final i in widget.data.cosmetics.where((i)=>i.equipped))i.renderKey:i.slug};
    if(item.category=='room') {
      result.removeWhere((key,value)=>value==item.slug);
      final slot=QuestwellHearthDecor.choices(item.slug).keys.firstWhere((s)=>s!='bookshelf_top',orElse:()=> 'right');
      result['room:$slot']=item.slug;
    }else if(item.category=='wall_art'){
      result[item.slug=='moonlit-woodland'?'wall_art':'wall_art:wall_left']=item.slug;
    }else {result[item.category]=item.slug;}
    return result;
  }
  Future<void> details(QuestwellCosmetic item) async {
    final result=await showModalBottomSheet<String>(context:context,isScrollControlled:true,
      backgroundColor:const Color(0xFF182B2E),showDragHandle:true,
      builder:(ctx)=>SafeArea(child:ConstrainedBox(constraints:BoxConstraints(maxHeight:MediaQuery.sizeOf(ctx).height*.88),
        child:SingleChildScrollView(padding:const EdgeInsets.fromLTRB(22,0,22,24),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          Text(item.name,style:QuestwellTypography.body(fontSize:25,fontWeight:FontWeight.w700,color:cream)),
          Text('${title(item.rarity)} · ${title(item.category.replaceAll('_',' '))}',style:QuestwellTypography.body(color:gold)),
          const SizedBox(height:16),
          if(room(item))QuestwellHearthPixelScene(height:265,archetype:widget.data.profile.adventurerArchetype,
            avatarBodyType:widget.data.profile.avatarBodyType,equippedSlugs:preview(item))
          else SizedBox(height:265,child:QuestwellLayeredAdventurerArt(
            archetype:item.requiredArchetype??widget.data.profile.adventurerArchetype,
            avatarBodyType:widget.data.profile.avatarBodyType,equippedSlugs:preview(item))),
          const SizedBox(height:10),Text('Try-on preview',textAlign:TextAlign.center,style:QuestwellTypography.body(color:muted,fontSize:12)),
          const SizedBox(height:16),Text(item.description,style:QuestwellTypography.body(color:cream,height:1.5)),
          const SizedBox(height:12),
          Text(item.requiredArchetype==null?'Available to every class':'For ${title(item.requiredArchetype!)} adventurers',style:QuestwellTypography.body(color:muted)),
          Text(item.owned?'Already in your inventory':item.price==0?'Free': '${item.price} coins',style:QuestwellTypography.body(color:gold,fontWeight:FontWeight.bold)),
          const SizedBox(height:20),
          FilledButton(style:FilledButton.styleFrom(textStyle:QuestwellTypography.control()),onPressed:canAct(item)?()=>Navigator.pop(ctx,'activate'):null,child:Text(action(item))),
          if(item.equipped&&widget.busyId==null) TextButton(style:TextButton.styleFrom(textStyle:QuestwellTypography.control()),onPressed:()=>Navigator.pop(ctx,'remove'),child:Text(room(item)?'Return to inventory':'Unequip')),
          if(item.equipped&&room(item)&&widget.busyId==null) TextButton(style:TextButton.styleFrom(textStyle:QuestwellTypography.control()),onPressed:()=>Navigator.pop(ctx,'move'),child:Text('Move item')),
          TextButton(style:TextButton.styleFrom(textStyle:QuestwellTypography.control()),onPressed:()=>Navigator.pop(ctx),child:Text('Back to shop')),
        ])))));
    if(!mounted)return;
    if(result=='activate')await _activateItem(item);
    if(result=='remove')await widget.onUnequip(item);
    if(result=='move')await widget.onEquip(item);
  }
  @override
  Widget build(BuildContext context) {
    final all=widget.data.cosmetics.where((i)=>i.unlockMethod=='shop').toList();
    final items=all.where((i)=>(category=='All'||group(i)==category)&&(!myClass||!restricted(i))&&
      (!owned||i.owned)&&(!affordable||i.owned||i.price<=widget.data.profile.coinBalance)&&
      ('${i.name} ${i.description}'.toLowerCase().contains(query.toLowerCase().trim()))).toList()
      ..sort((a,b){final price=a.price.compareTo(b.price);return price!=0?price:a.name.compareTo(b.name);});
    return RefreshIndicator(onRefresh:widget.onRefresh,child:ListView(padding:const EdgeInsets.fromLTRB(18,8,18,30),children:[
      Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:const Color(0xFF23453F),border:Border.all(color:const Color(0xFF678475)),borderRadius:BorderRadius.circular(14)),
        child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('THE GUILD EMPORIUM',style:QuestwellTypography.sectionHeading(size:9,color:gold)),
          const SizedBox(height:10),Text('The Market',style:QuestwellTypography.body(fontSize:26,height:1.25,fontWeight:FontWeight.w700,color:cream)),
          const SizedBox(height:12),Text('Rare finds, class gear, and questionable fashion choices.',style:QuestwellTypography.body(color:Color(0xFFC0D2C7),height:1.4)),
          const SizedBox(height:16),Wrap(spacing:14,runSpacing:10,crossAxisAlignment:WrapCrossAlignment.center,children:[
            Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:8),decoration:BoxDecoration(color:const Color(0xFF142D2B),borderRadius:BorderRadius.circular(20)),
              child:Text('◈  ${widget.data.profile.coinBalance} coins',style:QuestwellTypography.body(color:gold,fontWeight:FontWeight.w700,fontSize:16))),
            Text('${all.where((i)=>i.owned).length} / ${all.length} collected',style:QuestwellTypography.body(color:muted,fontSize:12)),
          ])])),
      const SizedBox(height:20),
      TextField(controller:searchController,onChanged:(v)=>setState(()=>query=v),style:QuestwellTypography.body(color:cream),decoration:InputDecoration(
        hintText:'Find your next treasure',hintStyle:QuestwellTypography.body(color:muted),prefixIcon:const Icon(Icons.search,color:muted),
        filled:true,fillColor:const Color(0xFF192F32),border:OutlineInputBorder(borderRadius:BorderRadius.circular(10),borderSide:BorderSide.none))),
      const SizedBox(height:12),
      Wrap(spacing:7,runSpacing:5,children:[for(final name in ['All','Wearables','Companions','Hearth','Effects'])
        ChoiceChip(label:Text(name),selected:category==name,onSelected:(_)=>setState(()=>category=name),selectedColor:gold,labelStyle:QuestwellTypography.body(color:category==name?ink:cream))]),
      const SizedBox(height:7),
      Wrap(spacing:7,runSpacing:5,children:[
        FilterChip(labelStyle:QuestwellTypography.body(fontSize:14),label:Text('My class'),selected:myClass,onSelected:(v)=>setState(()=>myClass=v)),
        FilterChip(labelStyle:QuestwellTypography.body(fontSize:14),label:Text('Affordable'),selected:affordable,onSelected:(v)=>setState(()=>affordable=v)),
        FilterChip(labelStyle:QuestwellTypography.body(fontSize:14),label:Text('Owned'),selected:owned,onSelected:(v)=>setState(()=>owned=v)),
      ]),
      const SizedBox(height:18),Text('${items.length} ${items.length==1?'treasure':'treasures'}',style:QuestwellTypography.body(color:muted,fontSize:12)),const SizedBox(height:10),
      if(items.isEmpty) Padding(padding:const EdgeInsets.symmetric(vertical:35),child:Column(children:[
        const Icon(Icons.search_off,color:gold,size:32),const SizedBox(height:12),Text('No treasures match these filters.',style:QuestwellTypography.body(color:cream)),
        TextButton(style:TextButton.styleFrom(textStyle:QuestwellTypography.control()),onPressed:()=>setState((){category='All';owned=false;affordable=false;myClass=true;query='';searchController.clear();}),child:Text('Reset filters'))])),
      LayoutBuilder(builder:(context,constraints){final width=constraints.maxWidth>650?(constraints.maxWidth-14)/2:constraints.maxWidth;
        return Wrap(spacing:14,runSpacing:12,children:[for(final i in items) SizedBox(width:width,child:card(i))]);}),
      const SizedBox(height:22),Text('Coins come from your quests. Every purchase stays in your inventory.',textAlign:TextAlign.center,style:QuestwellTypography.body(color:muted,fontSize:12,height:1.5)),
    ]));
  }
  Widget card(QuestwellCosmetic item)=>Container(
    key:ValueKey('market-${item.slug}'),padding:const EdgeInsets.all(14),
    decoration:BoxDecoration(color:cream,borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFFCDBB96))),
    child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      InkWell(onTap:()=>details(item),borderRadius:BorderRadius.circular(8),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Container(width:80,height:80,decoration:BoxDecoration(color:const Color(0xFF213C3B),borderRadius:BorderRadius.circular(8),border:Border.all(color:const Color(0xFF436153),width:2)),
          alignment:Alignment.center,child:QuestwellItemPixelArt(slug:item.slug,category:item.category,size:64,locked:restricted(item))),
        const SizedBox(width:13),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('${title(item.rarity)} · ${group(item)}',style:QuestwellTypography.body(color:Color(0xFF6B6655),fontSize:12,fontWeight:FontWeight.w600)),
          const SizedBox(height:4),Text(item.name,style:QuestwellTypography.body(color:ink,fontSize:17,fontWeight:FontWeight.w700,height:1.35)),
          const SizedBox(height:7),Text(item.owned?(item.equipped?'✓ In use':'✓ Owned'):item.price==0?'Free':'◈ ${item.price} coins',style:QuestwellTypography.body(color:Color(0xFF675125),fontSize:13,fontWeight:FontWeight.w700)),
        ])),
      ])),
      const SizedBox(height:10),Text(item.description,maxLines:2,overflow:TextOverflow.ellipsis,style:QuestwellTypography.body(color:Color(0xFF5E6559),height:1.4,fontSize:14)),
      if(restricted(item))Padding(padding:const EdgeInsets.only(top:8),child:Text('Requires ${title(item.requiredArchetype!)} class',style:QuestwellTypography.body(color:Color(0xFF88534C),fontSize:13))),
      const SizedBox(height:10),Wrap(alignment:WrapAlignment.spaceBetween,spacing:8,runSpacing:5,children:[
        TextButton(onPressed:()=>details(item),style:TextButton.styleFrom(foregroundColor:ink,textStyle:QuestwellTypography.control()),child:Text('Preview')),
        FilledButton(onPressed:canAct(item)?()=>_activateItem(item):null,
          style:FilledButton.styleFrom(textStyle:QuestwellTypography.control(),backgroundColor:ink,foregroundColor:cream,disabledBackgroundColor:const Color(0xFFDDD4BE),disabledForegroundColor:const Color(0xFF656B5D)),child:Text(action(item))),
      ]),
    ]));
}
