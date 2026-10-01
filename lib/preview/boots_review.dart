import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/questwell_item_icon.dart';
import '../widgets/questwell_pixel_art.dart';
import '../widgets/questwell_typography.dart';

class BootsReviewApp extends StatefulWidget {
  const BootsReviewApp({super.key});
  @override
  State<BootsReviewApp> createState() => _BootsReviewAppState();
}

class _BootsReviewAppState extends State<BootsReviewApp> {
  String _body = 'female';
  String _archetype = 'scout';
  String _cloak = '';
  bool _worn = true;
  @override
  Widget build(BuildContext context) {
    final equipment = <String, String>{
      if (_worn) 'feet': 'pathfinder-boots',
      if (_cloak.isNotEmpty) 'chest': _cloak,
    };
    return MaterialApp(debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme)),
      home: Scaffold(backgroundColor: const Color(0xFF111E23),
        body: SafeArea(child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: ListView(padding: const EdgeInsets.all(18), children: [
            Text('Pathfinder Boots', style: QuestwellTypography.sectionHeading()),
            const SizedBox(height: 8),
            const Text('For finding the shortest route through a long day.'),
            const SizedBox(height: 12),
            const Row(children: [QuestwellItemIcon(slug: 'pathfinder-boots', size: 48),
              SizedBox(width: 12), Text('Rare · Scout gear\n160 coins in the Market')]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: ['female', 'male', 'neutral'].map((body) =>
              ChoiceChip(label: Text(body[0].toUpperCase() + body.substring(1)),
                selected: body == _body, onSelected: (_) => setState(() => _body = body))).toList()),
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Wear Pathfinder Boots'),
              value: _worn, onChanged: (value) => setState(() => _worn = value)),
            Wrap(spacing: 8, children: ['scout', 'scholar', 'wanderer'].map((type) =>
              ChoiceChip(label: Text(type[0].toUpperCase() + type.substring(1)),
                selected: type == _archetype, onSelected: (_) => setState(() => _archetype = type))).toList()),
            Wrap(spacing: 8, children: const {'': 'No cloak', 'moss-green-cloak': 'Moss',
              'hearthguard-mantle': 'Hearthguard'}.entries.map((entry) => ChoiceChip(
                label: Text(entry.value), selected: entry.key == _cloak,
                onSelected: (_) => setState(() => _cloak = entry.key))).toList()),
            QuestwellEquippedAvatar(archetype: _archetype, avatarBodyType: _body,
              equippedSlugs: equipment, height: 340, artHeightFactor: .98),
            const SizedBox(height: 12),
            Text('At the Hearth', style: QuestwellTypography.sectionHeading()),
            const SizedBox(height: 8),
            QuestwellHearthPixelScene(archetype: _archetype, avatarBodyType: _body,
              equippedSlugs: equipment, height: 342),
            const SizedBox(height: 12),
            const Text('Sample garment try-on · your equipment and coins stay as they are.',
              style: TextStyle(color: Color(0xFFB9C6BD), fontSize: 13)),
          ]),
        ))),
      ),
    );
  }
}
