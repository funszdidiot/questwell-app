import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/questwell_pixel_art.dart';
import '../widgets/questwell_typography.dart';

class CloakReviewApp extends StatefulWidget {
  const CloakReviewApp({super.key});
  @override
  State<CloakReviewApp> createState() => _CloakReviewAppState();
}
class _CloakReviewAppState extends State<CloakReviewApp> {
  String _slug = 'moss-green-cloak';
  String _body = 'female';
  String _class = 'scholar';
  bool _wear = true;
  @override
  Widget build(BuildContext context) {
    final mantle = _slug == 'hearthguard-mantle';
    final archetype = mantle ? 'guardian' : _class;
    final equipment = <String,String>{if (_wear) 'chest': _slug};
    return MaterialApp(debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme)),
      home: Scaffold(backgroundColor: const Color(0xFF111E23),
        body: SafeArea(child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: ListView(padding: const EdgeInsets.all(18), children: [
            Text('Cloaks for the journey', style: QuestwellTypography.sectionHeading()),
            const SizedBox(height: 8),
            const Text('Leaf-stitched wool or a guardian’s mantle. Try the fit on your adventurer.'),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: [
              for (final entry in const {'moss-green-cloak':'Moss Cloak','hearthguard-mantle':'Hearthguard'}.entries)
                ChoiceChip(label: Text(entry.value), selected: _slug == entry.key,
                  onSelected: (_) => setState(() => _slug = entry.key)),
            ]),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: ['female','male','neutral'].map((body) =>
              ChoiceChip(label: Text(body[0].toUpperCase()+body.substring(1)),
                selected: body == _body,
                onSelected: (_) => setState(() => _body = body))).toList()),
            if (!mantle) DropdownButton<String>(value: _class, isExpanded: true,
              items: ['scholar','scout','alchemist','guardian','wanderer'].map((value) =>
                DropdownMenuItem(value: value, child: Text(value[0].toUpperCase()+value.substring(1)))).toList(),
              onChanged: (value) { if (value != null) setState(() => _class = value); })
            else const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Guardian class')),
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Try on cloak'),
              value: _wear, onChanged: (value) => setState(() => _wear = value)),
            QuestwellEquippedAvatar(archetype: archetype, avatarBodyType: _body,
              equippedSlugs: equipment, height: 340, artHeightFactor: .98),
            const SizedBox(height: 12),
            Text('At the Hearth', style: QuestwellTypography.sectionHeading()),
            const SizedBox(height: 8),
            QuestwellHearthPixelScene(archetype: archetype, avatarBodyType: _body,
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
