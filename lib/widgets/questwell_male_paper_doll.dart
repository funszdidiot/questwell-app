import 'package:flutter/material.dart';

/// The locked male v3 foundation and its approved, unified everyday outfit.
///
/// Every layer shares the same authored 240 × 320 canvas. Do not apply fitting
/// offsets, split the outfit into pieces, or clip the body to fit clothing.
class QuestwellMalePaperDoll extends StatelessWidget {
  const QuestwellMalePaperDoll({
    super.key,
    this.showEveryday = true,
  });

  /// False exposes the intact foundation for development fit inspection.
  final bool showEveryday;

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
          _layer(baseAsset),
          if (showEveryday) ...[
            _layer(everydayAsset),
            _layer(identityAsset),
          ],
        ],
      );
}
