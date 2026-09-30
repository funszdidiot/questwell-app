import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Center and side paintings remain independent of floor decor.
class QuestwellWallArt extends StatelessWidget {
  const QuestwellWallArt({super.key, this.artSlug = slug});
  static const slug = 'moonlit-woodland';
  static const fern = 'fern-study';
  static const celestial = 'celestial-study';
  static bool isSide(String value) => value == fern || value == celestial;
  final String artSlug;

  // A restrained room-light grade: 7% less saturation, slightly lower
  // brightness, and warmer highlights. Preserve the source alpha exactly.
  static const _roomLight = ColorFilter.matrix([
    .930333, .049290, .004977, 0, 0,
    .014291, .941156, .004853, 0, 0,
    .013786, .046377, .866187, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final name = artSlug == fern ? 'Fern Study' : artSlug == celestial ? 'Celestial Study' : 'Moonlit Woodland';
    final asset = artSlug.replaceAll('-', '_');
    return Semantics(
      label: '$name painting hanging on the Hearth wall', image: true,
      child: IgnorePointer(child: LayoutBuilder(builder: (context, constraints) {
        final scale = ((isSide(artSlug)
          ? constraints.maxHeight / 64 : constraints.maxWidth / 80))
          .clamp(.6, 2.0).toDouble();
        Widget artwork() => Image.asset(
          'assets/images/questwell/hearth/$asset.webp',
          fit: BoxFit.contain, filterQuality: FilterQuality.high,
          excludeFromSemantics: true);
        return Stack(fit: StackFit.expand, clipBehavior: Clip.none, children: [
          // Use the actual frame silhouette, including transparent margins.
          // The fireplace casts this shallow shadow down and to the right.
          Transform.translate(
            offset: Offset(.8 * scale, 1.2 * scale),
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: .85 * scale, sigmaY: .85 * scale),
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(Color(0x660F0B09), BlendMode.srcIn),
                child: artwork()),
            ),
          ),
          ColorFiltered(colorFilter: _roomLight, child: artwork()),
        ]);
      })));
  }
}
