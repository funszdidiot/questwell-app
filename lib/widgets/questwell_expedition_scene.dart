import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Paint-only ambience over the approved illustration; never ticks page data.
class QuestwellExpeditionScene extends StatefulWidget {
  const QuestwellExpeditionScene({super.key, this.motion = true, this.campfire = false});
  final bool campfire;
  final bool motion;
  @override
  State<QuestwellExpeditionScene> createState() => _QuestwellExpeditionSceneState();
}

class _QuestwellExpeditionSceneState extends State<QuestwellExpeditionScene>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _ambience = AnimationController(
    vsync: this, duration: const Duration(seconds: 24));
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
    label: widget.campfire
        ? 'A welcoming campfire beneath ancient trees, overlooking a moonlit citadel'
        : 'Lantern-lit woodland path and stone bridge leading toward a moonlit citadel',
    image: true,
    child: AspectRatio(aspectRatio: 1.5, child: ClipRect(child: Stack(fit: StackFit.expand, children: [
      RepaintBoundary(child: Image.asset(widget.campfire
          ? 'assets/images/questwell_campfire_rest_v1.webp'
          : 'assets/images/questwell_expedition_trail_v1.webp',
        key: ValueKey(widget.campfire ? 'expedition-campfire-art' : 'expedition-trail-art'), fit: BoxFit.cover,
        excludeFromSemantics: true, filterQuality: FilterQuality.low)),
      Positioned.fill(child: IgnorePointer(child: ExcludeSemantics(child: RepaintBoundary(
        child: CustomPaint(key: ValueKey(widget.campfire ? 'campfire-ambience' : 'expedition-ambience'),
          painter: widget.campfire
              ? _CampfireAmbience(_ambience, still: _still)
              : _TrailAmbience(_ambience, still: _still)),
      )))),
    ]))),
  );
}

class _TrailAmbience extends CustomPainter {
  _TrailAmbience(this.phase, {required this.still}) : super(repaint: phase);
  final Animation<double> phase;
  final bool still;
  // Three familiar ambience cycles share one longer, occasional breeze cycle.
  double get _effectPhase => phase.value * 3;
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
    final t = (still ? .25 : _effectPhase) * math.pi * 2;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    _paintLeafRustle(canvas, size, phase.value, still: still, campfire: false);
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
      ..strokeWidth = 1536 / size.width * 1.25
      ..strokeCap = StrokeCap.round;
    // Deliberate tracks stay in the visible pools. Their travel and minimum
    // screen-space width remain readable when the scene shrinks to a phone.
    const tracks = [
      Offset(942, 788), Offset(984, 792), Offset(1031, 796),
      Offset(1070, 800), Offset(1112, 797), Offset(1044, 825),
      Offset(1090, 829), Offset(1140, 840), Offset(1195, 850),
      Offset(1032, 840), Offset(1070, 850), Offset(1234, 854),
      Offset(1420, 966), Offset(1460, 965), Offset(1500, 971),
      Offset(1448, 975), Offset(1484, 980), Offset(1510, 986),
    ];
    for (var i = 0; i < tracks.length; i++) {
      final travel = ((still ? .25 : _effectPhase) * 4 + i * .173) % 1;
      final strength = math.sin(travel * math.pi);
      final x = tracks[i].dx + travel * 32;
      final y = tracks[i].dy + travel * 3;
      final wave = Path()..moveTo(x, y)
        ..quadraticBezierTo(x + 14, y - 2.5, x + 28 + i % 3 * 5, y);
      // A soft teal body and a brighter crest read as water, without flashes.
      ripple.strokeWidth = 1536 / size.width * 3;
      ripple.color = const Color(0xFF69BFCF).withValues(alpha: strength * .24);
      canvas.drawPath(wave, ripple);
      ripple.strokeWidth = 1536 / size.width * 1.25;
      ripple.color = const Color(0xFFD6F3F7).withValues(alpha: strength * .76);
      canvas.drawPath(wave, ripple);
    }
    // The lantern reflection stays directly below the bridge lantern.
    for (var i = 0; i < 10; i++) {
      final pulse = (1 + math.sin(t * 2 + i * .8)) / 2;
      final y = 791.0 + i * 7;
      final halfWidth = 6.0 + i * .7 + pulse * 9;
      ripple.color = const Color(0xFFFFD38A).withValues(alpha: .22 + pulse * .40);
      canvas.drawLine(Offset(1084 - halfWidth, y), Offset(1084 + halfWidth, y), ripple);
    }
    canvas.restore();
    // Longer, brighter falling crests and foam make the tiny cascades legible.
    for (var f = 0; f < _fallCourses.length; f++) {
      final metric = _fallCourses[f];
      for (var strand = 0; strand < 3; strand++) {
        canvas.save();
        canvas.translate(strand * 4.0, 0);
        final travel = ((still ? .25 : _effectPhase) * 8 + strand / 3 + f * .23) % 1;
        ripple.strokeWidth = 1536 / size.width * 1.5;
        ripple.color = const Color(0xFFE1F6FF)
          .withValues(alpha: .85 * math.sin(travel * math.pi));
        canvas.drawPath(metric.extractPath(metric.length * travel,
          metric.length * math.min(1.0, travel + .50)), ripple);
        canvas.restore();
      }
    }
    const foamCenters = [Offset(1330, 928), Offset(1360, 935), Offset(1466, 943)];
    for (var i = 0; i < foamCenters.length; i++) {
      final spread = ((still ? .25 : _effectPhase) * 4 + i / 3) % 1;
      ripple.strokeWidth = 1536 / size.width;
      ripple.color = const Color(0xFFD6F3F7)
        .withValues(alpha: .6 * math.sin(spread * math.pi));
      canvas.drawArc(Rect.fromCenter(center: foamCenters[i],
        width: 12 + spread * 28, height: 3 + spread * 7),
        0, math.pi, false, ripple);
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _TrailAmbience oldDelegate) => oldDelegate.still != still;
}

/// Firelight and ember paths repaint independently of the artwork and timer.
class _CampfireAmbience extends CustomPainter {
  _CampfireAmbience(this.phase, {required this.still}) : super(repaint: phase);
  final Animation<double> phase;
  final bool still;
  // Three familiar ambience cycles share one longer, occasional breeze cycle.
  double get _effectPhase => phase.value * 3;
  @override
  void paint(Canvas canvas, Size size) {
    final progress = still ? .25 : _effectPhase;
    final t = progress * math.pi * 2;
    final breath = (1 + math.sin(t * 4)) / 2;
    final fire = Offset(size.width * .518, size.height * .74);
    final glowRadius = size.width * (.115 + breath * .012);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    _paintLeafRustle(canvas, size, phase.value, still: still, campfire: true);
    final glow = Rect.fromCircle(center: fire, radius: glowRadius);
    canvas.drawCircle(fire, glowRadius, Paint()..shader = RadialGradient(colors: [
      const Color(0xFFFFAB42).withValues(alpha: .12 + breath * .12),
      const Color(0x00FFAB42),
    ]).createShader(glow));
    // The animated tongues sit within the illustrated fire, above the logs.
    for (var i = 0; i < 4; i++) {
      final sway = math.sin(t * 4 + i * 1.6);
      final lift = (1 + math.sin(t * 6 + i * 1.3)) / 2;
      final x = size.width * (.487 + i * .019);
      final base = size.height * (.741 + (i % 2) * .008);
      final height = size.height * (.063 + lift * .055);
      final width = size.width * .017;
      final tipX = x + sway * size.width * .012;
      final flame = Path()..moveTo(x - width, base)
        ..cubicTo(x - width * 1.2, base - height * .38,
          tipX + width * .2, base - height * .63, tipX, base - height)
        ..cubicTo(tipX + width * .9, base - height * .58,
          x + width * 1.3, base - height * .2, x + width, base)
        ..close();
      canvas.drawPath(flame, Paint()..shader = const LinearGradient(
        begin: Alignment.bottomCenter, end: Alignment.topCenter,
        colors: [Color(0xD9FFF3B0), Color(0xBFFFCA5C), Color(0x55FF741E)],
      ).createShader(Rect.fromLTWH(x - width * 2, base - height, width * 4, height)));
    }
    // Smoothly fading sparks rise at staggered phases, with no abrupt reset.
    for (var i = 0; i < 18; i++) {
      final rise = (progress * 2 + i / 18) % 1;
      final alpha = math.sin(rise * math.pi) * .90;
      final x = size.width * (.49 + (i * .017 % .065)
        + math.sin(t * 2 + i) * .011 + (rise * (i.isEven ? -.018 : .018)));
      final y = size.height * (.72 - rise * (.23 + i % 3 * .025));
      final point = Offset(x, y);
      final core = (size.width * .004).clamp(1.4, 2.4).toDouble();
      canvas.drawCircle(point, core * 2.4,
        Paint()..color = const Color(0xFFFF9C3B).withValues(alpha: alpha * .18));
      canvas.drawRect(Rect.fromCenter(center: point, width: core, height: core * 1.5),
        Paint()..color = const Color(0xFFFFD67E).withValues(alpha: alpha));
    }
    // The campsite lantern breathes more slowly than the flames.
    final lantern = Offset(size.width * .103, size.height * .565);
    final radius = size.width * .05;
    canvas.drawCircle(lantern, radius, Paint()..shader = RadialGradient(colors: [
      const Color(0xFFFFCF73).withValues(alpha: .12 + .10 * (1 + math.sin(t * 2)) / 2),
      const Color(0x00FFCF73),
    ]).createShader(Rect.fromCircle(center: lantern, radius: radius)));
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _CampfireAmbience oldDelegate) => oldDelegate.still != still;
}

/// Small foliage accents sway only during two short breezes in each 24-second
/// cycle. The base art stays fixed; there is no camera or whole-image motion.
void _paintLeafRustle(Canvas canvas, Size size, double phase,
    {required bool still, required bool campfire}) {
  final anchors = campfire
      ? const [Offset(.40, .095), Offset(.49, .054), Offset(.58, .076),
          Offset(.66, .032), Offset(.074, .864), Offset(.125, .91)]
      : const [Offset(.43, .079), Offset(.51, .044), Offset(.60, .078),
          Offset(.68, .025), Offset(.063, .837), Offset(.121, .892)];
  double gust(double start) {
    final u = (phase - start) / .13;
    if (still || u <= 0 || u >= 1) return 0;
    final envelope = math.sin(u * math.pi);
    return envelope * envelope * math.sin(u * math.pi * 3);
  }
  final scale = (size.width / 560).clamp(.65, 1.5).toDouble();
  for (var group = 0; group < anchors.length; group++) {
    final delay = group * .012;
    final breeze = gust(.12 + delay) + gust(.66 + delay);
    canvas.save();
    canvas.translate(anchors[group].dx * size.width, anchors[group].dy * size.height);
    canvas.scale(scale);
    canvas.rotate((group.isEven ? -.28 : .32) + breeze * .18);
    final stem = Paint()..color = const Color(0xFF41472B)
      ..strokeWidth = 1;
    canvas.drawLine(Offset.zero, Offset(15 + breeze * 2, 7), stem);
    for (var leaf = 0; leaf < 5; leaf++) {
      canvas.save();
      canvas.translate(3.0 + leaf * 2.9, leaf * 1.3);
      canvas.rotate((leaf.isEven ? -.75 : .85) + breeze * (.18 + leaf * .035));
      final blade = Path()..moveTo(0, 0)..lineTo(2, -2)
        ..lineTo(5, -3)..lineTo(8, -1)..lineTo(6, 2)
        ..lineTo(3, 2)..close();
      canvas.drawPath(blade, Paint()..color =
        (leaf.isEven ? const Color(0xFF465132) : const Color(0xFF596039)));
      canvas.drawLine(const Offset(1, 0), const Offset(6, -1),
        Paint()..color = const Color(0xFF7B7947).withValues(alpha: .55)
          ..strokeWidth = .7);
      canvas.restore();
    }
    canvas.restore();
  }
}
