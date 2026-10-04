import 'package:flutter/material.dart';

import '../widgets/questwell_male_paper_doll.dart';

/// All five robe surfaces on one immutable foundation; no account mutations.
class MaleClassRobesReviewApp extends StatelessWidget {
  const MaleClassRobesReviewApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Questwell · Male class robes',
        theme: ThemeData.dark(useMaterial3: true),
        home: Scaffold(
          backgroundColor: const Color(0xFF1F3937),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(children: [
                    const Text('Male class robes', textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 28, color: Color(0xFFE0C481))),
                    const SizedBox(height: 10),
                    const Text('One fixed body. Five class designs.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    const Text('Development review · account wardrobe rollout pending',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 24),
                    LayoutBuilder(builder: (context, constraints) {
                      final width = constraints.maxWidth.clamp(0.0, 240.0).toDouble();
                      return Wrap(
                        spacing: 16, runSpacing: 24, alignment: WrapAlignment.center,
                        children: [
                          for (final entry in QuestwellMalePaperDoll.classLabels.entries)
                            SizedBox(
                              width: width,
                              child: Column(children: [
                                Text(entry.value, style: const TextStyle(
                                    fontSize: 20, color: Color(0xFFE0C481))),
                                const SizedBox(height: 10),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF2E9DB),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 240 / 320,
                                    child: Semantics(
                                      label: '${entry.value} robe on locked male foundation',
                                      image: true,
                                      child: QuestwellMalePaperDoll(
                                        showRobe: true, robeArchetype: entry.key,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                        ],
                      );
                    }),
                    const SizedBox(height: 24),
                    const Text('The Woodland Scout outfit is a separate wardrobe build.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70)),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
}
