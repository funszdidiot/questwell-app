import 'dart:math' as math;
import 'package:flutter/material.dart';

class QuestwellPixelPalette {
  const QuestwellPixelPalette._();

  static List<Color> forClass(String archetype) {
    switch (archetype) {
      case 'scholar':
        return const [Color(0xFF2D1B69), Color(0xFF6B4BB8), Color(0xFFF0C96A)];
      case 'scout':
        return const [Color(0xFF173B2B), Color(0xFF477A4C), Color(0xFFD6A84B)];
      case 'alchemist':
        return const [Color(0xFF0C4A4F), Color(0xFF2F9B8F), Color(0xFFB7E86A)];
      case 'guardian':
        return const [Color(0xFF5C1D1D), Color(0xFFA84432), Color(0xFFF1B24A)];
      default:
        return const [Color(0xFF1A2E5A), Color(0xFF3D5A9A), Color(0xFFF1C75B)];
    }
  }
}

class QuestwellPixelFrame extends StatelessWidget {
  const QuestwellPixelFrame({
    super.key,
    required this.child,
    this.height = 180,
    this.background = const Color(0xFF15141B),
  });

  final Widget child;
  final double height;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: const Color(0xFF8E6B35), width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x55000000), blurRadius: 0, offset: Offset(4, 4)),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: child),
          const _PixelCorner(alignment: Alignment.topLeft),
          const _PixelCorner(alignment: Alignment.topRight),
          const _PixelCorner(alignment: Alignment.bottomLeft),
          const _PixelCorner(alignment: Alignment.bottomRight),
        ],
      ),
    );
  }
}

class _PixelCorner extends StatelessWidget {
  const _PixelCorner({required this.alignment});
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 10,
        height: 10,
        color: const Color(0xFFF1C75B),
      ),
    );
  }
}

class QuestwellHearthPixelScene extends StatelessWidget {
  const QuestwellHearthPixelScene({super.key, this.height = 170});
  final double height;

  @override
  Widget build(BuildContext context) {
    return QuestwellPixelFrame(
      height: height,
      child: CustomPaint(painter: _HearthPainter()),
    );
  }
}

class QuestwellExpeditionPixelScene extends StatelessWidget {
  const QuestwellExpeditionPixelScene({
    super.key,
    this.height = 150,
    this.campfire = false,
  });

  final double height;
  final bool campfire;

  @override
  Widget build(BuildContext context) {
    return QuestwellPixelFrame(
      height: height,
      background: const Color(0xFF101827),
      child: CustomPaint(
        painter: _ExpeditionPainter(campfire: campfire),
      ),
    );
  }
}

class QuestwellClassPixelPortrait extends StatelessWidget {
  const QuestwellClassPixelPortrait({
    super.key,
    required this.archetype,
    this.height = 190,
    this.showRelic = false,
  });

  final String archetype;
  final double height;
  final bool showRelic;

  @override
  Widget build(BuildContext context) {
    final palette = QuestwellPixelPalette.forClass(archetype);
    return QuestwellPixelFrame(
      height: height,
      background: palette.first,
      child: CustomPaint(
        painter: _ClassPortraitPainter(
          archetype: archetype,
          palette: palette,
          showRelic: showRelic,
        ),
      ),
    );
  }
}

class QuestwellRelicPixelArt extends StatelessWidget {
  const QuestwellRelicPixelArt({
    super.key,
    required this.archetype,
    this.size = 72,
  });

  final String archetype;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _RelicPainter(
          archetype: archetype,
          palette: QuestwellPixelPalette.forClass(archetype),
        ),
      ),
    );
  }
}

class QuestwellBossPixelArt extends StatelessWidget {
  const QuestwellBossPixelArt({
    super.key,
    required this.bossType,
    this.height = 130,
  });

  final String bossType;
  final double height;

  @override
  Widget build(BuildContext context) {
    return QuestwellPixelFrame(
      height: height,
      background: const Color(0xFF14131A),
      child: CustomPaint(painter: _BossPainter(bossType)),
    );
  }
}

class _HearthPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    void rect(double x, double y, double w, double h, Color color) {
      p.color = color;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), p);
    }

    rect(0, 0, size.width, size.height, const Color(0xFF101827));
    rect(0, size.height * .62, size.width, size.height * .38, const Color(0xFF4A2D1D));

    // Moonlit window.
    rect(size.width * .66, 12, size.width * .28, size.height * .46, const Color(0xFF193B65));
    rect(size.width * .68, 14, size.width * .24, size.height * .42, const Color(0xFF315F8E));
    p.color = const Color(0xFFF7E58E);
    canvas.drawCircle(Offset(size.width * .85, 34), 12, p);

    // Fireplace.
    rect(size.width * .06, size.height * .25, size.width * .34, size.height * .60, const Color(0xFF6C442C));
    rect(size.width * .10, size.height * .38, size.width * .26, size.height * .37, const Color(0xFF1F1613));
    rect(size.width * .14, size.height * .58, size.width * .18, size.height * .13, const Color(0xFFEE7A24));
    rect(size.width * .18, size.height * .48, size.width * .10, size.height * .19, const Color(0xFFF6B83F));
    rect(size.width * .21, size.height * .43, size.width * .05, size.height * .20, const Color(0xFFFFE07A));

    // Bookshelf.
    rect(size.width * .44, size.height * .16, size.width * .17, size.height * .48, const Color(0xFF5A361F));
    for (var row = 0; row < 3; row++) {
      rect(size.width * .46, size.height * (.20 + row * .13), size.width * .13, 4, const Color(0xFFB98245));
      for (var book = 0; book < 5; book++) {
        final colors = [
          const Color(0xFF7A2830),
          const Color(0xFF285C4D),
          const Color(0xFF374F82),
          const Color(0xFF8B6530),
          const Color(0xFF6E3C72),
        ];
        rect(
          size.width * (.46 + book * .025),
          size.height * (.21 + row * .13),
          size.width * .018,
          size.height * .09,
          colors[(row + book) % colors.length],
        );
      }
    }

    // Rug + sleeping cat silhouette.
    rect(size.width * .46, size.height * .72, size.width * .30, size.height * .15, const Color(0xFF305449));
    rect(size.width * .54, size.height * .74, size.width * .14, size.height * .07, const Color(0xFFD38A43));
    rect(size.width * .64, size.height * .71, size.width * .04, size.height * .07, const Color(0xFFD38A43));

    // Lantern pixels.
    for (final x in [size.width * .43, size.width * .61, size.width * .94]) {
      rect(x, size.height * .08, 5, 20, const Color(0xFF7B4F24));
      rect(x - 5, size.height * .16, 15, 20, const Color(0xFFF1B64B));
      rect(x - 2, size.height * .19, 9, 9, const Color(0xFFFFE29A));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ExpeditionPainter extends CustomPainter {
  _ExpeditionPainter({required this.campfire});
  final bool campfire;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    void rect(double x, double y, double w, double h, Color color) {
      p.color = color;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), p);
    }

    rect(0, 0, size.width, size.height, const Color(0xFF101827));
    rect(0, size.height * .68, size.width, size.height * .32, const Color(0xFF203A2D));

    // Moon / sun.
    p.color = campfire ? const Color(0xFFE7D67A) : const Color(0xFFF4CB67);
    canvas.drawCircle(
      Offset(size.width * .80, size.height * .23),
      size.height * .11,
      p,
    );

    // Mountain silhouettes.
    final back = Path()
      ..moveTo(0, size.height * .70)
      ..lineTo(size.width * .18, size.height * .36)
      ..lineTo(size.width * .33, size.height * .67)
      ..lineTo(size.width * .50, size.height * .25)
      ..lineTo(size.width * .70, size.height * .68)
      ..lineTo(size.width, size.height * .42)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    p.color = const Color(0xFF31506A);
    canvas.drawPath(back, p);

    final front = Path()
      ..moveTo(0, size.height * .82)
      ..lineTo(size.width * .24, size.height * .58)
      ..lineTo(size.width * .42, size.height * .80)
      ..lineTo(size.width * .61, size.height * .52)
      ..lineTo(size.width * .80, size.height * .82)
      ..lineTo(size.width, size.height * .60)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    p.color = const Color(0xFF17362A);
    canvas.drawPath(front, p);

    // Trail.
    final trail = Path()
      ..moveTo(size.width * .38, size.height)
      ..quadraticBezierTo(
        size.width * .48,
        size.height * .79,
        size.width * .56,
        size.height * .68,
      )
      ..quadraticBezierTo(
        size.width * .62,
        size.height * .60,
        size.width * .66,
        size.height * .52,
      )
      ..lineTo(size.width * .70, size.height * .55)
      ..quadraticBezierTo(
        size.width * .61,
        size.height * .72,
        size.width * .55,
        size.height,
      )
      ..close();
    p.color = const Color(0xFFB98A4B);
    canvas.drawPath(trail, p);

    if (campfire) {
      rect(size.width * .15, size.height * .75, size.width * .12, 7, const Color(0xFF6B4528));
      rect(size.width * .19, size.height * .68, size.width * .06, size.height * .13, const Color(0xFFF09A2A));
      rect(size.width * .205, size.height * .63, size.width * .03, size.height * .14, const Color(0xFFFFD35A));
    }

    // Stars.
    for (var i = 0; i < 16; i++) {
      final x = (i * 43 % 91) / 91 * size.width;
      final y = (i * 29 % 57) / 57 * size.height * .42;
      rect(x, y, 2, 2, const Color(0xFFD7E6F7));
    }
  }

  @override
  bool shouldRepaint(covariant _ExpeditionPainter oldDelegate) =>
      oldDelegate.campfire != campfire;
}

class _ClassPortraitPainter extends CustomPainter {
  _ClassPortraitPainter({
    required this.archetype,
    required this.palette,
    required this.showRelic,
  });

  final String archetype;
  final List<Color> palette;
  final bool showRelic;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    void rect(double x, double y, double w, double h, Color color) {
      p.color = color;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), p);
    }

    rect(0, 0, size.width, size.height, palette.first);
    // Distant stars / particles.
    for (var i = 0; i < 16; i++) {
      final x = (i * 47 % 97) / 97 * size.width;
      final y = (i * 31 % 83) / 83 * size.height * .65;
      rect(x, y, 3, 3, palette.last.withValues(alpha: .65));
    }

    // Ground.
    rect(0, size.height * .76, size.width, size.height * .24, const Color(0xFF17151A));

    final cx = size.width * .50;
    // Body.
    rect(cx - 28, size.height * .40, 56, 72, palette[1]);
    rect(cx - 20, size.height * .29, 40, 42, const Color(0xFFD9A56E));
    rect(cx - 24, size.height * .25, 48, 14, const Color(0xFF2B241F));

    switch (archetype) {
      case 'scholar':
        // Hat + book.
        rect(cx - 33, size.height * .20, 66, 8, palette.last);
        rect(cx - 18, size.height * .11, 36, 42, palette[1]);
        rect(cx + 26, size.height * .48, 34, 26, const Color(0xFF6B3C84));
        rect(cx + 30, size.height * .50, 26, 4, palette.last);
        break;
      case 'scout':
        // Hood + bow.
        rect(cx - 27, size.height * .18, 54, 18, const Color(0xFF375E37));
        rect(cx - 35, size.height * .38, 14, 74, const Color(0xFF6A4A2A));
        p.color = palette.last;
        canvas.drawArc(
          Rect.fromCenter(center: Offset(cx + 48, size.height * .52), width: 45, height: 85),
          -1.3,
          2.6,
          false,
          p..style = PaintingStyle.stroke..strokeWidth = 4,
        );
        p.style = PaintingStyle.fill;
        break;
      case 'alchemist':
        // Goggles + flask.
        rect(cx - 24, size.height * .28, 20, 9, palette.last);
        rect(cx + 4, size.height * .28, 20, 9, palette.last);
        rect(cx + 32, size.height * .48, 10, 30, const Color(0xFFB8EAF1));
        rect(cx + 25, size.height * .62, 25, 24, const Color(0xFF75D65D));
        break;
      case 'guardian':
        // Shield + cape.
        rect(cx - 45, size.height * .38, 18, 88, const Color(0xFF742525));
        rect(cx + 28, size.height * .44, 42, 62, const Color(0xFF9C4A2F));
        rect(cx + 33, size.height * .49, 32, 42, palette.last);
        break;
      default:
        // Pack + staff.
        rect(cx - 50, size.height * .42, 23, 64, const Color(0xFF6D5333));
        rect(cx + 42, size.height * .24, 5, 115, palette.last);
        rect(cx + 35, size.height * .20, 20, 8, palette.last);
    }

    if (showRelic) {
      final relic = _RelicPainter(archetype: archetype, palette: palette);
      canvas.save();
      canvas.translate(size.width * .69, size.height * .58);
      relic.paint(canvas, Size(size.width * .25, size.width * .25));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ClassPortraitPainter oldDelegate) =>
      oldDelegate.archetype != archetype || oldDelegate.showRelic != showRelic;
}

class _RelicPainter extends CustomPainter {
  _RelicPainter({required this.archetype, required this.palette});
  final String archetype;
  final List<Color> palette;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    final c = Offset(size.width / 2, size.height / 2);

    p.color = const Color(0x33111111);
    canvas.drawCircle(c, size.shortestSide * .46, p);
    p.color = palette.last;
    canvas.drawCircle(c, size.shortestSide * .34, p);
    p.color = palette[1];
    canvas.drawCircle(c, size.shortestSide * .25, p);
    p.color = const Color(0xFF17151A);

    switch (archetype) {
      case 'scholar':
        canvas.drawRect(
          Rect.fromCenter(center: c, width: size.width * .34, height: size.height * .42),
          p,
        );
        p.color = palette.last;
        canvas.drawRect(
          Rect.fromCenter(center: c, width: size.width * .06, height: size.height * .26),
          p,
        );
        break;
      case 'scout':
        p.style = PaintingStyle.stroke;
        p.strokeWidth = 4;
        canvas.drawCircle(c, size.shortestSide * .18, p);
        canvas.drawLine(Offset(c.dx, c.dy - 17), Offset(c.dx + 10, c.dy + 11), p);
        p.style = PaintingStyle.fill;
        break;
      case 'alchemist':
        canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy - 11), width: 8, height: 14), p);
        canvas.drawCircle(Offset(c.dx, c.dy + 7), size.shortestSide * .16, p);
        break;
      case 'guardian':
        final path = Path()
          ..moveTo(c.dx, c.dy - 20)
          ..lineTo(c.dx + 17, c.dy - 10)
          ..lineTo(c.dx + 12, c.dy + 18)
          ..lineTo(c.dx, c.dy + 26)
          ..lineTo(c.dx - 12, c.dy + 18)
          ..lineTo(c.dx - 17, c.dy - 10)
          ..close();
        canvas.drawPath(path, p);
        break;
      default:
        p.style = PaintingStyle.stroke;
        p.strokeWidth = 4;
        canvas.drawCircle(c, size.shortestSide * .18, p);
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          canvas.drawLine(
            Offset(c.dx + math.cos(a) * 10, c.dy + math.sin(a) * 10),
            Offset(c.dx + math.cos(a) * 22, c.dy + math.sin(a) * 22),
            p,
          );
        }
        p.style = PaintingStyle.fill;
    }
  }

  @override
  bool shouldRepaint(covariant _RelicPainter oldDelegate) =>
      oldDelegate.archetype != archetype;
}

class _BossPainter extends CustomPainter {
  _BossPainter(this.bossType);
  final String bossType;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    void rect(double x, double y, double w, double h, Color color) {
      p.color = color;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), p);
    }

    rect(0, 0, size.width, size.height, const Color(0xFF14131A));
    final violet = const Color(0xFF5B2C83);
    final ember = const Color(0xFFE06B2D);
    final paper = const Color(0xFFD8C7A3);

    if (bossType == 'inbox_hydra') {
      rect(size.width * .25, size.height * .35, size.width * .50, size.height * .48, const Color(0xFF44362E));
      for (var i = 0; i < 3; i++) {
        rect(size.width * (.26 + i * .18), size.height * (.18 + (i % 2) * .06), 26, 50, paper);
        rect(size.width * (.29 + i * .18), size.height * (.29 + (i % 2) * .06), 8, 8, ember);
      }
      rect(size.width * .36, size.height * .50, size.width * .28, 14, const Color(0xFF1A1010));
      rect(size.width * .40, size.height * .53, 9, 7, ember);
      rect(size.width * .56, size.height * .53, 9, 7, ember);
    } else if (bossType == 'meeting_mimic') {
      rect(size.width * .31, size.height * .16, size.width * .38, size.height * .67, violet);
      for (var i = 0; i < 6; i++) {
        final x = size.width * (.12 + (i % 3) * .30);
        final y = size.height * (.17 + (i ~/ 3) * .38);
        rect(x, y, 36, 30, const Color(0xFF2E5480));
        rect(x + 12, y + 8, 12, 12, const Color(0xFFB9D4E8));
      }
      rect(size.width * .43, size.height * .42, 9, 9, const Color(0xFFE94A6B));
      rect(size.width * .55, size.height * .42, 9, 9, const Color(0xFFE94A6B));
    } else if (bossType == 'calendar_kraken') {
      rect(size.width * .31, size.height * .15, size.width * .38, size.height * .67, const Color(0xFF7A4D2B));
      rect(size.width * .34, size.height * .22, size.width * .32, size.height * .35, paper);
      for (var i = 0; i < 9; i++) {
        rect(size.width * (.37 + (i % 3) * .09), size.height * (.28 + (i ~/ 3) * .09), 9, 9, ember);
      }
      p.color = const Color(0xFF22242B);
      canvas.drawCircle(Offset(size.width * .50, size.height * .69), 22, p);
      p.color = paper;
      canvas.drawLine(Offset(size.width * .50, size.height * .69), Offset(size.width * .50, size.height * .56), p..strokeWidth = 3);
      canvas.drawLine(Offset(size.width * .50, size.height * .69), Offset(size.width * .61, size.height * .69), p);
    } else if (bossType == 'notification_swarm') {
      for (var i = 0; i < 14; i++) {
        final x = size.width * ((i * 37 % 91) / 100 + .04);
        final y = size.height * ((i * 29 % 73) / 100 + .08);
        rect(x, y, 16, 16, i.isEven ? const Color(0xFFE94A6B) : const Color(0xFF4B8DE8));
      }
      rect(size.width * .39, size.height * .28, size.width * .22, size.height * .52, const Color(0xFF22142E));
      rect(size.width * .44, size.height * .42, 8, 8, const Color(0xFFF064AF));
      rect(size.width * .55, size.height * .42, 8, 8, const Color(0xFFF064AF));
    } else {
      // Generic backlog / spreadsheet / printer / ticket monster.
      for (var i = 0; i < 10; i++) {
        final w = size.width * (.22 + (i % 3) * .03);
        rect(size.width * (.18 + (i % 4) * .16), size.height * (.12 + i * .055), w, 13, paper);
      }
      rect(size.width * .40, size.height * .55, size.width * .20, size.height * .28, const Color(0xFF382B26));
      rect(size.width * .44, size.height * .63, 8, 8, ember);
      rect(size.width * .55, size.height * .63, 8, 8, ember);
    }
  }

  @override
  bool shouldRepaint(covariant _BossPainter oldDelegate) =>
      oldDelegate.bossType != bossType;
}
