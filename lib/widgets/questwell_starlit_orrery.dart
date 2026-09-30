import 'package:flutter/material.dart';

class QuestwellStarlitOrrery extends StatelessWidget {
  const QuestwellStarlitOrrery({super.key});
  static const slug = 'starlit-orrery';
  static const asset = 'assets/images/questwell/hearth/starlit_orrery.webp';
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Starlit Orrery celestial globe trophy', image: true,
    child: IgnorePointer(child: Image.asset(asset, fit: BoxFit.contain,
      filterQuality: FilterQuality.high, excludeFromSemantics: true)));
}
