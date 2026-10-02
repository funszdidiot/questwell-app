import 'package:flutter/material.dart';
import '../widgets/questwell_pixel_art.dart';
import '../widgets/questwell_item_icon.dart';

/// Account-free fit review using the same layers as the live avatar.
class HarvestCoatReviewApp extends StatefulWidget {
  const HarvestCoatReviewApp({super.key});
  @override
  State<HarvestCoatReviewApp> createState() => _HarvestCoatReviewAppState();
}
class _HarvestCoatReviewAppState extends State<HarvestCoatReviewApp> {
  String archetype = 'wanderer';
  String held = 'none';
  bool accessories = false;
  bool wear = true;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: Scaffold(backgroundColor: const Color(0xFF111E23),
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20),
        child: Column(children: [
          const Text('Midnight Harvest Coat', style: TextStyle(fontSize: 25)),
          const Text('Three body fits · copper oak leaves · matching 16-bit icon'),
          const QuestwellItemIcon(slug: 'midnight-harvest-coat', size: 56),
          Wrap(spacing: 16, crossAxisAlignment: WrapCrossAlignment.center, children: [
            FilterChip(label: const Text('Wear coat'), selected: wear, onSelected: (v)=>setState(()=>wear=v)),
            FilterChip(label: const Text('Accessories'), selected: accessories, onSelected: (v)=>setState(()=>accessories=v)),
            DropdownButton<String>(value: archetype, items: ['scholar','scout','alchemist','guardian','wanderer'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(), onChanged:(v)=>setState(()=>archetype=v!)),
            DropdownButton<String>(value: held, items: ['none','brass-lantern','annotated-grimoire'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(), onChanged:(v)=>setState(()=>held=v!)),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 20, runSpacing: 24, alignment: WrapAlignment.center,
            children: [for(final body in ['female','male','neutral'])
              SizedBox(width: 380, child: Column(children: [
                Text(body, style: const TextStyle(fontSize:20)),
                SizedBox(width:240,height:320,child:QuestwellLayeredAdventurerArt(
                  archetype:archetype,avatarBodyType:body,equippedSlugs:equipment)),
                QuestwellHearthPixelScene(height:285,setting:QuestwellHearthSetting.midnightHarvest,
                  archetype:archetype,avatarBodyType:body,equippedSlugs:{...equipment,
                    'familiar':'pumpkin-sprite','room:floor':'emerald-wayfarer-rug'}),
              ])),
            ]),
        ]),
      )),
    ),
  );
  Map<String,String> get equipment => {
    if(wear) 'chest':'midnight-harvest-coat',
    if(held!='none') 'hands':held,
    if(accessories) ...{'neck':'emerald-scholar-scarf','back':'leather-satchel',
      'face':'round-scholar-glasses','head':'tiny-wizard-hat','accessory':'moonstone-brooch'},
  };
}
