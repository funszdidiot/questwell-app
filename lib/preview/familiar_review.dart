import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/questwell_familiar.dart';
import '../widgets/questwell_pixel_art.dart';
import '../widgets/questwell_typography.dart';
import '../widgets/questwell_item_icon.dart';

/// Account-free try-on. Candidate pets are not Market inventory.
class FamiliarReviewApp extends StatefulWidget {
  const FamiliarReviewApp({super.key});
  @override
  State<FamiliarReviewApp> createState() => _FamiliarReviewAppState();
}

class _FamiliarReviewAppState extends State<FamiliarReviewApp> {
  String _slug = 'boston-terrier';
  String _body = 'female';
  bool _motion = true;
  bool _rain = true;
  @override
  Widget build(BuildContext context) {
    final archetype = switch (_slug) {
      'signal-fox' => 'scout',
      'glass-slime' => 'alchemist',
      'moss-moth' => 'wanderer',
      _ => 'scholar',
    };
    final equipment = <String, String>{'familiar': _slug};
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
      ),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations:
                !_motion || MediaQuery.disableAnimationsOf(context),
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFF111E23),
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      Text(
                        'Meet your familiars',
                        style: QuestwellTypography.sectionHeading(),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'A little company for the journey. Try each companion beside your adventurer.',
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _slug,
                        decoration: const InputDecoration(
                          labelText: 'Companion',
                          border: OutlineInputBorder(),
                        ),
                        items: QuestwellFamiliarLayer.allNames.entries
                            .map(
                              (entry) => DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _slug = value);
                        },
                      ),
                      const SizedBox(height: 8),
                      Center(child: QuestwellItemIcon(slug: _slug, size: 48)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['female', 'male', 'neutral']
                            .map(
                              (body) => ChoiceChip(
                                label: Text(
                                  body[0].toUpperCase() + body.substring(1),
                                ),
                                selected: body == _body,
                                onSelected: (_) => setState(() => _body = body),
                              ),
                            )
                            .toList(),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Animations'),
                        value: _motion,
                        onChanged: (value) => setState(() => _motion = value),
                      ),
                      QuestwellEquippedAvatar(
                        archetype: archetype,
                        avatarBodyType: _body,
                        equippedSlugs: equipment,
                        height: 340,
                        artHeightFactor: .98,
                      ),
                      Text(
                        'At the Hearth',
                        style: QuestwellTypography.sectionHeading(),
                      ),
                      const SizedBox(height: 12),
                      QuestwellHearthPixelScene(
                        archetype: archetype,
                        avatarBodyType: _body,
                        equippedSlugs: {
                          ...equipment,
                          if (_rain) 'room:window': 'rainy-window',
                        },
                        height: 342,
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Rainy window'),
                        value: _rain,
                        onChanged: (value) => setState(() => _rain = value),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        QuestwellFamiliarLayer.previewNames.containsKey(_slug)
                            ? 'New companion preview · Market release pending.'
                            : 'Sample try-on · find this companion in the Market.',
                        style: const TextStyle(
                          color: Color(0xFFB9C6BD),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
