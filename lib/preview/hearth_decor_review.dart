import 'package:flutter/material.dart';
import '../widgets/questwell_pixel_art.dart';

/// Development-only, account-free review of every three-item arrangement.
class HearthDecorReviewApp extends StatefulWidget {
  const HearthDecorReviewApp({super.key});
  @override
  State<HearthDecorReviewApp> createState() => _HearthDecorReviewAppState();
}
class _HearthDecorReviewAppState extends State<HearthDecorReviewApp> {
  double width = 390;
  static const items = ['hearth-fern', 'walnut-bookshelf', 'burgundy-reading-chair'];
  static const arrangements = [[0,1,2],[1,0,2],[1,2,0]];
  static const names = ['Fern', 'Bookshelf', 'Chair'];
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false, theme: ThemeData.dark(),
    home: Scaffold(backgroundColor: const Color(0xFF111827),
      body: SingleChildScrollView(child: Column(children: [
        const SizedBox(height: 16),
        const Text('Hearth décor · placement review', style: TextStyle(fontSize: 22)),
        const Text('Supported arrangements • Left / Right / Front'),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('Room width: '),
          DropdownButton<double>(value: width,
            items: [320.0,390.0,768.0].map((w) => DropdownMenuItem(
              value: w, child: Text('${w.toInt()} px'))).toList(),
            onChanged: (w) => setState(() => width = w!)),
        ]),
        Wrap(spacing: 12, runSpacing: 14, alignment: WrapAlignment.center,
          children: [for (final order in arrangements)
            SizedBox(width: width, child: Column(children: [
              Text(order.map((i) => names[i]).join(' / ')),
              const SizedBox(height: 6),
              QuestwellHearthPixelScene(height: 310, archetype: 'alchemist',
                avatarBodyType: 'female', equippedSlugs: {
                  'room:left': items[order[0]], 'room:right': items[order[1]],
                  'room:front': items[order[2]],
                }),
            ])),
          ]),
        const SizedBox(height: 20),
      ])),
    ),
  );
}
