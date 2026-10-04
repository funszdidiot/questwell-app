import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Guardian-class Hearth lantern. Development visual only while the catalog
/// entry remains inactive.
///
/// The shape is deliberately chunky and authored for the Questwell Hearth:
/// grounded base, brass frame, emerald ward glass, pale sigil core and a
/// restrained radial glow that does not wash out nearby furniture.
class QuestwellWardingLantern extends StatelessWidget {
  const QuestwellWardingLantern({super.key});

  static const slug = 'warding-lantern';

  static Rect bounds(Size scene, String slot) {
    final avatarHeight = math.min(scene.height * .76, scene.width * .62 * 4 / 3);
    final height = avatarHeight * (slot == 'front' ? .32 : .29);
    final width = height * .58;
    final center = scene.width *
        (slot == 'left' ? .24 : slot == 'right' ? .79 : .18);
    final floor = scene.height * (slot == 'front' ? .87 : .72);
    return Rect.fromLTWH(center - width / 2, floor - height, width, height);
  }

  @override
  Widget build(BuildContext context) => const RepaintBoundary(
        child: CustomPaint(painter: _WardingLanternPainter()),
      );
}

class _WardingLanternPainter extends CustomPainter {
  const _WardingLanternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 100;
    final sy = size.height / 160;
    canvas.save();
    canvas.scale(sx, sy);

    final p = Paint()..isAntiAlias = false;
    void rect(double x, double y, double w, double h, Color c) {
      p
        ..style = PaintingStyle.fill
        ..shader = null
        ..color = c;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), p);
    }

    const ink = Color(0xFF201A16);
    const brassDark = Color(0xFF70502E);
    const brass = Color(0xFFB98A49);
    const brassLight = Color(0xFFE0BD76);
    const glassDark = Color(0xFF173C33);
    const glass = Color(0xFF2D6A50);
    const glassLight = Color(0xFF74A875);
    const ward = Color(0xFFE9F1B5);
    const wardSoft = Color(0xFFBFD58B);

    // Grounding shadow.
    p
      ..isAntiAlias = true
      ..color = const Color(0x55140E0B);
    canvas.drawOval(const Rect.fromLTWH(13, 145, 74, 10), p);

    // Restrained magical glow.
    p.shader = const RadialGradient(
      colors: [Color(0x554FA66F), Color(0x223C7454), Color(0x004FA66F)],
    ).createShader(const Rect.fromLTWH(6, 28, 88, 108));
    canvas.drawOval(const Rect.fromLTWH(6, 28, 88, 108), p);
    p.shader = null;
    p.isAntiAlias = false;

    // Handle and cap.
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = brassDark;
    canvas.drawArc(const Rect.fromLTWH(30, 3, 40, 35), math.pi, math.pi, false, p);
    p
      ..strokeWidth = 2
      ..color = brassLight;
    canvas.drawArc(const Rect.fromLTWH(34, 7, 32, 27), math.pi, math.pi, false, p);
    p.style = PaintingStyle.fill;
    rect(34, 30, 32, 5, ink);
    rect(38, 31, 24, 5, brass);
    rect(43, 27, 14, 5, brassLight);

    // Broad shoulders make it read as a warding object, not a handheld lamp.
    rect(24, 37, 52, 5, ink);
    rect(28, 38, 44, 6, brassDark);
    rect(33, 39, 34, 2, brassLight);

    // Main frame.
    rect(21, 44, 58, 82, ink);
    rect(25, 47, 50, 75, brassDark);
    rect(30, 50, 40, 68, glassDark);

    // Glass with vertical shading.
    for (var x = 31; x < 70; x += 3) {
      final t = (x - 31) / 39;
      final color = Color.lerp(glass, glassLight, .16 + .26 * (1 - (t - .5).abs() * 2))!;
      rect(x.toDouble(), 51, 3, 66, color);
    }

    // Frame uprights / crossbar.
    rect(24, 48, 5, 71, brass);
    rect(71, 48, 5, 71, brass);
    rect(26, 79, 48, 5, brassDark);
    rect(27, 80, 46, 2, brassLight);

    // Ward sigil: diamond shield with four rays.
    final center = const Offset(50, 84);
    p
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = wardSoft;
    canvas.drawPath(
      Path()
        ..moveTo(50, 61)
        ..lineTo(62, 84)
        ..lineTo(50, 108)
        ..lineTo(38, 84)
        ..close(),
      p,
    );
    p.color = ward;
    canvas.drawPath(
      Path()
        ..moveTo(50, 67)
        ..lineTo(57, 84)
        ..lineTo(50, 101)
        ..lineTo(43, 84)
        ..close(),
      p,
    );
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = brassLight;
    canvas.drawLine(const Offset(50, 55), const Offset(50, 113), p);
    canvas.drawLine(const Offset(34, 84), const Offset(66, 84), p);
    p.style = PaintingStyle.fill;

    // Bottom housing and foot.
    rect(24, 122, 52, 6, ink);
    rect(27, 123, 46, 6, brass);
    rect(32, 128, 36, 7, brassDark);
    rect(38, 135, 24, 8, ink);
    rect(41, 135, 18, 8, brass);
    rect(31, 143, 38, 5, ink);
    rect(35, 143, 30, 4, brassDark);
    rect(39, 143, 22, 2, brassLight);

    // Small Guardian notch details.
    rect(17, 63, 6, 24, ink);
    rect(18, 66, 4, 18, brassDark);
    rect(77, 63, 6, 24, ink);
    rect(78, 66, 4, 18, brassDark);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WardingLanternPainter oldDelegate) => false;
}
