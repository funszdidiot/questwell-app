import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/questwell_cosmetic_models.dart';
import '../widgets/questwell_pixel_art.dart';

/// Local visual fixture only: no catalog, inventory or account mutations.
class HallowedHearthReviewApp extends StatefulWidget {
  const HallowedHearthReviewApp({super.key});

  @override
  State<HallowedHearthReviewApp> createState() => _HallowedHearthReviewState();
}

class _HallowedHearthReviewState extends State<HallowedHearthReviewApp> {
  final Map<String, String> _profiles = {};
  final Map<String, QuestwellHearthRenderSpec> _renders = {};
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadDecor();
  }

  Future<void> _loadDecor() async {
    try {
      final manifest = jsonDecode(await rootBundle.loadString(
        'assets/jsons/hallowed_hearth_decor_2026.json',
      )) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        for (final raw in manifest['items'] as List) {
          final item = Map<String, dynamic>.from(raw as Map);
          final hearth = Map<String, dynamic>.from(item['hearth'] as Map);
          final slug = item['slug'] as String;
          _profiles[slug] = hearth['profile_key'] as String;
          _renders[slug] = QuestwellHearthRenderSpec.fromJson(
            Map<String, dynamic>.from(hearth['render'] as Map),
          );
        }
      });
    } catch (_) {
      if (mounted) setState(() => _loadError = 'Unable to load furnishings.');
    }
  }

  bool _avatar = false;
  bool _furnished = false;
  bool _paused = false;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('The Hallowed Hearth',
                      style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  const Text('A little company in the cobwebs.'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [
                      FilterChip(
                        label: const Text('Adventurer'),
                        selected: _avatar,
                        onSelected: (value) => setState(() => _avatar = value),
                      ),
                      FilterChip(
                        label: const Text('Furnishings'),
                        selected: _furnished,
                        onSelected: _renders.isEmpty
                            ? null
                            : (value) => setState(() => _furnished = value),
                      ),
                      FilterChip(
                        label: const Text('Pause spiders'),
                        selected: _paused,
                        onSelected: (value) => setState(() => _paused = value),
                      ),
                    ],
                  ),
                  if (_loadError != null) Text(_loadError!),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final height = constraints.maxWidth / 1.5;
                        return TickerMode(
                          enabled: !_paused,
                          child: QuestwellHearthPixelScene(
                            height: height,
                            immersive: true,
                            setting: QuestwellHearthSetting.hallowedHearth,
                            showAvatar: _avatar,
                            avatarBodyType: 'female',
                            hearthProfileBySlug: _profiles,
                            hearthRenderBySlug: _renders,
                            equippedSlugs: _furnished
                                ? const {
                                    'room:right': 'witchlight-bookcase',
                                    'room:front': 'velvet-batwing-chair',
                                    'room:side': 'moonbrew-side-table',
                                    'room:floor': 'moonweb-rug',
                                    'wall_art:wall_left':
                                        'midnight-visitors-print',
                                  }
                                : const {},
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
