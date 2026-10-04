import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/questwell_neutral_scout.dart';

class NeutralScoutReviewApp extends StatefulWidget {
  const NeutralScoutReviewApp({super.key});
  @override
  State<NeutralScoutReviewApp> createState() => _NeutralScoutReviewAppState();
}

class _NeutralScoutReviewAppState extends State<NeutralScoutReviewApp> {
  final layers = <String>{'top', 'trousers', 'boots', 'robe', 'outfit'};
  bool details = false;

  Widget card(String title, Set<String> selection, double width) => SizedBox(
    width: width,
    child: Column(children: [
      Text(title, style: const TextStyle(fontSize: 20, color: Color(0xFFE0C481))),
      const SizedBox(height: 8),
      AspectRatio(aspectRatio: 240/320, child: QuestwellNeutralScout(layers: selection)),
      if (details) ...[
        const SizedBox(height: 18),
        const Text('Sleeve detail', style: TextStyle(color: Colors.white70)),
        ClipRect(child: SizedBox(width: width, height: width * 60/120,
          child: Stack(children: [Positioned(
            left: -64 * width/120, top: -80 * width/120,
            width: 240 * width/120, height: 320 * width/120,
            child: QuestwellNeutralScout(layers: selection),
          )]),
        )),
        const SizedBox(height: 18),
        const Text('Wrist detail', style: TextStyle(color: Colors.white70)),
        ClipRect(child: SizedBox(width: width, height: width * 50/148,
          child: Stack(children: [Positioned(
            left: -48 * width/148, top: -157 * width/148,
            width: 240 * width/148, height: 320 * width/148,
            child: QuestwellNeutralScout(layers: selection),
          )]),
        )),
      ],
    ]),
  );

  Widget toggle(String key, String title) => FilterChip(
    label: Text(title), selected: layers.contains(key),
    onSelected: (value) => setState(() {value ? layers.add(key) : layers.remove(key);}),
  );

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false, theme: ThemeData.dark(),
    home: Scaffold(backgroundColor: const Color(0xFF1F3937),
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20),
        child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(children: [
            const Text('The gender-neutral Scout', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, color: Color(0xFFE0C481))),
            const SizedBox(height: 10),
            const Text('Your approved frame. One body beneath every layer.', textAlign: TextAlign.center),
            const SizedBox(height: 6),
            const Text('Approved everyday clothes and robe fit · Woodland fitting preview', style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Wrap(spacing: 10, alignment: WrapAlignment.center, children: [
              toggle('top', 'Everyday top'), toggle('trousers', 'Trousers'),
              toggle('boots', 'Boots'), toggle('robe', 'Scout robe'),
              toggle('outfit', 'Woodland outfit'),
              FilterChip(label: const Text('Fit details'), selected: details,
                onSelected: (value) => setState(() => details = value)),
            ]),
            const SizedBox(height: 22),
            LayoutBuilder(builder: (context, constraints) {
              final width = ((constraints.maxWidth-54)/4).clamp(220.0, 300.0).toDouble();
              return Column(children: [
                if (width*4+54 > constraints.maxWidth) const Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: Text('Swipe sideways to compare the four stages.', textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70)),
                ),
                SingleChildScrollView(scrollDirection: Axis.horizontal,
                  child: SizedBox(width: math.max(constraints.maxWidth,width*4+54),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                        card('Fixed base', const {}, width), const SizedBox(width: 18),
                        card('Everyday clothes', layers.intersection({'top', 'trousers', 'boots'}), width), const SizedBox(width: 18),
                        card('Woodland Scout', layers.intersection({'outfit'}), width), const SizedBox(width: 18),
                        card('Scout robe', layers.difference({'outfit'}), width),
                      ]),
                  ),
                ),
              ]);
            }),
            const SizedBox(height: 20),
            const Text('Top, trousers and boots equip independently beneath the robe. Woodland is a separate outfit. The base stays fixed.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
          ]),
        )),
      )),
    ),
  );
}
