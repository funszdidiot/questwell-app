import 'package:flutter/material.dart';
import '../widgets/questwell_pixel_art.dart';
import '../widgets/questwell_item_icon.dart';
import '../widgets/questwell_typography.dart';

class EffectsReviewApp extends StatefulWidget {
  const EffectsReviewApp({super.key});
  @override
  State<EffectsReviewApp> createState() => _EffectsReviewAppState();
}
class _EffectsReviewAppState extends State<EffectsReviewApp> {
  String _effect = 'victory-sparkle';
  String _body = 'female';
  bool _equipped = true;
  bool _motion = true;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false, theme: ThemeData.dark(useMaterial3: true),
    home: Builder(builder: (context) {
      final equipment = <String, String>{if (_equipped) 'effect': _effect};
      return MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: !_motion),
        child: Scaffold(backgroundColor: const Color(0xFF111E23), body: SafeArea(
          child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(padding: const EdgeInsets.all(18), children: [
              Text('A little everyday magic', style: QuestwellTypography.sectionHeading()),
              const SizedBox(height: 12),
              Wrap(spacing: 8, children: ['victory-sparkle', 'focus-tonic'].map((slug) => ChoiceChip(
                label: Text(slug == 'victory-sparkle' ? 'Victory Sparkle' : 'Focus Tonic'),
                selected: _effect == slug, onSelected: (_) => setState(() => _effect = slug))).toList()),
              const SizedBox(height: 12),
              Row(children: [QuestwellItemIcon(slug: _effect, size: 48), const SizedBox(width: 12),
                Expanded(child: Text(_effect == 'victory-sparkle'
                  ? 'A golden flourish for your small victories.' : 'A little calm, bottled in green.'))]),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: ['female', 'male', 'neutral'].map((body) => ChoiceChip(
                label: Text(body == 'neutral' ? 'Gender neutral' : body == 'male' ? 'Male' : 'Female'),
                selected: _body == body, onSelected: (_) => setState(() => _body = body))).toList()),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Try on effect'),
                value: _equipped, onChanged: (v) => setState(() => _equipped = v)),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Animations'),
                value: _motion, onChanged: (v) => setState(() => _motion = v)),
              QuestwellEquippedAvatar(archetype: 'scholar', avatarBodyType: _body,
                equippedSlugs: equipment, height: 340, artHeightFactor: .98),
              const SizedBox(height: 12),
              Text('At the Hearth', style: QuestwellTypography.sectionHeading()),
              const SizedBox(height: 8),
              QuestwellHearthPixelScene(archetype: 'scholar', avatarBodyType: _body,
                equippedSlugs: equipment, height: 342),
              const SizedBox(height: 12),
              const Text('Cosmetic effects only. Your equipment and coins stay as they are.'),
            ])))),
        ));
    }));
}
