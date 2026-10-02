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
    duration: const Duration(seconds: 9));
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
    for (var i=0; i<24; i++) {
      final right = i.isEven;
      final x = (right ? .88 : .12) + math.sin(phase+i*2.4)*(astral ? .035 : .060);
      final y = .13 + (i%12)*.039 + math.cos(phase+i)*(astral ? .025 : .045);
      final pulse = .60 + .35*(1+math.sin(phase+i*1.7))/2;
      final p = Offset(x,y);
      if (!astral) {
        for (var trail=1; trail<=4; trail++) {
          final lag=trail*.075;
          final tail=Offset((right ? .88 : .12)+math.sin(phase-lag+i*2.4)*.060,
            .13+(i%12)*.039+math.cos(phase-lag+i)*.045);
          paint.shader=null;
          paint.color=color.withValues(alpha:pulse*(5-trail)*.08);
          canvas.drawCircle(tail,.0025,paint);
        }
      }
      paint.shader = RadialGradient(colors: [color.withValues(alpha: pulse*.7),
        color.withValues(alpha: 0)]).createShader(Rect.fromCircle(center:p,radius:.024));
      canvas.drawCircle(p,.024,paint);
      paint.shader = null; paint.color=color.withValues(alpha:pulse);
      canvas.drawRect(Rect.fromCenter(center:p,width:.0055,height:.0055),paint);
    }
    if (astral) {
      // Soft atmospheric light follows the painted sky, with no hard ribbon
      // outlines or rectangular pane cutouts.
      for (var glow=0; glow<3; glow++) {
        final center=Offset(.982+math.sin(phase+glow*1.8)*.009,
          .19+glow*.12+math.sin(phase*.999+glow)*.028);
        canvas.save();
        canvas.translate(center.dx,center.dy);
        canvas.scale(.028,.105);
        paint.shader=RadialGradient(colors:[
          (glow.isEven ? const Color(0xFFB4CFFF) : const Color(0xFFB49AE8))
            .withValues(alpha:.12+.06*(1+math.sin(phase+glow))/2),
          const Color(0x00000000),
        ]).createShader(const Rect.fromLTRB(-1,-1,1,1));
        canvas.drawCircle(Offset.zero,1,paint);
        canvas.restore();
      }
      for (final x in [.06,.16,.85]) {
        final p=Offset(x,x==.06 ? .27 : .52);
        paint.shader=RadialGradient(colors:[color.withValues(alpha:.24+.14*math.sin(phase)),
          color.withValues(alpha:0)]).createShader(Rect.fromCircle(center:p,radius:.085));
        canvas.drawCircle(p,.085,paint);
      }
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant QuestwellSettingPainter old) => old.astral != astral || old.clock != clock;
}
