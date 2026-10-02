import 'package:flutter/material.dart';
import '../widgets/questwell_pixel_art.dart';
import '../widgets/questwell_woven_rug.dart';

/// Account-free visual fixture; no purchase or saved equipment changes.
class RugReviewApp extends StatefulWidget {
  const RugReviewApp({super.key});
  @override
  State<RugReviewApp> createState() => _RugReviewAppState();
}

class _RugReviewAppState extends State<RugReviewApp> {
  bool placed = true, avatar = true;
  String body = 'female';
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: Scaffold(backgroundColor: const Color(0xFF111827),
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          const Text('Emerald Wayfarer Rug', style: TextStyle(fontSize: 22)),
          const Text('20 coins · Hearth décor · Sample preview'),
          Wrap(spacing: 12, alignment: WrapAlignment.center, children: [
            TextButton(onPressed: () => setState(() => placed = !placed),
              child: Text(placed ? 'Return to inventory' : 'Place rug')),
            TextButton(onPressed: () => setState(() => avatar = !avatar),
              child: Text(avatar ? 'Hide adventurer' : 'Show adventurer')),
            DropdownButton<String>(value: body,
              items: ['female', 'male', 'neutral'].map((b) => DropdownMenuItem(
                value: b, child: Text(b))).toList(),
              onChanged: (b) => setState(() => body = b!)),
          ]),
          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 430),
            child: QuestwellHearthPixelScene(height: 420,
              archetype: 'wanderer', avatarBodyType: body, showAvatar: avatar,
              equippedSlugs: {
                if (placed) 'room:floor': QuestwellWovenRugPainter.slug,
                'room:right': 'walnut-bookshelf',
                'room:front': 'burgundy-reading-chair',
                'room:side': 'walnut-reading-table',
              })),
          const SizedBox(height: 12),
          const Text('Deep green threads, a woven gold border, and a compass rose.',
            textAlign: TextAlign.center),
        ]),
      )),
    ),
  );
}
