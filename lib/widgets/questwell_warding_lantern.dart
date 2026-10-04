import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Guardian-class Hearth lantern. Development visual only while the catalog
/// entry remains inactive.
///
/// Asset-led like the other polished Hearth decor: the authored sprite carries
/// material/shading detail while runtime code handles placement and restrained glow.
class QuestwellWardingLantern extends StatelessWidget {
  const QuestwellWardingLantern({super.key});

  static const slug = 'warding-lantern';
  static const asset =
      'assets/images/questwell/hearth/warding_lantern_v3_64bit.webp';

  static Rect bounds(Size scene, String slot) {
    final avatarHeight =
        math.min(scene.height * .76, scene.width * .62 * 4 / 3);
    final height = avatarHeight * (slot == 'front' ? .42 : .38);
    final width = height * 900 / 1500;
    final center = scene.width *
        (slot == 'left' ? .23 : slot == 'right' ? .80 : .18);
    final floor = scene.height * (slot == 'front' ? .88 : .72);
    return Rect.fromLTWH(
      center - width / 2,
      floor - height * .96,
      width,
      height,
    );
  }

  @override
  Widget build(BuildContext context) => Semantics(
        label:
            'Guardian warding lantern with brass frame, emerald ward glass, and walnut stand',
        image: true,
        child: IgnorePointer(
          child: RepaintBoundary(
            child: Stack(
              fit: StackFit.expand,
              children: [
                const _WardingGlow(),
                Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  gaplessPlayback: true,
                  excludeFromSemantics: true,
                ),
              ],
            ),
          ),
        ),
      );
}

class _WardingGlow extends StatelessWidget {
  const _WardingGlow();

  @override
  Widget build(BuildContext context) => Align(
        alignment: const Alignment(0, -.23),
        child: FractionallySizedBox(
          widthFactor: .56,
          heightFactor: .34,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const RadialGradient(
                colors: [
                  Color(0x28CDEB8C),
                  Color(0x1274A76F),
                  Color(0x0074A76F),
                ],
              ),
            ),
          ),
        ),
      );
}
