import 'package:flutter/material.dart';
import '../widgets/questwell_pixel_art.dart';

/// Shared renderer, enlarged at the wrists. Does not write account equipment.
class WandererCuffReviewApp extends StatefulWidget {
  const WandererCuffReviewApp({super.key});
  @override
  State<WandererCuffReviewApp> createState() => _WandererCuffReviewAppState();
}
class _WandererCuffReviewAppState extends State<WandererCuffReviewApp> {
  bool satchel = false;
  @override
  Widget build(BuildContext context) {
    final equipment = <String, String>{if (satchel) 'back': 'wayfarer-satchel'};
    Widget art() => QuestwellLayeredAdventurerArt(archetype: 'wanderer',
      avatarBodyType: 'male', equippedSlugs: equipment);
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(),
      home: Scaffold(backgroundColor: const Color(0xFF111E23),
        body: SafeArea(child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: ListView(padding: const EdgeInsets.all(16), children: [
            const Text('Male Wanderer cuffs', style: TextStyle(fontSize: 22)),
            const Text('Revised wrist fit · awaiting your visual review'),
            SwitchListTile(contentPadding: EdgeInsets.zero,
              title: const Text('Try on satchel'), value: satchel,
              onChanged: (value) => setState(() => satchel = value)),
            QuestwellEquippedAvatar(archetype: 'wanderer', avatarBodyType: 'male',
              equippedSlugs: equipment, height: 320, artHeightFactor: .98),
            const SizedBox(height: 16),
            const Text('Wrist close-up', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Container(height: 175, decoration: BoxDecoration(
              color: const Color(0xFF23323A), border: Border.all(color: const Color(0xFF967B50))),
              child: ClipRect(child: LayoutBuilder(builder: (context, constraints) {
                final scale = constraints.maxWidth / 150;
                return Stack(clipBehavior: Clip.hardEdge, children: [
                  Positioned(left: (constraints.maxWidth - 240 * scale) / 2,
                    top: -144 * scale, width: 240 * scale,
                    height: 320 * scale, child: art()),
                ]);
              }))),
            const SizedBox(height: 12),
            const Text('The sleeve ends should meet the wrists without flared corners or detached bands.'),
            const SizedBox(height: 16),
            QuestwellHearthPixelScene(archetype: 'wanderer', avatarBodyType: 'male',
              equippedSlugs: equipment, height: 340),
          ]),
        ))),
      ));
  }
}
