import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Candidate artwork, activated only by the account-free review fixture slug.
class QuestwellLeatherSatchel extends StatelessWidget {
  const QuestwellLeatherSatchel({super.key, required this.bodyType});
  static const previewSlug = 'preview-leather-satchel';
  static const asset = 'assets/images/questwell/avatar/satchel_leather_illustrated_v1.png';
  final String bodyType;

  @override
  Widget build(BuildContext context) => IgnorePointer(child: ExcludeSemantics(
    child: LayoutBuilder(builder: (context, constraints) {
      final scale = math.min(constraints.maxWidth / 240, constraints.maxHeight / 320);
      final bag = switch (bodyType) {
        'female' => const Rect.fromLTWH(74, 137, 62, 64),
        'male' => const Rect.fromLTWH(69, 143, 66, 68),
        _ => const Rect.fromLTWH(72, 141, 64, 66),
      };
      return Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _SatchelStrap(bodyType))),
        Positioned(
          left: (constraints.maxWidth - 240 * scale) / 2 + bag.left * scale,
          top: constraints.maxHeight - 320 * scale + bag.top * scale,
          width: bag.width * scale, height: bag.height * scale,
          child: Image.asset(asset, fit: BoxFit.contain,
            filterQuality: FilterQuality.high, gaplessPlayback: true),
        ),
      ]);
    }),
  ));
}

class _SatchelStrap extends CustomPainter {
  const _SatchelStrap(this.bodyType);
  final String bodyType;
  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 240, size.height / 320);
    canvas.save();
    canvas.translate((size.width - 240 * scale) / 2, size.height - 320 * scale);
    canvas.scale(scale);
    final female = bodyType == 'female';
    final shoulder = female ? const Offset(143, 85) : const Offset(147, 87);
    // Bag's outer ring is at 25% of the image width; account for alpha margins.
    final attachment = switch (bodyType) {
      'female' => const Offset(90, 149),
      'male' => const Offset(86, 155),
      _ => const Offset(88, 153),
    };
    final strap = Path()..moveTo(shoulder.dx, shoulder.dy)
      ..cubicTo(137, 101, 106, 125, attachment.dx, attachment.dy);
    final paint = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawPath(strap, paint..color = const Color(0xFF382015)..strokeWidth = 4.5);
    canvas.drawPath(strap, paint..color = const Color(0xFF80502F)..strokeWidth = 3.3);
    canvas.drawPath(strap, paint..color = const Color(0xFFAC7848)..strokeWidth = .7);
    // Small brass adjustment buckle follows the diagonal strap.
    canvas.save();
    final metric = strap.computeMetrics().first;
    final tangent = metric.getTangentForOffset(metric.length * .44)!;
    canvas.translate(tangent.position.dx, tangent.position.dy);
    canvas.rotate(tangent.angle - math.pi / 2);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-2.5, -3.5, 5, 7),
      const Radius.circular(.8)), paint..color = const Color(0xFFD3A65C)..strokeWidth = .8);
    canvas.restore();
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _SatchelStrap oldDelegate) => oldDelegate.bodyType != bodyType;
}

/// Reuses the original forearm and hand above the bag, without changing art.
class SatchelForearmClipper extends CustomClipper<Path> {
  const SatchelForearmClipper(this.bodyType);
  final String bodyType;
  @override
  Path getClip(Size size) {
    final scale = math.min(size.width / 240, size.height / 320);
    final rect = switch (bodyType) {
      'female' => const Rect.fromLTWH(58, 143, 29, 52),
      'male' => const Rect.fromLTWH(50, 148, 35, 52),
      _ => const Rect.fromLTWH(57, 147, 31, 52),
    };
    return Path()..addRect(Rect.fromLTWH(
      (size.width - 240 * scale) / 2 + rect.left * scale,
      size.height - 320 * scale + rect.top * scale,
      rect.width * scale, rect.height * scale));
  }
  @override
  bool shouldReclip(covariant SatchelForearmClipper oldClipper) => oldClipper.bodyType != bodyType;
}
