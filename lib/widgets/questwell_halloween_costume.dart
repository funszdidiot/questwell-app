import 'package:flutter/material.dart';

import 'questwell_male_paper_doll.dart';
import 'questwell_neutral_paper_doll.dart';
import 'questwell_scout_wardrobe.dart';

/// One outfit selection, with depth passes on the immutable paper doll.
/// Candidate-only until catalog, pricing and release approval are complete.
class QuestwellHalloweenCostume extends StatelessWidget {
  const QuestwellHalloweenCostume({
    super.key,
    required this.body,
    required this.costume,
    this.equipped = true,
  });

  final String body;
  final String costume;
  final bool equipped;

  static const costumes = {
    'midnight_masquerade': 'Midnight Masquerade',
    'pumpkin_court': 'Pumpkin Court',
  };
  static const bodies = ['female', 'neutral', 'male'];

  /// Surface repairs preserve each body's existing garment masks.
  static String assetPath(String costume, String body, String layer) {
    final repaired = costume == 'pumpkin_court' && body == 'male';
    final familyEdges = costume == 'pumpkin_court' &&
        const {'female', 'neutral'}.contains(body) &&
        const {'front', 'cuffs'}.contains(layer);
    final midnightEdges = costume == 'midnight_masquerade' &&
        bodies.contains(body) &&
        (const {'front', 'cuffs'}.contains(layer) ||
            body != 'female' && layer == 'collar');
    final version = repaired && const {'front', 'rear'}.contains(layer)
        ? '_v3'
        : familyEdges ||
                midnightEdges ||
                repaired && const {'collar', 'cuffs'}.contains(layer)
            ? '_v2'
            : '';
    return 'assets/images/questwell/avatar/halloween_v1/'
        '$costume/$body/$layer$version.webp';
  }

  @override
  Widget build(BuildContext context) {
    final fit = bodies.contains(body) ? body : 'neutral';
    final outfit =
        costumes.containsKey(costume) ? costume : 'midnight_masquerade';
    final base = switch (fit) {
      'female' => QuestwellScoutWardrobeFoundation.femaleBaseAsset,
      'male' => QuestwellMalePaperDoll.baseAsset,
      _ => QuestwellNeutralPaperDoll.baseAsset,
    };
    final identity = switch (fit) {
      'female' => QuestwellScoutWardrobeFoundation.femaleIdentityAsset,
      'male' => QuestwellMalePaperDoll.identityAsset,
      _ => QuestwellNeutralPaperDoll.identityAsset,
    };
    Widget layer(String name) =>
        QuestwellScoutWardrobeFoundation.image(assetPath(outfit, fit, name));
    return Stack(
      fit: StackFit.expand,
      children: [
        if (equipped) layer('rear'),
        QuestwellScoutWardrobeFoundation.image(base),
        if (equipped) ...[
          layer('underlay'),
          layer('front'),
          QuestwellScoutWardrobeFoundation.image(identity),
          if (fit != 'female') layer('collar'),
          layer('cuffs'),
          layer('mask'),
        ],
      ],
    );
  }
}
