import 'package:flutter/material.dart';

/// Small, shared Hearth illustrations. Scene and catalog artwork are unchanged.
class QuestwellHearthIcon extends StatelessWidget {
  const QuestwellHearthIcon({super.key, required this.kind, this.size = 32});
  final String kind;
  final double size;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
      child: SizedBox.square(
          dimension: size,
          child:
              ClipRect(child: CustomPaint(painter: _HearthIconPainter(kind)))));
}

class _HearthIconPainter extends CustomPainter {
  const _HearthIconPainter(this.kind);
  final String kind;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 64, size.height / 64);
    final p = Paint()..isAntiAlias = true;
    void rect(double x, double y, double w, double h, Color color) {
      p
        ..shader = null
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), p);
    }

    void shape(List<Offset> points, List<Color> colors) {
      final path = Path()..addPolygon(points, true);
      p
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ).createShader(path.getBounds());
      canvas.drawPath(path, p);
      p
        ..shader = null
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFF6B4729);
      canvas.drawPath(path, p);
    }

    p.color = const Color(0x44000000);
    canvas.drawOval(const Rect.fromLTWH(8, 54, 48, 7), p);
    if (kind == 'coin' || kind.startsWith('class_')) {
      // Faceted brass rims share the same light direction as the Hearth frames.
      const rim = [
        Offset(20, 5),
        Offset(44, 5),
        Offset(58, 19),
        Offset(58, 43),
        Offset(44, 57),
        Offset(20, 57),
        Offset(6, 43),
        Offset(6, 19)
      ];
      shape(rim, const [Color(0xFFFFE7A1), Color(0xFFAA7134)]);
      shape(
          const [
            Offset(22, 11),
            Offset(42, 11),
            Offset(52, 21),
            Offset(52, 41),
            Offset(42, 51),
            Offset(22, 51),
            Offset(12, 41),
            Offset(12, 21)
          ],
          kind == 'coin'
              ? const [Color(0xFFF9D571), Color(0xFFC48B35)]
              : const [Color(0xFF376B59), Color(0xFF142F2C)]);
      if (kind == 'coin') {
        shape(const [
          Offset(28, 16),
          Offset(36, 16),
          Offset(36, 46),
          Offset(28, 46)
        ], const [
          Color(0xFFFFEBAA),
          Color(0xFFB67A2B)
        ]);
        rect(18, 21, 2, 17, const Color(0xFFF9E3A0));
      } else if (kind == 'class_scout') {
        rect(30, 14, 3, 34, const Color(0xFF102825));
        rect(16, 30, 32, 3, const Color(0xFF102825));
        shape(const [Offset(39, 16), Offset(34, 34), Offset(25, 30)],
            const [Color(0xFFFFEDBF), Color(0xFFCFB67D)]);
        shape(const [Offset(25, 46), Offset(25, 30), Offset(34, 34)],
            const [Color(0xFF9AD1B1), Color(0xFF49947B)]);
      } else if (kind == 'class_scholar') {
        shape(const [
          Offset(17, 21),
          Offset(31, 24),
          Offset(31, 44),
          Offset(17, 41)
        ], const [
          Color(0xFFFFEDC1),
          Color(0xFFD9B982)
        ]);
        shape(const [
          Offset(33, 24),
          Offset(47, 21),
          Offset(47, 41),
          Offset(33, 44)
        ], const [
          Color(0xFFFFEDC1),
          Color(0xFFD9B982)
        ]);
        for (final y in [28.0, 34.0]) {
          rect(20, y, 7, 2, const Color(0xFF94764E));
          rect(37, y, 7, 2, const Color(0xFF94764E));
        }
      } else if (kind == 'class_alchemist') {
        shape(const [
          Offset(26, 18),
          Offset(38, 18),
          Offset(37, 28),
          Offset(45, 40),
          Offset(42, 46),
          Offset(22, 46),
          Offset(19, 40),
          Offset(27, 28)
        ], const [
          Color(0xFFE1EFE0),
          Color(0xFF96B8BE)
        ]);
        shape(const [
          Offset(25, 34),
          Offset(39, 34),
          Offset(42, 42),
          Offset(22, 42)
        ], const [
          Color(0xFF8ACAE2),
          Color(0xFF4E75B3)
        ]);
        rect(25, 16, 14, 4, const Color(0xFFD6AB65));
      } else if (kind == 'class_guardian') {
        shape(const [
          Offset(20, 19),
          Offset(44, 19),
          Offset(44, 35),
          Offset(32, 47),
          Offset(20, 35)
        ], const [
          Color(0xFFE7C283),
          Color(0xFFAC733D)
        ]);
        shape(const [
          Offset(24, 23),
          Offset(40, 23),
          Offset(40, 33),
          Offset(32, 41),
          Offset(24, 33)
        ], const [
          Color(0xFFB36970),
          Color(0xFF793F52)
        ]);
        rect(30, 24, 4, 15, const Color(0xFFFFE8B5));
        rect(26, 28, 12, 4, const Color(0xFFFFE8B5));
      } else {
        shape(const [
          Offset(17, 23),
          Offset(27, 19),
          Offset(37, 23),
          Offset(47, 19),
          Offset(47, 42),
          Offset(37, 46),
          Offset(27, 42),
          Offset(17, 46)
        ], const [
          Color(0xFFFFEDC1),
          Color(0xFFC9A46D)
        ]);
        rect(26, 23, 2, 18, const Color(0xFFA8834D));
        rect(36, 25, 2, 17, const Color(0xFFA8834D));
        rect(21, 32, 21, 3, const Color(0xFF577B60));
        rect(39, 27, 3, 8, const Color(0xFF577B60));
      }
    } else if (kind == 'xp') {
      shape(
          const [Offset(32, 4), Offset(53, 25), Offset(32, 59), Offset(11, 25)],
          const [Color(0xFFE2C7FF), Color(0xFF7846AC)]);
      shape(const [Offset(32, 4), Offset(32, 59), Offset(21, 25)],
          const [Color(0xFFC09AEF), Color(0xFF9161CB)]);
      shape(const [Offset(32, 4), Offset(43, 25), Offset(32, 59)],
          const [Color(0xFFF0DFFF), Color(0xFFAB7CD7)]);
    } else if (kind == 'chronicle' ||
        kind == 'adventurer' ||
        kind == 'boss' ||
        kind == 'bosses' ||
        kind == 'market' ||
        kind == 'campfire') {
      if (kind == 'chronicle') {
        shape(const [
          Offset(10, 11),
          Offset(30, 15),
          Offset(32, 20),
          Offset(35, 15),
          Offset(55, 11),
          Offset(55, 53),
          Offset(34, 57),
          Offset(30, 57),
          Offset(10, 53)
        ], const [
          Color(0xFFB8814D),
          Color(0xFF634329)
        ]);
        shape(const [
          Offset(14, 10),
          Offset(29, 14),
          Offset(30, 50),
          Offset(14, 46)
        ], const [
          Color(0xFFFFEDC1),
          Color(0xFFD9B982)
        ]);
        shape(const [
          Offset(34, 14),
          Offset(51, 10),
          Offset(51, 46),
          Offset(34, 50)
        ], const [
          Color(0xFFFFEDC1),
          Color(0xFFD9B982)
        ]);
        for (final y in [23.0, 31.0, 39.0]) {
          rect(18, y, 8, 2, const Color(0xFF94764E));
          rect(38, y, 9, 2, const Color(0xFF94764E));
        }
      } else if (kind == 'adventurer') {
        shape(const [
          Offset(9, 56),
          Offset(15, 41),
          Offset(25, 36),
          Offset(39, 36),
          Offset(49, 41),
          Offset(55, 56)
        ], const [
          Color(0xFF91AC79),
          Color(0xFF365B44)
        ]);
        shape(const [
          Offset(21, 12),
          Offset(32, 6),
          Offset(44, 14),
          Offset(45, 28),
          Offset(38, 38),
          Offset(25, 38),
          Offset(18, 27)
        ], const [
          Color(0xFFEDC899),
          Color(0xFFB17B51)
        ]);
        shape(const [
          Offset(18, 23),
          Offset(20, 10),
          Offset(31, 5),
          Offset(43, 11),
          Offset(46, 22),
          Offset(36, 15),
          Offset(28, 20)
        ], const [
          Color(0xFFB27A46),
          Color(0xFF5B3929)
        ]);
        rect(24, 25, 3, 3, const Color(0xFF483225));
        rect(36, 25, 3, 3, const Color(0xFF483225));
        rect(30, 44, 4, 6, const Color(0xFFE3C07C));
      } else if (kind == 'boss' || kind == 'bosses') {
        shape(const [
          Offset(10, 10),
          Offset(54, 10),
          Offset(53, 35),
          Offset(43, 49),
          Offset(32, 58),
          Offset(21, 49),
          Offset(11, 35)
        ], const [
          Color(0xFFFFE3A0),
          Color(0xFF9C6739)
        ]);
        shape(const [
          Offset(17, 17),
          Offset(47, 17),
          Offset(46, 33),
          Offset(39, 43),
          Offset(32, 49),
          Offset(25, 43),
          Offset(18, 33)
        ], const [
          Color(0xFFAB6871),
          Color(0xFF623643)
        ]);
        shape(const [
          Offset(32, 19),
          Offset(39, 31),
          Offset(32, 42),
          Offset(25, 31)
        ], const [
          Color(0xFFFFE3A0),
          Color(0xFFCF9C53)
        ]);
      } else if (kind == 'market') {
        shape(const [
          Offset(11, 27),
          Offset(53, 27),
          Offset(53, 56),
          Offset(11, 56)
        ], const [
          Color(0xFFE6C38B),
          Color(0xFFA97945)
        ]);
        shape(const [
          Offset(14, 10),
          Offset(50, 10),
          Offset(59, 28),
          Offset(5, 28)
        ], const [
          Color(0xFF93AF85),
          Color(0xFF315E47)
        ]);
        rect(18, 12, 6, 15, const Color(0xFFEAD29B));
        rect(38, 12, 6, 15, const Color(0xFFEAD29B));
        rect(17, 35, 13, 12, const Color(0xFF466453));
        rect(36, 34, 10, 22, const Color(0xFF62492E));
        rect(8, 54, 48, 4, const Color(0xFFC79957));
      } else {
        shape(const [
          Offset(12, 49),
          Offset(16, 43),
          Offset(53, 54),
          Offset(49, 60)
        ], const [
          Color(0xFFAA7845),
          Color(0xFF62412A)
        ]);
        shape(const [
          Offset(12, 54),
          Offset(49, 43),
          Offset(53, 49),
          Offset(16, 60)
        ], const [
          Color(0xFFAA7845),
          Color(0xFF62412A)
        ]);
        shape(const [
          Offset(14, 39),
          Offset(22, 21),
          Offset(24, 30),
          Offset(34, 4),
          Offset(39, 22),
          Offset(44, 17),
          Offset(51, 39),
          Offset(44, 49),
          Offset(25, 51)
        ], const [
          Color(0xFFFFCF58),
          Color(0xFFD75E26)
        ]);
        shape(const [
          Offset(24, 42),
          Offset(33, 24),
          Offset(36, 36),
          Offset(40, 30),
          Offset(43, 44),
          Offset(34, 49)
        ], const [
          Color(0xFFFFEFBA),
          Color(0xFFFFAD3E)
        ]);
      }
    } else if (kind == 'hearth') {
      rect(43, 10, 7, 20, const Color(0xFF916138));
      shape(const [
        Offset(14, 28),
        Offset(32, 12),
        Offset(50, 28),
        Offset(50, 55),
        Offset(14, 55)
      ], const [
        Color(0xFFFFE9B0),
        Color(0xFFD2A05C)
      ]);
      shape(const [
        Offset(5, 29),
        Offset(32, 5),
        Offset(59, 29),
        Offset(54, 35),
        Offset(32, 16),
        Offset(10, 35)
      ], const [
        Color(0xFFFFE29B),
        Color(0xFFB87937)
      ]);
      rect(25, 35, 14, 20, const Color(0xFF674329));
      rect(28, 37, 8, 18, const Color(0xFFFFD477));
      rect(17, 33, 5, 7, const Color(0xFFF8F0BC));
      rect(42, 33, 5, 7, const Color(0xFFF8F0BC));
      rect(23, 55, 18, 3, const Color(0xFFEDC58A));
      rect(34, 46, 2, 2, const Color(0xFF7D522C));
    } else if (kind == 'quests') {
      shape(
          const [Offset(13, 9), Offset(50, 9), Offset(53, 55), Offset(13, 57)],
          const [Color(0xFFB7874E), Color(0xFF684526)]);
      shape(const [
        Offset(17, 13),
        Offset(46, 13),
        Offset(46, 46),
        Offset(40, 53),
        Offset(17, 53)
      ], const [
        Color(0xFFFFEDC1),
        Color(0xFFD9B982)
      ]);
      shape(const [Offset(40, 46), Offset(48, 46), Offset(40, 54)],
          const [Color(0xFFFDF0CA), Color(0xFFBD945C)]);
      shape(const [
        Offset(24, 8),
        Offset(28, 8),
        Offset(28, 4),
        Offset(36, 4),
        Offset(36, 8),
        Offset(40, 8),
        Offset(40, 17),
        Offset(24, 17)
      ], const [
        Color(0xFFF2D58E),
        Color(0xFFA7753D)
      ]);
      for (final y in [25.0, 34.0, 43.0]) {
        rect(22, y, 4, 4, const Color(0xFF916039));
        rect(30, y + 1, 11, 1.5, const Color(0xFF8F714C));
      }
    } else {
      shape(const [Offset(3, 53), Offset(25, 12), Offset(49, 53)],
          const [Color(0xFFE0D5BC), Color(0xFF9D917E)]);
      shape(const [
        Offset(25, 12),
        Offset(49, 53),
        Offset(25, 45),
        Offset(18, 36)
      ], const [
        Color(0xFF968C7E),
        Color(0xFF5D5C56)
      ]);
      shape(const [
        Offset(17, 26),
        Offset(25, 12),
        Offset(33, 26),
        Offset(26, 23),
        Offset(22, 28)
      ], const [
        Color(0xFFF5EDD6),
        Color(0xFFDCD2B7)
      ]);
      for (final tree in [const Offset(45, 23), const Offset(52, 29)]) {
        rect(tree.dx - 2, tree.dy + 20, 4, 14, const Color(0xFFA07746));
        shape([
          Offset(tree.dx, tree.dy),
          Offset(tree.dx - 7, tree.dy + 13),
          Offset(tree.dx - 4, tree.dy + 13),
          Offset(tree.dx - 11, tree.dy + 26),
          Offset(tree.dx + 11, tree.dy + 26),
          Offset(tree.dx + 4, tree.dy + 13),
          Offset(tree.dx + 7, tree.dy + 13)
        ], const [
          Color(0xFF9BA88B),
          Color(0xFF4D6855)
        ]);
      }
      rect(9, 12, 3, 9, const Color(0xFFE8CE93));
      rect(6, 15, 9, 3, const Color(0xFFE8CE93));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HearthIconPainter oldDelegate) =>
      kind != oldDelegate.kind;
}
