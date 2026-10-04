import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'questwell_male_paper_doll.dart';

/// Legacy male chest garments rendered on the locked v3 paper-doll foundation.
///
/// This preserves catalog/equipment behavior without ever restoring legacy male
/// anatomy. The Business Suit artwork is reused only as a clothing overlay;
/// its old head/hands are explicitly excluded so v3 remains authoritative.
class QuestwellMaleLegacyChestFoundation extends StatelessWidget {
  const QuestwellMaleLegacyChestFoundation({
    super.key,
    required this.slug,
  });

  final String slug;

  static const _legacySuitAsset =
      'assets/images/questwell/avatar/base/base_male.webp';

  Widget _layer(String asset) => Image.asset(
        asset,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
      );

  @override
  Widget build(BuildContext context) {
    final businessSuit = slug == 'starter-business-suit';

    return Stack(
      fit: StackFit.expand,
      children: [
        _layer(QuestwellMalePaperDoll.baseAsset),
        if (businessSuit)
          ClipPath(
            clipper: const _LegacyBusinessSuitGarmentClipper(),
            child: _layer(_legacySuitAsset),
          )
        else
          _layer(QuestwellMalePaperDoll.everydayAsset),
      ],
    );
  }
}

/// Keeps the old suit's clothing pixels while removing its legacy identity.
///
/// The suit asset is already transparent outside the dressed silhouette. We
/// retain the garment from the collar downward and carve out both hand regions
/// so the locked v3 hands remain the only visible anatomy.
class _LegacyBusinessSuitGarmentClipper extends CustomClipper<Path> {
  const _LegacyBusinessSuitGarmentClipper();

  @override
  Path getClip(Size size) {
    var path = Path()..addRect(const Rect.fromLTRB(0, 74, 240, 320));

    final hands = Path()
      ..addPolygon(const [
        Offset(53, 169),
        Offset(87, 169),
        Offset(89, 202),
        Offset(52, 202),
      ], true)
      ..addPolygon(const [
        Offset(151, 169),
        Offset(187, 169),
        Offset(187, 202),
        Offset(151, 202),
      ], true);

    path = Path.combine(PathOperation.difference, path, hands);

    final scale = math.min(size.width / 240, size.height / 320);
    final dx = (size.width - 240 * scale) / 2;
    final dy = size.height - 320 * scale;
    return path
        .transform((Matrix4.identity()..scale(scale, scale)).storage)
        .shift(Offset(dx, dy));
  }

  @override
  bool shouldReclip(covariant _LegacyBusinessSuitGarmentClipper oldClipper) =>
      false;
}
