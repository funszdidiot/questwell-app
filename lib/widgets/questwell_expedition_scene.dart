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
    vsync: this, duration: const Duration(seconds: 8));
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
  static final _fallCourses = [
    Path()..moveTo(1309, 888)..quadraticBezierTo(1322, 901, 1324, 921),
    Path()..moveTo(1339, 897)..quadraticBezierTo(1350, 909, 1353, 929),
    Path()..moveTo(1449, 888)..quadraticBezierTo(1457, 908, 1459, 934),
  ].map((path) => path.computeMetrics().first).toList(growable: false);
  @override
  void paint(Canvas canvas, Size size) {
    final t = (still ? .25 : phase.value) * math.pi * 2;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    // Warm, clearly visible breathing light; continuous curves avoid flashes.
    for (var i = 0; i < _lanterns.length; i++) {
      final point = Offset(_lanterns[i].dx * size.width, _lanterns[i].dy * size.height);
      final pulse = (1 + math.sin(t * 2 + i * 1.7)) / 2;
      final radius = size.width * (i == 0 ? .066 : .036) * (.85 + pulse * .25);
      final strength = .24 + .25 * pulse;
      final rect = Rect.fromCircle(center: point, radius: radius);
      canvas.drawCircle(point, radius, Paint()..shader = RadialGradient(colors: [
        const Color(0xFFFFC469).withValues(alpha: strength), const Color(0x00FFC469),
      ]).createShader(rect));
    }
    _paintWater(canvas, size, t);
    // Larger glowing fireflies trace visible loops even on phone screens.
    final coreSize = (size.width * .005).clamp(1.8, 2.8).toDouble();
    for (var i = 0; i < 18; i++) {
      final x = size.width * (.09 + (i * .071 % .72) + math.sin(t + i * 1.4) * .038);
      final y = size.height * (.32 + (i * .113 % .54) + math.cos(t + i * .8) * .045);
      final alpha = .45 + .45 * (1 + math.sin(t + i * 1.8)) / 2;
      final point = Offset(x, y);
      final halo = Rect.fromCircle(center: point, radius: coreSize * 4);
      canvas.drawCircle(point, coreSize * 4, Paint()..shader = RadialGradient(colors: [
        const Color(0xFFFFD57F).withValues(alpha: alpha * .45), const Color(0x00FFD57F),
      ]).createShader(halo));
      canvas.drawRect(Rect.fromCenter(center: point, width: coreSize, height: coreSize),
        Paint()..color = const Color(0xFFFFE9AE).withValues(alpha: alpha));
    }
    canvas.restore();
  }
  // Trace the visible water in the 1536 x 1024 illustration. Separate pools
  // keep highlights off the bank, bridge, and foreground rocks.
  void _paintWater(Canvas canvas, Size size, double t) {
    canvas.save();
    canvas.scale(size.width / 1536, size.height / 1024);
    final pools = Path()
      ..moveTo(925, 779)..lineTo(1048, 782)..lineTo(1135, 790)
      ..lineTo(1160, 801)..lineTo(1125, 809)..lineTo(1095, 814)
      ..lineTo(1030, 808)..lineTo(977, 800)..lineTo(925, 797)..close()
      ..moveTo(1018, 819)..lineTo(1112, 821)..lineTo(1141, 833)
      ..lineTo(1230, 845)..lineTo(1280, 852)..lineTo(1252, 858)
      ..lineTo(1143, 852)..lineTo(1098, 849)..lineTo(1090, 860)
      ..lineTo(1044, 856)..lineTo(1018, 848)..close()
      ..moveTo(1408, 960)..lineTo(1450, 956)..lineTo(1505, 961)
      ..lineTo(1536, 962)..lineTo(1536, 1002)..lineTo(1500, 989)
      ..lineTo(1455, 980)..lineTo(1408, 973)..close();
    canvas.save();
    canvas.clipPath(pools);
    final ripple = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1536 / size.width * .75
      ..strokeCap = StrokeCap.round;
    // Local surface shimmer, rather than lines sliding down over the landscape.
    for (var i = 0; i < 32; i++) {
      final lower = i >= 23;
      final x = lower ? 1410.0 + (i * 29 % 110) : 944.0 + (i * 47 % 320);
      final y = lower ? 959.0 + (i * 7 % 32) : 784.0 + (i * 11 % 74);
      final sway = math.sin(t * 2 + i * .9) * 5;
      final brightness = (1 + math.sin(t * 2 + i * 1.3)) / 2;
      ripple.color = const Color(0xFFBBE5ED).withValues(alpha: .10 + brightness * .22);
      final wave = Path()..moveTo(x + sway, y)
        ..quadraticBezierTo(x + sway + 9, y + math.sin(t * 2 + i) * 1.5,
          x + sway + 17 + i % 3 * 5, y);
      canvas.drawPath(wave, ripple);
    }
    // The lantern reflection stays directly below the bridge lantern.
    for (var i = 0; i < 10; i++) {
      final pulse = (1 + math.sin(t * 2 + i * .8)) / 2;
      final y = 791.0 + i * 7;
      final halfWidth = 5.0 + i * .7 + pulse * 4;
      ripple.color = const Color(0xFFFFD38A).withValues(alpha: .14 + pulse * .25);
      canvas.drawLine(Offset(1084 - halfWidth, y), Offset(1084 + halfWidth, y), ripple);
    }
    canvas.restore();
    // Short falling highlights follow the individual cascades between rocks.
    for (var f = 0; f < _fallCourses.length; f++) {
      final metric = _fallCourses[f];
      for (var strand = 0; strand < 3; strand++) {
        canvas.save();
        canvas.translate(strand * 3.0, 0);
        final travel = ((still ? .25 : phase.value) * 6 + strand / 3 + f * .23) % 1;
        ripple.color = const Color(0xFFCCEAF2)
          .withValues(alpha: .40 * math.sin(travel * math.pi));
        canvas.drawPath(metric.extractPath(metric.length * travel,
          metric.length * math.min(1.0, travel + .24)), ripple);
        canvas.restore();
      }
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _TrailAmbience oldDelegate) => oldDelegate.still != still;
}
