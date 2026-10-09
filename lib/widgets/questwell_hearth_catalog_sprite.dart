import 'questwell_hearth_assets.dart';
import 'package:flutter/material.dart';
import '../services/questwell_cosmetic_models.dart';

/// Generic backend-registered Hearth sprite.
///
/// The backend decides the asset/effect/shadow metadata; the Hearth profile
/// decides scale/placement. New ordinary decor should not require a slug branch.
class QuestwellHearthCatalogSprite extends StatelessWidget {
  const QuestwellHearthCatalogSprite({
    super.key,
    required this.spec,
  });

  final QuestwellHearthRenderSpec spec;

  Widget _image() {
    final quality = spec.pixelated ? FilterQuality.none : FilterQuality.high;
    if (spec.assetSource == 'network') {
      return Image.network(
        spec.assetPath,
        fit: BoxFit.contain,
        filterQuality: quality,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    }
    return Image.asset(
      QuestwellHearthAssets.resolve(spec.assetPath),
      fit: BoxFit.contain,
      filterQuality: quality,
      gaplessPlayback: true,
      excludeFromSemantics: true,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (spec.effectProfile case final effect?)
                _QuestwellHearthEffect(profile: effect),
              _image(),
            ],
          ),
        ),
      );
}

/// Canonical floor-sprite envelope. Every rug/floor textile uses the same
/// footprint; its artwork changes, the room does not.
class QuestwellHearthFloorSprite extends StatelessWidget {
  const QuestwellHearthFloorSprite({
    super.key,
    required this.spec,
  });

  final QuestwellHearthRenderSpec spec;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final quality =
                spec.pixelated ? FilterQuality.none : FilterQuality.high;
            final image = spec.assetSource == 'network'
                ? Image.network(
                    spec.assetPath,
                    fit: BoxFit.fill,
                    filterQuality: quality,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  )
                : Image.asset(
                    QuestwellHearthAssets.resolve(spec.assetPath),
                    fit: BoxFit.fill,
                    filterQuality: quality,
                    gaplessPlayback: true,
                    excludeFromSemantics: true,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  );
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  left: constraints.maxWidth * .22,
                  top: constraints.maxHeight * .69,
                  width: constraints.maxWidth * .56,
                  height: constraints.maxHeight * .26,
                  child: image,
                ),
              ],
            );
          },
        ),
      );
}

class _QuestwellHearthEffect extends StatelessWidget {
  const _QuestwellHearthEffect({required this.profile});
  final String profile;

  @override
  Widget build(BuildContext context) {
    final colors = switch (profile) {
      'ward_glow' => const [
          Color(0x28CDEB8C),
          Color(0x1274A76F),
          Color(0x0074A76F),
        ],
      'warm_glow' => const [
          Color(0x28FFD87A),
          Color(0x12D98642),
          Color(0x00D98642),
        ],
      _ => const [
          Color(0x00000000),
          Color(0x00000000),
          Color(0x00000000),
        ],
    };
    return Align(
      alignment: const Alignment(0, -.22),
      child: FractionallySizedBox(
        widthFactor: .58,
        heightFactor: .36,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: RadialGradient(colors: colors),
          ),
        ),
      ),
    );
  }
}
