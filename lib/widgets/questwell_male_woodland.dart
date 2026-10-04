import 'package:flutter/material.dart';

import 'questwell_male_paper_doll.dart';

/// Candidate fit capability only; account eligibility is managed separately.
/// One authored outfit over the unchanged male foundation, with no transforms.
class QuestwellMaleWoodland extends StatelessWidget {
  const QuestwellMaleWoodland({super.key});

  static const outfitAsset =
      'assets/images/questwell/avatar/woodland_scout_unified_male_candidate_v1.webp';

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          for (final asset in [
            QuestwellMalePaperDoll.baseAsset,
            outfitAsset,
            QuestwellMalePaperDoll.identityAsset,
          ])
            Image.asset(
              asset,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
            ),
        ],
      );
}
