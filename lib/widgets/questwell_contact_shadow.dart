import 'package:flutter/material.dart';

/// Contact points follow the visible feet inside each transparent art canvas.
/// Paint behind the item, and mirror with its artwork when its facing changes.
class QuestwellContactShadowPainter extends CustomPainter {
  const QuestwellContactShadowPainter(this.subject);

  final String subject;

  @override
  void paint(Canvas canvas, Size size) {
    void oval(double x, double y, double width, double height,
        {int alpha = 68}) {
      canvas.save();
      canvas.translate(size.width * x, size.height * y);
      canvas.scale(size.width * width / 2, size.height * height / 2);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            Color.fromARGB(alpha, 14, 9, 6),
            Color.fromARGB(alpha ~/ 2, 14, 9, 6),
            const Color(0x000E0906),
          ],
          stops: const [0, .45, 1],
        ).createShader(const Rect.fromLTWH(-1, -1, 2, 2));
      canvas.drawCircle(Offset.zero, 1, paint);
      canvas.restore();
    }

    switch (subject) {
      case 'burgundy-reading-chair':
        oval(.53, .865, .70, .12, alpha: 22);
        oval(.20, .882, .16, .040);
        oval(.685, .943, .17, .040);
        oval(.845, .827, .13, .032, alpha: 52);
        oval(.445, .793, .11, .028, alpha: 44);
      case 'walnut-reading-table':
        oval(.50, .83, .78, .14, alpha: 18);
        oval(.189, .807, .16, .030);
        oval(.470, .942, .19, .036);
        oval(.810, .813, .16, .030);
        oval(.555, .715, .12, .025, alpha: 44);
      case 'walnut-bookshelf':
        oval(.49, .89, .86, .072, alpha: 28);
        oval(.140, .880, .17, .035);
        oval(.800, .921, .18, .037);
        oval(.860, .874, .13, .030, alpha: 44);
      case 'hearth-fern':
        oval(.51, .908, .41, .065, alpha: 36);
        oval(.51, .906, .32, .025, alpha: 58);
      case 'scholar-seal':
      case 'scout-compass':
      case 'alchemist-phial':
      case 'guardian-crest':
      case 'wanderer-star-map':
        // Cropped display sprites share a narrow walnut stand. Match its
        // three visible feet, rather than using the avatar's boot shadows.
        oval(.50, .932, .65, .090, alpha: 32);
        oval(.24, .902, .18, .035, alpha: 88);
        oval(.58, .974, .19, .035, alpha: 94);
        oval(.79, .876, .16, .030, alpha: 66);
      default:
        // All avatar bodies use the same 240 × 320 canvas and boot baseline.
        oval(.525, .968, .55, .037, alpha: 20);
        oval(subject == 'female' ? .405 : .375, .963, .21, .023);
        oval(.680, .966, .22, .023);
    }
  }

  @override
  bool shouldRepaint(covariant QuestwellContactShadowPainter oldDelegate) =>
      oldDelegate.subject != subject;
}
