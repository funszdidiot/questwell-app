import 'package:flutter/material.dart';
import '../services/questwell_cosmetic_models.dart';
import '../widgets/questwell_amberfall_window.dart';
import '../widgets/questwell_pixel_art.dart';

/// Typed local fixture only. Never used as account/catalog data.
abstract final class AutumnHearthFixture {
  static const profiles = {
    'maple-hearth-rug': 'floor_rug',
    'mooncap-grove': 'plant',
    'harvest-lanterns': 'pedestal_light',
    'sages-rest': 'seating',
  };
  static const renders = {
    'sages-rest': QuestwellHearthRenderSpec(
      renderKind: 'static_sprite',
      assetSource: 'bundle',
      assetPath: 'assets/images/questwell/hearth/sages_rest_candidate_v1.png',
      canvasWidth: 1254,
      canvasHeight: 1254,
      visibleBase: 1036 / 1254,
      shadowProfile: 'seating',
    ),
    'maple-hearth-rug': QuestwellHearthRenderSpec(
      renderKind: 'floor_sprite',
      assetSource: 'bundle',
      assetPath: 'assets/images/questwell/hearth/maple_rug_candidate_v1.png',
      canvasWidth: 1816,
      canvasHeight: 866,
      visibleBase: 1,
      shadowProfile: 'none',
    ),
    'mooncap-grove': QuestwellHearthRenderSpec(
      renderKind: 'static_sprite',
      assetSource: 'bundle',
      assetPath:
          'assets/images/questwell/hearth/mooncap_grove_candidate_v1.png',
      canvasWidth: 1254,
      canvasHeight: 1254,
      visibleBase: 1150 / 1254,
      shadowProfile: 'plant',
    ),
    'harvest-lanterns': QuestwellHearthRenderSpec(
      renderKind: 'static_sprite',
      assetSource: 'bundle',
      assetPath:
          'assets/images/questwell/hearth/harvest_lanterns_candidate_v1.png',
      canvasWidth: 1254,
      canvasHeight: 1254,
      visibleBase: 1183 / 1254,
      shadowProfile: 'pedestal',
    ),
  };
}

class AutumnHearthScene extends StatelessWidget {
  const AutumnHearthScene(
      {super.key,
      required this.height,
      this.hallowed = false,
      this.avatar = true,
      this.decor = true,
      this.body = 'neutral'});
  final double height;
  final bool hallowed;
  final bool avatar;
  final bool decor;
  final String body;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: Stack(fit: StackFit.expand, children: [
          QuestwellHearthPixelScene(
            height: height,
            immersive: true,
            showAvatar: avatar,
            avatarBodyType: body,
            setting: hallowed ? QuestwellHearthSetting.hallowedHearth : null,
            equippedSlugs: decor
                ? const {
                    'room:floor': 'maple-hearth-rug',
                    'room:right': 'mooncap-grove',
                    'room:left': 'harvest-lanterns',
                    'room:front': 'sages-rest',
                  }
                : const {},
            hearthProfileBySlug: AutumnHearthFixture.profiles,
            hearthRenderBySlug: AutumnHearthFixture.renders,
          ),
          QuestwellAmberfallWindow(hallowed: hallowed),
        ]),
      );
}

class AutumnHearthReviewApp extends StatefulWidget {
  const AutumnHearthReviewApp({super.key});
  @override
  State<AutumnHearthReviewApp> createState() => _AutumnReviewState();
}

class _AutumnReviewState extends State<AutumnHearthReviewApp> {
  bool _hallowed = false;
  bool _avatar = true;
  bool _decor = true;
  bool _paused = false;
  String _body = 'neutral';

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: SafeArea(
                child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            const Text('Autumn Hearth • Development review',
                style: TextStyle(fontSize: 22)),
            const Text(
                'Development candidates. No purchases or account changes.'),
            Wrap(spacing: 8, children: [
              FilterChip(
                  label: const Text('Halloween room (optional)'),
                  selected: _hallowed,
                  onSelected: (value) => setState(() => _hallowed = value)),
              FilterChip(
                  label: const Text('Avatar'),
                  selected: _avatar,
                  onSelected: (value) => setState(() => _avatar = value)),
              FilterChip(
                  label: const Text('Décor'),
                  selected: _decor,
                  onSelected: (value) => setState(() => _decor = value)),
              FilterChip(
                  label: const Text('Pause leaves'),
                  selected: _paused,
                  onSelected: (value) => setState(() => _paused = value)),
              for (final body in ['female', 'neutral', 'male'])
                ChoiceChip(
                    label: Text(body),
                    selected: _body == body,
                    onSelected: (_) => setState(() => _body = body)),
            ]),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: LayoutBuilder(
                  builder: (context, constraints) => TickerMode(
                        enabled: !_paused,
                        child: AutumnHearthScene(
                          // Preserve the usual room's square layout and window.
                          height: !_hallowed
                              ? constraints.maxWidth
                              : constraints.maxWidth < 500
                                  ? 420
                                  : constraints.maxWidth / 1.5,
                          hallowed: _hallowed,
                          avatar: _avatar,
                          decor: _decor,
                          body: _body,
                        ),
                      )),
            ),
          ]),
        ))),
      );
}
