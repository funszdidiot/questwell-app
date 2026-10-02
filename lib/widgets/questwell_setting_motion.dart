import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Ambient paint only: never rebuilds the avatar, furniture, or background.
class QuestwellSettingMotion extends StatefulWidget {
  const QuestwellSettingMotion({super.key, required this.astral});
  final bool astral;
  @override
  State<QuestwellSettingMotion> createState() => _QuestwellSettingMotionState();
}
class _QuestwellSettingMotionState extends State<QuestwellSettingMotion>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _clock = AnimationController(vsync: this,
    duration: const Duration(seconds: 12));
  bool _enabled = false;
  bool _foreground = true;
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addObserver(this); }
  void _sync() {
    if (_enabled && _foreground) {
      if (!_clock.isAnimating) _clock.repeat();
    } else { _clock.stop(); }
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _enabled = !MediaQuery.disableAnimationsOf(context) && TickerMode.of(context);
    _sync();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _sync();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); _clock.dispose(); super.dispose();
  }
  @override
  Widget build(BuildContext context) => IgnorePointer(child: RepaintBoundary(
    child: CustomPaint(painter: QuestwellSettingPainter(_clock, astral: widget.astral))));
}
class QuestwellSettingPainter extends CustomPainter {
  QuestwellSettingPainter(this.clock, {required this.astral}) : super(repaint: clock);
  final Animation<double> clock;
  final bool astral;
  @override
  void paint(Canvas canvas, Size size) {
    final side = math.max(size.width, size.height);
    canvas.save(); canvas.clipRect(Offset.zero & size);
    canvas.translate((size.width-side)/2, (size.height-side)*.52);
    canvas.scale(side);
    final phase = clock.value * math.pi * 2;
    final color = astral ? const Color(0xFFCFB3FF) : const Color(0xFFFFD66A);
    final paint = Paint();
    // Stay in the architectural side margins, clear of paintings and avatar.
    for (var i=0; i<18; i++) {
      final right = i.isEven;
      final x = (right ? .87 : .13) + math.sin(phase+i*2.4)*.025;
      final y = .12 + (i%9)*.052 + math.cos(phase+i)*.014;
      final pulse = .35 + .3*(1+math.sin(phase+i*1.7))/2;
      final p = Offset(x,y);
      paint.shader = RadialGradient(colors: [color.withValues(alpha: pulse*.5),
        color.withValues(alpha: 0)]).createShader(Rect.fromCircle(center:p,radius:.014));
      canvas.drawCircle(p,.014,paint);
      paint.shader = null; paint.color=color.withValues(alpha:pulse);
      canvas.drawRect(Rect.fromCenter(center:p,width:.003,height:.003),paint);
    }
    if (astral) {
      for (final x in [.06,.16,.85]) {
        final p=Offset(x,x==.06 ? .27 : .52);
        paint.shader=RadialGradient(colors:[color.withValues(alpha:.10+.06*math.sin(phase)),
          color.withValues(alpha:0)]).createShader(Rect.fromCircle(center:p,radius:.065));
        canvas.drawCircle(p,.065,paint);
      }
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant QuestwellSettingPainter old) => old.astral != astral || old.clock != clock;
}
