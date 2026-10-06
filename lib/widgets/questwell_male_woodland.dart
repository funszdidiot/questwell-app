import 'package:flutter/material.dart';

import 'questwell_male_paper_doll.dart';

/// Founder-approved Woodland v2; account eligibility is managed separately.
/// One authored outfit over the unchanged male foundation, with no transforms.
class QuestwellMaleWoodland extends StatelessWidget {
  const QuestwellMaleWoodland({
    super.key,
    this.showOutfit = true,
    this.includeIdentity = true,
  });

  final bool showOutfit;

  /// The shared avatar renderer restores identity after its foundation layer.
  final bool includeIdentity;

  static const outfitAsset =
      'assets/images/questwell/avatar/woodland_scout_unified_male_candidate_v2.webp';

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          for (final asset in [
            QuestwellMalePaperDoll.baseAsset,
            if (showOutfit) outfitAsset,
          ])
            Image.asset(
              asset,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
            ),
          if (includeIdentity) const QuestwellMaleIdentity(),
        ],
      );
}
