import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Founder-approved upper-robe accessory, independent of neck and hands slots.
class QuestwellMoonstoneBrooch extends StatelessWidget {
  const QuestwellMoonstoneBrooch({super.key, required this.bodyType});
  static const slug = 'moonstone-brooch';
  static const asset = 'assets/images/questwell/avatar/brooch_moonstone_illustrated_v1.png';
  final String bodyType;

  // Viewer-left upper lapel, above the armhole and beside the scarf.
  // The approved square asset has transparent padding around its oval shape.
  static Rect bounds(String bodyType) => switch (bodyType) {
    'female' => const Rect.fromLTWH(92, 87, 14, 14),
    'male' => const Rect.fromLTWH(91, 83, 14, 14),
    _ => const Rect.fromLTWH(91.5, 85, 14, 14),
  };

  @override
  Widget build(BuildContext context) => IgnorePointer(child: ExcludeSemantics(
    child: LayoutBuilder(builder: (context, constraints) {
      final scale = math.min(constraints.maxWidth / 240, constraints.maxHeight / 320);
      final fit = bounds(bodyType);
      return Stack(children: [Positioned(
        left: (constraints.maxWidth - 240 * scale) / 2 + fit.left * scale,
        top: constraints.maxHeight - 320 * scale + fit.top * scale,
        width: fit.width * scale, height: fit.height * scale,
        child: Image.asset(asset, fit: BoxFit.contain,
          filterQuality: FilterQuality.high, gaplessPlayback: true),
      )]);
    }),
  ));
}
