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
