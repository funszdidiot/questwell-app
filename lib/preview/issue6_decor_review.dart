import 'package:flutter/material.dart';
import '../widgets/questwell_pixel_art.dart';
import '../widgets/questwell_woven_rug.dart';
import '../widgets/questwell_warding_lantern.dart';

/// Development-only review for Issue #6 replacement visuals.
/// No account, inventory, catalog activation, ownership or economy writes.
class Issue6DecorReviewApp extends StatefulWidget {
  const Issue6DecorReviewApp({super.key});

  @override
  State<Issue6DecorReviewApp> createState() => _Issue6DecorReviewAppState();
}

class _Issue6DecorReviewAppState extends State<Issue6DecorReviewApp> {
  String body = 'female';
  bool showAvatar = true;
  bool showRug = true;
  bool showLantern = true;
  String lanternSlot = 'right';

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          backgroundColor: const Color(0xFF111827),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text('Issue #6 · Hearth replacements',
                      style: TextStyle(fontSize: 22)),
                  const SizedBox(height: 4),
                  const Text(
                    'Development review only · catalog entries remain inactive',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      DropdownButton<String>(
                        value: body,
                        items: const ['female', 'male', 'neutral']
                            .map((value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => body = value!),
                      ),
                      DropdownButton<String>(
                        value: lanternSlot,
                        items: const ['left', 'right']
                            .map((value) => DropdownMenuItem(
                                  value: value,
                                  child: Text('Lantern: $value'),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => lanternSlot = value!),
                      ),
                      FilterChip(
                        label: const Text('Avatar'),
                        selected: showAvatar,
                        onSelected: (value) =>
                            setState(() => showAvatar = value),
                      ),
                      FilterChip(
                        label: const Text('Wayfarer Rug'),
                        selected: showRug,
                        onSelected: (value) =>
                            setState(() => showRug = value),
                      ),
                      FilterChip(
                        label: const Text('Warding Lantern'),
                        selected: showLantern,
                        onSelected: (value) =>
                            setState(() => showLantern = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: QuestwellHearthPixelScene(
                      height: 420,
                      archetype: 'guardian',
                      avatarBodyType: body,
                      showAvatar: showAvatar,
                      equippedSlugs: {
                        if (showRug)
                          'room:floor': QuestwellWovenRugPainter.slug,
                        if (lanternSlot != 'left')
                          'room:left': 'walnut-bookshelf',
                        if (showLantern)
                          'room:$lanternSlot': QuestwellWardingLantern.slug,
                        'room:front': 'burgundy-reading-chair',
                        'room:side': 'walnut-reading-table',
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Review the lantern silhouette, grounding, ward glow, and scale; '
                    'then the rug weave, border, compass stitching, perspective, '
                    'and readability underneath the adventurer.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
