import 'package:flutter/material.dart';
import '../widgets/questwell_pixel_art.dart';
import '../widgets/questwell_item_icon.dart';
import '../widgets/questwell_autumn_lantern.dart';

class AutumnLanternReviewApp extends StatefulWidget {
  const AutumnLanternReviewApp({super.key});
  @override
  State<AutumnLanternReviewApp> createState() => _AutumnLanternReviewAppState();
}
class _AutumnLanternReviewAppState extends State<AutumnLanternReviewApp> {
  bool placed = true;
  bool still = false;
  String body = 'neutral';
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: Scaffold(body: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        const Text('Autumn Ember Lantern', style: TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        const Text('240 earned coins · all classes · matching 16-bit icon'),
        const SizedBox(height: 10),
        const QuestwellItemIcon(slug: QuestwellAutumnLantern.slug, size: 64),
        Wrap(spacing: 20, crossAxisAlignment: WrapCrossAlignment.center, children: [
          FilterChip(label: const Text('Still mode'), selected: still,
            onSelected: (v) => setState(() => still = v)),
          FilterChip(label: const Text('Place lantern'), selected: placed,
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
              MediaQuery(data: MediaQueryData(disableAnimations: still), child: QuestwellHearthPixelScene(height: 360,
                setting: QuestwellHearthSetting.midnightHarvest,
                archetype: 'wanderer', avatarBodyType: body,
                equippedSlugs: {
                  'chest': 'midnight-harvest-coat', 'familiar': 'pumpkin-sprite',
                  'room:floor': 'emerald-wayfarer-rug',
                  'room:${slot == 'left' ? 'right' : 'left'}': 'harvest-apothecary-display',
                  if (placed) 'room:$slot': QuestwellAutumnLantern.slug,
                })),
            ])),
          ]),
      ]),
    ))),
  );
}
