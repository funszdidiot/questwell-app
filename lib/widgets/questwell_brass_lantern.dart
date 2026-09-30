import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Review-only hand accessory. Not present in the equipment-policy allowlist.
class QuestwellBrassLantern extends StatelessWidget {
  const QuestwellBrassLantern({super.key, required this.bodyType});
  static const previewSlug = 'preview-brass-lantern';
  static const asset = 'assets/images/questwell/avatar/lantern_brass_illustrated_v1.png';
  final String bodyType;

  static Rect bounds(String bodyType) => switch (bodyType) {
    'female' => const Rect.fromLTWH(143, 179, 40, 60),
    'male' => const Rect.fromLTWH(149, 186, 40, 60),
    _ => const Rect.fromLTWH(146, 184, 40, 60),
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

/// Existing hand pixels overlap the loop so the lantern is held, not floating.
class LanternHandClipper extends CustomClipper<Path> {
  const LanternHandClipper(this.bodyType);
  final String bodyType;
  @override
  Path getClip(Size size) {
    final scale = math.min(size.width / 240, size.height / 320);
    final rect = switch (bodyType) {
      'female' => const Rect.fromLTWH(151, 162, 24, 29),
      'male' => const Rect.fromLTWH(158, 169, 25, 29),
      _ => const Rect.fromLTWH(154, 167, 26, 29),
    };
    return Path()..addRect(Rect.fromLTWH(
      (size.width - 240 * scale) / 2 + rect.left * scale,
      size.height - 320 * scale + rect.top * scale,
      rect.width * scale, rect.height * scale));
  }
  @override
  bool shouldReclip(covariant LanternHandClipper oldClipper) => oldClipper.bodyType != bodyType;
}
