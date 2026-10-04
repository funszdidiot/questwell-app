import 'package:flutter/material.dart';

/// The locked male v3 foundation and its approved, unified everyday outfit.
///
/// Every layer shares the same authored 240 × 320 canvas. Do not apply fitting
/// offsets, split the outfit into pieces, or clip the body to fit clothing.
class QuestwellMalePaperDoll extends StatelessWidget {
  const QuestwellMalePaperDoll({
    super.key,
    this.showEveryday = true,
    this.showRobe = false,
  });

  /// False exposes the intact foundation for development fit inspection.
  final bool showEveryday;

  /// Approved Scout robe template; implies its unchanged everyday underlayer.
  final bool showRobe;

  static const robeRearAsset =
      'assets/images/questwell/avatar/classes/scout/scout_robe_rear_male_v3.webp';
  static const robeFrontAsset =
      'assets/images/questwell/avatar/classes/scout/scout_robe_front_male_v3.webp';
  static const robeCollarAsset =
      'assets/images/questwell/avatar/classes/scout/scout_robe_collar_male_v3.webp';
  static const robeCuffsAsset =
      'assets/images/questwell/avatar/classes/scout/scout_robe_cuffs_male_v3.webp';

  static const baseAsset =
      'assets/images/questwell/avatar/base/paper_doll_male_v3.webp';
  static const everydayAsset =
      'assets/images/questwell/avatar/everyday_outfit_male_v2.webp';
  static const identityAsset =
      'assets/images/questwell/avatar/base/paper_doll_male_identity_v3.webp';

  Widget _layer(String asset) => Image.asset(
        asset,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
      );

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          if (showRobe) _layer(robeRearAsset),
          _layer(baseAsset),
          if (showEveryday || showRobe) ...[
            _layer(everydayAsset),
            if (showRobe) _layer(robeFrontAsset),
            _layer(identityAsset),
            if (showRobe) ...[
              _layer(robeCollarAsset),
              _layer(robeCuffsAsset),
            ],
          ],
        ],
      );
}
