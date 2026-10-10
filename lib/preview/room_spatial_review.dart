import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/questwell_cosmetic_models.dart';
import '../widgets/questwell_pixel_art.dart';
import 'autumn_hearth_review.dart';

/// Account-free review of the real renderer, with unchanged saved-slot semantics.
class RoomSpatialReviewApp extends StatefulWidget {
  const RoomSpatialReviewApp({super.key});
  @override
  State<RoomSpatialReviewApp> createState() => _RoomSpatialReviewState();
}

class _RoomSpatialReviewState extends State<RoomSpatialReviewApp> {
  final _profiles = {...AutumnHearthFixture.profiles};
  final _renders = {...AutumnHearthFixture.renders};
  var _room = QuestwellHearthSetting.original;
  var _arrangement = 'Witchlight right';
  var _narrow = false;
  var _avatar = true;
  var _ready = false;
  String? _error;

  static const arrangements = {
    'Witchlight left': {'room:left': 'witchlight-bookcase'},
    'Witchlight right': {'room:right': 'witchlight-bookcase'},
    'Cabinet and reading corner': {
      'room:left': 'copper-potion-workbench',
      'room:right': 'burgundy-reading-chair',
      'room:side': 'moonbrew-side-table',
      'room:floor': 'maple-hearth-rug',
    },
    'Bookcases and left chair': {
      'room:right': 'witchlight-bookcase',
      'room:front': 'velvet-batwing-chair',
      'room:side': 'moonbrew-side-table',
    },
    'Floor cushions': {
      'room:front': 'sages-rest',
      'room:left': 'harvest-lanterns',
      'room:right': 'mooncap-grove',
    },
    'Two wall cabinets': {
      'room:left': 'walnut-bookshelf',
      'room:right': 'copper-potion-workbench',
    },
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final manifest = jsonDecode(await rootBundle
              .loadString('assets/jsons/hallowed_hearth_decor_2026.json'))
          as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        for (final item in manifest['items'] as List) {
          final hearth = item['hearth'] as Map<String, dynamic>;
          _profiles[item['slug'] as String] = hearth['profile_key'] as String;
          _renders[item['slug'] as String] = QuestwellHearthRenderSpec.fromJson(
              hearth['render'] as Map<String, dynamic>);
        }
        _ready = true;
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'Unable to load room furnishings.');
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                const Text('Questwell • Room arrangements',
                    style: TextStyle(fontSize: 24)),
                const SizedBox(height: 12),
                Wrap(spacing: 12, runSpacing: 8, children: [
                  DropdownButton<QuestwellHearthSetting>(
                    value: _room,
                    items: [
                      for (final room in QuestwellHearthSetting.values)
                        DropdownMenuItem(value: room, child: Text(room.label)),
                    ],
                    onChanged: (room) {
                      if (room != null) setState(() => _room = room);
                    },
                  ),
                  DropdownButton<String>(
                    value: _arrangement,
                    items: [
                      for (final name in arrangements.keys)
                        DropdownMenuItem(value: name, child: Text(name)),
                    ],
                    onChanged: (name) {
                      if (name != null) setState(() => _arrangement = name);
                    },
                  ),
                  FilterChip(
                    label: const Text('Phone width'),
                    selected: _narrow,
                    onSelected: (v) => setState(() => _narrow = v),
                  ),
                  FilterChip(
                    label: const Text('Adventurer'),
                    selected: _avatar,
                    onSelected: (v) => setState(() => _avatar = v),
                  ),
                ]),
                const SizedBox(height: 16),
                if (_error != null)
                  Text(_error!)
                else if (!_ready)
                  const CircularProgressIndicator()
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _narrow ? 390 : 760),
                    child: LayoutBuilder(
                        builder: (context, constraints) => MediaQuery(
                              data:
                                  const MediaQueryData(disableAnimations: true),
                              child: QuestwellHearthPixelScene(
                                height: constraints.maxWidth * .68 + 8,
                                immersive: true,
                                setting: _room,
                                showAvatar: _avatar,
                                avatarBodyType: 'male',
                                archetype: 'scout',
                                hearthProfileBySlug: _profiles,
                                hearthRenderBySlug: _renders,
                                equippedSlugs: {
                                  ...arrangements[_arrangement]!,
                                  'chest': 'pumpkin-court',
                                  'room:window': 'amberfall-window',
                                },
                              ),
                            )),
                  ),
              ]),
            ),
          ),
        ),
      );
}
