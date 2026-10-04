import 'package:flutter/material.dart';

/// Complete, fixed neutral anatomy for the development foundation review.
/// Outfit fitting must add garment layers without changing this body image.
class QuestwellNeutralPaperDoll extends StatelessWidget {
  const QuestwellNeutralPaperDoll({super.key});

  static const baseAsset =
      'assets/images/questwell/avatar/base/paper_doll_neutral_v4.webp';
  static const identityAsset =
      'assets/images/questwell/avatar/base/paper_doll_neutral_identity_v4.webp';

  @override
  Widget build(BuildContext context) => Image.asset(
        baseAsset,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
      );
}
