import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Visual layer only: phase is supplied by the encounter's persistent intro.
class QuestwellHollowHarvest extends StatelessWidget {
  const QuestwellHollowHarvest(
      {super.key, required this.phase, this.defeatPhase = 0});
  final double phase;
  final double defeatPhase;
  static const sprite = 'assets/images/questwell/hollow_harvest/idle.png';

  double _part(double start, double end) => Curves.easeOutCubic
      .transform(((phase - start) / (end - start)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) => Align(
      alignment: Alignment.bottomCenter,
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(builder: (context, constraints) {
          final size = constraints.maxWidth;
          // Complementary silhouette masks preserve the approved source exactly.
          Widget piece(String name, double amount, Offset travel) =>
              Transform.translate(
                  key: ValueKey('harvest-$name'),
                  offset: travel * (1 - amount),
                  child: Opacity(
                      opacity: amount,
                      child: ClipPath(
                          clipBehavior: Clip.hardEdge,
                          clipper: _SourceRegion(name, amount),
                          child: Image.asset(sprite,
                              width: size,
                              height: size,
                              fit: BoxFit.fill,
                              excludeFromSemantics: true))));
          final victory = defeatPhase.clamp(0.0, 1.0);
          final body = _part(.12, .73) * (1 - (victory / .65).clamp(0.0, 1.0));
          final pile = ((victory - .25) / .60).clamp(0.0, 1.0);
          final spider = _part(.76, .96);
          return Semantics(
              label: victory == 1
                  ? 'The Hollow Harvest rests as a pumpkin pile beside his spider'
                  : 'The Hollow Harvest and his spider sidekick',
              child: Stack(fit: StackFit.expand, children: [
                if (body > 0) piece('body', body, Offset.zero),
                if (pile > 0)
                  Positioned(
                      right: 0,
                      bottom: 0,
                      width: size * .74,
                      height: size * .74,
                      child: Opacity(
                          key: const ValueKey('harvest-pumpkin-pile'),
                          opacity: pile,
                          child: Transform.translate(
                              offset: Offset(
                                  0, -size * .035 * math.sin(pile * math.pi)),
                              child: Image.asset(
                                  'assets/images/questwell/hollow_harvest/defeated_v1.png',
                                  fit: BoxFit.contain,
                                  excludeFromSemantics: true)))),
                piece('spider', spider, Offset(size * .30, 0)),
                if (phase < .84 && victory == 0)
                  IgnorePointer(
                      child: CustomPaint(painter: _HarvestLeaves(phase))),
                if (victory > 0 && victory < 1)
                  IgnorePointer(
                      child:
                          CustomPaint(painter: _HarvestLeaves(victory * .84))),
              ]));
        }),
      ));
}

class _SourceRegion extends CustomClipper<Path> {
  const _SourceRegion(this.region, this.amount);
  final String region;
  final double amount;
  @override
  Path getClip(Size size) {
    Path polygon(List<Offset> points) => Path()
      ..addPolygon([
        for (final p in points)
          Offset(p.dx * size.width / 1254, p.dy * size.height / 1254),
      ], true);
    final spider = polygon(const [
      Offset(0, 1005),
      Offset(353, 1005),
      Offset(353, 1160),
      Offset(330, 1205),
      Offset(0, 1205)
    ]);
    if (region == 'spider') return spider;
    // Keep the pumpkin, neck and cloak connected throughout the reveal. A
    // detached head cutout exposed a crescent-shaped hole above the collar.
    return Path.combine(
        PathOperation.difference, Path()..addRect(Offset.zero & size), spider);
  }

  @override
  bool shouldReclip(_SourceRegion oldClipper) =>
      region != oldClipper.region || amount != oldClipper.amount;
}

class _HarvestLeaves extends CustomPainter {
  const _HarvestLeaves(this.phase);
  final double phase;
  @override
  void paint(Canvas canvas, Size size) {
    final opacity = math.sin((phase / .84).clamp(0.0, 1.0) * math.pi);
    for (var i = 0; i < 18; i++) {
      final angle = i * 2.4 + phase * math.pi * 5;
      final radius = size.width * (.16 + (i % 4) * .06);
      final point = Offset(size.width * .53 + math.cos(angle) * radius,
          size.height * (.83 - phase * .57) + math.sin(angle) * radius * .35);
      final paint = Paint()
        ..color = (i.isEven ? const Color(0xFFDF8A33) : const Color(0xFFAB542D))
            .withValues(alpha: opacity);
      canvas.save();
      canvas.translate(point.dx, point.dy);
      canvas.rotate(angle);
      canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: 7, height: 3), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_HarvestLeaves oldDelegate) => phase != oldDelegate.phase;
}
