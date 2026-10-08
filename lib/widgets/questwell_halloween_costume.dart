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
    Widget layer(String name) => QuestwellScoutWardrobeFoundation.image(
          'assets/images/questwell/avatar/halloween_v1/$outfit/$fit/$name.webp',
        );
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
