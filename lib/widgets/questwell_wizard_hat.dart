import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Illustrated accessory uses the same contain/bottom-center coordinates as
/// the frozen body. The taller crown can extend into the scene's headroom.
class QuestwellWizardHat extends StatelessWidget {
  const QuestwellWizardHat({super.key, required this.bodyType});
  static const asset = 'assets/images/questwell/avatar/wizard_hat_illustrated_v2.png';
  final String bodyType;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(child: LayoutBuilder(builder: (context, constraints) {
      final scale = math.min(constraints.maxWidth / 240, constraints.maxHeight / 320);
      final fit = switch (bodyType) {
        'male' => const Rect.fromLTWH(77, -29, 89, 89),
        'female' => const Rect.fromLTWH(72, -27, 89, 89),
        _ => const Rect.fromLTWH(75, -25, 87, 87),
      };
      return Stack(clipBehavior: Clip.none, children: [
        Positioned(
          left: (constraints.maxWidth - 240 * scale) / 2 + fit.left * scale,
          top: constraints.maxHeight - 320 * scale + fit.top * scale,
          width: fit.width * scale, height: fit.height * scale,
          child: Image.asset(asset, fit: BoxFit.contain,
            filterQuality: FilterQuality.high, gaplessPlayback: true),
        ),
      ]);
    })),
  );
}
