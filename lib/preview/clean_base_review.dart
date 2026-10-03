import 'package:flutter/material.dart';
import '../widgets/questwell_clean_base.dart';
import '../widgets/questwell_pixel_art.dart';

/// Development-only review; no profile, inventory or equipment writes.
class CleanBaseReviewApp extends StatefulWidget {
  const CleanBaseReviewApp({super.key});
  @override
  State<CleanBaseReviewApp> createState() => _CleanBaseReviewAppState();
}
class _CleanBaseReviewAppState extends State<CleanBaseReviewApp> {
  String archetype = 'wanderer';
  String outfit = 'midnight-harvest-coat';
  String held = 'none';
  bool accessories = false;
  Map<String, String> get equipment => {
    if (outfit != 'class') 'chest': outfit,
    if (held != 'none') 'hands': held,
    if (accessories) ...{
      'face': 'round-scholar-glasses', 'neck': 'emerald-scholar-scarf',
      'back': 'leather-satchel', 'feet': 'pathfinder-boots',
    },
  };
  Widget avatar(String body, double height) => SizedBox(width: height * .75,
    height: height, child: QuestwellLayeredAdventurerArt(archetype: archetype,
      avatarBodyType: body, equippedSlugs: equipment));
  Widget select(String value, List<String> values, ValueChanged<String> change) =>
    DropdownButton<String>(value: value, items: values.map((v) =>
      DropdownMenuItem(value: v, child: Text(v))).toList(),
      onChanged: (v) => setState(() => change(v!)));
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false, theme: ThemeData.dark(),
    home: Scaffold(backgroundColor: const Color(0xFF1F3937),
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20),
        child: Column(children: [
          const Text('A clean foundation', style: TextStyle(fontSize: 26)),
          const SizedBox(height: 6),
          const Text('Same faces. Simple base layers. Your existing wardrobe.'),
          Wrap(spacing: 18, crossAxisAlignment: WrapCrossAlignment.center, children: [
            select(archetype, ['scholar','scout','alchemist','guardian','wanderer'], (v) => archetype = v),
            select(outfit, ['class','midnight-harvest-coat','starter-business-suit','moss-green-cloak','hearthguard-mantle'], (v) => outfit = v),
            select(held, ['none','brass-lantern','annotated-grimoire'], (v) => held = v),
            FilterChip(label: const Text('Accessories'), selected: accessories,
              onSelected: (v) => setState(() => accessories = v)),
          ]),
          const SizedBox(height: 20),
          Wrap(spacing: 24, runSpacing: 28, alignment: WrapAlignment.center,
            children: [for (final body in ['female','male','neutral'])
              SizedBox(width: 310, child: Column(children: [
                Text(body == 'neutral' ? 'Gender neutral' : body == 'female' ? 'Female' : 'Male',
                  style: const TextStyle(fontSize: 20, color: Color(0xFFE0C481))),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Column(children: [const Text('Base layer'),
                    SizedBox(width: 144, height: 192, child: QuestwellCleanBase(body: body))]),
                  Column(children: [const Text('Selection card'), avatar(body, 192)]),
                ]),
                const SizedBox(height: 12),
                avatar(body, 340),
              ])),
            ]),
        ]),
      )),
    ),
  );
}
