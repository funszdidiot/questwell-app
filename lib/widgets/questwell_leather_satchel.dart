import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Approved satchel artwork, shared by account equipment and visual previews.
class QuestwellLeatherSatchel extends StatelessWidget {
  const QuestwellLeatherSatchel({super.key, required this.bodyType});
  static const slug = 'leather-satchel';
  static const asset = 'assets/images/questwell/avatar/satchel_leather_illustrated_v1.png';
  final String bodyType;

  static Rect bagBounds(String bodyType) => switch (bodyType) {
    'female' => const Rect.fromLTWH(74, 137, 62, 64),
    'male' => const Rect.fromLTWH(69, 143, 66, 68),
    _ => const Rect.fromLTWH(72, 141, 64, 66),
  };

  // The PNG includes transparent margins. Use the same contain/center mapping
  // as Image.asset so the strap stays registered to the actual brass eyelet.
  static Offset strapAttachment(String bodyType) {
    const source = Size(1322, 1190);
    const innerEyelet = Offset(1064, 230);
    final bounds = bagBounds(bodyType);
    final fitted = applyBoxFit(BoxFit.contain, source, bounds.size);
    final image = Alignment.center.inscribe(fitted.destination, bounds);
    return Offset(image.left + innerEyelet.dx / source.width * image.width,
      image.top + innerEyelet.dy / source.height * image.height);
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(child: ExcludeSemantics(
    child: LayoutBuilder(builder: (context, constraints) {
      final scale = math.min(constraints.maxWidth / 240, constraints.maxHeight / 320);
      final bag = bagBounds(bodyType);
      return Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _SatchelStrap(bodyType))),
        // Tight alpha-shaped contact shadow follows the bag, not its image box.
        Positioned(
          left: (constraints.maxWidth - 240 * scale) / 2 + (bag.left + 1.1) * scale,
          top: constraints.maxHeight - 320 * scale + (bag.top + 1.3) * scale,
          width: bag.width * scale, height: bag.height * scale,
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: .65 * scale, sigmaY: .65 * scale),
            child: Image.asset(asset, fit: BoxFit.contain,
              color: const Color(0x420B0806), colorBlendMode: BlendMode.srcIn,
              filterQuality: FilterQuality.high, gaplessPlayback: true),
          ),
        ),
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
    final attachment = QuestwellLeatherSatchel.strapAttachment(bodyType);
    final strap = Path()..moveTo(shoulder.dx, shoulder.dy)
      ..cubicTo(shoulder.dx - 5, shoulder.dy + 21,
        attachment.dx + 2, attachment.dy - 20, attachment.dx, attachment.dy);
    final paint = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawPath(strap, paint..color = const Color(0xFF382015)..strokeWidth = 4.5);
    canvas.drawPath(strap, paint..color = const Color(0xFF80502F)..strokeWidth = 3.3);
    canvas.drawPath(strap, paint..color = const Color(0xB396704E)..strokeWidth = .5);
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
