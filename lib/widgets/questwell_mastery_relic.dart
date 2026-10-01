import 'dart:math' as math;
import 'package:flutter/material.dart';

/// One collectible design shared by mastery, inventory, and the Hearth.
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
    child: SizedBox.square(dimension: size, child: CustomPaint(
      painter: QuestwellMasteryRelicPainter(archetype))),
  );
}

/// A furniture-sized display; its base rests on the room's existing floor slots.
class QuestwellMasteryDisplay extends StatelessWidget {
  const QuestwellMasteryDisplay({super.key, required this.archetype});
  final String archetype;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) =>
    Stack(fit: StackFit.expand, children: [
      const CustomPaint(painter: _MasteryPedestalPainter()),
      Positioned(top: 0, left: 0, right: 0, height: constraints.maxHeight * .60,
        child: QuestwellMasteryRelic(archetype: archetype)),
    ]));
}

class _MasteryPedestalPainter extends CustomPainter {
  const _MasteryPedestalPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 128, size.height / 192);
    final p = Paint();
    void rect(double x, double y, double w, double h, int color) {
      p.color = Color(color);
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), p);
    }
    rect(28, 107, 72, 8, 0xFFB6894D);
    rect(31, 107, 66, 2, 0xFFE9C77E);
    rect(34, 115, 60, 62, 0xFF392E2D);
    rect(39, 117, 50, 58, 0xFF574032);
    rect(46, 121, 36, 47, 0xFF342B29);
    rect(48, 123, 32, 43, 0xFF65503C);
    rect(39, 116, 3, 59, 0xFF9C7546);
    rect(87, 116, 3, 59, 0xFF805C3B);
    rect(31, 175, 66, 6, 0xFFAC8247);
    rect(26, 181, 76, 7, 0xFF3C2C26);
    rect(27, 181, 74, 2, 0xFFBA9254);
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _MasteryPedestalPainter oldDelegate) => false;
}

class QuestwellMasteryRelicPainter extends CustomPainter {
  const QuestwellMasteryRelicPainter(this.archetype);
  final String archetype;
  static const ink = Color(0xFF251D27);
  static const brass = Color(0xFFA77739);
  static const gold = Color(0xFFE9C77E);
  static const light = Color(0xFFFFECC0);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final unit = math.min(size.width, size.height) / 128;
    canvas.translate((size.width - 128 * unit) / 2, (size.height - 128 * unit) / 2);
    canvas.scale(unit);
    final p = Paint()..isAntiAlias = true;
    void rect(double x, double y, double w, double h, Color color) {
      p..color = color..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), p);
    }
    void line(double x, double y, double x2, double y2, Color color, [double width = 2]) {
      p..color = color..strokeWidth = width..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(x, y), Offset(x2, y2), p);
      p.style = PaintingStyle.fill;
    }
    void circle(double x, double y, double r, Color color) {
      p..color = color..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), r, p);
    }
    void shape(List<Offset> points, Color color) {
      final path = Path()..addPolygon(points, true);
      p..color = color..style = PaintingStyle.fill;
      canvas.drawPath(path, p);
    }
    // Every relic rests on the same walnut and brass collector's plinth.
    p.color = const Color(0x33000000);
    canvas.drawOval(const Rect.fromLTWH(21, 114, 86, 9), p);
    rect(27, 102, 74, 13, ink);
    rect(30, 103, 68, 7, const Color(0xFF67442E));
    rect(27, 100, 74, 4, brass);
    rect(30, 100, 68, 1.5, gold);
    rect(24, 113, 80, 5, const Color(0xFF3B2924));
    rect(25, 113, 78, 1.5, brass);
    rect(54, 105, 20, 7, brass);
    rect(57, 106, 14, 2, gold);

    switch (archetype) {
      case 'scholar':
        // Gilt archive seal, mounted in burgundy enamel.
        rect(59, 79, 10, 21, brass);
        rect(49, 97, 30, 3, gold);
        circle(64, 49, 39, ink);
        circle(64, 48, 36, brass);
        circle(64, 47, 32, gold);
        circle(64, 47, 28, const Color(0xFF652E46));
        circle(64, 47, 24, const Color(0xFF432333));
        for (var i = 0; i < 16; i++) {
          final a = i * math.pi / 8;
          circle(64 + 32 * math.cos(a), 47 + 32 * math.sin(a), 1.3, light);
        }
        shape(const [Offset(41,34),Offset(60,37),Offset(64,41),Offset(68,37),Offset(87,34),Offset(87,64),Offset(68,67),Offset(64,70),Offset(60,67),Offset(41,64)], brass);
        shape(const [Offset(44,36),Offset(61,40),Offset(62,64),Offset(44,61)], light);
        shape(const [Offset(66,40),Offset(84,36),Offset(84,61),Offset(66,64)], const Color(0xFFE4C98A));
        line(64,41,64,67,ink);
        for (var y = 45.0; y < 58; y += 5) {
          line(48,y,58,y+2,brass,1);
          line(70,y+2,80,y,brass,1);
        }
        circle(64,23,3,const Color(0xFFB787D9));
        break;
      case 'scout':
        rect(59, 79, 10, 21, brass);
        rect(49, 97, 30, 3, gold);
        circle(64, 46, 38, ink);
        circle(64, 45, 35, brass);
        circle(64, 44, 31, gold);
        circle(64, 44, 27, const Color(0xFF193F3B));
        circle(64, 44, 22, const Color(0xFF28534A));
        for (var i = 0; i < 16; i++) {
          final a = i * math.pi / 8;
          line(64+24*math.cos(a),44+24*math.sin(a),
            64+(i%4==0?18:21)*math.cos(a),44+(i%4==0?18:21)*math.sin(a),gold,1.5);
        }
        shape(const [Offset(64,19),Offset(70,44),Offset(64,69),Offset(58,44)], light);
        shape(const [Offset(64,19),Offset(70,44),Offset(64,45)], const Color(0xFFD98565));
        shape(const [Offset(42,44),Offset(64,38),Offset(86,44),Offset(64,50)], brass);
        circle(64,44,4,ink); circle(64,43,2.5,gold);
        line(44,23,51,19,light);
        break;
      case 'alchemist':
        rect(42,92,44,8,brass);
        rect(37,87,5,11,gold); rect(86,87,5,11,gold);
        final glass = Path()..moveTo(53,26)..lineTo(75,26)..lineTo(75,42)
          ..cubicTo(100,60,99,91,78,96)..lineTo(50,96)
          ..cubicTo(29,91,28,60,53,42)..close();
        p.color = ink; canvas.drawPath(glass,p);
        canvas.save(); canvas.clipPath(glass);
        p.shader = const LinearGradient(colors:[Color(0xFF387B78),Color(0xFF91CAB4),Color(0xFF25514C)])
          .createShader(const Rect.fromLTWH(36,26,56,70));
        canvas.drawRect(const Rect.fromLTWH(38,28,52,66),p); p.shader=null;
        p.color=const Color(0xFF3B946B);
        canvas.drawOval(const Rect.fromLTWH(38,60,52,18),p);
        rect(37,69,54,27,const Color(0xFF2F745B));
        circle(71,76,5,const Color(0xFFB3DF8C));
        circle(56,84,3,const Color(0xFF86BE78));
        line(47,57,44,73,light,3); line(60,30,60,43,light,2);
        canvas.restore();
        rect(49,23,30,7,brass); rect(51,23,26,2,light);
        rect(55,13,18,10,ink); rect(57,14,14,8,const Color(0xFF946A48));
        rect(49,48,30,5,brass);
        shape(const [Offset(64,51),Offset(70,60),Offset(64,69),Offset(58,60)],gold);
        circle(64,60,3,const Color(0xFFBBE7B0));
        break;
      case 'guardian':
        rect(60,83,8,17,brass); rect(45,97,38,3,gold);
        shape(const [Offset(64,10),Offset(101,24),Offset(96,65),Offset(84,82),Offset(64,94),Offset(44,82),Offset(32,65),Offset(27,24)],ink);
        shape(const [Offset(64,14),Offset(97,27),Offset(92,64),Offset(80,80),Offset(64,89),Offset(48,80),Offset(36,64),Offset(31,27)],gold);
        shape(const [Offset(64,20),Offset(90,30),Offset(85,62),Offset(75,75),Offset(64,83),Offset(53,75),Offset(43,62),Offset(38,30)],const Color(0xFF713844));
        shape(const [Offset(64,20),Offset(90,30),Offset(85,62),Offset(75,75),Offset(64,83)],const Color(0xFF4C2938));
        rect(59,32,10,37,gold); rect(48,43,32,8,gold);
        shape(const [Offset(64,28),Offset(72,39),Offset(64,50),Offset(56,39)],light);
        circle(64,39,3,const Color(0xFF92B4DB));
        for (final pt in const [Offset(35,29),Offset(93,29),Offset(64,87)]) circle(pt.dx,pt.dy,2,light);
        break;
      default:
        rect(58,82,12,18,brass); rect(45,97,38,3,gold);
        shape(const [Offset(29,19),Offset(96,13),Offset(104,81),Offset(37,87)],ink);
        shape(const [Offset(32,22),Offset(93,17),Offset(100,78),Offset(40,83)],brass);
        shape(const [Offset(37,26),Offset(89,22),Offset(95,74),Offset(44,78)],const Color(0xFF24374F));
        line(44,58,58,39,gold,1.5); line(58,39,75,47,gold,1.5);
        line(75,47,84,31,gold,1.5); line(75,47,82,66,gold,1.5);
        line(44,58,61,69,gold,1.5); line(61,69,82,66,gold,1.5);
        for (final pt in const [Offset(44,58),Offset(58,39),Offset(75,47),Offset(84,31),Offset(82,66),Offset(61,69)]) {
          circle(pt.dx,pt.dy,2.8,gold); circle(pt.dx-.6,pt.dy-.6,1.2,light);
        }
        circle(49,34,1,light); circle(86,55,1,light); circle(68,28,1,light);
        line(40,79,98,74,light,1);
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant QuestwellMasteryRelicPainter oldDelegate) =>
      oldDelegate.archetype != archetype;
}
