import 'dart:math' as math;
import 'package:flutter/material.dart';

class QuestwellWovenRug extends StatelessWidget {
  const QuestwellWovenRug({super.key, required this.emerald});
  final bool emerald;
  static const emeraldAsset =
      'assets/images/questwell/hearth/emerald_wayfarer_rug_v3_64bit.webp';

  @override
  Widget build(BuildContext context) => emerald
      ? IgnorePointer(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    left: width * .16,
                    top: height * .675,
                    width: width * .68,
                    height: height * .285,
                    child: Image.asset(
                      emeraldAsset,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.none,
                      gaplessPlayback: true,
                      excludeFromSemantics: true,
                    ),
                  ),
                ],
              );
            },
          ),
        )
      : IgnorePointer(
          child: CustomPaint(
            painter: const QuestwellWovenRugPainter(),
          ),
        );
}

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
      // Layered weave: keep the approved footprint and perspective, but make
      // the surface read as a textile rather than a flat geometric panel.
      p.style = PaintingStyle.stroke;
      p.strokeWidth = 1;
      for (double v = .13; v < .90; v += .032) {
        final odd = ((v * 1000).round() ~/ 32).isOdd;
        p.color = odd ? const Color(0xFF2E654D) : const Color(0xFF244F3E);
        canvas.drawLine(point(.105, v), point(.895, v), p);
      }
      for (double u = .13; u < .90; u += .028) {
        final odd = ((u * 1000).round() ~/ 28).isOdd;
        p.color = odd ? const Color(0x442F7255) : const Color(0x333A7B5F);
        canvas.drawLine(point(u, .12), point(u, .89), p);
      }

      // Inner double border creates a woven band rather than a single vector line.
      p.color = const Color(0xFFC4A45F);
      p.strokeWidth = 1.6;
      canvas.drawPath(panel(.105), p);
      p.color = const Color(0xFF7B663D);
      p.strokeWidth = .9;
      canvas.drawPath(panel(.125), p);

      // Compass ring.
      final ring = Path();
      for (var i = 0; i <= 40; i++) {
        final a = i * math.pi / 20;
        final q = point(.5 + .242 * math.cos(a), .5 + .292 * math.sin(a));
        if (i == 0) {
          ring.moveTo(q.dx, q.dy);
        } else {
          ring.lineTo(q.dx, q.dy);
        }
      }
      p
        ..color = const Color(0xFFB99B5B)
        ..strokeWidth = 1.35;
      canvas.drawPath(ring, p);

      // Eight stitched compass points. Alternating thread values give the motif
      // a hand-woven feel while preserving the existing compass language.
      final center = point(.5, .5);
      p.style = PaintingStyle.fill;
      for (var i = 0; i < 8; i++) {
        final a = i * math.pi / 4 - math.pi / 2;
        final radius = i.isEven ? .27 : .185;
        final tip = point(.5 + radius * math.cos(a), .5 + radius * math.sin(a));
        final left = point(.5 + .055 * math.cos(a - math.pi / 2),
            .5 + .060 * math.sin(a - math.pi / 2));
        final right = point(.5 + .055 * math.cos(a + math.pi / 2),
            .5 + .060 * math.sin(a + math.pi / 2));
        p.color = i.isEven ? const Color(0xFFD6B875) : const Color(0xFF9A7B47);
        canvas.drawPath(Path()..addPolygon([center, tip, left], true), p);
        p.color = i.isEven ? const Color(0xFF9F824C) : const Color(0xFFC2A364);
        canvas.drawPath(Path()..addPolygon([center, tip, right], true), p);
      }

      // Central woven medallion.
      p.color = const Color(0xFF183B30);
      canvas.drawOval(Rect.fromCenter(center: center, width: size.width * .027,
          height: size.height * .020), p);
      p.color = const Color(0xFFE0C884);
      canvas.drawOval(Rect.fromCenter(center: center, width: size.width * .014,
          height: size.height * .010), p);

      // Corner diamonds sit outside the avatar silhouette and balance the field.
      for (final u in [.19, .81]) {
        for (final v in [.22, .78]) {
          final q = point(u, v);
          p.color = const Color(0xFF7D6A42);
          canvas.drawPath(Path()..addPolygon([
            Offset(q.dx, point(u, v - .048).dy),
            Offset(point(u + .030, v).dx, q.dy),
            Offset(q.dx, point(u, v + .048).dy),
            Offset(point(u - .030, v).dx, q.dy),
          ], true), p);
          final qi = point(u, v);
          p.color = const Color(0xFFC7AA68);
          canvas.drawOval(Rect.fromCenter(center: qi, width: size.width * .008,
              height: size.height * .006), p);
        }
      }
      p.style = PaintingStyle.fill;
    }
    canvas.restore();
    p.color = emerald ? const Color(0xFFC9A96B) : const Color(0xFFD2B17F);
    for (double u = .12; u < .9; u += .065) {
      for (final v in [.058, .94]) {
        canvas.drawLine(point(u, v), point(u + .018, v), p);
        if (emerald) {
          p.color = const Color(0xFF80653E);
          canvas.drawLine(point(u + .006, v), point(u + .020, v), p);
          p.color = const Color(0xFFC9A96B);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant QuestwellWovenRugPainter oldDelegate) =>
      oldDelegate.emerald != emerald;
}
