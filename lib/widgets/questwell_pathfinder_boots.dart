import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Detailed 64-bit-style boots beneath garment hems, on the 240 x 320 canvas.
class QuestwellPathfinderBoots extends StatelessWidget {
  const QuestwellPathfinderBoots({super.key, required this.bodyType});
  static const slug = 'pathfinder-boots';
  static const leftAsset = 'assets/images/questwell_pathfinder_boot_left_v1.webp';
  static const rightAsset = 'assets/images/questwell_pathfinder_boot_right_v1.webp';
  final String bodyType;

  static List<Rect> bounds(String body) => switch (body) {
    'female' => const [Rect.fromLTWH(76, 249, 39, 59), Rect.fromLTWH(146, 248, 42, 62)],
    'male' => const [Rect.fromLTWH(68, 245, 43, 64), Rect.fromLTWH(136, 245, 43, 65)],
    _ => const [Rect.fromLTWH(70, 241, 42, 63), Rect.fromLTWH(137, 241, 43, 64)],
  };

  @override
  Widget build(BuildContext context) => IgnorePointer(child: ExcludeSemantics(
    child: LayoutBuilder(builder: (context, constraints) {
      final scale = math.min(constraints.maxWidth / 240, constraints.maxHeight / 320);
      final fits = bounds(bodyType);
      return Stack(children: [for (var i = 0; i < fits.length; i++) Positioned(
        left: (constraints.maxWidth - 240 * scale) / 2 + fits[i].left * scale,
        top: constraints.maxHeight - 320 * scale + fits[i].top * scale,
        width: fits[i].width * scale, height: fits[i].height * scale,
        child: Image.asset(i == 0 ? leftAsset : rightAsset, fit: BoxFit.fill,
          filterQuality: FilterQuality.high, gaplessPlayback: true),
      )]);
    }),
  ));
}

/// Remove the original shoes and lower trouser ends only while boots are worn.
/// Keep the upper trousers entering the cuff; never mask class or cloak hems.
class PathfinderBaseClipper extends CustomClipper<Path> {
  const PathfinderBaseClipper(this.body);
  final String body;
  @override
  Path getClip(Size size) {
    final scale = math.min(size.width / 240, size.height / 320);
    final top = QuestwellPathfinderBoots.bounds(body).first.top + 8;
    return Path()..addRect(Rect.fromLTWH(0, 0, size.width,
      size.height - (320 - top) * scale));
  }
  @override
  bool shouldReclip(covariant PathfinderBaseClipper oldClipper) => body != oldClipper.body;
}
