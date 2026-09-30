import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A quiet pixel trail beside the wordmark, with a still reduced-motion state.
class QuestwellWordmarkSparkles extends StatefulWidget {
  const QuestwellWordmarkSparkles({super.key});
  @override
  State<QuestwellWordmarkSparkles> createState() => _QuestwellWordmarkSparklesState();
}

class _QuestwellWordmarkSparklesState extends State<QuestwellWordmarkSparkles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer = AnimationController(
    vsync: this, duration: const Duration(seconds: 7));
  bool _still = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context);
    if (_still || !TickerMode.of(context)) {
      _shimmer.stop();
    } else if (!_shimmer.isAnimating) {
      _shimmer.repeat();
    }
  }
  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => IgnorePointer(child: ExcludeSemantics(
    child: RepaintBoundary(child: CustomPaint(size: const Size(52, 36),
      painter: _SparklePainter(_shimmer, still: _still))),
  ));
}

class _SparklePainter extends CustomPainter {
  _SparklePainter(this.animation, {required this.still}) : super(repaint: animation);
  final Animation<double> animation;
  final bool still;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = false;
    const points = [(6.0, 25.0), (23.0, 14.0), (39.0, 7.0), (18.0, 30.0), (43.0, 21.0)];
    for (var i = 0; i < points.length; i++) {
      final phase = (animation.value + i * .23) % 1;
      final fade = still ? .72 : .25 + .65 * math.sin(phase * math.pi);
      final x = (points[i].$1 + (still ? 0 : phase * 4)).roundToDouble();
      final y = (points[i].$2 - (still ? 0 : phase * 4)).roundToDouble();
      paint.color = const Color(0xFFFFD886).withValues(alpha: fade * (1 - i * .12));
      if (i < 3) {
        final arm = i == 0 ? 4.0 : 2.0;
        canvas.drawRect(Rect.fromLTWH(x - arm, y, arm * 2 + 2, 2), paint);
        canvas.drawRect(Rect.fromLTWH(x, y - arm, 2, arm * 2 + 2), paint);
        paint.color = const Color(0xFFFFF0BE).withValues(alpha: fade);
        canvas.drawRect(Rect.fromLTWH(x, y, 2, 2), paint);
      } else {
        canvas.drawRect(Rect.fromLTWH(x, y, 2, 2), paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => oldDelegate.still != still;
}
