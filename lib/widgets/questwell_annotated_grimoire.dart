import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Integrated book-and-grip sprite; its wrist is registered beneath the cuff.
class QuestwellAnnotatedGrimoire extends StatelessWidget {
  const QuestwellAnnotatedGrimoire({super.key, required this.bodyType});
  static const slug = 'annotated-grimoire';
  static const asset = 'assets/images/questwell_annotated_grimoire_grip_v2.webp';
  final String bodyType;

  static Rect bounds(String body) {
    final (wrist, factor) = switch (body) {
      'female' => (const Offset(162, 170.5), .041),
      'male' => (const Offset(166.5, 175), .046),
      _ => (const Offset(164.8, 174), .044),
    };
    // Mirror the integrated grip to the avatar LEFT hand (viewer right).
    // Its thumb faces inward; the book rests against the thigh.
    // Mirrored wrist center: (1062 - 296, 17).
    return Rect.fromLTWH(wrist.dx - 766 * factor, wrist.dy - 17 * factor,
      1062 * factor, 1481 * factor);
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(child: ExcludeSemantics(
    child: LayoutBuilder(builder: (context, constraints) {
      final scale = math.min(constraints.maxWidth / 240, constraints.maxHeight / 320);
      final fit = bounds(bodyType);
      return Stack(children: [Positioned(
        left: (constraints.maxWidth - 240 * scale) / 2 + fit.left * scale,
        top: constraints.maxHeight - 320 * scale + fit.top * scale,
        width: fit.width * scale, height: fit.height * scale,
        child: Transform.flip(flipX: true,
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

/// Hide the relaxed hand only; the source avatar and the rest of its body stay intact.
class GrimoireHandUnderlayerClipper extends CustomClipper<Path> {
  const GrimoireHandUnderlayerClipper(this.body);
  final String body;
  @override
  Path getClip(Size size) {
    final scale = math.min(size.width / 240, size.height / 320);
    final dx = (size.width - 240 * scale) / 2;
    final dy = size.height - 320 * scale;
    final hand = switch (body) {
      'female' => const Rect.fromLTWH(152, 168, 25, 28),
      'male' => const Rect.fromLTWH(153, 172, 29, 29),
      _ => const Rect.fromLTWH(151, 171, 31, 29),
    };
    return Path()..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRect(Rect.fromLTWH(dx + hand.left * scale, dy + hand.top * scale,
        hand.width * scale, hand.height * scale));
  }
  @override
  bool shouldReclip(covariant GrimoireHandUnderlayerClipper oldClipper) => oldClipper.body != body;
}

/// Only the sleeve cuff returns over the new wrist, never the relaxed hand.
class GrimoireCuffClipper extends CustomClipper<Path> {
  const GrimoireCuffClipper(this.body);
  final String body;
  @override
  Path getClip(Size size) {
    final scale = math.min(size.width / 240, size.height / 320);
    final rect = body == 'female'
      ? const Rect.fromLTWH(150, 155, 32, 20)
      : const Rect.fromLTWH(152, 158, 34, 22);
    return Path()..addRect(Rect.fromLTWH(
      (size.width - 240 * scale) / 2 + rect.left * scale,
      size.height - 320 * scale + rect.top * scale,
      rect.width * scale, rect.height * scale));
  }
  @override
  bool shouldReclip(covariant GrimoireCuffClipper oldClipper) => oldClipper.body != body;
}
