import 'package:flutter/material.dart';
import 'questwell_neutral_paper_doll.dart';

/// Body-specific fitting candidate. All garments share the immutable canvas.
class QuestwellNeutralScout extends StatelessWidget {
  const QuestwellNeutralScout({super.key, required this.layers});
  final Set<String> layers;

  static const outfitAsset = 'assets/images/questwell/avatar/woodland_scout_unified_neutral_v1.webp';
  static const underRobeAsset = 'assets/images/questwell/avatar/woodland_scout_robe_under_neutral_v1.webp';
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
    if (layers.contains('outfit')) image(layers.contains('robe') ? underRobeAsset : outfitAsset),
    if (layers.contains('robe')) image(robeAsset),
    image(QuestwellNeutralPaperDoll.identityAsset),
    if (layers.contains('robe')) image(cuffsAsset),
  ]);
}
