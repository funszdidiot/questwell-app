import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Crisp 32-pixel collectible icons for mastery, inventory, and avatar badges.
class QuestwellMasteryRelic extends StatelessWidget {
  const QuestwellMasteryRelic({super.key, required this.archetype, this.size = 96});
  final String archetype;
  final double size;
  static const slugs = {
    'scholar': 'scholar-seal', 'scout': 'scout-compass',
    'alchemist': 'alchemist-phial', 'guardian': 'guardian-crest',
    'wanderer': 'wanderer-star-map',
  };
  static const names = {
    'scholar': 'Scholar Seal', 'scout': 'Scout Compass',
    'alchemist': 'Alchemist Phial', 'guardian': 'Guardian Crest',
    'wanderer': 'Wanderer Star Map',
  };
  static bool supports(String? slug) => slugs.containsValue(slug);
  static String classFor(String slug) => slugs.entries
      .firstWhere((entry) => entry.value == slug).key;
  @override
  Widget build(BuildContext context) => Semantics(
    label: names[archetype] ?? names['wanderer'], image: true,
    child: SizedBox.square(dimension: size, child: CustomPaint(painter: QuestwellMasteryRelicPainter(archetype))),
  );
}

/// Furniture and its relic are one authored sprite, so light and perspective agree.
class QuestwellMasteryDisplay extends StatelessWidget {
  const QuestwellMasteryDisplay({super.key, required this.archetype, this.surface = false});
  final String archetype;
  final bool surface;
  @override
  Widget build(BuildContext context) => _MasteryAsset(archetype: archetype, symbol: surface);
}

class _MasteryAsset extends StatelessWidget {
  const _MasteryAsset({required this.archetype, this.symbol = false});
  final String archetype;
  final bool symbol;
  static const fullBounds = <String, Rect>{
    'alchemist': Rect.fromLTWH(148,80,729,1397),
    'scholar': Rect.fromLTWH(133,48,761,1443),
    'scout': Rect.fromLTWH(141,36,741,1358),
    'guardian': Rect.fromLTWH(142,44,748,1395),
    'wanderer': Rect.fromLTWH(119,27,789,1448),
  };
  static const symbolBounds = <String, Rect>{
    'alchemist': Rect.fromLTWH(337,75,345,530),
    'scholar': Rect.fromLTWH(310,44,390,500),
    'scout': Rect.fromLTWH(304,32,423,500),
    'guardian': Rect.fromLTWH(322,40,379,480),
    'wanderer': Rect.fromLTWH(285,24,470,527),
  };
  @override
  Widget build(BuildContext context) {
    final name = fullBounds.containsKey(archetype) ? archetype : 'wanderer';
    final crop = (symbol ? symbolBounds : fullBounds)[name]!;
    // A display viewport preserves the original alpha and anchors its actual
    // feet to the floor. Symbols use the same artwork's upper artifact detail.
    return FittedBox(fit: BoxFit.contain, alignment: Alignment.bottomCenter,
      child: SizedBox(width: crop.width, height: crop.height,
        child: ClipRect(child: OverflowBox(alignment: Alignment.topLeft,
          minWidth: 1024, maxWidth: 1024, minHeight: 1536, maxHeight: 1536,
          child: Transform.translate(offset: Offset(-crop.left,-crop.top),
            child: Image.asset('assets/images/questwell/hearth/mastery/${name}_display_v2.webp',
              width: 1024, height: 1536, fit: BoxFit.fill, filterQuality: FilterQuality.medium,
              errorBuilder: (_, __, ___) => const SizedBox.shrink()))))));
  }
}

/// Integer grid, limited palette, and stepped contours: no smooth vector edges.
class QuestwellMasteryRelicPainter extends CustomPainter {
  const QuestwellMasteryRelicPainter(this.archetype);
  final String archetype;
  @override
  void paint(Canvas canvas, Size size) {
    final unit = math.min(size.width, size.height) / 32;
    final origin = Offset((size.width - 32 * unit) / 2, (size.height - 32 * unit) / 2);
    final paint = Paint()..isAntiAlias = false;
    const ink = Color(0xFF292333), bronze = Color(0xFF986339),
      gold = Color(0xFFDCAA55), light = Color(0xFFFFE3A0),
      paper = Color(0xFFF2D6A1), shade = Color(0xFFC29766);
    void block(int x, int y, int w, int h, Color color) {
      paint.color = color;
      canvas.drawRect(Rect.fromLTRB(
        (origin.dx + x * unit).roundToDouble(), (origin.dy + y * unit).roundToDouble(),
        (origin.dx + (x + w) * unit).roundToDouble(), (origin.dy + (y + h) * unit).roundToDouble()), paint);
    }
    void disk(int cx, int cy, int radius, Color color) {
      for (var y = -radius; y <= radius; y++) {
        final half = math.sqrt(radius * radius - y * y).floor();
        block(cx - half, cy + y, half * 2 + 1, 1, color);
      }
    }
    void star(int x, int y) {
      block(x, y-1, 1, 3, light); block(x-1,y,3,1,light);
    }
    switch (archetype) {
      case 'alchemist':
        block(12,2,8,5,ink); block(13,3,6,3,bronze); block(13,3,4,1,light);
        block(11,7,10,2,gold); block(12,9,8,6,ink);
        block(13,9,6,6,const Color(0xFF83BCA9));
        block(10,14,12,2,ink); block(8,16,16,2,ink);
        block(6,18,20,8,ink); block(8,26,16,3,ink);
        block(10,29,12,1,ink); block(8,18,16,8,const Color(0xFF285E58));
        block(10,16,12,2,const Color(0xFF83BCA9));
        block(9,21,14,6,const Color(0xFF3D9161)); block(11,27,10,1,const Color(0xFF285E58));
        block(9,18,2,5,paper); block(14,10,1,4,paper);
        block(12,17,8,2,gold); block(15,19,2,3,light);
        block(18,23,2,2,const Color(0xFFB9DD87)); block(12,25,1,1,light);
        break;
      case 'guardian':
        block(14,2,4,1,ink); block(9,3,14,2,ink); block(5,5,22,3,ink);
        block(6,8,20,11,ink); block(8,19,16,4,ink); block(11,23,10,3,ink);
        block(14,26,4,3,ink); block(7,6,18,2,gold); block(8,8,16,10,gold);
        block(10,18,12,4,gold); block(12,22,8,3,gold); block(15,25,2,2,gold);
        block(9,8,14,9,const Color(0xFF924A54)); block(11,17,10,4,const Color(0xFF713443));
        block(13,21,6,2,const Color(0xFF713443)); block(16,8,7,9,const Color(0xFF713443));
        block(15,9,2,12,light); block(11,13,10,2,light);
        block(15,10,2,2,const Color(0xFF9DBCCB)); block(8,6,7,1,light);
        break;
      case 'wanderer':
        block(5,5,22,22,ink); block(3,7,3,18,ink); block(26,3,3,23,ink);
        block(5,6,22,20,gold); block(7,7,18,17,const Color(0xFF293D60));
        block(5,7,2,17,light); block(25,5,2,19,bronze); block(7,24,18,2,bronze);
        for (final point in const [Offset(10,18),Offset(11,17),Offset(12,16),Offset(13,15),Offset(14,14),Offset(16,14),Offset(17,15),Offset(18,16),Offset(19,14),Offset(20,12),Offset(21,11),Offset(19,18),Offset(20,20)]) {
          block(point.dx.toInt(),point.dy.toInt(),1,1,gold);
        }
        star(10,19); star(14,13); star(18,16); star(22,10); star(21,21);
        block(10,10,1,1,paper); block(15,21,1,1,paper);
        break;
      default:
        disk(16,16,13,ink); disk(16,16,11,bronze); disk(16,15,10,gold);
        disk(16,15,8,archetype == 'scholar' ? const Color(0xFF68344B) : const Color(0xFF29584F));
        block(10,6,7,1,light); block(7,9,1,4,light);
        if (archetype == 'scholar') {
          block(9,11,6,11,bronze); block(17,11,6,11,bronze); block(15,12,2,12,bronze);
          block(9,10,5,10,paper); block(14,11,1,10,paper);
          block(17,11,1,10,shade); block(18,10,5,10,shade);
          block(10,13,3,1,bronze); block(10,16,3,1,bronze);
          block(19,13,3,1,bronze); block(19,16,3,1,bronze);
          block(15,12,2,9,ink);
        } else {
          block(16,7,1,3,light); block(16,21,1,3,gold);
          block(7,15,3,1,gold); block(23,15,3,1,gold);
          for (var row=0; row<8; row++) {
            final half = row ~/ 3;
            block(16-half,8+row,half*2+1,1,const Color(0xFFD77858));
            block(16-half,22-row,half*2+1,1,paper);
          }
          block(14,14,5,3,ink); block(15,14,3,2,light);
        }
    }
  }
  @override
  bool shouldRepaint(covariant QuestwellMasteryRelicPainter oldDelegate) => oldDelegate.archetype != archetype;
}
