import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Decorative light registered to the arena's bottom-aligned cover transform.
/// A separate repaint boundary keeps ambient frames out of the battle UI.
class QuestwellHarvestLanterns extends StatefulWidget {
  const QuestwellHarvestLanterns({super.key});

  @override
  State<QuestwellHarvestLanterns> createState() =>
      _QuestwellHarvestLanternsState();
}

class _QuestwellHarvestLanternsState extends State<QuestwellHarvestLanterns>
    with SingleTickerProviderStateMixin {
  late final AnimationController _light = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 4200));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled) {
      _light.stop();
      _light.value = 0;
    } else if (!_light.isAnimating) {
      _light.repeat();
    }
  }

  @override
  void dispose() {
    _light.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
      child: ExcludeSemantics(
          child: RepaintBoundary(
              child: CustomPaint(painter: HarvestLanternGlow(_light)))));
}

@visibleForTesting
class HarvestLanternGlow extends CustomPainter {
  HarvestLanternGlow(this.phase) : super(repaint: phase);
  final Animation<double> phase;

  @override
  void paint(Canvas canvas, Size size) {
    const source = Size(1536, 1024);
    final scale =
        math.max(size.width / source.width, size.height / source.height);
    final left = (size.width - source.width * scale) / 2;
    final top = size.height - source.height * scale;
    const anchors = [Offset(138, 358), Offset(1438, 414), Offset(123, 780)];
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    for (var i = 0; i < anchors.length; i++) {
      final wave = phase.value * math.pi * 2;
      final strength =
          .15 + .035 * math.sin(wave + i * 2) + .015 * math.sin(wave * 2 + i);
      final center =
          Offset(left + anchors[i].dx * scale, top + anchors[i].dy * scale);
      final radius = (i == 2 ? 80.0 : 65.0) * scale;
      canvas.drawCircle(
          center,
          radius,
          Paint()
            ..shader = RadialGradient(colors: [
              const Color(0xFFFFD37A).withValues(alpha: strength),
              const Color(0xFFFFA03D).withValues(alpha: strength * .4),
              const Color(0x00FFA03D),
            ], stops: const [
              0,
              .3,
              1
            ]).createShader(Rect.fromCircle(center: center, radius: radius)));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(HarvestLanternGlow oldDelegate) =>
      phase != oldDelegate.phase;
}
