import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/questwell_pixel_art.dart';

enum _WardrobeStage { underwear, everyday, robe }

class ScoutWardrobeReviewApp extends StatefulWidget {
  const ScoutWardrobeReviewApp({super.key, this.woodland = false, this.archetype = 'scout'});
  final bool woodland;
  final String archetype;

  @override
  State<ScoutWardrobeReviewApp> createState() => _ScoutWardrobeReviewAppState();
}

class _ScoutWardrobeReviewAppState extends State<ScoutWardrobeReviewApp> {
  final Set<String> layers = {'top', 'trousers', 'boots', 'robe'};
  bool accessories = false;
  bool detail = false;
  bool compareStages = true;
  String held = 'none';
  String bodyView = 'female';

  String get className => switch (widget.archetype) {
    'alchemist' => 'Alchemist',
    'scholar' => 'Scholar',
    _ => 'Scout',
  };

  @override
  void initState() {
    super.initState();
    if (widget.woodland) {
      layers..clear()..add('outfit');
    }
    final q = Uri.base.queryParameters;
    if (q.containsKey('layers')) {
      layers.retainAll(q['layers']!.split(','));
    }
    if (!widget.woodland && widget.archetype == 'scout' && ['all', 'female', 'male', 'neutral'].contains(q['body'])) {
      bodyView = q['body']!;
    }
    // Older compare=base links also open the complete layer comparison.
    compareStages = q['compare'] != 'none';
    accessories = q['gear'] == 'all';
    detail = q['detail'] == 'cuffs';
    if (['brass-lantern', 'annotated-grimoire'].contains(q['held'])) {
      held = q['held']!;
    }
  }

  Set<String> stageLayers(String body, _WardrobeStage stage) {
    if (stage == _WardrobeStage.underwear) return <String>{};
    if (widget.woodland) return layers.contains('outfit') ? {'outfit'} : <String>{};
    return layers.where((layer) {
      if (layer == 'boots' && body != 'female') return false;
      return stage == _WardrobeStage.robe || layer != (widget.woodland ? 'vest' : 'robe');
    }).toSet();
  }

  Widget art(String body, _WardrobeStage stage) {
    final dressed = stage != _WardrobeStage.underwear;
    return QuestwellLayeredAdventurerArt(
      archetype: widget.archetype,
      avatarBodyType: body,
      previewScoutLayers: widget.woodland
          ? (stage == _WardrobeStage.everyday ? const {'top', 'trousers', 'boots'} : null)
          : stageLayers(body, stage),
      previewWoodlandLayers: widget.woodland && stage != _WardrobeStage.everyday
          ? stageLayers(body, stage) : null,
      equippedSlugs: {
        if (dressed && held != 'none') 'hands': held,
        if (dressed && accessories) ...{
          'head': 'tiny-wizard-hat',
          'face': 'round-scholar-glasses',
          'neck': 'emerald-scholar-scarf',
          'back': 'leather-satchel',
          'accessory': 'moonstone-brooch',
        },
      },
    );
  }

  Widget cuffs(String body, _WardrobeStage stage) => SizedBox(
        height: widget.woodland ? 164 : 120,
        child: ClipRect(
          child: LayoutBuilder(builder: (context, constraints) {
            final scale = constraints.maxWidth / 148;
            return Stack(children: [
              Positioned(
                left: (constraints.maxWidth - 240 * scale) / 2,
                top: -(widget.woodland ? 118 : 153) * scale,
                width: 240 * scale,
                height: 320 * scale,
                child: art(body, stage),
              ),
            ]);
          }),
        ),
      );

  Widget fitCard(String body, _WardrobeStage stage, double width) {
    final title = switch (stage) {
      _WardrobeStage.underwear => 'Underwear',
      _WardrobeStage.everyday => 'Everyday clothes',
      _WardrobeStage.robe => widget.woodland ? 'Woodland Scout' : 'Robe',
    };
    return SizedBox(
      width: width,
      child: Column(children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, color: Color(0xFFE0C481)),
        ),
        const SizedBox(height: 8),
        // Every stage uses the same complete canvas at exactly the same scale.
        AspectRatio(aspectRatio: 240 / 320, child: art(body, stage)),
        if (detail) ...[
          const SizedBox(height: 12),
          Text(widget.woodland ? 'Sleeves and hands' : 'Wrists', style: const TextStyle(color: Colors.white60)),
          cuffs(body, stage),
        ],
      ]),
    );
  }

  Widget bodyReview(String body, double availableWidth) {
    final label = switch (body) {
      'female' => 'Female',
      'male' => 'Male',
      _ => 'Gender neutral',
    };
    final stages = compareStages
        ? _WardrobeStage.values
        : [_WardrobeStage.robe];
    const gap = 18.0;
    final cardWidth = compareStages
        ? ((availableWidth - gap * 2) / 3).clamp(220.0, 320.0).toDouble()
        : math.min(360.0, availableWidth);
    final rowWidth = cardWidth * stages.length + gap * (stages.length - 1);
    return Column(children: [
      Text(label, style: const TextStyle(fontSize: 22)),
      const SizedBox(height: 4),
      Text(
        body == 'female'
            ? (widget.archetype == 'scholar' ? 'Locked female fit. Scholar design preview.'
                : widget.archetype == 'alchemist' ? 'Approved female Alchemist fit.' : 'Approved female fit.')
            : 'Previous fit candidate — fixed-body rebuild pending.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70),
      ),
      if (rowWidth > availableWidth) ...[
        const SizedBox(height: 8),
        const Text(
          'Swipe sideways to compare the three stages at the same size.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
      const SizedBox(height: 16),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: math.max(availableWidth, rowWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < stages.length; index++) ...[
                if (index > 0) const SizedBox(width: gap),
                fitCard(body, stages[index], cardWidth),
              ],
            ],
          ),
        ),
      ),
    ]);
  }

  Widget layerToggle(String layer, String label, {bool enabled = true}) =>
      FilterChip(
        label: Text(label),
        selected: layers.contains(layer),
        onSelected: enabled
            ? (selected) => setState(() {
                  if (selected) {
                    layers.add(layer);
                  } else {
                    layers.remove(layer);
                  }
                })
            : null,
      );

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
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(children: [
                    Text(
                      widget.woodland ? 'Woodland Scout' : 'The $className wardrobe',
                      style: const TextStyle(fontSize: 28, color: Color(0xFFE0C481)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'One body. Clothes added in layers.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        if (!widget.woodland && widget.archetype == 'scout') SizedBox(
                          width: 180,
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: bodyView,
                            items: const [
                              DropdownMenuItem(value: 'female', child: Text('Female fit')),
                              DropdownMenuItem(value: 'male', child: Text('Male fit')),
                              DropdownMenuItem(value: 'neutral', child: Text('Gender-neutral fit')),
                              DropdownMenuItem(value: 'all', child: Text('All three bodies')),
                            ],
                            onChanged: (value) => setState(() => bodyView = value!),
                          ),
                        ),
                        if (widget.woodland)
                          layerToggle('outfit', 'Complete outfit')
                        else ...[
                        layerToggle('top', 'Linen top'),
                        layerToggle('trousers', 'Travel trousers'),
                        layerToggle(
                          'boots',
                          bodyView == 'female' ? 'Boots' : 'Boots (female)',
                          enabled: bodyView == 'female' || bodyView == 'all',
                        ),
                        layerToggle('robe', '$className robe'),
                        ],
                        FilterChip(
                          label: const Text('Accessories'),
                          selected: accessories,
                          onSelected: (value) => setState(() => accessories = value),
                        ),
                        FilterChip(
                          label: Text(widget.woodland ? 'Sleeve detail' : 'Cuff detail'),
                          selected: detail,
                          onSelected: (value) => setState(() => detail = value),
                        ),
                        FilterChip(
                          label: const Text('Three stages'),
                          selected: compareStages,
                          onSelected: (value) => setState(() => compareStages = value),
                        ),
                        SizedBox(
                          width: 190,
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: held,
                            items: const [
                              DropdownMenuItem(value: 'none', child: Text('Empty hands')),
                              DropdownMenuItem(value: 'brass-lantern', child: Text('Brass lantern')),
                              DropdownMenuItem(value: 'annotated-grimoire', child: Text('Grimoire')),
                            ],
                            onChanged: (value) => setState(() => held = value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(builder: (context, constraints) {
                      final bodies = bodyView == 'all'
                          ? ['female', 'male', 'neutral']
                          : [bodyView];
                      return Column(children: [
                        for (var index = 0; index < bodies.length; index++) ...[
                          if (index > 0) const SizedBox(height: 36),
                          bodyReview(bodies[index], constraints.maxWidth),
                        ],
                      ]);
                    }),
                    const SizedBox(height: 20),
                    const Text(
                      'Clothing controls affect the dressed stages. Underwear stays visible for comparison.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
}
