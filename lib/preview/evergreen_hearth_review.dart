import 'package:flutter/material.dart';
import '../services/questwell_cosmetic_models.dart';
import '../widgets/questwell_app_style.dart';
import '../widgets/questwell_pixel_art.dart';

/// Review-only registration. Account ownership, class eligibility and pricing
/// remain server-owned and are deliberately not synthesized here.
abstract final class EvergreenHearthFixture {
  static const names = {
    'hearthwoven-macrame': 'Hearthwoven Macramé',
    'woodland-path-tapestry': 'Woodland Path Tapestry',
    'guardians-oath-tapestry': 'Guardian’s Oath Tapestry',
  };
  static const profiles = {
    'hearthwoven-macrame': 'wall_textile',
    'woodland-path-tapestry': 'wall_textile',
    'guardians-oath-tapestry': 'wall_textile',
  };
  static const renders = {
    'hearthwoven-macrame': QuestwellHearthRenderSpec(
      renderKind: 'wall_art_sprite',
      assetSource: 'bundle',
      assetPath: 'assets/images/questwell/hearth/hearthwoven_macrame_v1.png',
      canvasWidth: 1402,
      canvasHeight: 1122,
      visibleBase: 1,
      shadowProfile: 'none',
      filterMode: 'smooth',
    ),
    'woodland-path-tapestry': QuestwellHearthRenderSpec(
      renderKind: 'wall_art_sprite',
      assetSource: 'bundle',
      assetPath: 'assets/images/questwell/hearth/woodland_path_tapestry_v1.png',
      canvasWidth: 1536,
      canvasHeight: 1024,
      visibleBase: 1,
      shadowProfile: 'none',
      filterMode: 'smooth',
    ),
    'guardians-oath-tapestry': QuestwellHearthRenderSpec(
      renderKind: 'wall_art_sprite',
      assetSource: 'bundle',
      assetPath:
          'assets/images/questwell/hearth/guardians_oath_tapestry_v1.png',
      canvasWidth: 1536,
      canvasHeight: 1024,
      visibleBase: 1,
      shadowProfile: 'none',
      filterMode: 'smooth',
    ),
  };
  static const rooms = [
    QuestwellHearthSetting.original,
    QuestwellHearthSetting.hallowedHearth,
    QuestwellHearthSetting.madAlchemistsLab,
    QuestwellHearthSetting.guardiansKeep,
  ];
}

class EvergreenHearthReviewApp extends StatefulWidget {
  const EvergreenHearthReviewApp({super.key});
  @override
  State<EvergreenHearthReviewApp> createState() =>
      _EvergreenHearthReviewState();
}

class _EvergreenHearthReviewState extends State<EvergreenHearthReviewApp> {
  var _room = QuestwellHearthSetting.original;
  var _art = 'hearthwoven-macrame';
  var _slot = 'wall_center';
  var _gallery = true;
  var _avatar = false;
  var _furniture = true;
  var _phone = false;
  var _window = 'none';

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: QuestwellAppStyle.fallbackTheme(),
        home: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Evergreen Hearth',
                      style: TextStyle(fontSize: 24)),
                  const Text(
                      'One statement piece. A gallery gathered around it.'),
                  const SizedBox(height: 16),
                  DropdownButton<QuestwellHearthSetting>(
                    key: const ValueKey('evergreen-room'),
                    isExpanded: true,
                    value: _room,
                    items: [
                      for (final room in EvergreenHearthFixture.rooms)
                        DropdownMenuItem(value: room, child: Text(room.label)),
                    ],
                    onChanged: (room) {
                      if (room != null) setState(() => _room = room);
                    },
                  ),
                  DropdownButton<String>(
                    key: const ValueKey('evergreen-art'),
                    isExpanded: true,
                    value: _art,
                    items: [
                      const DropdownMenuItem(
                        value: 'none',
                        child: Text('No hanging'),
                      ),
                      for (final entry in EvergreenHearthFixture.names.entries)
                        DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                    ],
                    onChanged: (art) {
                      if (art != null) setState(() => _art = art);
                    },
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                          label: const Text('Gallery wall'),
                          selected: _gallery,
                          onSelected: (value) => setState(() {
                                _gallery = value;
                                if (value) _slot = 'wall_center';
                              })),
                      for (final slot in const {
                        'wall_left': 'Left wall',
                        'wall_center': 'Center / Hearth',
                        'wall_right': 'Right wall',
                      }.entries)
                        ChoiceChip(
                          label: Text(slot.value),
                          selected: _slot == slot.key,
                          onSelected: (_) => setState(() {
                            _slot = slot.key;
                            _gallery = false;
                          }),
                        ),
                      FilterChip(
                        label: const Text('Adventurer'),
                        selected: _avatar,
                        onSelected: (value) => setState(() => _avatar = value),
                      ),
                      FilterChip(
                        label: const Text('Furniture'),
                        selected: _furniture,
                        onSelected: (value) =>
                            setState(() => _furniture = value),
                      ),
                      FilterChip(
                        label: const Text('Phone width'),
                        selected: _phone,
                        onSelected: (value) => setState(() => _phone = value),
                      ),
                    ],
                  ),
                  DropdownButton<String>(
                    key: const ValueKey('evergreen-window'),
                    isExpanded: true,
                    value: _window,
                    items: const [
                      DropdownMenuItem(
                        value: 'none',
                        child: Text('Original window'),
                      ),
                      DropdownMenuItem(
                        value: 'rainy-window',
                        child: Text('Rainy window'),
                      ),
                      DropdownMenuItem(
                        value: 'amberfall-window',
                        child: Text('Amberfall window'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _window = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _phone ? 358 : 960),
                    child: LayoutBuilder(
                      builder: (context, bounds) => QuestwellHearthPixelScene(
                        height: bounds.maxWidth /
                            (_room.usesHallowedLayout ? 1.5 : 1),
                        immersive: true,
                        setting: _room,
                        showAvatar: _avatar,
                        archetype:
                            _room == QuestwellHearthSetting.madAlchemistsLab
                                ? 'alchemist'
                                : 'guardian',
                        avatarBodyType: 'neutral',
                        hearthProfileBySlug: EvergreenHearthFixture.profiles,
                        hearthRenderBySlug: EvergreenHearthFixture.renders,
                        equippedSlugs: {
                          if (_art != 'none')
                            (_slot == 'wall_center'
                                ? 'wall_art'
                                : 'wall_art:$_slot'): _art,
                          if (_gallery && _art != 'none') ...{
                            'wall_art:wall_left': 'fern-study',
                            'wall_art:wall_right': 'celestial-study',
                          },
                          if (_window != 'none') 'room:window': _window,
                          if (_furniture) ...{
                            'room:right': 'walnut-bookshelf',
                            'room:front': 'burgundy-reading-chair',
                            'room:side': 'walnut-reading-table',
                          },
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
