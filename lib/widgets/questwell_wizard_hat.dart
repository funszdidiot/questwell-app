import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Small crown accessory, registered to each frozen 240 x 320 body canvas.
class QuestwellWizardHat extends StatelessWidget {
  const QuestwellWizardHat({super.key, required this.bodyType});
  final String bodyType;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(child: CustomPaint(painter: _WizardHatPainter(bodyType))),
  );
}

class _WizardHatPainter extends CustomPainter {
  const _WizardHatPainter(this.bodyType);
  final String bodyType;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 240, size.height / 320);
    final anchor = switch (bodyType) {
      'male' => const Offset(130, 24),
      'female' => const Offset(124, 26),
      _ => const Offset(126, 27),
    };
    canvas.save();
    canvas.translate((size.width - 240 * scale) / 2, size.height - 320 * scale);
    canvas.scale(scale);
    canvas.translate(anchor.dx, anchor.dy);
    canvas.rotate(.16);
    // Tight contact shadow makes the brim sit on the hair, not float above it.
    canvas.drawOval(const Rect.fromLTWH(-19, 0, 38, 7),
      Paint()..color = const Color(0x80301C21));
    final brim = Path()
      ..moveTo(-21, 0)
      ..quadraticBezierTo(-10, -6, 4, -4)
      ..quadraticBezierTo(15, -3, 21, 1)
      ..quadraticBezierTo(8, 7, -6, 5)
      ..quadraticBezierTo(-17, 4, -21, 0)..close();
    canvas.drawPath(brim, Paint()..shader = const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFF6A548D), Color(0xFF211B3B)],
    ).createShader(const Rect.fromLTWH(-21, -4, 42, 10)));
    canvas.drawPath(brim, Paint()..style = PaintingStyle.stroke
      ..strokeWidth = 1..color = const Color(0xFFCCA867));
    final crown = Path()
      ..moveTo(-13, 0)
      ..quadraticBezierTo(-9, -9, -6, -19)
      ..quadraticBezierTo(0, -24, 13, -21)
      ..lineTo(6, -16)
      ..quadraticBezierTo(8, -7, 13, 0)
      ..quadraticBezierTo(0, 4, -13, 0)..close();
    canvas.drawPath(crown, Paint()..shader = const LinearGradient(
      colors: [Color(0xFF8A70AC), Color(0xFF493866), Color(0xFF241E3B)],
      stops: [0, .43, 1],
    ).createShader(const Rect.fromLTWH(-13, -23, 26, 27)));
    canvas.drawPath(crown, Paint()..style = PaintingStyle.stroke
      ..strokeWidth = 1..color = const Color(0xFF21182C));
    canvas.drawPath(Path()..moveTo(-11, -4)..quadraticBezierTo(0, -1, 11, -4),
      Paint()..style = PaintingStyle.stroke..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round..color = const Color(0xFFC89A51));
    final star = Path()..moveTo(-1, -15)..lineTo(.4, -12)
      ..lineTo(3, -11)..lineTo(.4, -10)..lineTo(-1, -7)
      ..lineTo(-2.2, -10)..lineTo(-5, -11)..lineTo(-2.2, -12)..close();
    canvas.drawPath(star, Paint()..color = const Color(0xFFF3D68B));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WizardHatPainter oldDelegate) => bodyType != oldDelegate.bodyType;
}
