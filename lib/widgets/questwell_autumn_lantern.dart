import 'dart:math' as math;
import 'package:flutter/material.dart';

/// One paint-only clock for light and leaves; the sprite and avatar stay static.
class QuestwellAutumnLantern extends StatefulWidget {
  const QuestwellAutumnLantern({super.key});
  static const slug = 'autumn-ember-lantern';
  static const asset = 'assets/images/questwell/hearth/autumn_ember_lantern_stand_v2.webp';
  static Rect bounds(Size scene, String slot) {
    final avatarHeight = math.min(scene.height * .76, scene.width * .62 * 4 / 3);
    final height = math.min(avatarHeight * .52, scene.width * .29 * 1681 / 935);
    // Compact tabletop lantern on a taller pedestal; effects orbit the upper lamp.
    // Wider paint canvas gives the leaves room outside the metal silhouette.
    final width = height * 935 / 1681 * 1.55;
    final center = scene.width * (slot == 'left' ? .22 : .80);
    return Rect.fromLTWH(center - width / 2, scene.height * .72 - height * 1605 / 1681, width, height);
  }
  @override
  State<QuestwellAutumnLantern> createState() => _QuestwellAutumnLanternState();
}
class _QuestwellAutumnLanternState extends State<QuestwellAutumnLantern>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _clock = AnimationController(vsync: this,
    duration: const Duration(seconds: 6));
  bool _enabled = false;
  bool _foreground = true;
  @override
  void initState() {
    super.initState();
    _foreground = WidgetsBinding.instance.lifecycleState == null ||
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
  }
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
    WidgetsBinding.instance.removeObserver(this);
    _clock.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Small autumn ember lantern on a walnut stand with glowing light and swirling leaves', image: true,
    child: IgnorePointer(child: RepaintBoundary(child: Stack(fit: StackFit.expand, children: [
      CustomPaint(painter: AutumnLanternPainter(_clock, foreground: false)),
      Image.asset(QuestwellAutumnLantern.asset, fit: BoxFit.contain,
        filterQuality: FilterQuality.high, excludeFromSemantics: true),
      CustomPaint(painter: AutumnLanternPainter(_clock, foreground: true)),
    ]))));
}

class AutumnLanternPainter extends CustomPainter {
  AutumnLanternPainter(this.clock, {required this.foreground}) : super(repaint: clock);
  final Animation<double> clock;
  final bool foreground;
  @override
  void paint(Canvas canvas, Size size) {
    final phase = clock.value * math.pi * 2;
    final flicker = .68 + .20 * math.sin(phase * 3) + .10 * math.sin(phase * 7 + .8);
    final paint = Paint();
    final center = Offset(size.width * .5, size.height * .30);
    if (!foreground) {
      final radius = size.width * .22;
      paint.shader = RadialGradient(colors: [
        Color.fromRGBO(255, 181, 54, .32 * flicker),
        const Color(0x00FFAF32),
      ]).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    } else {
      // Local flame glint stays inside the center glass pane.
      final radius = size.height * .055;
      paint.shader = RadialGradient(colors: [
        Color.fromRGBO(255, 242, 162, .60 * flicker),
        const Color(0x00FFC44E),
      ]).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }
    paint.shader = null;
    for (var i = 0; i < 9; i++) {
      final t = (clock.value + i / 9) % 1;
      final angle = t * math.pi * 3 + i * 1.8;
      // Alternate behind/in front of the sprite for a real orbit.
      if ((math.cos(angle) >= 0) != foreground) continue;
      final x = size.width * (.5 + math.sin(angle) * .34);
      final y = size.height * (.45 - t * .39);
      final opacity = math.pow(math.sin(t * math.pi), .5).toDouble() * .92;
      final length = size.height * (.035 + (i % 3) * .004);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + math.sin(phase + i) * .4);
      canvas.scale(.65 + .35 * math.cos(angle).abs(), 1);
      final leaf = Path()
        ..moveTo(0, -length)
        ..lineTo(length * .35, -length * .45)
        ..lineTo(length * .60, -length * .55)
        ..lineTo(length * .43, -length * .08)
        ..lineTo(length * .70, length * .05)
        ..lineTo(length * .35, length * .40)
        ..lineTo(0, length * .75)
        ..lineTo(-length * .35, length * .40)
        ..lineTo(-length * .70, length * .05)
        ..lineTo(-length * .43, -length * .08)
        ..lineTo(-length * .60, -length * .55)
        ..lineTo(-length * .35, -length * .45)
        ..close();
      paint.style = PaintingStyle.fill;
      paint.color = [const Color(0xFFF0B74E),const Color(0xFFD16B30),const Color(0xFFC99045)][i % 3].withValues(alpha: opacity);
      canvas.drawPath(leaf, paint);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = .65;
      paint.color = const Color(0xFFFFD986).withValues(alpha: opacity * .8);
      canvas.drawPath(leaf, paint);
      paint.style = PaintingStyle.fill;
      paint.color = const Color(0xFF714323).withValues(alpha: opacity);
      paint.strokeWidth = math.max(.6, size.height * .004);
      canvas.drawLine(Offset(0, -length * .55), Offset(0, length), paint);
      canvas.restore();
    }
  }
  @override
  bool shouldRepaint(covariant AutumnLanternPainter old) => old.clock != clock || old.foreground != foreground;
}
