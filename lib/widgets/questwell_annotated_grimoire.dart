import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Detailed Scholar spellbook. Existing hand pixels grip its upper cover edge.
class QuestwellAnnotatedGrimoire extends StatelessWidget {
  const QuestwellAnnotatedGrimoire({super.key, required this.bodyType});
  static const slug = 'annotated-grimoire';
  static const asset = 'assets/images/questwell_annotated_grimoire_v1.webp';
  final String bodyType;

  static Rect bounds(String body) => switch (body) {
    'female' => const Rect.fromLTWH(149, 178, 34, 49),
    'male' => const Rect.fromLTWH(154, 184, 36, 52),
    _ => const Rect.fromLTWH(151, 182, 35, 51),
  };

  @override
  Widget build(BuildContext context) => IgnorePointer(child: ExcludeSemantics(
    child: LayoutBuilder(builder: (context, constraints) {
      final scale = math.min(constraints.maxWidth / 240, constraints.maxHeight / 320);
      final fit = bounds(bodyType);
      return Stack(children: [Positioned(
        left: (constraints.maxWidth - 240 * scale) / 2 + fit.left * scale,
        top: constraints.maxHeight - 320 * scale + fit.top * scale,
        width: fit.width * scale, height: fit.height * scale,
        child: Transform.rotate(angle: -.07, alignment: const Alignment(-.35, -.7),
          child: Stack(fit: StackFit.expand, clipBehavior: Clip.none, children: [
            Transform.translate(offset: Offset(.65 * scale, .8 * scale),
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: .45 * scale, sigmaY: .45 * scale),
                child: Image.asset(asset, fit: BoxFit.contain,
                  color: const Color(0x480B0806), colorBlendMode: BlendMode.srcIn,
                  filterQuality: FilterQuality.high, gaplessPlayback: true))),
            Image.asset(asset, fit: BoxFit.contain,
              filterQuality: FilterQuality.high, gaplessPlayback: true),
          ])),
      )]);
    }),
  ));
}
