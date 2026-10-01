import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Green canvas, leather and map artwork registered to the frozen avatar frame.
class QuestwellWayfarerSatchel extends StatelessWidget {
  const QuestwellWayfarerSatchel({super.key, required this.bodyType});
  static const slug = 'wayfarer-satchel';
  static const asset = 'assets/images/questwell_wayfarer_satchel_v1.webp';
  final String bodyType;

  static Rect bagBounds(String body) => switch (body) {
    'female' => const Rect.fromLTWH(75, 138, 56, 56),
    'male' => const Rect.fromLTWH(68, 143, 60, 60),
    _ => const Rect.fromLTWH(72, 141, 58, 58),
  };

  static Offset strapAttachment(String body) {
    final bag = bagBounds(body);
    // Source-ring coordinates include the transparent margin of the square art.
    return Offset(bag.left + bag.width * 1155 / 1254,
      bag.top + bag.height * 294 / 1254);
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(child: ExcludeSemantics(
    child: LayoutBuilder(builder: (context, constraints) {
      final scale = math.min(constraints.maxWidth / 240, constraints.maxHeight / 320);
      final bag = bagBounds(bodyType);
      final left = (constraints.maxWidth - 240 * scale) / 2 + bag.left * scale;
      final top = constraints.maxHeight - 320 * scale + bag.top * scale;
      return Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _WayfarerStrap(bodyType))),
        Positioned(left: left + scale, top: top + 1.2 * scale,
          width: bag.width * scale, height: bag.height * scale,
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: .6 * scale, sigmaY: .6 * scale),
            child: Image.asset(asset, fit: BoxFit.contain,
              color: const Color(0x480B0806), colorBlendMode: BlendMode.srcIn,
              filterQuality: FilterQuality.high, gaplessPlayback: true))),
        Positioned(left: left, top: top, width: bag.width * scale, height: bag.height * scale,
          child: Image.asset(asset, fit: BoxFit.contain,
            filterQuality: FilterQuality.high, gaplessPlayback: true)),
      ]);
    }),
  ));
}

class _WayfarerStrap extends CustomPainter {
  const _WayfarerStrap(this.body);
  final String body;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 240, size.height / 320);
    canvas.save();
    canvas.translate((size.width - 240 * scale) / 2, size.height - 320 * scale);
    canvas.scale(scale);
    final shoulder = body == 'female' ? const Offset(143, 85) : const Offset(147, 87);
    final ring = QuestwellWayfarerSatchel.strapAttachment(body);
    final strap = Path()..moveTo(shoulder.dx, shoulder.dy)
      ..cubicTo(shoulder.dx - 5, shoulder.dy + 23, ring.dx + 3, ring.dy - 19, ring.dx, ring.dy);
    final paint = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawPath(strap, paint..color = const Color(0xFF382519)..strokeWidth = 4.5);
    canvas.drawPath(strap, paint..color = const Color(0xFF956038)..strokeWidth = 3.2);
    canvas.drawPath(strap, paint..color = const Color(0xBBD3A76B)..strokeWidth = .5);
    final metric = strap.computeMetrics().first;
    final tangent = metric.getTangentForOffset(metric.length * .43)!;
    canvas.save();
    canvas.translate(tangent.position.dx, tangent.position.dy);
    canvas.rotate(tangent.angle - math.pi / 2);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-2.5, -3, 5, 6),
      const Radius.circular(.7)), paint..color = const Color(0xFFE0BB72)..strokeWidth = .8);
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WayfarerStrap oldDelegate) => oldDelegate.body != body;
}
