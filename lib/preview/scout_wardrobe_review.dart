import 'package:flutter/material.dart';
import '../widgets/questwell_pixel_art.dart';

class ScoutWardrobeReviewApp extends StatefulWidget {
  const ScoutWardrobeReviewApp({super.key});
  @override
  State<ScoutWardrobeReviewApp> createState() => _ScoutWardrobeReviewAppState();
}
class _ScoutWardrobeReviewAppState extends State<ScoutWardrobeReviewApp> {
  final Set<String> layers = {'top', 'trousers', 'robe'};
  bool accessories = false;
  bool detail = false;
  bool compareBase = true;
  String held = 'none';
  String bodyView = 'female';
  @override
  void initState() {
    super.initState();
    final q = Uri.base.queryParameters;
    if (q.containsKey('layers')) {
      layers.retainAll(q['layers']!.split(','));
    }
    if (['all', 'female', 'male', 'neutral'].contains(q['body'])) bodyView = q['body']!;
    compareBase = q['compare'] != 'none';
    accessories = q['gear'] == 'all';
    detail = q['detail'] == 'cuffs';
    if (['brass-lantern', 'annotated-grimoire'].contains(q['held'])) held = q['held']!;
  }
  Widget art(String body, {bool withoutRobe = false}) => QuestwellLayeredAdventurerArt(archetype: 'scout',
      avatarBodyType: body, previewScoutLayers: layers.where((l) => !withoutRobe || l != 'robe').toSet(), equippedSlugs: {
        if (held != 'none') 'hands': held,
        if (accessories) ...{'head': 'tiny-wizard-hat', 'face': 'round-scholar-glasses',
          'neck': 'emerald-scholar-scarf', 'back': 'leather-satchel',
          'accessory': 'moonstone-brooch', 'feet': 'pathfinder-boots'},
      });
  Widget cuffs(String body, {bool withoutRobe = false}) => SizedBox(height: 144, child: ClipRect(
    child: LayoutBuilder(builder: (context, constraints) {
      final scale = constraints.maxWidth / 148;
      return Stack(children: [Positioned(
        left: (constraints.maxWidth - 240 * scale) / 2, top: -153 * scale,
        width: 240 * scale, height: 320 * scale, child: art(body, withoutRobe: withoutRobe))]);
    })));
  Widget fitCard(String body, {bool withoutRobe = false}) {
    final label = body == 'neutral' ? 'Gender neutral' : body == 'female' ? 'Female' : 'Male';
    final comparing = compareBase && bodyView != 'all';
    return SizedBox(width: bodyView == 'all' ? 280 : comparing ? 360 : 420,
      child: Column(children: [
        Text(comparing ? '$label · ${withoutRobe ? 'Base fit' : 'Robe fit'}' : label,
          style: const TextStyle(fontSize: 20, color: Color(0xFFE0C481))),
        if (detail) cuffs(body, withoutRobe: withoutRobe),
        SizedBox(width: double.infinity, height: bodyView == 'all' ? 400 : comparing ? 480 : 560,
          child: art(body, withoutRobe: withoutRobe)),
      ]));
  }
  @override
  Widget build(BuildContext context) => MaterialApp(debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), home: Scaffold(backgroundColor: const Color(0xFF1F3937),
        body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20),
          child: Column(children: [
            const Text('The Scout wardrobe', style: TextStyle(fontSize: 28, color: Color(0xFFE0C481))),
            const SizedBox(height: 8),
            const Text('Individual robe fits: shoulders, hips, and wrists.', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 8, alignment: WrapAlignment.center, children: [
              SizedBox(width: 180, child: DropdownButton<String>(isExpanded: true, value: bodyView,
                items: const [DropdownMenuItem(value: 'all', child: Text('All three fits')),
                  DropdownMenuItem(value: 'female', child: Text('Female fit')),
                  DropdownMenuItem(value: 'male', child: Text('Male fit')),
                  DropdownMenuItem(value: 'neutral', child: Text('Gender-neutral fit'))],
                onChanged: (v) => setState(() => bodyView = v!))),
              for (final entry in {'top':'Linen top', 'trousers':'Travel trousers', 'robe':'Scout robe'}.entries)
                FilterChip(label: Text(entry.value), selected: layers.contains(entry.key),
                  onSelected: (v) => setState(() { if (v) {layers.add(entry.key);} else {layers.remove(entry.key);} })),
              FilterChip(label: const Text('Accessories'), selected: accessories,
                onSelected: (v) => setState(() => accessories = v)),
              FilterChip(label: const Text('Cuff detail'), selected: detail,
                onSelected: (v) => setState(() => detail = v)),
              if (bodyView != 'all') FilterChip(label: const Text('Base beside robe'), selected: compareBase,
                onSelected: (v) => setState(() => compareBase = v)),
              SizedBox(width: 190, child: DropdownButton<String>(isExpanded: true, value: held,
                items: const [DropdownMenuItem(value: 'none', child: Text('Empty hands')),
                  DropdownMenuItem(value: 'brass-lantern', child: Text('Brass lantern')),
                  DropdownMenuItem(value: 'annotated-grimoire', child: Text('Grimoire'))],
                onChanged: (v) => setState(() => held = v!))),
            ]),
            const SizedBox(height: 24),
            Wrap(spacing: 18, runSpacing: 24, alignment: WrapAlignment.center, children: [
              for (final body in bodyView == 'all' ? ['female', 'male', 'neutral'] : [bodyView]) ...[
                if (compareBase && bodyView != 'all') fitCard(body, withoutRobe: true),
                fitCard(body),
              ],
            ]),
            const SizedBox(height: 16),
            const Text('Wardrobe fitting preview', style: TextStyle(color: Colors.white60)),
          ]),
        )),
      ));
}
