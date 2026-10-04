import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The original book hangs from a belt loop; the avatar's hands stay intact.
class QuestwellAnnotatedGrimoire extends StatelessWidget {
  const QuestwellAnnotatedGrimoire({super.key, required this.bodyType});
  static const slug = 'annotated-grimoire';
  static const asset = 'assets/images/questwell_annotated_grimoire_v1.webp';
  static const angle = .10;
  static const sourceAspectRatio = 356 / 499;
  final String bodyType;

  /// Shared 240 x 320 paper-doll coordinates, inset from the relaxed hand.
  static Rect bounds(String body) => switch (body) {
    'female' => const Rect.fromLTWH(126, 157, 24, 24 / sourceAspectRatio),
    'male' => const Rect.fromLTWH(130, 164, 26, 26 / sourceAspectRatio),
    _ => const Rect.fromLTWH(130, 165, 25, 25 / sourceAspectRatio),
  };

  static Offset beltAnchor(String body) => switch (body) {
    'female' => const Offset(132, 147),
    'male' => const Offset(137, 155),
    _ => const Offset(136, 157),
  };

  @override
  Widget build(BuildContext context) => IgnorePointer(child: ExcludeSemantics(
    child: LayoutBuilder(builder: (context, constraints) {
      final scale = math.min(constraints.maxWidth / 240, constraints.maxHeight / 320);
      final origin = Offset((constraints.maxWidth - 240 * scale) / 2,
          constraints.maxHeight - 320 * scale);
      final fit = bounds(bodyType);
      return Stack(clipBehavior: Clip.none, children: [
        Positioned.fill(child: CustomPaint(painter: GrimoireBeltLoopPainter(
            anchor: beltAnchor(bodyType), book: fit, scale: scale, origin: origin))),
        Positioned(
          left: origin.dx + fit.left * scale,
          top: origin.dy + fit.top * scale,
          width: fit.width * scale, height: fit.height * scale,
          child: Transform.rotate(angle: angle, alignment: Alignment.topCenter,
            child: Image.asset(asset, fit: BoxFit.contain,
              filterQuality: FilterQuality.high, gaplessPlayback: true)),
        ),
      ]);
    }),
  ));
}

/// A small leather loop connects the book to the existing clothing belt.
/// This painter adds accessory pixels only; it never clips the avatar.
class GrimoireBeltLoopPainter extends CustomPainter {
  const GrimoireBeltLoopPainter({required this.anchor, required this.book,
    required this.scale, required this.origin});
  final Offset anchor;
  final Rect book;
  final double scale;
  final Offset origin;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(scale);
    final loop = RRect.fromRectAndRadius(
      Rect.fromLTRB(anchor.dx - 3, anchor.dy - 1.5,
          anchor.dx + 3, book.top + 5), const Radius.circular(1.7));
    canvas.drawRRect(loop, Paint()..color = const Color(0xFF291C13));
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTRB(anchor.dx - 2, anchor.dy - .5,
          anchor.dx + 2, book.top + 4), const Radius.circular(1)),
      Paint()..color = const Color(0xFF765032));
    canvas.drawLine(Offset(anchor.dx - 1.5, anchor.dy + .7),
      Offset(anchor.dx - 1.5, book.top + 3),
      Paint()..color = const Color(0xFFAD8051)..strokeWidth = .6);
    canvas.drawCircle(Offset(anchor.dx, anchor.dy + 2), 1.05,
      Paint()..color = const Color(0xFFD0A24E));
    canvas.drawCircle(Offset(anchor.dx - .25, anchor.dy + 1.7), .35,
      Paint()..color = const Color(0xFFF3D487));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GrimoireBeltLoopPainter oldDelegate) =>
    anchor != oldDelegate.anchor || book != oldDelegate.book ||
    scale != oldDelegate.scale || origin != oldDelegate.origin;
}
