import 'package:flutter/material.dart';
import '../widgets/questwell_pixel_art.dart';
import '../widgets/questwell_item_icon.dart';
import '../widgets/questwell_harvest_display.dart';

class HarvestDisplayReviewApp extends StatefulWidget {
  const HarvestDisplayReviewApp({super.key});
  @override
  State<HarvestDisplayReviewApp> createState() => _HarvestDisplayReviewAppState();
}
class _HarvestDisplayReviewAppState extends State<HarvestDisplayReviewApp> {
  bool placed = true;
  String body = 'neutral';
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: Scaffold(body: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        const Text('Harvest Apothecary Display', style: TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        const Text('140 earned coins · all classes · matching 16-bit icon'),
        const SizedBox(height: 10),
        const QuestwellItemIcon(slug: QuestwellHarvestDisplay.slug, size: 64),
        Wrap(spacing: 20, crossAxisAlignment: WrapCrossAlignment.center, children: [
          FilterChip(label: const Text('Place display'), selected: placed,
            onSelected: (v) => setState(() => placed = v)),
          DropdownButton<String>(value: body,
            items: ['female','male','neutral'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => body = v!)),
        ]),
        const SizedBox(height: 16),
        Wrap(spacing: 24, runSpacing: 20, alignment: WrapAlignment.center,
          children: [for (final slot in ['left','right']) SizedBox(width: 390,
            child: Column(children: [
              Text(slot == 'left' ? 'Left placement' : 'Right placement', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              QuestwellHearthPixelScene(height: 360,
                setting: QuestwellHearthSetting.midnightHarvest,
                archetype: 'wanderer', avatarBodyType: body,
                equippedSlugs: {
                  'chest': 'midnight-harvest-coat', 'familiar': 'pumpkin-sprite',
                  'room:floor': 'emerald-wayfarer-rug',
                  if (placed) 'room:$slot': QuestwellHarvestDisplay.slug,
                }),
            ])),
          ]),
      ]),
    ))),
  );
}
