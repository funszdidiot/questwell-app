import 'package:flutter/material.dart';

import '../widgets/questwell_halloween_costume.dart';

/// Account-free candidate inspection. Never grants or purchases a costume.
class HalloweenCostumesReviewApp extends StatefulWidget {
  const HalloweenCostumesReviewApp({super.key});

  @override
  State<HalloweenCostumesReviewApp> createState() =>
      _HalloweenCostumesReviewAppState();
}

class _HalloweenCostumesReviewAppState
    extends State<HalloweenCostumesReviewApp> {
  bool equipped = true;
  bool dark = false;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Questwell Halloween costumes',
        theme: ThemeData.dark(useMaterial3: true),
        home: Scaffold(
          backgroundColor: const Color(0xFF1F3937),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Halloween Wardrobe',
                    style: TextStyle(fontSize: 28, color: Color(0xFFE0C481)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Halloween collection · 180 coins per complete outfit',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [
                      FilterChip(
                        label: const Text('Complete outfit'),
                        selected: equipped,
                        onSelected: (value) => setState(() => equipped = value),
                      ),
                      FilterChip(
                        label: const Text('Dark backdrop'),
                        selected: dark,
                        onSelected: (value) => setState(() => dark = value),
                      ),
                    ],
                  ),
                  for (final costume
                      in QuestwellHalloweenCostume.costumes.entries) ...[
                    const SizedBox(height: 28),
                    Text(costume.value, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final body in QuestwellHalloweenCostume.bodies)
                          SizedBox(
                            width: 240,
                            child: Column(
                              children: [
                                Text(body),
                                const SizedBox(height: 8),
                                ColoredBox(
                                  color: dark
                                      ? const Color(0xFF202A2B)
                                      : const Color(0xFFF2E9DB),
                                  child: SizedBox(
                                    height: 320,
                                    child: QuestwellHalloweenCostume(
                                      body: body,
                                      costume: costume.key,
                                      equipped: equipped,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
}
