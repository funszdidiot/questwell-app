import 'package:flutter/material.dart';
import '../widgets/questwell_pixel_art.dart';

/// Account-free fit audit using the same renderer as Hearth and inventory.
class LegacyWardrobeReviewApp extends StatefulWidget {
  const LegacyWardrobeReviewApp({super.key, this.initialBody = 'male', this.focusGarment});
  final String initialBody;
  final String? focusGarment;

  @override
  State<LegacyWardrobeReviewApp> createState() => _LegacyWardrobeReviewAppState();
}

class _LegacyWardrobeReviewAppState extends State<LegacyWardrobeReviewApp> {
  late String body = const ['female', 'neutral'].contains(widget.initialBody)
      ? widget.initialBody : 'male';
  String archetype = 'scout';
  bool light = false, enlarged = false, equipped = true;
  static const garments = {
    'Class robe': null,
    'Business Suit': 'starter-business-suit',
    'Midnight Harvest Coat': 'midnight-harvest-coat',
    'Moss-Green Cloak': 'moss-green-cloak',
    'Hearthguard Mantle': 'hearthguard-mantle',
  };

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true),
    home: Scaffold(body: SafeArea(child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Legacy wardrobe fit audit', style: TextStyle(fontSize: 24)),
        const Text('Shared app renderer · sample equipment · no account changes. '
            'Technical body preservation does not establish garment approval.'),
        Wrap(spacing: 8, children: [for (final value in ['male', 'female', 'neutral'])
          ChoiceChip(label: Text(value), selected: body == value,
            onSelected: (_) => setState(() => body = value)),
        ]),
        Wrap(spacing: 8, children: [for (final value in ['scout', 'scholar', 'alchemist', 'guardian', 'wanderer'])
          ChoiceChip(label: Text(value), selected: archetype == value,
            onSelected: (_) => setState(() => archetype = value)),
        ]),
        Wrap(spacing: 8, children: [
          FilterChip(label: const Text('Light background'), selected: light,
            onSelected: (value) => setState(() => light = value)),
          FilterChip(label: const Text('Enlarged'), selected: enlarged,
            onSelected: (value) => setState(() => enlarged = value)),
          FilterChip(label: const Text('Garments equipped'), selected: equipped,
            onSelected: (value) => setState(() => equipped = value)),
        ]),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, constraints) {
          final width = (enlarged ? 480.0 : 240.0).clamp(0.0, constraints.maxWidth).toDouble();
          return Wrap(spacing: 16, runSpacing: 16, children: [
            for (final entry in garments.entries.where((entry) =>
                !garments.containsValue(widget.focusGarment) ||
                widget.focusGarment == null || entry.value == null ||
                entry.value == widget.focusGarment))
              SizedBox(width: width, child: Column(children: [
              Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ColoredBox(color: light ? const Color(0xFFF4EDDF) : const Color(0xFF18252C),
                child: SizedBox(width: width, height: width * 4 / 3,
                  child: QuestwellLayeredAdventurerArt(
                    key: ValueKey('${entry.key}-$body-$archetype'),
                    avatarBodyType: body, archetype: archetype,
                    equippedSlugs: {if (equipped && entry.value != null) 'chest': entry.value!},
                  ))),
            ])),
          ]);
        }),
      ],
    ))),
  );
}
