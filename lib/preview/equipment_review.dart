import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/questwell_pixel_art.dart';
import '../widgets/questwell_typography.dart';

/// Local visual fixture only: never owns items or writes equipment to an account.
class EquipmentReviewApp extends StatefulWidget {
  const EquipmentReviewApp({super.key, this.headwear = false, this.neckwear = false});
  final bool headwear;
  final bool neckwear;
  @override
  State<EquipmentReviewApp> createState() => _EquipmentReviewAppState();
}

class _EquipmentReviewAppState extends State<EquipmentReviewApp> {
  String _body = 'female';
  bool _glasses = true;
  bool _hat = true;
  bool _scarf = true;
  String _class = 'scholar';

  @override
  Widget build(BuildContext context) {
    final equipment = <String, String>{
      if (_glasses) 'face': 'round-scholar-glasses',
      if (widget.headwear && _hat) 'head': 'tiny-wizard-hat',
      if (widget.neckwear && _scarf) 'neck': 'emerald-scholar-scarf',
    };
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme)),
      home: Scaffold(backgroundColor: const Color(0xFF111827),
        body: SafeArea(child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: ListView(padding: const EdgeInsets.all(18), children: [
            Text(widget.neckwear ? 'Emerald scarf' : widget.headwear ? 'Tiny Wizard Hat' : 'Scholar glasses', style: QuestwellTypography.sectionHeading()),
            const SizedBox(height: 12),
            if (widget.neckwear) DropdownButton<String>(
              value: _class, isExpanded: true,
              items: ['scholar', 'scout', 'alchemist', 'guardian', 'wanderer'].map((value) =>
                DropdownMenuItem(value: value, child: Text(value[0].toUpperCase() + value.substring(1)))).toList(),
              onChanged: (value) { if (value != null) setState(() => _class = value); }),
            Text(widget.headwear ? 'A little magic, perched just so. Preview only.'
              : 'A warm brass frame, with room for a little curiosity. Preview only.'),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: ['female', 'male', 'neutral'].map((body) =>
              ChoiceChip(label: Text(body[0].toUpperCase() + body.substring(1)),
                labelStyle: GoogleFonts.roboto(fontSize: 14),
                selected: _body == body,
                onSelected: (_) => setState(() => _body = body))).toList()),
            if (widget.headwear) SwitchListTile(contentPadding: EdgeInsets.zero,
              title: const Text('Try on hat'), value: _hat,
              onChanged: (value) => setState(() => _hat = value)),
            if (widget.neckwear) SwitchListTile(contentPadding: EdgeInsets.zero,
              title: const Text('Try on scarf'), value: _scarf,
              onChanged: (value) => setState(() => _scarf = value)),
            SwitchListTile(contentPadding: EdgeInsets.zero,
              title: const Text('Try on glasses'), value: _glasses,
              onChanged: (value) => setState(() => _glasses = value)),
            QuestwellEquippedAvatar(archetype: _class, avatarBodyType: _body,
              equippedSlugs: equipment, height: 340, artHeightFactor: .98),
            const SizedBox(height: 24),
            Text('At the Hearth', style: QuestwellTypography.sectionHeading()),
            const SizedBox(height: 12),
            QuestwellHearthPixelScene(archetype: _class, avatarBodyType: _body,
              equippedSlugs: equipment, height: 342),
          ]),
        ))),
      ),
    );
  }
}
