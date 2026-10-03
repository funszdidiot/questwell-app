import 'package:flutter/material.dart';
import 'questwell_neutral_paper_doll.dart';

/// Body-specific fitting candidate. All garments share the immutable canvas.
class QuestwellNeutralScout extends StatelessWidget {
  const QuestwellNeutralScout({super.key, required this.layers});
  final Set<String> layers;

  static const outfitAsset = 'assets/images/questwell/avatar/woodland_scout_unified_neutral_v2.webp';
  static const topAsset = 'assets/images/questwell/avatar/everyday_top_neutral_v1.webp';
  static const topUnderRobeAsset = 'assets/images/questwell/avatar/everyday_top_robe_under_neutral_v1.webp';
  static const trousersAsset = 'assets/images/questwell/avatar/everyday_trousers_neutral_v1.webp';
  static const bootsAsset = 'assets/images/questwell/avatar/everyday_boots_neutral_v1.webp';
  static const robeAsset = 'assets/images/questwell/avatar/scout_robe_neutral_v5.webp';
  static const rearAsset = 'assets/images/questwell/avatar/scout_robe_rear_neutral_v5.webp';
  static const cuffsAsset = 'assets/images/questwell/avatar/scout_robe_cuff_front_neutral_v5.webp';

  Widget image(String asset) => Image.asset(asset,
      fit: BoxFit.contain, alignment: Alignment.bottomCenter,
      filterQuality: FilterQuality.high, gaplessPlayback: true);

  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
    if (layers.contains('robe')) image(rearAsset),
    const QuestwellNeutralPaperDoll(),
    // Woodland is a separate complete outfit. Robes always use everyday pieces.
    if (layers.contains('outfit') && !layers.contains('robe')) image(outfitAsset)
    else ...[
      if (layers.contains('trousers')) image(trousersAsset),
      if (layers.contains('top')) image(layers.contains('robe') ? topUnderRobeAsset : topAsset),
      if (layers.contains('boots')) image(bootsAsset),
    ],
    if (layers.contains('robe')) image(robeAsset),
    image(QuestwellNeutralPaperDoll.identityAsset),
    if (layers.contains('robe')) image(cuffsAsset),
  ]);
}
