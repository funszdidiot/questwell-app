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
          child: CustomPaint(painter: _HearthIconPainter(kind))));
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
    if (kind == 'hearth') {
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
