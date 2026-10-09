import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shared 32-pixel artwork with the shading and limited palettes of 16-bit RPGs.
/// Integer coordinates and no anti-aliasing keep Inventory and Market consistent.
class QuestwellItemIcon extends StatelessWidget {
  const QuestwellItemIcon({
    super.key,
    required this.slug,
    this.size = 64,
    this.locked = false,
  });
  final String slug;
  final double size;
  final bool locked;
  @override
  Widget build(BuildContext context) => Semantics(
        label: '${slug.replaceAll('-', ' ')} icon',
        image: true,
        child: SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: QuestwellItemIconPainter(slug, locked: locked),
          ),
        ),
      );
}

class QuestwellItemIconPainter extends CustomPainter {
  const QuestwellItemIconPainter(this.slug, {this.locked = false});
  final String slug;
  final bool locked;
  static const ink = Color(0xFF172329),
      gold = Color(0xFFE6BD69),
      goldShade = Color(0xFF916039),
      cream = Color(0xFFFFEBC0),
      wood = Color(0xFF865435),
      woodLight = Color(0xFFBE8755),
      woodDark = Color(0xFF4B332B),
      green = Color(0xFF4C956E),
      greenDark = Color(0xFF28534A),
      mint = Color(0xFF95D3A0),
      red = Color(0xFFAA4D59),
      redDark = Color(0xFF612F40),
      purple = Color(0xFF8170B3),
      purpleDark = Color(0xFF493D72),
      blue = Color(0xFF75B8D1);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final scale = math.min(size.width, size.height) / 32;
    canvas.translate(
      (size.width - 32 * scale) / 2,
      (size.height - 32 * scale) / 2,
    );
    canvas.scale(scale);
    final paint = Paint()..isAntiAlias = false;
    void r(num x, num y, num w, num h, Color c) {
      paint.color = c;
      canvas.drawRect(
        Rect.fromLTWH(x.toDouble(), y.toDouble(), w.toDouble(), h.toDouble()),
        paint,
      );
    }

    void gem(int x, int y, Color c) {
      r(x + 1, y, 2, 1, c);
      r(x, y + 1, 4, 3, c);
      r(x + 1, y + 4, 2, 1, c);
      r(x + 1, y + 1, 1, 1, cream);
    }

    void star(int x, int y, Color c) {
      r(x, y - 2, 1, 5, c);
      r(x - 2, y, 5, 1, c);
    }

    void panel(int x, int y, int w, int h, Color c, Color light, Color dark) {
      r(x, y, w, h, ink);
      r(x + 1, y + 1, w - 2, h - 2, c);
      r(x + 1, y + 1, w - 2, 1, light);
      r(x + 1, y + 1, 1, h - 2, light);
      r(x + w - 2, y + 2, 1, h - 3, dark);
      r(x + 2, y + h - 2, w - 3, 1, dark);
    }

    if (slug == 'amberfall-window') {
      panel(5, 2, 22, 28, wood, woodLight, woodDark);
      r(7, 4, 18, 23, blue);
      r(8, 6, 5, 8, goldShade);
      r(9, 5, 6, 7, gold);
      r(20, 5, 4, 9, red);
      r(7, 23, 18, 4, greenDark);
      r(12, 17, 3, 2, gold);
      r(20, 20, 2, 3, red);
      r(15, 4, 2, 23, wood);
      r(7, 15, 18, 2, wood);
    } else if (slug == 'maple-hearth-rug') {
      panel(3, 9, 26, 15, goldShade, gold, woodDark);
      r(5, 11, 22, 11, redDark);
      for (final x in [4, 7, 10, 13, 16, 19, 22, 25, 28]) {
        r(x, 7, 1, 2, cream);
        r(x, 24, 1, 2, gold);
      }
      r(14, 12, 4, 8, gold);
      r(11, 14, 10, 3, gold);
      r(12, 13, 2, 5, woodLight);
      r(18, 13, 2, 5, woodLight);
      r(16, 19, 1, 2, cream);
    } else if (slug == 'mooncap-grove') {
      r(4, 26, 24, 3, greenDark);
      r(7, 24, 19, 3, green);
      r(10, 12, 4, 14, cream);
      r(7, 7, 10, 3, purple);
      r(5, 10, 14, 5, purpleDark);
      r(7, 10, 10, 2, purple);
      r(9, 9, 2, 2, cream);
      r(15, 12, 2, 1, blue);
      r(21, 19, 3, 8, cream);
      r(20, 15, 5, 3, purple);
      r(18, 18, 9, 3, purpleDark);
      r(20, 17, 2, 2, cream);
    } else if (slug == 'harvest-lanterns') {
      for (final origin in [const Offset(3, 8), const Offset(18, 14)]) {
        final x = origin.dx.toInt(), y = origin.dy.toInt();
        panel(x + 3, y - 5, 6, 5, woodDark, gold, ink);
        panel(x, y, 12, 17, goldShade, gold, woodDark);
        r(x + 2, y + 3, 8, 11, woodDark);
        r(x + 4, y + 6, 4, 7, gold);
        r(x + 5, y + 5, 2, 6, cream);
        r(x + 1, y + 15, 10, 1, gold);
      }
    } else if (slug == 'sages-rest') {
      panel(3, 20, 26, 9, redDark, red, woodDark);
      panel(6, 14, 22, 8, goldShade, gold, woodDark);
      panel(4, 8, 21, 8, greenDark, green, woodDark);
      r(7, 10, 15, 1, gold);
      r(7, 13, 15, 1, goldShade);
      gem(13, 9, gold);
    } else if (slug == 'midnight-masquerade' || slug == 'pumpkin-court') {
      final pumpkin = slug == 'pumpkin-court';
      final cloth = pumpkin ? woodLight : purpleDark;
      final facing = pumpkin ? greenDark : ink;
      r(10, 9, 12, 20, ink);
      r(7, 10, 4, 12, ink);
      r(21, 10, 4, 12, ink);
      r(8, 11, 3, 10, cloth);
      r(21, 11, 3, 10, cloth);
      r(11, 10, 10, 18, cloth);
      r(13, 10, 6, 12, pumpkin ? cream : purple);
      r(11, 10, 2, 18, facing);
      r(19, 10, 2, 18, facing);
      r(10, 27, 12, 2, goldShade);
      r(12, 29, 3, 2, ink);
      r(17, 29, 3, 2, ink);
      r(9, 3, 14, 4, goldShade);
      r(10, 4, 12, 3, facing);
      r(12, 5, 2, 1, cream);
      r(18, 5, 2, 1, cream);
      r(8, 2, 2, 3, facing);
      r(22, 2, 2, 3, facing);
      gem(15, 13, gold);
    } else if (slug == 'hallowed-hearth') {
      panel(2, 3, 28, 27, woodDark, woodLight, ink);
      r(4, 5, 24, 20, purpleDark);
      r(4, 25, 24, 3, wood);
      panel(6, 13, 12, 12, wood, woodLight, ink);
      r(9, 17, 6, 7, ink);
      r(10, 19, 4, 5, goldShade);
      r(11, 18, 2, 5, gold);
      r(12, 20, 1, 3, cream);
      panel(21, 7, 6, 13, purple, goldShade, ink);
      r(22, 8, 3, 4, cream);
      r(23, 8, 3, 3, purple);
      r(5, 4, 1, 6, cream);
      r(4, 10, 3, 2, ink);
      r(3, 9, 1, 1, ink);
      r(7, 9, 1, 1, ink);
      r(20, 25, 6, 3, goldShade);
      r(21, 24, 4, 4, woodLight);
      r(23, 23, 1, 1, greenDark);
    } else if (slug == 'velvet-batwing-chair') {
      panel(8, 6, 16, 15, purpleDark, purple, ink);
      r(6, 3, 3, 8, woodDark);
      r(23, 3, 3, 8, woodDark);
      r(9, 5, 3, 2, purple);
      r(20, 5, 3, 2, purple);
      panel(6, 19, 20, 8, purpleDark, purple, ink);
      panel(4, 17, 5, 8, purpleDark, purple, ink);
      panel(23, 17, 5, 8, purpleDark, purple, ink);
      r(8, 27, 3, 4, wood);
      r(21, 27, 3, 4, wood);
      panel(12, 13, 8, 6, purple, purple, ink);
      r(14, 14, 3, 3, gold);
      r(15, 14, 3, 2, purple);
    } else if (slug == 'moonbrew-side-table') {
      panel(3, 16, 26, 5, wood, woodLight, woodDark);
      r(14, 21, 4, 7, wood);
      r(15, 21, 1, 7, goldShade);
      r(9, 28, 14, 2, woodDark);
      panel(6, 11, 12, 4, purpleDark, purple, ink);
      r(7, 13, 10, 1, cream);
      panel(21, 9, 6, 6, goldShade, gold, woodDark);
      r(27, 10, 2, 4, goldShade);
      r(22, 7, 1, 2, cream);
      r(24, 5, 1, 3, cream);
    } else if (slug == 'witchlight-bookcase') {
      panel(5, 4, 22, 26, wood, woodLight, woodDark);
      r(7, 6, 18, 20, woodDark);
      r(8, 2, 16, 2, woodDark);
      r(11, 1, 10, 1, goldShade);
      for (final y in [7, 15]) {
        r(8, y, 3, 6, purple);
        r(12, y, 3, 6, redDark);
        r(16, y, 2, 6, greenDark);
        r(21, y, 2, 2, gold);
        r(20, y + 2, 4, 4, goldShade);
        r(21, y + 2, 1, 2, cream);
        r(7, y + 6, 18, 2, woodLight);
      }
      panel(8, 24, 16, 4, woodDark, wood, ink);
      r(15, 25, 2, 1, gold);
    } else if (slug == 'moonweb-rug') {
      panel(3, 8, 26, 16, purpleDark, goldShade, woodDark);
      r(5, 10, 22, 12, purple);
      r(7, 11, 18, 10, purpleDark);
      for (final x in [4, 7, 10, 13, 16, 19, 22, 25, 28]) {
        r(x, 6, 1, 2, gold);
        r(x, 24, 1, 2, goldShade);
      }
      r(13, 12, 6, 8, gold);
      r(16, 12, 5, 6, purpleDark);
      for (var j = 0; j < 4; j++) {
        r(7 + j, 11 + j, 1, 1, goldShade);
        r(24 - j, 20 - j, 1, 1, goldShade);
      }
    } else if (slug == 'midnight-visitors-print') {
      panel(7, 3, 18, 27, wood, woodLight, woodDark);
      r(9, 5, 14, 23, goldShade);
      r(10, 6, 12, 21, purpleDark);
      r(16, 8, 4, 4, cream);
      r(18, 8, 3, 3, purpleDark);
      r(12, 18, 8, 7, wood);
      r(14, 16, 4, 2, woodDark);
      r(15, 20, 2, 3, gold);
      for (final x in [11, 17]) {
        r(x, 13, 1, 1, ink);
        r(x + 1, 14, 1, 1, ink);
        r(x + 2, 13, 1, 1, ink);
      }
    } else if (slug == 'autumn-ember-lantern') {
      // Small copper lamp on its own walnut pedestal, on the shared 32px grid.
      r(13, 2, 6, 2, ink);
      r(12, 4, 2, 3, goldShade);
      r(18, 4, 2, 3, goldShade);
      r(14, 3, 4, 1, gold);
      r(13, 6, 6, 2, goldShade);
      r(11, 8, 10, 2, ink);
      r(10, 10, 12, 2, gold);
      panel(11, 12, 10, 6, goldShade, gold, woodDark);
      r(13, 13, 6, 4, const Color(0xFFD98028));
      r(15, 13, 2, 3, cream);
      r(10, 17, 12, 2, goldShade);
      panel(7, 19, 18, 3, wood, woodLight, woodDark);
      r(8, 19, 16, 1, goldShade);
      r(14, 22, 4, 6, woodDark);
      r(15, 22, 2, 6, woodLight);
      r(13, 23, 6, 1, goldShade);
      r(12, 27, 8, 2, wood);
      r(9, 29, 14, 2, woodDark);
      r(10, 29, 12, 1, goldShade);
      r(5, 10, 2, 2, gold);
      r(4, 12, 3, 2, woodLight);
      r(5, 14, 1, 2, wood);
      r(25, 5, 2, 2, woodLight);
      r(24, 7, 3, 2, goldShade);
      r(25, 9, 1, 2, wood);
    } else if (slug == 'harvest-apothecary-display') {
      // Chunky 32px seasonal emblem: bottles, pumpkin, book and level stand.
      panel(2, 21, 28, 9, wood, woodLight, woodDark);
      r(1, 20, 30, 2, woodLight);
      r(2, 29, 28, 2, woodDark);
      panel(4, 23, 11, 5, woodDark, wood, ink);
      panel(17, 23, 11, 5, woodDark, wood, ink);
      r(9, 25, 2, 1, gold);
      r(22, 25, 2, 1, gold);
      r(5, 12, 24, 2, woodDark);
      r(5, 12, 24, 1, woodLight);
      for (final x in [9, 17, 25]) {
        r(x, 3, 2, 2, goldShade);
        r(x - 1, 5, 4, 2, ink);
        r(x - 2, 7, 6, 5, ink);
        r(
          x - 1,
          7,
          4,
          4,
          x == 9
              ? green
              : x == 17
                  ? red
                  : gold,
        );
        r(x - 1, 7, 1, 2, cream);
      }
      const orange = Color(0xFFDA7831), pumpkinShade = Color(0xFF9A4927);
      r(4, 14, 9, 6, ink);
      r(3, 15, 11, 4, ink);
      r(4, 15, 9, 4, orange);
      r(6, 14, 5, 6, orange);
      r(7, 15, 1, 4, gold);
      r(10, 15, 1, 4, pumpkinShade);
      r(7, 12, 2, 2, woodDark);
      r(9, 12, 2, 1, green);
      r(12, 17, 5, 3, cream);
      r(14, 16, 1, 1, wood);
      panel(19, 16, 10, 4, redDark, red, ink);
      r(20, 18, 7, 1, cream);
      r(25, 16, 1, 4, gold);
      r(21, 14, 5, 1, greenDark);
      r(23, 13, 1, 2, green);
    } else if (slug == 'copper-potion-workbench') {
      // Copper alembic and jewel bottles above a level apothecary cabinet.
      panel(3, 18, 26, 12, wood, woodLight, woodDark);
      r(2, 17, 28, 2, goldShade);
      r(3, 17, 26, 1, gold);
      for (final x in [5, 11, 17, 23]) {
        panel(x, 20, 4, 3, woodDark, wood, ink);
        r(x + 1, 21, 2, 1, gold);
      }
      panel(5, 24, 10, 4, woodDark, woodLight, ink);
      panel(17, 24, 10, 4, woodDark, woodLight, ink);
      r(13, 25, 1, 1, gold);
      r(18, 25, 1, 1, gold);
      r(3, 29, 26, 2, woodDark);
      r(6, 7, 7, 2, goldShade);
      r(4, 9, 11, 5, ink);
      r(5, 9, 9, 5, goldShade);
      r(6, 9, 6, 3, woodLight);
      r(7, 9, 2, 2, cream);
      r(6, 14, 2, 3, woodDark);
      r(12, 14, 2, 3, woodDark);
      r(8, 4, 4, 4, goldShade);
      r(9, 3, 5, 2, gold);
      r(13, 4, 3, 2, gold);
      r(15, 5, 3, 2, goldShade);
      r(17, 6, 2, 4, gold);
      r(16, 10, 4, 2, blue);
      r(15, 12, 6, 4, ink);
      r(16, 12, 4, 3, blue);
      r(16, 14, 4, 2, green);
      r(16, 12, 1, 1, cream);
      for (final x in [23, 27]) {
        r(x, 10, 2, 2, gold);
        r(x - 1, 12, 4, 5, ink);
        r(x, 12, 2, 4, x == 23 ? green : red);
        r(x, 12, 1, 1, cream);
      }
    } else if (const [
      'woodland-cottage',
      'midnight-harvest',
      'enchanted-library',
      'midnight-observatory',
      'alchemists-workshop',
      'astral-sanctuary',
      'emberglass-conservatory',
    ].contains(slug)) {
      // Miniature room emblems share a 32px grid, each with its own motif.
      final harvest = slug == 'midnight-harvest';
      final library = slug == 'enchanted-library';
      final alchemy = slug == 'alchemists-workshop';
      final astral = slug == 'astral-sanctuary';
      final observatory = slug == 'midnight-observatory';
      final conservatory = slug == 'emberglass-conservatory';
      final sky = astral || observatory;
      final wall = harvest
          ? const Color(0xFF704333)
          : alchemy
              ? redDark
              : sky
                  ? purpleDark
                  : greenDark;
      panel(2, 3, 28, 27, wood, woodLight, woodDark);
      r(5, 6, 22, 19, wall);
      r(4, 25, 24, 4, wood);
      r(5, 25, 22, 1, woodLight);
      r(5, 28, 22, 1, goldShade);
      panel(20, 7, 7, 13, sky ? purple : blue, gold, woodDark);
      r(23, 8, 1, 11, goldShade);
      r(21, 13, 5, 1, goldShade);
      if (library) {
        for (final x in [6, 13]) {
          r(x, 8, 5, 15, woodDark);
          for (final y in [9, 15]) {
            r(x, y, 1, 4, red);
            r(x + 2, y, 1, 4, gold);
            r(x + 4, y, 1, 4, blue);
            r(x, y + 4, 5, 1, woodLight);
          }
        }
        r(20, 22, 7, 2, gold);
        r(21, 21, 5, 1, cream);
      } else if (alchemy) {
        r(6, 18, 12, 2, woodLight);
        r(7, 20, 2, 5, wood);
        r(16, 20, 2, 5, wood);
        r(8, 11, 2, 3, gold);
        r(6, 14, 6, 4, ink);
        r(7, 14, 4, 3, green);
        r(8, 14, 1, 1, cream);
        r(14, 9, 2, 3, gold);
        r(13, 12, 4, 6, purple);
        r(14, 12, 1, 3, cream);
        r(7, 5, 10, 1, goldShade);
        r(16, 5, 1, 4, gold);
      } else if (sky) {
        r(8, 8, 5, 5, cream);
        r(10, 7, 4, 5, wall);
        star(16, 7, gold);
        if (astral) {
          gem(7, 16, purple);
          gem(12, 20, blue);
          star(25, 9, cream);
          r(21, 17, 2, 1, mint);
          r(24, 16, 2, 1, purple);
        } else {
          r(9, 17, 9, 3, goldShade);
          r(11, 16, 5, 2, gold);
          r(8, 18, 3, 3, blue);
          r(14, 20, 1, 5, gold);
          r(11, 24, 7, 1, goldShade);
        }
      } else {
        r(5, 7, 2, 15, woodDark);
        r(5, 21, 9, 3, woodDark);
        r(7, 16, 6, 6, ink);
        r(8, 18, 4, 4, harvest ? red : goldShade);
        r(9, 18, 2, 3, gold);
        r(10, 19, 1, 2, cream);
        for (final pos in [
          const Offset(6, 7),
          const Offset(10, 5),
          const Offset(16, 6),
          const Offset(26, 5),
        ]) {
          r(pos.dx, pos.dy, 3, 2, harvest ? red : green);
          r(pos.dx + 1, pos.dy + 2, 2, 2, harvest ? woodLight : mint);
        }
        if (conservatory) {
          r(18, 5, 1, 18, goldShade);
          gem(15, 12, gold);
          star(25, 22, gold);
          r(16, 21, 1, 1, cream);
        } else if (harvest) {
          r(16, 21, 3, 3, woodLight);
          r(17, 20, 1, 1, greenDark);
          r(24, 8, 2, 3, cream);
        } else {
          r(16, 19, 2, 5, green);
          r(14, 20, 5, 1, mint);
          r(15, 24, 4, 1, woodLight);
        }
      }
    } else if (slug == 'emerald-wayfarer-rug') {
      // Flat woven textile, gold edging and an eight-point compass rose.
      panel(3, 7, 26, 18, greenDark, gold, goldShade);
      r(5, 9, 22, 14, gold);
      r(6, 10, 20, 12, greenDark);
      for (final y in [12, 15, 18, 21]) r(7, y, 18, 1, const Color(0xFF30664D));
      for (final x in [4, 7, 10, 13, 16, 19, 22, 25, 28]) {
        r(x, 5, 1, 2, gold);
        r(x, 25, 1, 2, goldShade);
      }
      star(16, 16, gold);
      r(15, 12, 3, 9, gold);
      r(11, 15, 11, 3, gold);
      r(13, 13, 1, 1, goldShade);
      r(19, 13, 1, 1, goldShade);
      r(13, 19, 1, 1, goldShade);
      r(19, 19, 1, 1, goldShade);
      r(15, 15, 3, 3, cream);
      r(16, 16, 1, 1, greenDark);
    } else if (slug == 'emerald-dragon') {
      // Stepped emerald wings, golden horns, sage belly, and curled tail.
      r(3, 12, 3, 11, ink);
      r(6, 10, 3, 15, ink);
      r(9, 14, 3, 10, ink);
      r(4, 14, 2, 7, greenDark);
      r(6, 12, 2, 11, green);
      r(8, 17, 2, 6, mint);
      r(22, 10, 3, 15, ink);
      r(25, 12, 3, 12, ink);
      r(28, 15, 2, 8, ink);
      r(23, 12, 2, 11, green);
      r(25, 14, 2, 8, greenDark);
      r(27, 17, 1, 4, mint);
      r(11, 4, 3, 5, ink);
      r(20, 3, 3, 7, ink);
      r(12, 4, 1, 4, gold);
      r(20, 4, 2, 4, goldShade);
      r(21, 3, 1, 3, gold);
      r(11, 8, 12, 8, ink);
      r(8, 11, 5, 5, ink);
      r(10, 10, 12, 5, green);
      r(12, 8, 8, 4, green);
      r(9, 12, 5, 3, mint);
      r(10, 14, 3, 1, greenDark);
      r(15, 10, 4, 3, gold);
      r(16, 10, 2, 3, ink);
      r(16, 10, 1, 1, cream);
      r(21, 12, 2, 3, greenDark);
      r(13, 15, 9, 12, ink);
      r(14, 15, 7, 11, green);
      r(14, 17, 4, 8, mint);
      r(14, 19, 4, 1, greenDark);
      r(14, 22, 4, 1, greenDark);
      r(20, 17, 2, 7, greenDark);
      r(21, 18, 2, 2, goldShade);
      r(9, 26, 15, 3, ink);
      r(10, 26, 5, 2, green);
      r(18, 26, 5, 2, green);
      r(10, 28, 2, 1, gold);
      r(19, 28, 2, 1, gold);
      r(23, 24, 5, 2, greenDark);
      r(26, 22, 3, 4, green);
      r(25, 21, 2, 2, gold);
    } else if (slug.contains('owl')) {
      final archive = slug == 'archive-owl';
      final main = archive ? purple : woodLight;
      r(8, 6, 3, 7, woodDark);
      r(21, 6, 3, 7, woodDark);
      r(9, 8, 14, 3, ink);
      r(7, 11, 18, 12, ink);
      r(9, 23, 14, 3, ink);
      r(9, 10, 14, 13, main);
      r(8, 15, 3, 7, archive ? purpleDark : wood);
      r(21, 15, 3, 7, archive ? purpleDark : wood);
      r(11, 20, 10, 4, cream);
      r(12, 21, 2, 1, woodLight);
      r(17, 22, 2, 1, woodLight);
      for (final x in [10, 18]) {
        r(x, 12, 5, 6, cream);
        r(x + 2, 14, 2, 3, ink);
        r(x + 2, 14, 1, 1, blue);
      }
      r(15, 17, 2, 2, gold);
      r(11, 26, 3, 2, goldShade);
      r(18, 26, 3, 2, goldShade);
      if (archive) {
        r(6, 27, 20, 3, purpleDark);
        r(8, 28, 16, 1, cream);
        r(9, 12, 7, 1, gold);
        r(17, 12, 7, 1, gold);
        r(15, 14, 2, 1, gold);
      }
    } else if (slug == 'woodland-scout-outfit' ||
        slug == 'everyday-adventurer-outfit') {
      final scout = slug == 'woodland-scout-outfit';
      r(10, 3, 12, 3, ink);
      r(6, 6, 20, 10, ink);
      r(4, 13, 5, 7, ink);
      r(23, 13, 5, 7, ink);
      r(7, 7, 18, 10, cream);
      r(5, 14, 3, 5, cream);
      r(24, 14, 3, 5, cream);
      r(10, 16, 12, 7, ink);
      r(10, 22, 5, 7, ink);
      r(17, 22, 5, 7, ink);
      r(11, 18, 10, 5, wood);
      r(11, 22, 3, 5, wood);
      r(18, 22, 3, 5, wood);
      r(8, 27, 7, 3, woodDark);
      r(17, 27, 7, 3, woodDark);
      if (scout) {
        r(10, 6, 4, 12, greenDark);
        r(18, 6, 4, 12, greenDark);
        r(11, 7, 2, 10, green);
        r(19, 7, 2, 10, green);
        for (final y in [9, 12, 15]) {
          r(14, y, 4, 1, gold);
        }
        r(10, 17, 12, 2, woodDark);
        r(18, 17, 5, 5, wood);
        r(19, 18, 2, 1, gold);
      } else {
        r(15, 7, 1, 10, goldShade);
        r(10, 17, 12, 1, woodDark);
      }
    } else if (slug == 'midnight-harvest-coat') {
      r(10, 4, 12, 3, ink);
      r(6, 7, 20, 9, ink);
      r(3, 14, 6, 12, ink);
      r(23, 14, 6, 12, ink);
      r(8, 13, 16, 15, ink);
      r(7, 26, 18, 3, ink);
      r(7, 8, 18, 8, redDark);
      r(4, 16, 4, 8, redDark);
      r(24, 16, 4, 8, redDark);
      r(9, 14, 14, 13, redDark);
      r(8, 26, 7, 2, red);
      r(17, 26, 7, 2, red);
      r(10, 7, 4, 9, greenDark);
      r(18, 7, 4, 9, greenDark);
      r(12, 6, 8, 3, cream);
      r(14, 9, 4, 16, woodDark);
      r(14, 9, 4, 3, cream);
      r(15, 12, 2, 1, cream);
      r(9, 9, 1, 7, goldShade);
      r(22, 9, 1, 7, goldShade);
      r(11, 16, 1, 11, goldShade);
      r(20, 16, 1, 11, goldShade);
      for (final y in [17, 22]) {
        r(10, y, 3, 1, gold);
        r(11, y - 1, 1, 3, gold);
        r(19, y, 3, 1, gold);
        r(20, y - 1, 1, 3, gold);
        r(15, y, 2, 1, goldShade);
      }
      r(4, 24, 4, 1, goldShade);
      r(24, 24, 4, 1, goldShade);
    } else if (slug == 'boston-terrier' || slug == 'hearth-cat') {
      const fur = Color(0xFF373137), highlight = Color(0xFF62515A);
      const plum = Color(0xFF784659), moss = Color(0xFF617442);
      final dog = slug == 'boston-terrier';
      // Same 32px grid as existing familiars; distinctive silhouettes at 48px.
      r(8, 3, 4, 9, ink);
      r(21, 4, 4, 8, ink);
      r(9, 5, 2, 5, plum);
      r(22, 6, 2, 4, plum);
      r(7, 10, 19, 11, ink);
      r(9, 9, 15, 13, fur);
      r(10, 10, 4, 2, highlight);
      r(21, 11, 2, 2, highlight);
      r(10, 21, 15, 8, ink);
      r(12, 21, 11, 7, fur);
      r(10, 28, 6, 2, ink);
      r(18, 28, 7, 2, ink);
      if (dog) {
        r(15, 9, 3, 10, cream);
        r(12, 17, 10, 3, cream);
        r(14, 19, 6, 2, cream);
        r(15, 17, 3, 2, ink);
        r(11, 14, 3, 3, ink);
        r(20, 14, 3, 3, ink);
        r(12, 14, 1, 1, cream);
        r(21, 14, 1, 1, cream);
        r(14, 23, 6, 5, cream);
        r(11, 28, 4, 1, cream);
        r(19, 28, 4, 1, cream);
        r(11, 21, 12, 2, moss);
        r(13, 23, 6, 1, moss);
        r(15, 24, 2, 1, moss);
        star(22, 22, gold);
      } else {
        r(11, 14, 4, 3, gold);
        r(20, 14, 4, 3, gold);
        r(13, 14, 1, 3, ink);
        r(21, 14, 1, 3, ink);
        r(16, 18, 2, 1, plum);
        r(5, 18, 7, 1, highlight);
        r(23, 18, 5, 1, highlight);
        r(11, 21, 12, 2, plum);
        r(18, 23, 1, 3, gold);
        r(19, 25, 2, 1, gold);
        r(6, 24, 3, 4, ink);
        r(7, 27, 5, 2, ink);
        r(8, 26, 2, 2, fur);
        r(9, 28, 14, 2, fur);
        r(11, 28, 9, 1, highlight);
      }
    } else if (slug == 'pumpkin-sprite') {
      // Same 32px grid, chunky outline and limited shading as the other familiars.
      const orange = Color(0xFFCE742C),
          light = Color(0xFFF0A448),
          shade = Color(0xFF95452D);
      r(15, 4, 5, 7, ink);
      r(17, 3, 4, 3, ink);
      r(16, 5, 3, 6, wood);
      r(18, 4, 2, 2, woodLight);
      r(9, 6, 7, 4, greenDark);
      r(10, 5, 4, 4, green);
      r(11, 6, 3, 1, mint);
      r(20, 7, 5, 2, greenDark);
      r(23, 8, 3, 3, green);
      r(23, 8, 2, 1, mint);
      r(3, 18, 4, 3, ink);
      r(2, 20, 3, 4, ink);
      r(4, 19, 3, 2, wood);
      r(3, 21, 1, 2, woodLight);
      r(25, 18, 4, 3, ink);
      r(27, 20, 3, 4, ink);
      r(25, 19, 3, 2, wood);
      r(28, 21, 1, 2, woodLight);
      r(9, 25, 5, 4, ink);
      r(19, 25, 5, 4, ink);
      r(8, 28, 6, 2, woodDark);
      r(19, 28, 6, 2, woodDark);
      r(10, 27, 3, 2, wood);
      r(20, 27, 3, 2, wood);
      r(11, 10, 10, 2, ink);
      r(8, 12, 16, 2, ink);
      r(6, 14, 20, 10, ink);
      r(8, 24, 16, 2, ink);
      r(11, 26, 10, 1, ink);
      r(11, 11, 10, 2, orange);
      r(8, 14, 16, 10, shade);
      r(9, 13, 14, 12, orange);
      r(10, 14, 3, 9, light);
      r(14, 12, 4, 13, light);
      r(18, 13, 3, 11, orange);
      r(22, 15, 2, 8, shade);
      r(10, 16, 4, 4, ink);
      r(18, 16, 4, 4, ink);
      r(11, 17, 2, 2, gold);
      r(19, 17, 2, 2, gold);
      r(11, 17, 1, 1, cream);
      r(19, 17, 1, 1, cream);
      r(12, 21, 8, 2, ink);
      r(14, 23, 4, 1, ink);
      r(14, 22, 4, 1, gold);
    } else if (slug == 'mushroom-familiar') {
      r(13, 14, 7, 13, ink);
      r(14, 15, 5, 11, cream);
      r(18, 18, 1, 8, gold);
      r(5, 12, 23, 6, ink);
      r(7, 9, 19, 4, ink);
      r(10, 6, 13, 4, ink);
      r(13, 4, 7, 3, ink);
      r(7, 12, 19, 4, redDark);
      r(8, 10, 17, 4, red);
      r(11, 7, 11, 5, red);
      r(14, 5, 5, 3, red);
      r(11, 9, 3, 2, cream);
      r(20, 11, 3, 3, cream);
      r(15, 6, 2, 2, cream);
      r(8, 14, 4, 1, cream);
      r(14, 21, 1, 2, ink);
      r(18, 21, 1, 2, ink);
      r(16, 24, 1, 1, red);
      r(12, 27, 3, 1, greenDark);
      r(19, 27, 3, 1, greenDark);
    } else if (slug == 'glass-slime') {
      r(11, 9, 10, 2, ink);
      r(8, 11, 16, 3, ink);
      r(6, 14, 20, 5, ink);
      r(4, 19, 24, 8, ink);
      r(8, 15, 16, 10, green);
      r(6, 20, 20, 5, blue);
      r(9, 12, 14, 10, blue);
      r(12, 10, 8, 2, blue);
      r(9, 14, 3, 6, cream);
      r(12, 12, 4, 2, cream);
      r(23, 20, 2, 4, greenDark);
      r(11, 20, 2, 3, ink);
      r(20, 20, 2, 3, ink);
      r(15, 24, 3, 1, greenDark);
      r(8, 26, 16, 1, mint);
      star(24, 8, cream);
    } else if (slug == 'signal-fox') {
      r(7, 4, 3, 10, ink);
      r(22, 4, 3, 10, ink);
      r(8, 6, 3, 8, woodLight);
      r(21, 6, 3, 8, woodLight);
      r(10, 9, 12, 3, ink);
      r(6, 12, 20, 9, ink);
      r(9, 21, 14, 3, ink);
      r(12, 24, 8, 3, ink);
      r(8, 12, 16, 8, woodLight);
      r(10, 11, 12, 10, woodLight);
      r(11, 20, 10, 4, cream);
      r(7, 16, 5, 5, cream);
      r(20, 16, 5, 5, cream);
      r(10, 15, 2, 3, ink);
      r(20, 15, 2, 3, ink);
      r(14, 20, 4, 2, ink);
      r(14, 26, 5, 2, green);
      gem(15, 25, gold);
      star(27, 10, gold);
    } else if (slug == 'moss-moth') {
      for (final x in [4, 19]) {
        r(x, 6, 9, 3, ink);
        r(x - 1, 9, 11, 11, ink);
        r(x + 1, 20, 7, 6, ink);
        r(x, 9, 9, 10, green);
        r(x + 2, 20, 5, 4, greenDark);
        r(x + 1, 9, 6, 3, mint);
        gem(x + 3, 14, gold);
      }
      r(14, 9, 4, 17, woodDark);
      r(15, 10, 2, 13, gold);
      r(13, 5, 1, 5, gold);
      r(18, 5, 1, 5, gold);
      r(12, 4, 1, 2, mint);
      r(19, 4, 1, 2, mint);
    } else if (slug.contains('glasses')) {
      for (final x in [3, 18]) {
        r(x + 2, 10, 7, 1, goldShade);
        r(x, 12, 11, 7, goldShade);
        r(x + 2, 20, 7, 1, goldShade);
        r(x + 1, 12, 9, 7, gold);
        r(x + 2, 13, 7, 5, greenDark);
        r(x + 3, 13, 2, 2, blue);
        r(x + 5, 14, 1, 1, cream);
      }
      r(13, 14, 6, 2, gold);
      r(1, 12, 3, 2, gold);
      r(28, 12, 3, 2, gold);
    } else if (slug.contains('hat')) {
      r(17, 3, 5, 2, ink);
      r(14, 5, 7, 4, ink);
      r(12, 9, 8, 5, ink);
      r(10, 14, 12, 7, ink);
      r(4, 22, 24, 4, ink);
      r(7, 26, 18, 2, ink);
      r(6, 22, 20, 3, purple);
      r(11, 15, 10, 7, purpleDark);
      r(13, 10, 6, 7, purple);
      r(15, 6, 5, 5, purple);
      r(18, 4, 3, 2, purple);
      r(12, 16, 2, 4, purple);
      r(10, 20, 12, 2, gold);
      gem(16, 19, blue);
      r(7, 23, 8, 1, cream);
    } else if (slug.contains('scarf')) {
      panel(5, 5, 22, 7, green, mint, greenDark);
      panel(8, 11, 9, 17, green, mint, greenDark);
      panel(20, 11, 6, 13, greenDark, green, ink);
      r(9, 24, 7, 2, gold);
      r(21, 20, 4, 2, gold);
      for (final x in [9, 12, 15]) r(x, 28, 1, 2, green);
      r(21, 24, 1, 2, greenDark);
      r(24, 24, 1, 2, greenDark);
    } else if (slug.contains('suit') ||
        slug.contains('cloak') ||
        slug.contains('mantle')) {
      final suit = slug.contains('suit'), guardian = slug.contains('mantle');
      final c = suit
          ? const Color(0xFF626D7F)
          : guardian
              ? red
              : green;
      final dark = suit
          ? const Color(0xFF35404D)
          : guardian
              ? redDark
              : greenDark;
      r(10, 4, 12, 3, ink);
      r(7, 7, 18, 5, ink);
      r(5, 12, 22, 15, ink);
      r(8, 27, 16, 2, ink);
      r(8, 9, 16, 17, c);
      r(6, 13, 3, 13, dark);
      r(23, 13, 3, 13, dark);
      r(10, 6, 12, 4, c);
      r(20, 10, 3, 16, dark);
      r(
        9,
        10,
        2,
        14,
        suit
            ? blue
            : guardian
                ? const Color(0xFFCC7881)
                : mint,
      );
      r(15, 11, 2, 17, ink);
      r(12, 6, 8, 3, suit ? cream : gold);
      r(14, 9, 4, 3, suit ? cream : goldShade);
      if (suit) {
        r(15, 7, 2, 2, red);
        r(15, 10, 2, 7, red);
        r(11, 7, 1, 5, blue);
        r(12, 12, 2, 2, blue);
        r(20, 7, 1, 5, blue);
      } else {
        gem(14, 8, gold);
        r(8, 26, 7, 1, gold);
        r(17, 26, 7, 1, gold);
      }
    } else if (slug.contains('boot')) {
      for (final x in [4, 18]) {
        panel(x + 3, 5, 7, 17, wood, woodLight, woodDark);
        r(x, 21, 10, 5, ink);
        r(x + 1, 21, 8, 3, wood);
        r(x, 26, 11, 2, woodDark);
        r(x + 4, 10, 5, 2, gold);
        r(x + 4, 15, 3, 1, cream);
        r(x + 4, 18, 3, 1, cream);
        r(x + 1, 22, 3, 1, woodLight);
      }
    } else if (slug.contains('satchel')) {
      final way = slug == 'wayfarer-satchel';
      r(10, 4, 12, 2, woodDark);
      r(8, 6, 3, 8, woodDark);
      r(21, 6, 3, 8, woodDark);
      r(10, 6, 2, 5, goldShade);
      panel(
        4,
        13,
        24,
        15,
        way ? const Color(0xFF414B2C) : wood,
        way ? const Color(0xFF76804A) : woodLight,
        woodDark,
      );
      panel(
        5,
        11,
        22,
        9,
        way ? const Color(0xFF626D3D) : woodLight,
        way ? const Color(0xFFA4A66B) : gold,
        woodDark,
      );
      panel(13, 17, 6, 6, gold, cream, goldShade);
      r(15, 18, 2, 3, woodDark);
      r(7, 23, 3, 1, goldShade);
      r(22, 23, 3, 1, goldShade);
      if (way) {
        r(5, 26, 22, 2, wood);
        r(14, 13, 4, 4, wood);
        r(14, 23, 4, 3, wood);
        r(5, 9, 22, 3, cream);
        r(6, 11, 20, 1, goldShade);
        r(8, 8, 2, 5, wood);
        r(22, 8, 2, 5, wood);
        r(25, 9, 2, 3, gold);
        r(26, 10, 1, 1, woodDark);
      }
    } else if (slug.contains('grimoire') || slug.contains('seal')) {
      final book = slug == 'annotated-grimoire';
      panel(
        7,
        4,
        20,
        24,
        book ? const Color(0xFF49344F) : purple,
        book ? const Color(0xFF79586E) : purple,
        purpleDark,
      );
      r(8, 5, 3, 22, goldShade);
      r(11, 6, 13, 1, cream);
      r(12, 25, 12, 1, cream);
      r(25, 8, 3, 4, red);
      r(25, 16, 4, 3, blue);
      gem(16, 12, gold);
      r(14, 20, 8, 1, cream);
      r(15, 22, 5, 1, gold);
      r(5, 6, 2, 21, purpleDark);
      if (book) {
        r(23, 5, 3, 2, gold);
        r(23, 24, 3, 2, gold);
        r(12, 27, 3, 4, redDark);
        r(13, 27, 1, 3, red);
        star(17, 14, gold);
        r(17, 14, 1, 1, cream);
      }
    } else if (slug.contains('tonic') || slug.contains('phial')) {
      panel(12, 3, 8, 5, wood, woodLight, woodDark);
      r(13, 8, 6, 5, blue);
      r(9, 13, 14, 3, ink);
      r(6, 16, 20, 11, ink);
      r(9, 27, 14, 2, ink);
      r(8, 17, 16, 9, green);
      r(10, 14, 12, 4, blue);
      r(10, 24, 12, 3, greenDark);
      r(9, 18, 3, 5, mint);
      r(10, 16, 2, 3, cream);
      r(15, 20, 3, 2, mint);
      r(20, 22, 2, 1, cream);
      star(25, 9, gold);
    } else if (slug.contains('lantern')) {
      final ward = slug == 'warding-lantern';
      r(12, 2, 8, 2, goldShade);
      r(10, 4, 2, 5, gold);
      r(20, 4, 2, 5, goldShade);
      r(8, 10, 16, 2, ink);
      r(6, 12, 20, 2, goldShade);
      panel(8, 14, 16, 13, gold, cream, goldShade);
      r(11, 15, 10, 10, ward ? greenDark : const Color(0xFFCB732F));
      r(12, 16, 8, 8, ward ? green : gold);
      r(15, 17, 2, 4, cream);
      r(14, 21, 4, 3, cream);
      r(10, 15, 1, 10, woodDark);
      r(21, 15, 1, 10, woodDark);
      r(6, 27, 20, 2, goldShade);
      r(8, 29, 16, 1, ink);
      if (ward) gem(14, 7, mint);
    } else if (slug.contains('brooch')) {
      for (final y in [5, 7, 9, 11, 13, 15, 17, 19, 21]) {
        final w = y < 13 ? y - 1 : 25 - y;
        r(16 - w ~/ 2, y, w, 2, goldShade);
      }
      r(11, 8, 10, 13, gold);
      r(13, 6, 6, 17, gold);
      r(12, 10, 8, 9, blue);
      r(14, 8, 4, 13, blue);
      r(13, 10, 2, 5, cream);
      r(16, 17, 3, 2, purple);
      r(14, 23, 4, 3, goldShade);
      star(6, 10, cream);
    } else if (slug == 'victory-sparkle' || slug == 'guardian-crest') {
      star(15, 14, gold);
      r(14, 9, 3, 11, gold);
      r(10, 13, 11, 3, gold);
      r(14, 13, 3, 3, cream);
      star(7, 23, mint);
      star(25, 7, cream);
      star(24, 25, goldShade);
      r(6, 8, 2, 2, blue);
    } else if (slug.contains('window')) {
      panel(5, 3, 22, 26, wood, woodLight, woodDark);
      r(8, 6, 16, 19, const Color(0xFF29475A));
      r(9, 7, 6, 8, const Color(0xFF35576A));
      for (final pos in [
        const Offset(10, 9),
        const Offset(20, 8),
        const Offset(12, 19),
        const Offset(21, 20),
      ]) {
        r(pos.dx, pos.dy, 1, 3, blue);
        r(pos.dx - 1, pos.dy + 3, 1, 2, blue);
      }
      r(15, 6, 2, 19, woodLight);
      r(8, 15, 16, 2, woodLight);
      r(3, 28, 26, 2, woodDark);
      r(3, 27, 26, 1, goldShade);
    } else if (slug.contains('bookshelf')) {
      panel(4, 3, 24, 26, wood, woodLight, woodDark);
      r(7, 6, 18, 20, woodDark);
      for (final y in [6, 14, 22]) {
        for (var j = 0; j < 4; j++) {
          final c = [green, red, purple, blue][j];
          r(8 + j * 4, y, 3, 5, c);
          r(8 + j * 4, y + 1, 2, 1, gold);
        }
        r(6, y + 6, 20, 2, woodLight);
      }
      r(4, 29, 24, 2, woodDark);
      r(5, 29, 22, 1, woodLight);
    } else if (slug.contains('chair')) {
      panel(8, 3, 16, 18, red, const Color(0xFFD28385), redDark);
      panel(6, 18, 20, 9, red, red, redDark);
      panel(4, 16, 5, 9, red, cream, redDark);
      panel(23, 16, 5, 9, red, cream, redDark);
      r(8, 27, 3, 4, wood);
      r(21, 27, 3, 4, wood);
      for (final x in [12, 19]) for (final y in [9, 14]) r(x, y, 1, 1, gold);
    } else if (slug.contains('table')) {
      panel(3, 17, 26, 4, wood, woodLight, woodDark);
      r(6, 21, 3, 9, wood);
      r(23, 21, 3, 9, wood);
      r(7, 22, 1, 5, goldShade);
      r(24, 22, 1, 5, goldShade);
      panel(6, 12, 12, 4, green, green, greenDark);
      r(7, 14, 10, 1, cream);
      panel(8, 8, 12, 4, red, red, redDark);
      r(9, 10, 10, 1, cream);
      r(24, 6, 2, 11, cream);
      r(22, 16, 6, 1, gold);
      r(24, 3, 2, 3, gold);
    } else if (slug == 'hearth-fern') {
      panel(10, 22, 12, 7, woodLight, gold, wood);
      r(9, 21, 14, 2, gold);
      r(15, 5, 2, 17, greenDark);
      for (final y in [7, 11, 15, 19]) {
        r(10, y - 2, 5, 2, green);
        r(7, y - 4, 4, 2, mint);
        r(17, y - 1, 5, 2, green);
        r(21, y - 3, 4, 2, mint);
      }
      r(15, 3, 2, 4, mint);
    } else if (slug == 'fern-study' ||
        slug == 'celestial-study' ||
        slug == 'moonlit-woodland') {
      final landscape = slug == 'moonlit-woodland';
      panel(
        landscape ? 2 : 7,
        4,
        landscape ? 28 : 18,
        24,
        wood,
        woodLight,
        woodDark,
      );
      r(landscape ? 4 : 9, 6, landscape ? 24 : 14, 20, gold);
      r(
        landscape ? 5 : 10,
        7,
        landscape ? 22 : 12,
        18,
        slug == 'fern-study' ? cream : const Color(0xFF293B61),
      );
      if (slug == 'fern-study') {
        r(15, 9, 1, 14, greenDark);
        for (final y in [11, 15, 19]) {
          r(12, y - 1, 3, 2, green);
          r(16, y, 3, 2, green);
        }
      } else {
        r(18, 9, 5, 5, cream);
        r(20, 9, 4, 4, const Color(0xFF293B61));
        star(12, 11, gold);
        if (landscape) {
          r(7, 17, 5, 7, greenDark);
          r(8, 14, 3, 5, green);
          r(16, 20, 9, 4, green);
        } else {
          star(13, 19, gold);
          r(19, 22, 1, 1, cream);
        }
      }
    } else if (slug == 'first-journey-trophy' ||
        slug == 'starlit-orrery' ||
        slug.contains('compass') ||
        slug.contains('map')) {
      final orrery = slug == 'starlit-orrery';
      r(8, 27, 16, 3, wood);
      r(10, 25, 12, 2, gold);
      r(15, 20, 2, 6, goldShade);
      for (var a = 0; a < 24; a++) {
        final angle = a * math.pi / 12;
        r(
          (16 + 10 * math.cos(angle)).round(),
          (14 + 10 * math.sin(angle)).round(),
          2,
          2,
          goldShade,
        );
      }
      if (orrery) {
        r(7, 13, 20, 2, gold);
        r(15, 5, 2, 19, gold);
        gem(14, 12, blue);
        gem(6, 8, mint);
        gem(23, 16, purple);
      } else {
        r(15, 7, 2, 14, gold);
        r(9, 13, 14, 2, gold);
        r(14, 10, 4, 7, cream);
        r(15, 8, 2, 7, red);
      }
    } else {
      gem(14, 12, gold);
      star(8, 8, mint);
      star(23, 22, blue);
    }
    if (locked) r(0, 0, 32, 32, const Color(0x55314349));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant QuestwellItemIconPainter oldDelegate) =>
      oldDelegate.slug != slug || oldDelegate.locked != locked;
}
