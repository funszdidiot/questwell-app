import 'dart:math' as math;
import 'package:flutter/material.dart';

class QuestwellHarvestDisplay extends StatelessWidget {
  const QuestwellHarvestDisplay({super.key});
  static const slug = 'harvest-apothecary-display';
  static const asset = 'assets/images/questwell/hearth/harvest_apothecary_display_v1.webp';
  static Rect bounds(Size scene, String slot) {
    final avatarHeight = math.min(scene.height * .76, scene.width * .62 * 4 / 3);
    final height = math.min(avatarHeight * .54, scene.width * .42 * 1199 / 1312);
    final width = height * 1312 / 1199;
    final left = slot == 'left' ? scene.width * .08 : scene.width * .98 - width;
    // Ground the visible plinth, not the transparent canvas edge.
    return Rect.fromLTWH(left, scene.height * .70 - height * 1095 / 1199, width, height);
  }
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Harvest apothecary display placed in the Hearth', image: true,
    child: IgnorePointer(child: Image.asset(asset, fit: BoxFit.contain,
      filterQuality: FilterQuality.high, excludeFromSemantics: true)));
}
