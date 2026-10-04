import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/questwell_cosmetic_models.dart';
import '../widgets/questwell_equipment_swap.dart';
import '../widgets/questwell_item_icon.dart';
import '../widgets/questwell_pixel_art.dart';
import '../widgets/questwell_typography.dart';
import 'market_catalog.dart';

/// Uses the production renderer and swap dialog without touching an account.
class GrimoireReviewApp extends StatefulWidget {
  const GrimoireReviewApp({super.key});
  @override
  State<GrimoireReviewApp> createState() => _GrimoireReviewAppState();
}

class _GrimoireReviewAppState extends State<GrimoireReviewApp> {
  String _body = const {'female', 'male', 'neutral'}.contains(Uri.base.queryParameters['body'])
      ? Uri.base.queryParameters['body']! : 'neutral';
  bool _held = true;
  bool _cloak = false;
  QuestwellCosmetic _item(String slug) => QuestwellCosmetic.fromJson(
    marketReviewCatalog.firstWhere((item) => item['slug'] == slug), owned: true);

  Future<void> _hold(BuildContext context, bool value) async {
    if (value && _cloak && !await confirmCloakSwap(context,
        _item('annotated-grimoire'), _item('moss-green-cloak'))) return;
    if (!mounted) return;
    setState(() { _held = value; if (value) _cloak = false; });
  }

  Future<void> _tryCloak(BuildContext context) async {
    if (!_cloak && _held && !await confirmCloakSwap(context,
        _item('moss-green-cloak'), _item('annotated-grimoire'))) return;
    if (!mounted) return;
    setState(() { _cloak = !_cloak; if (_cloak) _held = false; });
  }

  @override
  Widget build(BuildContext context) {
    final equipment = <String, String>{
      if (_held) 'hands': 'annotated-grimoire',
      if (_cloak) 'chest': 'moss-green-cloak',
      'neck': 'emerald-scholar-scarf',
      'back': 'leather-satchel',
      'accessory': 'moonstone-brooch',
    };
    return MaterialApp(debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme)),
      home: Scaffold(backgroundColor: const Color(0xFF111E23),
        body: SafeArea(child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: ListView(padding: const EdgeInsets.all(18), children: [
            Text('Annotated Grimoire', style: QuestwellTypography.sectionHeading()),
            const SizedBox(height: 8),
            const Text('A margin-filled field guide for people who weaponize footnotes.'),
            const SizedBox(height: 12),
            const Row(children: [
              QuestwellItemIcon(slug: 'annotated-grimoire', size: 48),
              SizedBox(width: 12), Text('Rare · Scholar gear\n160 coins in the Market'),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: ['female', 'male', 'neutral'].map((body) =>
              ChoiceChip(label: Text(body[0].toUpperCase() + body.substring(1)),
                selected: body == _body,
                onSelected: (_) => setState(() => _body = body))).toList()),
            Builder(builder: (context) => SwitchListTile(contentPadding: EdgeInsets.zero,
              title: const Text('Equip grimoire on belt'), value: _held,
              onChanged: (value) => _hold(context, value))),
            Builder(builder: (context) => Align(alignment: Alignment.centerLeft,
              child: TextButton.icon(onPressed: () => _tryCloak(context),
                icon: const Icon(Icons.swap_horiz),
                label: Text(_cloak ? 'Remove Moss Cloak' : 'Try Moss Cloak')))),
            QuestwellEquippedAvatar(archetype: 'scholar', avatarBodyType: _body,
              equippedSlugs: equipment, height: 340, artHeightFactor: .98),
            const SizedBox(height: 12),
            Text('At the Hearth', style: QuestwellTypography.sectionHeading()),
            const SizedBox(height: 8),
            QuestwellHearthPixelScene(archetype: 'scholar', avatarBodyType: _body,
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
