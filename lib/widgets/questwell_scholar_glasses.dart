import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Face layer registered to the frozen 240 x 320 avatar canvas.
/// Match Image.asset's contain + bottomCenter transform, including wide cards.
class QuestwellScholarGlasses extends StatelessWidget {
  const QuestwellScholarGlasses({super.key, required this.bodyType});
  final String bodyType;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(child: CustomPaint(
      painter: _ScholarGlassesPainter(bodyType),
    )),
  );
}

class _ScholarGlassesPainter extends CustomPainter {
  const _ScholarGlassesPainter(this.bodyType);
  final String bodyType;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 240, size.height / 320);
    canvas.save();
    canvas.translate((size.width - 240 * scale) / 2, size.height - 320 * scale);
    canvas.scale(scale);
    final left = switch (bodyType) {
      'male' => const Offset(111, 51),
      'female' => const Offset(106, 55),
      _ => const Offset(109, 55),
    };
    final right = switch (bodyType) {
      'male' => const Offset(130, 50),
      'female' => const Offset(125, 53),
      _ => const Offset(128, 55),
    };
    final frames = Path()
      ..addOval(Rect.fromCircle(center: left, radius: 7))
      ..addOval(Rect.fromCircle(center: right, radius: 7))
      ..moveTo(left.dx + 7, left.dy)
      ..quadraticBezierTo((left.dx + right.dx) / 2, left.dy - 3,
          right.dx - 7, right.dy)
      ..moveTo(left.dx - 7, left.dy - 1)
      ..lineTo(left.dx - 11, left.dy - 3)
      ..moveTo(right.dx + 7, right.dy - 1)
      ..lineTo(right.dx + 10, right.dy - 3);
    // Clear lenses preserve the original eyes and expression.
    canvas.drawPath(frames, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF382619));
    canvas.drawPath(frames, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFD0A665));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScholarGlassesPainter oldDelegate) =>
      bodyType != oldDelegate.bodyType;
}
