import 'package:flutter/material.dart';
import '../services/questwell_cosmetic_models.dart';
import '../services/questwell_equipment_policy.dart';
import 'questwell_pixel_art.dart';
import 'questwell_hearth_decor.dart';
import 'questwell_typography.dart';
import 'questwell_market_shopfront.dart';
import 'questwell_market_motion.dart';

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
  String category='All',query='',collection='All',rarity='All';
  final searchController=TextEditingController();
  final categoryScrollController=ScrollController();
  @override
  void dispose(){searchController.dispose();categoryScrollController.dispose();super.dispose();}
  bool affordable=false,owned=false,myClass=false;
  String get collectionLabel => collection=='All'?'All collections':title(collection.replaceAll('-', ' '));
  static const cream=Color(0xFFF1E4C9),muted=Color(0xFFA9BEB8),gold=Color(0xFFE0BF79),ink=Color(0xFF253E3D);
  bool room(QuestwellCosmetic item)=>['room','wall_art'].contains(item.category);
  bool bodyRestricted(QuestwellCosmetic i)=>!QuestwellEquipmentPolicy.supportsBody(i.slug,widget.data.profile.avatarBodyType);
  bool restricted(QuestwellCosmetic i)=>bodyRestricted(i)||i.requiredArchetype!=null&&i.requiredArchetype!=widget.data.profile.adventurerArchetype;
  String group(QuestwellCosmetic i) {
    if(room(i)) return 'Hearth';
    if(i.category=='familiar') return 'Familiars';
    if(i.category=='effect') return 'Effects';
    if(['chest'].contains(i.category)) return 'Outfits';
    return 'Gear';
  }
  bool get hasSeasonal => widget.data.cosmetics.any((i)=>i.unlockMethod=='shop'&&i.editionType!='standard');
  String editionLabel(String value)=>switch(value){
    'seasonal'=>'Seasonal','limited'=>'Limited Edition','event_reward'=>'Event Reward',
    'founder_beta'=>'Founder/Beta',_=>'Standard'};
  String title(String text)=>text.isEmpty?text:'${text[0].toUpperCase()}${text.substring(1)}';
  String action(QuestwellCosmetic i) {
    if(widget.busyId==i.id)return 'Saving…';
    if(bodyRestricted(i))return 'Female fit only';
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
      scrollable:true,
      titleTextStyle:QuestwellTypography.body(fontSize:20,fontWeight:FontWeight.w700,color:cream),
      contentTextStyle:QuestwellTypography.body(color:cream),
      title:Text(i.price==0?'Claim ${i.name}?':'Buy ${i.name}?'),
      content:Text(i.price==0?'Add this item to your inventory for free.':'${i.price} coins · ${widget.data.profile.coinBalance-i.price} coins will remain.\n\nYou can equip or place it from your inventory.'),
      actions:[TextButton(style:TextButton.styleFrom(textStyle:QuestwellTypography.control(),minimumSize:const Size(48,48)),onPressed:()=>Navigator.pop(ctx,false),child:Text('Cancel')),
        FilledButton(style:FilledButton.styleFrom(textStyle:QuestwellTypography.control(),minimumSize:const Size(48,48)),onPressed:()=>Navigator.pop(ctx,true),child:Text(i.price==0?'Claim item':'Buy item'))]));
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
            avatarBodyType:bodyRestricted(item)?'female':widget.data.profile.avatarBodyType,equippedSlugs:preview(item))),
          const SizedBox(height:10),Text(bodyRestricted(item)?'Female fit preview':'Try-on preview',textAlign:TextAlign.center,style:QuestwellTypography.body(color:muted,fontSize:12)),
          const SizedBox(height:16),Text(item.description,style:QuestwellTypography.body(color:cream,height:1.5)),
          const SizedBox(height:12),
          Text(item.requiredArchetype==null?'Available to every class':'For ${title(item.requiredArchetype!)} adventurers',style:QuestwellTypography.body(color:muted)),
          Text(item.owned?'Already in your inventory':item.price==0?'Free': '${item.price} coins',style:QuestwellTypography.body(color:gold,fontWeight:FontWeight.bold)),
          const SizedBox(height:20),
          FilledButton(style:FilledButton.styleFrom(textStyle:QuestwellTypography.control(),minimumSize:const Size(48,48)),onPressed:canAct(item)?()=>Navigator.pop(ctx,'activate'):null,child:Text(action(item))),
          if(item.equipped&&widget.busyId==null) TextButton(style:TextButton.styleFrom(textStyle:QuestwellTypography.control(),minimumSize:const Size(48,48)),onPressed:()=>Navigator.pop(ctx,'remove'),child:Text(room(item)?'Return to inventory':'Unequip')),
          if(item.equipped&&room(item)&&widget.busyId==null) TextButton(style:TextButton.styleFrom(textStyle:QuestwellTypography.control(),minimumSize:const Size(48,48)),onPressed:()=>Navigator.pop(ctx,'move'),child:Text('Move item')),
          TextButton(style:TextButton.styleFrom(textStyle:QuestwellTypography.control(),minimumSize:const Size(48,48)),onPressed:()=>Navigator.pop(ctx),child:Text('Back to shop')),
        ])))));
    if(!mounted)return;
    if(result=='activate')await _activateItem(item);
    if(result=='remove')await widget.onUnequip(item);
    if(result=='move')await widget.onEquip(item);
  }
  @override
  Widget build(BuildContext context) {
    final all=widget.data.cosmetics.where((i)=>i.unlockMethod=='shop').toList();
    final items=all.where((i)=>(category=='All'||category=='Collections'&&i.collectionKey!=null||category=='Seasonal'&&i.specialEdition||group(i)==category)&&
      (collection=='All'||i.collectionKey==collection)&&
      (rarity=='All'||i.rarity.toLowerCase()==rarity.toLowerCase())&&
      (!myClass||!restricted(i))&&(!owned||i.owned)&&
      (!affordable||i.owned||i.price<=widget.data.profile.coinBalance)&&
      ('${i.name} ${i.description} ${i.collectionKey??''} ${editionLabel(i.editionType)}'
        .toLowerCase().contains(query.toLowerCase().trim()))).toList()
      ..sort((a,b){final price=a.price.compareTo(b.price);return price!=0?price:a.name.compareTo(b.name);});
    return RefreshIndicator(onRefresh:widget.onRefresh,child:ListView(padding:const EdgeInsets.fromLTRB(18,8,18,30),children:[
      QuestwellMarketShopfront(coins:widget.data.profile.coinBalance),
      const SizedBox(height:16),
      _browseControls(),
      const SizedBox(height:14),
      Text('${items.length} ${items.length==1?'treasure':'treasures'}',
        style:QuestwellTypography.body(color:muted,fontSize:12)),
      const SizedBox(height:10),
      if(items.isEmpty) Padding(padding:const EdgeInsets.symmetric(vertical:35),child:Column(children:[
        const Icon(Icons.search_off,color:gold,size:32),const SizedBox(height:12),Text('No treasures match these filters.',style:QuestwellTypography.body(color:cream)),
        TextButton(style:TextButton.styleFrom(textStyle:QuestwellTypography.control(),minimumSize:const Size(48,48)),onPressed:()=>setState((){category='All';collection='All';rarity='All';owned=false;affordable=false;myClass=false;query='';searchController.clear();}),child:Text('Reset filters'))])),
      LayoutBuilder(builder:(context,constraints){final width=constraints.maxWidth>650?(constraints.maxWidth-14)/2:constraints.maxWidth;
        return Wrap(spacing:14,runSpacing:12,children:[for(final i in items) SizedBox(key:ValueKey(i.id),width:width,child:QuestwellPurchaseGlow(owned:i.owned,child:card(i)))]);}),
      const SizedBox(height:22),Text('Coins come from your quests. Every purchase stays in your inventory.',textAlign:TextAlign.center,style:QuestwellTypography.body(color:muted,fontSize:12,height:1.5)),
    ]));
  }
  Widget _browseControls()=>Container(
    padding:const EdgeInsets.all(12),
    decoration:BoxDecoration(color:const Color(0xFF14272A),
      border:Border.all(color:const Color(0xFF344C46)),
      borderRadius:BorderRadius.circular(10)),
    child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      TextField(controller:searchController,onChanged:(v)=>setState(()=>query=v),
        style:QuestwellTypography.body(color:cream),
        decoration:InputDecoration(
          hintText:'Find your next treasure',
          hintStyle:QuestwellTypography.body(color:muted),
          prefixIcon:const Icon(Icons.search,color:muted,size:21),
          suffixIcon:query.isEmpty?null:IconButton(tooltip:'Clear search',
            icon:const Icon(Icons.close,color:muted,size:19),
            onPressed:()=>setState((){query='';searchController.clear();})),
          contentPadding:const EdgeInsets.symmetric(horizontal:12,vertical:12),
          isDense:true,filled:true,fillColor:const Color(0xFF0E1F23),
          enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(6),
            borderSide:const BorderSide(color:Color(0xFF344C46))),
          focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(6),
            borderSide:const BorderSide(color:gold)),
        )),
      const SizedBox(height:8),
      Scrollbar(controller:categoryScrollController,thumbVisibility:true,
        thickness:2,radius:const Radius.circular(2),
        child:SingleChildScrollView(controller:categoryScrollController,
          scrollDirection:Axis.horizontal,
          padding:const EdgeInsets.only(bottom:6),
          child:Row(children:[
            for(final name in ['All','Outfits','Gear','Familiars','Effects','Hearth',if(hasSeasonal)'Seasonal','Collections'])
              Semantics(selected:category==name,child:Container(
                decoration:BoxDecoration(border:Border(bottom:BorderSide(
                  color:category==name?gold:Colors.transparent,width:2))),
                child:TextButton(onPressed:()=>setState((){category=name;if(name!='Collections')collection='All';}),
                  style:TextButton.styleFrom(
                    foregroundColor:category==name?gold:muted,
                    textStyle:QuestwellTypography.body(fontSize:14,
                      fontWeight:category==name?FontWeight.w700:FontWeight.w400),
                    minimumSize:const Size(48,48),
                    padding:const EdgeInsets.symmetric(horizontal:12,vertical:10),
                    tapTargetSize:MaterialTapTargetSize.shrinkWrap,
                    shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(4))),
                  child:Text(name)))),
          ]))),
      const SizedBox(height:8),
      if(category=='Collections') ...[
        DropdownButtonFormField<String>(
          value: collection,
          dropdownColor: const Color(0xFF14272A),
          style: QuestwellTypography.body(color:cream),
          decoration: InputDecoration(labelText:'Collection',
            labelStyle:QuestwellTypography.body(color:muted),
            border:const OutlineInputBorder()),
          items:[
            const DropdownMenuItem(value:'All',child:Text('All collections')),
            for(final key in widget.data.cosmetics.map((i)=>i.collectionKey).whereType<String>().toSet().toList()..sort())
              DropdownMenuItem(value:key,child:Text(title(key.replaceAll('-', ' ')))),
          ],
          onChanged:(value)=>setState(()=>collection=value??'All'),
        ),
        const SizedBox(height:8),
      ],
      Wrap(spacing:6,runSpacing:4,children:[
        _filterControl('My class',myClass,(v)=>setState(()=>myClass=v)),
        _filterControl('Affordable',affordable,(v)=>setState(()=>affordable=v)),
        _filterControl('Owned',owned,(v)=>setState(()=>owned=v)),
        PopupMenuButton<String>(tooltip:'Rarity',initialValue:rarity,onSelected:(v)=>setState(()=>rarity=v),itemBuilder:(_)=>[for(final r in ['All','common','uncommon','rare','epic','legendary'])PopupMenuItem(value:r,child:Text(r=='All'?'All rarities':title(r)))],child:Padding(padding:const EdgeInsets.symmetric(horizontal:10,vertical:13),child:Text(rarity=='All'?'Rarity':title(rarity),style:QuestwellTypography.body(fontSize:13,color:muted)))),
      ]),
    ]));

  Widget _filterControl(String label,bool selected,ValueChanged<bool> onChanged)=>
    Semantics(toggled:selected,child:OutlinedButton(
      onPressed:()=>onChanged(!selected),
      style:OutlinedButton.styleFrom(
        foregroundColor:selected?gold:muted,
        backgroundColor:selected?const Color(0xFF2B3D31):Colors.transparent,
        side:BorderSide(color:selected?const Color(0xFF8D794E):const Color(0xFF3A514B)),
        shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(6)),
        textStyle:QuestwellTypography.body(fontSize:13,
          fontWeight:selected?FontWeight.w600:FontWeight.w400),
        minimumSize:const Size(48,48),
        padding:const EdgeInsets.symmetric(horizontal:10,vertical:10),
        tapTargetSize:MaterialTapTargetSize.shrinkWrap),
      child:Row(mainAxisSize:MainAxisSize.min,children:[
        if(selected)...[const Icon(Icons.check,size:14),const SizedBox(width:5)],
        Text(label),
      ])));

  Widget card(QuestwellCosmetic item)=>Container(
    key:ValueKey('market-${item.slug}'),padding:const EdgeInsets.all(14),
    decoration:BoxDecoration(color:cream,borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFFCDBB96))),
    child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      InkWell(onTap:()=>details(item),borderRadius:BorderRadius.circular(8),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Container(width:80,height:80,decoration:BoxDecoration(color:const Color(0xFF213C3B),borderRadius:BorderRadius.circular(8),border:Border.all(color:const Color(0xFF436153),width:2)),
          alignment:Alignment.center,child:QuestwellItemPixelArt(slug:item.slug,category:item.category,size:64,locked:restricted(item))),
        const SizedBox(width:13),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('${title(item.rarity)} · ${group(item)}${item.specialEdition?' · ${editionLabel(item.editionType)}':''}',style:QuestwellTypography.body(color:Color(0xFF6B6655),fontSize:12,fontWeight:FontWeight.w600)),
          const SizedBox(height:4),Text(item.name,style:QuestwellTypography.body(color:ink,fontSize:17,fontWeight:FontWeight.w700,height:1.35)),
          const SizedBox(height:7),Text(item.owned?(item.equipped?'✓ In use':'✓ Owned'):item.price==0?'Free':'◈ ${item.price} coins',style:QuestwellTypography.body(color:Color(0xFF675125),fontSize:13,fontWeight:FontWeight.w700)),
        ])),
      ])),
      const SizedBox(height:10),Text(item.description,maxLines:2,overflow:TextOverflow.ellipsis,style:QuestwellTypography.body(color:Color(0xFF5E6559),height:1.4,fontSize:14)),
      if(bodyRestricted(item))Padding(padding:const EdgeInsets.only(top:8),child:Text('Available for the female body.',style:QuestwellTypography.body(color:Color(0xFF88534C),fontSize:13))),
      if(item.requiredArchetype!=null && item.requiredArchetype!=widget.data.profile.adventurerArchetype)Padding(padding:const EdgeInsets.only(top:8),child:Text('Requires ${title(item.requiredArchetype!)} class',style:QuestwellTypography.body(color:Color(0xFF88534C),fontSize:13))),
      const SizedBox(height:10),Wrap(alignment:WrapAlignment.spaceBetween,spacing:8,runSpacing:5,children:[
        TextButton(onPressed:()=>details(item),style:TextButton.styleFrom(foregroundColor:ink,textStyle:QuestwellTypography.control(),minimumSize:const Size(48,48)),child:Text('Preview')),
        FilledButton(onPressed:canAct(item)?()=>_activateItem(item):null,
          style:FilledButton.styleFrom(textStyle:QuestwellTypography.control(),backgroundColor:ink,foregroundColor:cream,disabledBackgroundColor:const Color(0xFFDDD4BE),disabledForegroundColor:const Color(0xFF656B5D)),child:Text(action(item))),
      ]),
    ]));
}
