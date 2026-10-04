import 'package:flutter/material.dart';

import '../widgets/questwell_pixel_art.dart';

/// All neutral class colors rendered through the same wardrobe as the app.
class NeutralRobesReviewApp extends StatelessWidget {
  const NeutralRobesReviewApp({super.key});

  static const classes = {
    'scout': 'Scout',
    'scholar': 'Scholar',
    'alchemist': 'Alchemist',
    'guardian': 'Guardian',
    'wanderer': 'Wanderer',
  };

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          backgroundColor: const Color(0xFF1F3937),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1320),
                  child: Column(children: [
                    const Text('Neutral class robes',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 28, color: Color(0xFFE0C481))),
                    const SizedBox(height: 10),
                    const Text('One approved fit. Five class designs.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    LayoutBuilder(builder: (context, constraints) {
                      final width = constraints.maxWidth.clamp(0.0, 240.0).toDouble();
                      return Wrap(
                        spacing: 24,
                        runSpacing: 32,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final entry in classes.entries)
                            SizedBox(
                              width: width,
                              child: Column(children: [
                                Text(entry.value,
                                    style: const TextStyle(fontSize: 20, color: Color(0xFFE0C481))),
                                const SizedBox(height: 8),
                                AspectRatio(
                                  aspectRatio: 240 / 320,
                                  child: QuestwellLayeredAdventurerArt(
                                    archetype: entry.key,
                                    avatarBodyType: 'neutral',
                                    equippedSlugs: const {},
                                  ),
                                ),
                              ]),
                            ),
                        ],
                      );
                    }),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
}
