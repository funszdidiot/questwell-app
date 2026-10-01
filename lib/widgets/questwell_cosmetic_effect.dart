import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Cosmetic-only animation; the clock repaints this layer, never the avatar tree.
class QuestwellCosmeticEffect extends StatefulWidget {
  const QuestwellCosmeticEffect({super.key, required this.slug});
  final String slug;
  @override
  State<QuestwellCosmeticEffect> createState() => _QuestwellCosmeticEffectState();
}

class _QuestwellCosmeticEffectState extends State<QuestwellCosmeticEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this, duration: const Duration(seconds: 6));
  bool _still = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context) || !TickerMode.of(context);
    if (_still) { _clock.stop(); } else if (!_clock.isAnimating) { _clock.repeat(); }
  }
  @override
  void dispose() { _clock.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => IgnorePointer(child: RepaintBoundary(
    child: CustomPaint(painter: QuestwellCosmeticEffectPainter(
      slug: widget.slug, clock: _clock, still: _still))));
}

class QuestwellCosmeticEffectPainter extends CustomPainter {
  QuestwellCosmeticEffectPainter({required this.slug, required this.clock, this.still = false})
      : super(repaint: clock);
  final String slug;
  final Animation<double> clock;
  final bool still;
  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 240, size.height / 320);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate((size.width - 240 * scale) / 2, size.height - 320 * scale);
    canvas.scale(scale);
    final phase = still ? .16 : clock.value;
    final paint = Paint()..isAntiAlias = true;
    void star(Offset at, double radius, double opacity) {
      if (opacity <= 0) return;
      final glow = Rect.fromCircle(center: at, radius: radius * 2.4);
      paint.shader = RadialGradient(colors: [
        Color.fromRGBO(255, 196, 77, opacity * .32), const Color(0x00FFC44D),
      ]).createShader(glow);
      canvas.drawOval(glow, paint); paint.shader = null;
      final path = Path();
      for (var i = 0; i < 8; i++) {
        final angle = -math.pi / 2 + i * math.pi / 4;
        final r = i.isEven ? radius : radius * .26;
        final p = at + Offset(math.cos(angle), math.sin(angle)) * r;
        if (i == 0) { path.moveTo(p.dx, p.dy); } else { path.lineTo(p.dx, p.dy); }
      }
      path.close();
      paint.color = Color.fromRGBO(247, 198, 94, opacity);
      canvas.drawPath(path, paint);
      paint.color = Color.fromRGBO(255, 247, 206, opacity);
      canvas.drawCircle(at, math.max(.65, radius * .18), paint);
    }
    if (slug == 'victory-sparkle') {
      // Two short staggered flourishes, followed by a quiet interval.
      for (var i = 0; i < 18; i++) {
        final delay = (i % 6) * .023 + (i >= 9 ? .19 : 0);
        final t = (phase - delay) / .34;
        if (t <= 0 || t >= 1) continue;
        final alpha = math.sin(math.pi * t);
        final side = i.isEven ? -1.0 : 1.0;
        final x = 120 + side * (61 + (i % 3) * 8 + t * 10);
        final y = 89.0 + (i % 9) * 21 + t * 19;
        star(Offset(x, y), (i % 4 == 0 ? 8.5 : 4.0) * (.65 + alpha * .35), alpha);
        paint.color = Color.fromRGBO(245, 190, 78, alpha * .65);
        canvas.drawRect(Rect.fromCenter(center: Offset(x - side * 4, y - 8), width: 1.7, height: 1.7), paint);
      }
    } else if (slug == 'focus-tonic') {
      // Slow rising sage bubbles stay outside the face and garment silhouette.
      for (var i = 0; i < 15; i++) {
        final t = (phase + i / 15) % 1;
        final alpha = math.sin(math.pi * t) * .85;
        final side = i.isEven ? -1.0 : 1.0;
        final x = 120 + side * (65 + (i % 3) * 7) + math.sin(t * math.pi * 2 + i) * 3;
        final y = 287 - t * 215;
        final radius = 2.0 + i % 4;
        paint.style = PaintingStyle.fill;
        paint.color = Color.fromRGBO(132, 208, 162, alpha * .18);
        canvas.drawCircle(Offset(x, y), radius + 1, paint);
        paint.style = PaintingStyle.stroke; paint.strokeWidth = .85;
        paint.color = Color.fromRGBO(173, 228, 183, alpha);
        canvas.drawCircle(Offset(x, y), radius, paint);
        paint.style = PaintingStyle.fill;
        paint.color = Color.fromRGBO(234, 250, 207, alpha);
        canvas.drawCircle(Offset(x - radius * .3, y - radius * .4), .8, paint);
        if (i % 5 == 0) star(Offset(x + side * 6, y + 13), 2.8, alpha * .65);
      }
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant QuestwellCosmeticEffectPainter oldDelegate) =>
      oldDelegate.slug != slug || oldDelegate.still != still || oldDelegate.clock != clock;
}
