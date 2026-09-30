import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Registered to the frozen 240 x 320 body, independently of class garments.
class QuestwellEmeraldScarf extends StatelessWidget {
  const QuestwellEmeraldScarf({super.key, required this.bodyType});
  static const asset = 'assets/images/questwell/avatar/scarf_emerald_illustrated_v1.png';
  final String bodyType;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(child: LayoutBuilder(builder: (context, constraints) {
      final scale = math.min(constraints.maxWidth / 240, constraints.maxHeight / 320);
      final fit = switch (bodyType) {
        'male' => const Rect.fromLTWH(94, 65, 50, 75),
        // Female collar anchors are (110, 76) and (129, 76): center 119.5.
        // The sprite's visible shoulder fold begins 8% below its top edge.
        'female' => const Rect.fromLTWH(95, 70, 49, 73.5),
        _ => const Rect.fromLTWH(94, 67, 48, 72),
      };
      return Stack(children: [Positioned(
        left: (constraints.maxWidth - 240 * scale) / 2 + fit.left * scale,
        top: constraints.maxHeight - 320 * scale + fit.top * scale,
        width: fit.width * scale, height: fit.height * scale,
        child: ClipPath(clipper: const _NeckOpening(), child: Image.asset(asset,
          fit: BoxFit.contain, filterQuality: FilterQuality.high, gaplessPlayback: true)),
      )]);
    })),
  );
}

/// The back-neck bridge belongs behind the neck, not across the shirt collar.
class _NeckOpening extends CustomClipper<Path> {
  const _NeckOpening();
  @override
  Path getClip(Size size) => Path()..fillType = PathFillType.evenOdd
    ..addRect(Offset.zero & size)
    ..addRect(Rect.fromLTWH(size.width * .30, 0, size.width * .40, size.height * .20));
  @override
  bool shouldReclip(covariant _NeckOpening oldClipper) => false;
}
