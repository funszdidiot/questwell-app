import 'dart:math' as math;
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
  bool cuffDetail = false;
  String bag = 'leather-satchel';
  static const classes = ['scholar','scout','alchemist','guardian','wanderer'];
  static const outfits = ['class','midnight-harvest-coat','starter-business-suit','moss-green-cloak','hearthguard-mantle'];
  static const heldItems = ['none','brass-lantern','annotated-grimoire'];
  static const bags = ['leather-satchel','wayfarer-satchel'];
  @override
  void initState() {
    super.initState();
    final query = Uri.base.queryParameters;
    if (classes.contains(query['archetype'])) archetype = query['archetype']!;
    if (outfits.contains(query['outfit'])) outfit = query['outfit']!;
    if (heldItems.contains(query['held'])) held = query['held']!;
    if (bags.contains(query['bag'])) bag = query['bag']!;
    accessories = query['gear'] == 'all';
    cuffDetail = query['detail'] == 'cuffs';
  }
  Map<String, String> get equipment => {
    if (outfit != 'class') 'chest': outfit,
    if (held != 'none') 'hands': held,
    if (accessories) ...{
      'face': 'round-scholar-glasses', 'neck': 'emerald-scholar-scarf',
      'back': bag,
      'head': 'tiny-wizard-hat', 'accessory': 'moonstone-brooch',
    },
  };
  Widget avatar(String body, double height) => SizedBox(width: height * .75,
    height: height, child: QuestwellLayeredAdventurerArt(archetype: archetype,
      avatarBodyType: body, equippedSlugs: equipment));
  Widget wrists(String body) => SizedBox(height: 150,
    child: ClipRect(child: LayoutBuilder(builder: (context, constraints) {
      final scale = constraints.maxWidth / 150;
      return Stack(children: [Positioned(
        left: (constraints.maxWidth - 240 * scale) / 2,
        top: -145 * scale, width: 240 * scale, height: 320 * scale,
        child: QuestwellLayeredAdventurerArt(archetype: archetype,
          avatarBodyType: body, equippedSlugs: equipment),
      )]);
    })));
  Widget select(String value, List<String> values, ValueChanged<String> change) =>
    SizedBox(width: 220, child: DropdownButton<String>(isExpanded: true, value: value, items: values.map((v) =>
      DropdownMenuItem(value: v, child: Text(v))).toList(),
      onChanged: (v) => setState(() => change(v!))));
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
            select(archetype, classes, (v) => archetype = v),
            select(outfit, outfits, (v) => outfit = v),
            select(held, heldItems, (v) => held = v),
            select(bag, bags, (v) => bag = v),
            FilterChip(label: const Text('Accessories'), selected: accessories,
              onSelected: (v) => setState(() => accessories = v)),
            FilterChip(label: const Text('Cuff detail'), selected: cuffDetail,
              onSelected: (v) => setState(() => cuffDetail = v)),
          ]),
          const SizedBox(height: 20),
          Wrap(spacing: 24, runSpacing: 28, alignment: WrapAlignment.center,
            children: [for (final body in ['female','male','neutral'])
              SizedBox(width: 310, child: LayoutBuilder(builder: (context, constraints) {
                final cardHeight = math.min(192.0, constraints.maxWidth / 1.5);
                return Column(children: [
                Text(body == 'neutral' ? 'Gender neutral' : body == 'female' ? 'Female' : 'Male',
                  style: const TextStyle(fontSize: 20, color: Color(0xFFE0C481))),
                const SizedBox(height: 10),
                if (cuffDetail) ...[
                  const Text('Wrist detail'),
                  const SizedBox(height: 8),
                  wrists(body),
                ] else Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Expanded(child: Column(children: [const Text('Base layer', textAlign: TextAlign.center),
                    SizedBox(width: cardHeight * .75, height: cardHeight, child: QuestwellCleanBase(body: body))])),
                  Expanded(child: Column(children: [const Text('Selection card', textAlign: TextAlign.center), avatar(body, cardHeight)])),
                ]),
                const SizedBox(height: 12),
                avatar(body, 340),
              ]);
              })),
            ]),
        ]),
      )),
    ),
  );
}
