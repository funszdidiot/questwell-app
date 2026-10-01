import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Paint-only ambience over the approved illustration; never ticks page data.
class QuestwellExpeditionScene extends StatefulWidget {
  const QuestwellExpeditionScene({super.key, this.motion = true});
  final bool motion;
  @override
  State<QuestwellExpeditionScene> createState() => _QuestwellExpeditionSceneState();
}

class _QuestwellExpeditionSceneState extends State<QuestwellExpeditionScene>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _ambience = AnimationController(
    vsync: this, duration: const Duration(seconds: 12));
  bool _foreground = true;
  bool _still = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final state = WidgetsBinding.instance.lifecycleState;
    _foreground = state == null || state == AppLifecycleState.resumed;
  }
  void _sync() {
    if (!_still && _foreground && TickerMode.of(context)) {
      if (!_ambience.isAnimating) _ambience.repeat();
    } else {
      _ambience.stop();
    }
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = !widget.motion || MediaQuery.disableAnimationsOf(context);
    _sync();
  }
  @override
  void didUpdateWidget(covariant QuestwellExpeditionScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    _still = !widget.motion || MediaQuery.disableAnimationsOf(context);
    _sync();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _sync();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ambience.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Lantern-lit woodland path and stone bridge leading toward a moonlit citadel',
    image: true,
    child: AspectRatio(aspectRatio: 1.5, child: ClipRect(child: Stack(fit: StackFit.expand, children: [
      RepaintBoundary(child: Image.asset('assets/images/questwell_expedition_trail_v1.webp',
        key: const ValueKey('expedition-trail-art'), fit: BoxFit.cover,
        excludeFromSemantics: true, filterQuality: FilterQuality.low)),
      Positioned.fill(child: IgnorePointer(child: ExcludeSemantics(child: RepaintBoundary(
        child: CustomPaint(key: const ValueKey('expedition-ambience'),
          painter: _TrailAmbience(_ambience, still: _still)),
      )))),
    ]))),
  );
}

class _TrailAmbience extends CustomPainter {
  _TrailAmbience(this.phase, {required this.still}) : super(repaint: phase);
  final Animation<double> phase;
  final bool still;
  static const _lanterns = [Offset(.05, .625), Offset(.21, .43),
    Offset(.255, .386), Offset(.309, .444), Offset(.421, .57),
    Offset(.697, .578), Offset(.595, .57)];
  @override
  void paint(Canvas canvas, Size size) {
    final t = (still ? .25 : phase.value) * math.pi * 2;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    // Slow brightness variation stays close to the original lantern lighting.
    for (var i = 0; i < _lanterns.length; i++) {
      final point = Offset(_lanterns[i].dx * size.width, _lanterns[i].dy * size.height);
      final radius = size.width * (i == 0 ? .042 : .021);
      final strength = .13 + .06 * math.sin(t * 2 + i * 1.7);
      final rect = Rect.fromCircle(center: point, radius: radius);
      canvas.drawCircle(point, radius, Paint()..shader = RadialGradient(colors: [
        const Color(0xFFFFC469).withValues(alpha: strength), const Color(0x00FFC469),
      ]).createShader(rect));
    }
    // Small horizontal reflections remain inside the foreground stream.
    final water = Path()..moveTo(size.width * .51, size.height * .765)
      ..lineTo(size.width * .70, size.height * .75)
      ..lineTo(size.width * .80, size.height * .85)
      ..lineTo(size.width * .96, size.height * .93)
      ..lineTo(size.width * .87, size.height)
      ..lineTo(size.width * .72, size.height)
      ..lineTo(size.width * .78, size.height * .88)
      ..lineTo(size.width * .57, size.height * .82)..close();
    canvas.save();
    canvas.clipPath(water);
    final ripple = Paint()..strokeWidth = math.max(1, size.width / 700);
    for (var i = 0; i < 22; i++) {
      final x = size.width * (.54 + (i * .073 % .40) + math.sin(t + i) * .008);
      final y = size.height * (.77 + i * .010);
      ripple.color = (i % 4 == 0 ? const Color(0xFFFFCF85) : const Color(0xFFB2DDEB))
        .withValues(alpha: .08 + .14 * (1 + math.sin(t * 2 + i * .9)) / 2);
      canvas.drawLine(Offset(x, y), Offset(x + size.width * (.012 + i % 3 * .009), y), ripple);
    }
    canvas.restore();
    // A small, fixed population drifts locally; no camera motion or flashing.
    for (var i = 0; i < 14; i++) {
      final x = size.width * (.09 + (i * .071 % .62) + math.sin(t + i * 1.4) * .012);
      final y = size.height * (.39 + (i * .113 % .45) + math.cos(t + i * .8) * .017);
      final alpha = .20 + .42 * (1 + math.sin(t + i * 1.8)) / 2;
      final point = Offset(x, y);
      canvas.drawCircle(point, 3, Paint()..color = const Color(0xFFFFD57F).withValues(alpha: alpha * .10));
      canvas.drawRect(Rect.fromCenter(center: point, width: 1.5, height: 1.5),
        Paint()..color = const Color(0xFFFFE9AE).withValues(alpha: alpha));
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _TrailAmbience oldDelegate) => oldDelegate.still != still;
}
