import 'package:flutter/material.dart';

/// Center and side paintings remain independent of floor decor.
class QuestwellWallArt extends StatelessWidget {
  const QuestwellWallArt({super.key, this.artSlug = slug});
  static const slug = 'moonlit-woodland';
  static const fern = 'fern-study';
  static const celestial = 'celestial-study';
  static bool isSide(String value) => value == fern || value == celestial;
  final String artSlug;
  @override
  Widget build(BuildContext context) {
    final name = artSlug == fern ? 'Fern Study' : artSlug == celestial ? 'Celestial Study' : 'Moonlit Woodland';
    final asset = artSlug.replaceAll('-', '_');
    return Semantics(
      label: '$name painting hanging on the Hearth wall', image: true,
      child: IgnorePointer(child: Image.asset(
        'assets/images/questwell/hearth/$asset.webp',
        fit: BoxFit.contain, filterQuality: FilterQuality.high,
        excludeFromSemantics: true)));
  }
}
