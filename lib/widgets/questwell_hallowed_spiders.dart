import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Decorative, account-free motion anchored to the approved 1536x1024 room.
/// Paint-only ticks keep avatar, equipment and home data out of the animation.
class QuestwellHallowedSpiders extends StatefulWidget {
  const QuestwellHallowedSpiders({super.key});

  @override
  State<QuestwellHallowedSpiders> createState() => _HallowedSpidersState();
}

class _HallowedSpidersState extends State<QuestwellHallowedSpiders>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );
  bool _still = true;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _syncMotion() {
    if (_still || !_foreground) {
      _motion.stop();
    } else if (!_motion.isAnimating) {
      _motion.repeat();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncMotion();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled;
    _syncMotion();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: ExcludeSemantics(
          child: RepaintBoundary(
            child: CustomPaint(
              key: const ValueKey('hallowed-spiders'),
              painter: HallowedSpiderPainter(_motion, still: _still),
            ),
          ),
        ),
      );
}

/// Public so animation endpoints can be rendered and checked deterministically.
class HallowedSpiderPainter extends CustomPainter {
  HallowedSpiderPainter(this.motion, {required this.still})
      : super(repaint: motion);

  final Animation<double> motion;
  final bool still;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    // Match the room Image's BoxFit.cover and Alignment(0, .04) exactly.
    final scale = math.max(size.width / 1536, size.height / 1024);
    final origin = Offset(
      (size.width - 1536 * scale) / 2,
      (size.height - 1024 * scale) * .52,
    );
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(scale);
    for (var i = 0; i < 2; i++) {
      final phase = ((still ? .12 : motion.value) + i * .43) % 1;
      // Cosine closes the loop with zero velocity, preventing a visible reset.
      final travel = (1 - math.cos(phase * math.pi * 2)) / 2;
      // Portrait cover crops remove the original corners. Keep silk and bodies
      // visible near the cropped ceiling edge without moving the room itself.
      final margin = math.min(32.0, size.width * .1);
      final anchor = Offset(
        (i == 0 ? 245.0 : 1300.0)
            .clamp(
              (margin - origin.dx) / scale,
              (size.width - margin - origin.dx) / scale,
            )
            .toDouble(),
        math.max(i == 0 ? 54.0 : 67.0, (12 - origin.dy) / scale),
      );
      final center = anchor +
          Offset(
            still ? 0 : math.sin(phase * math.pi * 2) * 5,
            32 + travel * (i == 0 ? 185 : 145),
          );
      canvas.drawLine(
        anchor,
        center,
        Paint()
          ..color = const Color(0xAAC4B9A7)
          ..strokeWidth = 1.6,
      );
      canvas.save();
      canvas.translate(center.dx, center.dy);
      final leg = Paint()
        ..color = const Color(0xFF241827)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      final flex = still ? 0.0 : math.sin(phase * math.pi * 12) * 2;
      for (final side in [-1.0, 1.0]) {
        for (var n = 0; n < 4; n++) {
          final y = -7.0 + n * 5;
          final bend = (n.isEven ? flex : -flex);
          canvas.drawPath(
            Path()
              ..moveTo(side * 6, y)
              ..lineTo(side * (16 + bend), y - 7 + n * 2)
              ..lineTo(side * (23 + bend), y + 5 + n * 2),
            leg,
          );
        }
      }
      canvas.drawOval(
        const Rect.fromLTWH(-10, -14, 20, 23),
        Paint()..color = const Color(0xFF302035),
      );
      canvas.drawOval(
        const Rect.fromLTWH(-7, 3, 14, 12),
        Paint()..color = const Color(0xFF211727),
      );
      canvas.drawOval(
        const Rect.fromLTWH(-5, -11, 5, 9),
        Paint()..color = const Color(0xFF674347),
      );
      final eye = Paint()..color = const Color(0xFFEAB36A);
      canvas.drawCircle(const Offset(-3, 10), 1.5, eye);
      canvas.drawCircle(const Offset(3, 10), 1.5, eye);
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant HallowedSpiderPainter oldDelegate) =>
      oldDelegate.still != still || oldDelegate.motion != motion;
}
