import 'package:flutter/material.dart';

/// Compact class symbols, distinct from the large mastery relic artwork.
class QuestwellClassEmblem extends StatelessWidget {
  const QuestwellClassEmblem({super.key, required this.archetype, this.size = 24});
  final String archetype;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: SizedBox.square(
    dimension: size,
    child: ClipRect(child: CustomPaint(painter: _ClassEmblemPainter(archetype))),
  ));
}

class _ClassEmblemPainter extends CustomPainter {
  const _ClassEmblemPainter(this.archetype);
  final String archetype;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 16, size.height / 16);
    final paint = Paint()..isAntiAlias = false;
    void r(double x, double y, double w, double h, Color color) {
      paint.color = color;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), paint);
    }
    const gold = Color(0xFFE4BC69);
    const paper = Color(0xFFE6D5AE);
    const ink = Color(0xFF14202F);
    const teal = Color(0xFF6BBBA6);
    switch (archetype) {
      case 'scholar':
        r(1, 4, 14, 9, const Color(0xFF9277BA));
        r(2, 3, 5, 9, paper);
        r(9, 3, 5, 9, paper);
        r(7, 4, 2, 10, gold);
        for (final y in [5.0, 8.0]) {
          r(3, y, 3, 1, const Color(0xFF907CAA));
          r(10, y, 3, 1, const Color(0xFF907CAA));
        }
      case 'scout':
        r(5, 1, 6, 1, gold);
        r(3, 2, 10, 2, gold);
        r(2, 4, 12, 8, gold);
        r(3, 12, 10, 2, gold);
        r(5, 14, 6, 1, gold);
        r(4, 4, 8, 8, const Color(0xFF28594B));
        r(7, 3, 2, 10, ink);
        r(3, 7, 10, 2, ink);
        r(8, 4, 2, 3, paper);
        r(7, 7, 2, 2, paper);
        r(6, 9, 2, 3, teal);
      case 'alchemist':
        r(6, 1, 4, 2, gold);
        r(5, 3, 6, 2, paper);
        r(6, 5, 4, 2, paper);
        r(4, 7, 8, 2, paper);
        r(3, 9, 10, 4, paper);
        r(4, 13, 8, 2, paper);
        r(4, 9, 8, 4, const Color(0xFF759DE0));
        r(5, 13, 6, 1, const Color(0xFF4674B4));
        r(5, 9, 2, 2, const Color(0xFFCCECF2));
      case 'guardian':
        r(2, 2, 12, 8, gold);
        r(3, 10, 10, 2, gold);
        r(5, 12, 6, 2, gold);
        r(7, 14, 2, 1, gold);
        r(4, 4, 8, 6, const Color(0xFF9B4456));
        r(5, 10, 6, 2, const Color(0xFF9B4456));
        r(7, 4, 2, 8, paper);
        r(5, 6, 6, 2, paper);
      default:
        // Folded parchment, teal landmarks and a winding gold route.
        r(1, 3, 5, 11, const Color(0xFF8C6243));
        r(6, 2, 4, 11, const Color(0xFF8C6243));
        r(10, 3, 5, 11, const Color(0xFF8C6243));
        r(2, 4, 4, 9, paper);
        r(6, 3, 4, 9, const Color(0xFFC4AF87));
        r(10, 4, 4, 9, paper);
        r(3, 5, 2, 2, teal);
        r(11, 10, 2, 2, teal);
        r(3, 10, 3, 1, const Color(0xFFB27E2D));
        r(5, 8, 1, 3, const Color(0xFFB27E2D));
        r(5, 8, 5, 1, const Color(0xFFB27E2D));
        r(9, 6, 1, 3, const Color(0xFFB27E2D));
        r(9, 6, 3, 1, const Color(0xFFB27E2D));
        r(11, 5, 2, 2, gold);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ClassEmblemPainter oldDelegate) =>
      oldDelegate.archetype != archetype;
}
