import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Visual layer only: phase is supplied by the encounter's persistent intro.
class QuestwellHollowHarvest extends StatelessWidget {
  const QuestwellHollowHarvest({super.key, required this.phase});
  final double phase;
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
                      opacity: name == 'body' ? 1 : amount,
                      child: ClipPath(
                          clipBehavior: Clip.hardEdge,
                          clipper: _SourceRegion(name, amount),
                          child: Image.asset(sprite,
                              width: size,
                              height: size,
                              fit: BoxFit.fill,
                              excludeFromSemantics: true))));
          final body = _part(.08, .58);
          final head = _part(.54, .73);
          final spider = _part(.76, .96);
          return Semantics(
              label: 'The Hollow Harvest and his spider sidekick',
              child: Stack(fit: StackFit.expand, children: [
                piece('body', body, Offset.zero),
                piece('head', head, Offset(0, -size * .23)),
                piece('spider', spider, Offset(size * .30, 0)),
                if (phase < .84)
                  IgnorePointer(
                      child: CustomPaint(painter: _HarvestLeaves(phase))),
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
    final head = polygon(const [
      Offset(570, 15),
      Offset(800, 15),
      Offset(800, 165),
      Offset(794, 230),
      Offset(775, 272),
      Offset(744, 297),
      Offset(704, 310),
      Offset(650, 313),
      Offset(596, 298),
      Offset(561, 277),
      Offset(536, 250),
      Offset(521, 217),
      Offset(518, 176),
      Offset(535, 137),
      Offset(565, 113),
      Offset(565, 65)
    ]);
    final spider = polygon(const [
      Offset(0, 1005),
      Offset(353, 1005),
      Offset(353, 1160),
      Offset(330, 1205),
      Offset(0, 1205)
    ]);
    if (region == 'head') return head;
    if (region == 'spider') return spider;
    final body = Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path.combine(PathOperation.union, head, spider));
    // Reveal the connected body from its roots upward, never move a cut robe strip.
    return Path.combine(
        PathOperation.intersect,
        body,
        Path()
          ..addRect(Rect.fromLTRB(
              0, size.height * (1 - amount), size.width, size.height)));
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
