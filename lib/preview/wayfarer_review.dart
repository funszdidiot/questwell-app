import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/questwell_item_icon.dart';
import '../widgets/questwell_pixel_art.dart';
import '../widgets/questwell_typography.dart';

/// Shared production renderer with sample equipment; no account writes.
class WayfarerReviewApp extends StatefulWidget {
  const WayfarerReviewApp({super.key});
  @override
  State<WayfarerReviewApp> createState() => _WayfarerReviewAppState();
}

class _WayfarerReviewAppState extends State<WayfarerReviewApp> {
  String _body = 'male';
  bool _satchel = true;
  bool _cloak = false;

  @override
  Widget build(BuildContext context) {
    final equipment = <String, String>{
      if (_satchel) 'back': 'wayfarer-satchel',
      if (_cloak) 'chest': 'moss-green-cloak',
      'neck': 'emerald-scholar-scarf',
      'accessory': 'moonstone-brooch',
      'familiar': 'moss-moth',
    };
    return MaterialApp(debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme)),
      home: Scaffold(backgroundColor: const Color(0xFF111E23),
        body: SafeArea(child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: ListView(padding: const EdgeInsets.all(18), children: [
            Text('Wayfarer Satchel', style: QuestwellTypography.sectionHeading()),
            const SizedBox(height: 8),
            const Text('Carries three plans, two snacks, and one backup plan.'),
            const SizedBox(height: 12),
            const Row(children: [
              QuestwellItemIcon(slug: 'wayfarer-satchel', size: 48),
              SizedBox(width: 12),
              Text('Rare · Wanderer gear\n160 coins in the Market'),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: ['female', 'male', 'neutral'].map((body) =>
              ChoiceChip(label: Text(body[0].toUpperCase() + body.substring(1)),
                selected: body == _body,
                onSelected: (_) => setState(() => _body = body))).toList()),
            SwitchListTile(contentPadding: EdgeInsets.zero,
              title: const Text('Try on satchel'), value: _satchel,
              onChanged: (value) => setState(() => _satchel = value)),
            SwitchListTile(contentPadding: EdgeInsets.zero,
              title: const Text('Wear Moss Cloak'), value: _cloak,
              onChanged: (value) => setState(() => _cloak = value)),
            QuestwellEquippedAvatar(archetype: 'wanderer', avatarBodyType: _body,
              equippedSlugs: equipment, height: 340, artHeightFactor: .98),
            const SizedBox(height: 12),
            Text('At the Hearth', style: QuestwellTypography.sectionHeading()),
            const SizedBox(height: 8),
            QuestwellHearthPixelScene(archetype: 'wanderer', avatarBodyType: _body,
              equippedSlugs: equipment, height: 342),
            const SizedBox(height: 12),
            const Text('Sample try-on · your equipment and coins stay as they are.',
              style: TextStyle(color: Color(0xFFB9C6BD), fontSize: 13)),
          ]),
        ))),
      ),
    );
  }
}
