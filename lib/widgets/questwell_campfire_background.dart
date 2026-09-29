import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Viewport-bound atmosphere. Only this paint layer ticks, never home data.
class QuestwellCampfireBackground extends StatefulWidget {
  const QuestwellCampfireBackground({super.key, required this.active, required this.child});
  final bool active;
  final Widget child;
  @override
  State<QuestwellCampfireBackground> createState() => _QuestwellCampfireBackgroundState();
}

class _QuestwellCampfireBackgroundState extends State<QuestwellCampfireBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift = AnimationController(
    vsync: this, duration: const Duration(seconds: 24));
  bool _reduceMotion = false;

  void _syncMotion() {
    if (widget.active && !_reduceMotion && TickerMode.of(context)) {
      if (!_drift.isAnimating) _drift.repeat();
    } else {
      _drift.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _syncMotion();
  }

  @override
  void didUpdateWidget(covariant QuestwellCampfireBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMotion();
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
    const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFF111B2B), Color(0xFF111827), Color(0xFF17120F)],
      stops: [0, .56, 1],
    ))),
    if (widget.active) Positioned.fill(child: IgnorePointer(
      child: ExcludeSemantics(child: RepaintBoundary(child: CustomPaint(
        painter: _EmberPainter(_drift, still: _reduceMotion),
      ))),
    )),
    widget.child,
  ]);
}

class _EmberPainter extends CustomPainter {
  _EmberPainter(this.drift, {required this.still}) : super(repaint: drift);
  final Animation<double> drift;
  final bool still;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final glow = Paint()..shader = const RadialGradient(
      center: Alignment(0, 1.1), radius: 1.2,
      colors: [Color(0x354E281C), Color(0x00763C24)],
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, glow);
    final paint = Paint()..isAntiAlias = false;
    // One cycle is 24 seconds, with fixed seeds and no sudden twinkling.
    for (var i = 0; i < 30; i++) {
      final phase = ((still ? .35 : drift.value) + i * i * .137 + i * .217) % 1;
      final baseX = ((i * .381966 + .07) % 1) * size.width;
      final x = (baseX + math.sin(phase * math.pi * 2 + i) * 14).roundToDouble();
      final y = ((1 - phase) * (size.height + 30) - 15).roundToDouble();
      final edgeFade = math.min(1.0, math.min(phase, 1 - phase) * 7);
      final side = i % 4 == 0 ? 4.0 : 2.0;
      paint.color = (i % 3 == 0 ? const Color(0xFFFFD27C) : const Color(0xFFEF9454))
        .withValues(alpha: edgeFade * (i % 3 == 0 ? .65 : .42));
      canvas.drawRect(Rect.fromLTWH(x, y, side, side), paint);
      if (side == 4) {
        paint.color = const Color(0xFFE7733F).withValues(alpha: edgeFade * .16);
        canvas.drawRect(Rect.fromLTWH(x, y + side, 2, 4), paint);
      }
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _EmberPainter oldDelegate) => oldDelegate.still != still;
}
