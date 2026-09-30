import 'package:flutter/material.dart';

/// Wall art occupies its own equipment category, independent of floor decor.
class QuestwellWallArt extends StatelessWidget {
  const QuestwellWallArt({super.key});
  static const slug = 'moonlit-woodland';
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Moonlit Woodland painting hanging on the Hearth wall', image: true,
    child: IgnorePointer(child: Image.asset(
      'assets/images/questwell/hearth/moonlit_woodland.webp',
      fit: BoxFit.contain, filterQuality: FilterQuality.high,
      excludeFromSemantics: true)));
}
