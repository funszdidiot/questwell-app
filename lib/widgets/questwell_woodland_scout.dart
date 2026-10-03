import 'package:flutter/material.dart';

import 'questwell_scout_wardrobe.dart';

/// Founder-approved female fit: one complete garment on the fixed body canvas.
/// No independently stretched shirt, vest, trousers, or boots.
class QuestwellWoodlandScoutFoundation extends StatelessWidget {
  const QuestwellWoodlandScoutFoundation({super.key, required this.layers});

  final Set<String> layers;
  static const outfitAsset =
      'assets/images/questwell/avatar/woodland_scout_unified_female_v11.webp';

  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        QuestwellScoutWardrobeFoundation.image(
          QuestwellScoutWardrobeFoundation.femaleBaseAsset,
        ),
        if (layers.isNotEmpty)
          QuestwellScoutWardrobeFoundation.image(outfitAsset),
      ]);
}
