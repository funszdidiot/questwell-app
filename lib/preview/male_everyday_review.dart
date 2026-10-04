import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/questwell_annotated_grimoire.dart';
import '../widgets/questwell_male_paper_doll.dart';
import '../widgets/questwell_male_woodland.dart';

enum _WardrobeStage { body, everyday, robe, woodland }

/// Isolated fit review: no account, catalog, class defaults or equipment writes.
class MaleEverydayReviewApp extends StatefulWidget {
  const MaleEverydayReviewApp({
    super.key, this.initialRobe = false, this.initialArchetype = 'scout',
    this.initialWoodland = false,
  });

  final bool initialRobe;
  final String initialArchetype;
  final bool initialWoodland;

  @override
  State<MaleEverydayReviewApp> createState() => _MaleEverydayReviewAppState();
}

class _MaleEverydayReviewAppState extends State<MaleEverydayReviewApp> {
  bool _enlarged = false;
  bool _showGrimoire = false;
  late _WardrobeStage _stage = widget.initialWoodland
      ? _WardrobeStage.woodland
      : widget.initialRobe ? _WardrobeStage.robe : _WardrobeStage.everyday;
  late String _robeClass = QuestwellMalePaperDoll.classLabels
          .containsKey(widget.initialArchetype)
      ? widget.initialArchetype : 'scout';
  String get _robeLabel => '${QuestwellMalePaperDoll.classLabels[_robeClass]} robe';
  String get _stageLabel => switch (_stage) {
    _WardrobeStage.body => 'Locked body',
    _WardrobeStage.everyday => 'Everyday outfit',
    _WardrobeStage.robe => _robeLabel,
    _WardrobeStage.woodland => 'Woodland Scout candidate',
  };

  Widget _preview(String label, Color background, double availableWidth) {
    final canvasWidth = _enlarged ? 480.0 : 240.0;
    final panelWidth = math.min(canvasWidth + 32, availableWidth);
    return SizedBox(
      width: panelWidth,
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Color(0xFFE0C481))),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF58716A)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: canvasWidth,
                  height: canvasWidth * 320 / 240,
                  child: Semantics(
                    label: '$label: $_stageLabel',
                    image: true,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_stage == _WardrobeStage.woodland)
                          const QuestwellMaleWoodland()
                        else
                          QuestwellMalePaperDoll(
                            showEveryday: _stage != _WardrobeStage.body,
                            showRobe: _stage == _WardrobeStage.robe,
                            robeArchetype: _robeClass,
                          ),
                        if (_showGrimoire && _stage != _WardrobeStage.body)
                          const QuestwellAnnotatedGrimoire(bodyType: 'male'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Questwell · Male wardrobe fit review',
        theme: ThemeData.dark(useMaterial3: true),
        home: Scaffold(
          backgroundColor: const Color(0xFF1F3937),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    children: [
                      const Text(
                        'Male wardrobe fit review',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 28, color: Color(0xFFE0C481)),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Everyday, Woodland Scout and class robes on the same locked body.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Account equipment rollout pending remaining garment fits',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Outfit'),
                            selected: _stage == _WardrobeStage.everyday,
                            onSelected: (_) => setState(() => _stage = _WardrobeStage.everyday),
                          ),
                          ChoiceChip(
                            label: const Text('Body only'),
                            selected: _stage == _WardrobeStage.body,
                            onSelected: (_) => setState(() => _stage = _WardrobeStage.body),
                          ),
                          ChoiceChip(
                            label: const Text('Robe'),
                            selected: _stage == _WardrobeStage.robe,
                            onSelected: (_) => setState(() => _stage = _WardrobeStage.robe),
                          ),
                          ChoiceChip(
                            label: const Text('Woodland'),
                            selected: _stage == _WardrobeStage.woodland,
                            onSelected: (_) => setState(() => _stage = _WardrobeStage.woodland),
                          ),
                          FilterChip(
                            label: const Text('Belt grimoire'),
                            selected: _showGrimoire && _stage != _WardrobeStage.body,
                            onSelected: _stage == _WardrobeStage.body ? null
                                : (value) => setState(() => _showGrimoire = value),
                          ),
                          FilterChip(
                            label: const Text('Enlarged view'),
                            selected: _enlarged,
                            onSelected: (value) => setState(() => _enlarged = value),
                          ),
                        ],
                      ),
                      ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 260,
                          child: DropdownButtonFormField<String>(
                            initialValue: _robeClass,
                            decoration: const InputDecoration(labelText: 'Robe class'),
                            items: [
                              for (final entry in QuestwellMalePaperDoll.classLabels.entries)
                                DropdownMenuItem(value: entry.key, child: Text(entry.value)),
                            ],
                            onChanged: (value) {
                              if (value != null) setState(() => _robeClass = value);
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        _enlarged
                            ? 'Scroll within each image to inspect the enlarged fit.'
                            : 'Compare the fit on light and dark backgrounds.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, constraints) => Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 24,
                          runSpacing: 24,
                          children: [
                            _preview('Light background', const Color(0xFFF2E9DB),
                                constraints.maxWidth),
                            _preview('Dark background', const Color(0xFF202A2B),
                                constraints.maxWidth),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'This review does not change your account or equipped items.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
