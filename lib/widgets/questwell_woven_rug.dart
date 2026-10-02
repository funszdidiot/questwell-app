import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shares the accepted Hearth rug's floor perspective and woven construction.
class QuestwellWovenRugPainter extends CustomPainter {
  const QuestwellWovenRugPainter({this.emerald = false});
  static const slug = 'emerald-wayfarer-rug';
  final bool emerald;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    Offset point(double u, double v) {
      final halfWidth = .17 + .11 * v;
      return Offset(size.width * (.5 + (u - .5) * 2 * halfWidth),
          size.height * (.69 + .26 * v));
    }
    Path panel(double inset) => Path()
      ..addPolygon([point(inset, inset), point(1 - inset, inset),
        point(1 - inset, 1 - inset), point(inset, 1 - inset)], true);
    p.color = emerald ? const Color(0xFF173B30) : const Color(0xFF492C30);
    canvas.drawPath(panel(0), p);
    p.color = emerald ? const Color(0xFFC0A060) : const Color(0xFFB58E5F);
    canvas.drawPath(panel(.045), p);
    p.color = emerald ? const Color(0xFF24543F) : const Color(0xFF70434A);
    canvas.drawPath(panel(.075), p);
    p.color = const Color(0xFFB58E5F);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 1;
    canvas.drawPath(panel(.105), p);
    p.style = PaintingStyle.fill;

    canvas.save();
    canvas.clipPath(panel(.115));
    p.color = emerald ? const Color(0xFF30664D) : const Color(0xFF7B4E54);
    p.strokeWidth = 1;
    for (double v = .13; v < .9; v += .045) {
      canvas.drawLine(point(.1, v), point(.9, v), p);
    }
    if (emerald) {
      p.color = const Color(0xFF285B44);
      for (double u = .14; u < .9; u += .035) {
        canvas.drawLine(point(u, .1), point(u, .9), p);
      }
      // A stitched compass rose projects through the same floor coordinates.
      final ring = Path();
      for (var i = 0; i <= 32; i++) {
        final a = i * math.pi / 16;
        final q = point(.5 + .245 * math.cos(a), .5 + .30 * math.sin(a));
        if (i == 0) { ring.moveTo(q.dx, q.dy); }
        else { ring.lineTo(q.dx, q.dy); }
      }
      p..color = const Color(0xFF8F8952)..style = PaintingStyle.stroke;
      canvas.drawPath(ring, p);
      p.style = PaintingStyle.fill;
      for (var i = 0; i < 8; i++) {
        final a = i * math.pi / 4 - math.pi / 2;
        final radius = i.isEven ? .275 : .19;
        final tip = point(.5 + radius * math.cos(a), .5 + radius * math.sin(a));
        final center = point(.5, .5);
        for (final side in [-1, 1]) {
          final flank = point(.5 + .048 * math.cos(a + side * math.pi / 2),
            .5 + .048 * math.sin(a + side * math.pi / 2));
          p.color = side < 0 ? const Color(0xFFD5B577) : const Color(0xFF9E804C);
          canvas.drawPath(Path()..addPolygon([center, tip, flank], true), p);
        }
      }
      // Small corner diamonds keep the design visible around the adventurer.
      p.color = const Color(0xFFB59A61);
      for (final u in [.19, .81]) {
        for (final v in [.22, .78]) {
          canvas.drawPath(Path()..addPolygon([point(u, v - .04),
            point(u + .025, v), point(u, v + .04), point(u - .025, v)], true), p);
        }
      }
    }
    canvas.restore();
    p.color = const Color(0xFFD2B17F);
    for (double u = .12; u < .9; u += .065) {
      for (final v in [.058, .94]) {
        canvas.drawLine(point(u, v), point(u + .018, v), p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant QuestwellWovenRugPainter oldDelegate) =>
      oldDelegate.emerald != emerald;
}
