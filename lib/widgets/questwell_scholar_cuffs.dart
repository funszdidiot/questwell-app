import 'dart:math' as math;
import 'package:flutter/material.dart';

// Registered on the approved 240 x 320 garment canvas. Source art stays intact.
List<Rect> _cuffs(String body) => switch (body) {
  'female' => const [Rect.fromLTWH(66, 161, 20, 15), Rect.fromLTWH(153, 161, 20, 15)],
  'male' => const [Rect.fromLTWH(57, 164, 25, 15), Rect.fromLTWH(155, 164, 25, 15)],
  _ => const [Rect.fromLTWH(61, 164, 23, 16), Rect.fromLTWH(154, 164, 25, 16)],
};

/// Remove the old flat trim, including its underside, on every robe pass.
class ScholarCuffReplacementClipper extends CustomClipper<Path> {
  const ScholarCuffReplacementClipper(this.body);
  final String body;
  @override
  Path getClip(Size size) {
    final scale = math.min(size.width / 240, size.height / 320);
    final dx = (size.width - 240 * scale) / 2;
    final dy = size.height - 320 * scale;
    final path = Path()..fillType = PathFillType.evenOdd..addRect(Offset.zero & size);
    for (final cuff in _cuffs(body)) {
      path.addRect(Rect.fromLTWH(dx + cuff.left * scale, dy + (cuff.top + 1) * scale,
        cuff.width * scale, (cuff.height + 1) * scale));
    }
    return path;
  }
  @override
  bool shouldReclip(covariant ScholarCuffReplacementClipper oldClipper) => oldClipper.body != body;
}

class QuestwellScholarCuffs extends StatelessWidget {
  const QuestwellScholarCuffs({super.key, required this.body});
  final String body;
  @override
  Widget build(BuildContext context) => IgnorePointer(child: ExcludeSemantics(
    child: CustomPaint(painter: _ScholarCuffPainter(body))));
}

class _ScholarCuffPainter extends CustomPainter {
  const _ScholarCuffPainter(this.body);
  final String body;
  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 240, size.height / 320);
    canvas.save();
    canvas.translate((size.width - 240 * scale) / 2, size.height - 320 * scale);
    canvas.scale(scale);
    for (final cuff in _cuffs(body)) {
      canvas.save();
      canvas.translate(cuff.left, cuff.top);
      canvas.scale(cuff.width / 24, cuff.height / 15);
      canvas.saveLayer(const Rect.fromLTWH(-1, -5, 26, 22), Paint());
      final right = cuff.left > 120;
      final curve = right ? 2.8 : 3.5;
      // A tapered sleeve flows into a cylindrical cuff. The front edge dips
      // below the side returns; the dark opening remains above the knuckles.
      final sleeve = Path()..moveTo(3, -4)..lineTo(21, -4)
        ..lineTo(24, 10)..quadraticBezierTo(24, 12, 22, 13)
        ..quadraticBezierTo(12, 16, 2, 13)
        ..quadraticBezierTo(0, 12, 0, 10)..close();
      canvas.drawPath(sleeve, Paint()..shader = const LinearGradient(
        colors: [Color(0xFF17152D), Color(0xFF393752), Color(0xFF29243E), Color(0xFF151225)],
        stops: [0, .32, .68, 1],
      ).createShader(const Rect.fromLTWH(0, 0, 24, 15)));
      // Recessed lining and front lip occlude the wrist instead of ending flat.
      canvas.drawOval(const Rect.fromLTWH(1, 10, 22, 5), Paint()..color = const Color(0xFF100E1E));
      for (final y in [6.0, 10.8]) {
        final trim = Path()..moveTo(.8, y)..cubicTo(5, y + curve, 19, y + curve, 23.2, y);
        canvas.drawPath(trim, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.2
          ..color = const Color(0xFF694523));
        canvas.drawPath(trim, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.1
          ..shader = const LinearGradient(colors: [Color(0xFF947039), Color(0xFFF0D287), Color(0xFFC89943), Color(0xFF75502C)],
            stops: [0, .35, .7, 1]).createShader(const Rect.fromLTWH(0, 0, 24, 15)));
      }
      final star = Path()..moveTo(12, 5.5)..lineTo(13, 8.2)..lineTo(15, 9.2)
        ..lineTo(13, 10.2)..lineTo(12, 12.5)..lineTo(11, 10.2)
        ..lineTo(9, 9.2)..lineTo(11, 8.2)..close();
      canvas.drawPath(star, Paint()..color = const Color(0xFFD5AD5F));
      canvas.drawLine(const Offset(12, 7), const Offset(12, 10.5),
        Paint()..strokeWidth = .6..color = const Color(0xFFF6DB96));
      // Feather into the original sleeve texture over five source pixels.
      // This retains the cloth folds instead of leaving a straight patch seam.
      canvas.drawRect(const Rect.fromLTWH(-1, -5, 26, 22), Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.white, Colors.white],
          stops: [0, .263, 1]).createShader(const Rect.fromLTWH(0, -4, 24, 19)));
      canvas.restore();
      canvas.restore();
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _ScholarCuffPainter oldDelegate) => oldDelegate.body != body;
}
