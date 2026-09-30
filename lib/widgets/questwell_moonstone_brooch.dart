import 'dart:math' as math;
import 'dart:ui' as ui;
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
    'female' => const Rect.fromLTWH(91, 86, 16, 16),
    'male' => const Rect.fromLTWH(90, 82, 16, 16),
    _ => const Rect.fromLTWH(90.5, 84, 16, 16),
  };

  @override
  Widget build(BuildContext context) => IgnorePointer(child: ExcludeSemantics(
    child: LayoutBuilder(builder: (context, constraints) {
      final scale = math.min(constraints.maxWidth / 240, constraints.maxHeight / 320);
      final fit = bounds(bodyType);
      final left = (constraints.maxWidth - 240 * scale) / 2 + fit.left * scale;
      final top = constraints.maxHeight - 320 * scale + fit.top * scale;
      return Stack(children: [
        // Tight alpha-shaped contact shadow, not a rectangular drop shadow.
        Positioned(
          left: left + .35 * scale, top: top + .55 * scale,
          width: fit.width * scale, height: fit.height * scale,
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: .35 * scale, sigmaY: .35 * scale),
            child: Image.asset(asset, fit: BoxFit.contain,
              color: const Color(0x700E101B), colorBlendMode: BlendMode.srcIn,
              filterQuality: FilterQuality.high, gaplessPlayback: true),
          ),
        ),
        Positioned(
        left: left, top: top,
        width: fit.width * scale, height: fit.height * scale,
        // Preserve the original artwork and alpha. Modest contrast makes the
        // existing pale stone highlight and dark gold rim read at phone scale.
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            1.12, 0, 0, 0, -10,
            0, 1.12, 0, 0, -10,
            0, 0, 1.12, 0, -10,
            0, 0, 0, 1, 0,
          ]),
          child: Image.asset(asset, fit: BoxFit.contain,
            filterQuality: FilterQuality.high, gaplessPlayback: true),
        ),
      )]);
    }),
  ));
}
