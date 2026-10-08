import '../widgets/questwell_app_style.dart';
import 'package:flutter/material.dart';
import '../widgets/questwell_pixel_art.dart';

/// Account-free development review; selection never changes saved equipment.
class HearthSettingsReviewApp extends StatefulWidget {
  const HearthSettingsReviewApp({super.key});
  @override
  State<HearthSettingsReviewApp> createState() =>
      _HearthSettingsReviewAppState();
}

class _HearthSettingsReviewAppState extends State<HearthSettingsReviewApp> {
  String body = 'female';
  String archetype = 'wanderer';
  bool furnished = true;
  bool reverse = false;
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: QuestwellAppStyle.theme(),
        home: QuestwellScaffold(
            body: SafeArea(
                child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            const Text('Find your next Hearth', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            const Text('Pumpkin Sprite · glowing-eye companion review'),
            Wrap(
                spacing: 20,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DropdownButton<String>(
                      value: body,
                      items: ['female', 'male', 'neutral']
                          .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) => setState(() => body = v!)),
                  DropdownButton<String>(
                      value: archetype,
                      items: [
                        'wanderer',
                        'scholar',
                        'scout',
                        'alchemist',
                        'guardian'
                      ]
                          .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) => setState(() => archetype = v!)),
                  FilterChip(
                      label: const Text('Furnishings'),
                      selected: furnished,
                      onSelected: (v) => setState(() => furnished = v)),
                  FilterChip(
                      label: const Text('Swap sides'),
                      selected: reverse,
                      onSelected: (v) => setState(() => reverse = v)),
                ]),
            const SizedBox(height: 16),
            Wrap(
                spacing: 20,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  for (final setting in [
                    QuestwellHearthSetting.midnightHarvest,
                    QuestwellHearthSetting.woodlandCottage,
                    QuestwellHearthSetting.astralSanctuary,
                    QuestwellHearthSetting.emberglassConservatory
                  ])
                    SizedBox(
                        width: 390,
                        child: Column(children: [
                          Text(setting.label,
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 12),
                          QuestwellHearthPixelScene(
                              height: 310,
                              setting: setting,
                              archetype: archetype,
                              avatarBodyType: body,
                              equippedSlugs: {
                                'familiar': 'pumpkin-sprite',
                                if (furnished) ...{
                                  'room:${reverse ? 'left' : 'right'}':
                                      setting ==
                                              QuestwellHearthSetting
                                                  .alchemistsWorkshop
                                          ? 'copper-potion-workbench'
                                          : 'walnut-bookshelf',
                                  'room:${reverse ? 'right' : 'left'}':
                                      'hearth-fern',
                                  'room:front': 'burgundy-reading-chair',
                                  'room:side': 'walnut-reading-table',
                                  'room:floor': 'emerald-wayfarer-rug',
                                  if (setting !=
                                      QuestwellHearthSetting.alchemistsWorkshop)
                                    'room:bookshelf_top': 'starlit-orrery',
                                  'wall_art': 'moonlit-woodland',
                                  'wall_art:wall_left': 'fern-study',
                                  'wall_art:wall_right': 'celestial-study',
                                }
                              }),
                        ])),
                ]),
          ]),
        ))),
      );
}
