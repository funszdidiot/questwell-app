import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The locked male v3 foundation and its approved, unified everyday outfit.
///
/// Every layer shares the same authored 240 × 320 canvas. Do not apply fitting
/// offsets, split the outfit into pieces, or clip the body to fit clothing.
class QuestwellMalePaperDoll extends StatelessWidget {
  const QuestwellMalePaperDoll({
    super.key,
    this.showEveryday = true,
    this.showRobe = false,
    this.robeArchetype = 'scout',
  });

  /// False exposes the intact foundation for development fit inspection.
  final bool showEveryday;

  /// Scout-derived robe with the requested rear repair; includes Everyday.
  final bool showRobe;

  final String robeArchetype;

  /// Development renderer capabilities, separate from account eligibility.
  static const classLabels = {
    'scout': 'Scout',
    'scholar': 'Scholar',
    'alchemist': 'Alchemist',
    'guardian': 'Guardian',
    'wanderer': 'Wanderer',
  };

  static String robeAsset(String archetype, String part) {
    final name = classLabels.containsKey(archetype) ? archetype : 'scout';
    // The later sleeve repair changes front RGB only, preserving every alpha.
    // The original accepted files remain immutable historical references.
    final version = part == 'rear' || part == 'front'
        ? (name == 'scout' ? 'v4' : 'v2')
        : (name == 'scout' ? 'v3' : 'v1');
    return 'assets/images/questwell/avatar/classes/$name/${name}_robe_${part}_male_$version.webp';
  }

  static const robeRearAsset =
      'assets/images/questwell/avatar/classes/scout/scout_robe_rear_male_v4.webp';
  static const robeFrontAsset =
      'assets/images/questwell/avatar/classes/scout/scout_robe_front_male_v4.webp';
  static const robeCollarAsset =
      'assets/images/questwell/avatar/classes/scout/scout_robe_collar_male_v3.webp';
  static const robeCuffsAsset =
      'assets/images/questwell/avatar/classes/scout/scout_robe_cuffs_male_v3.webp';

  static const baseAsset =
      'assets/images/questwell/avatar/base/paper_doll_male_v3.webp';
  static const everydayAsset =
      'assets/images/questwell/avatar/everyday_outfit_male_v2.webp';
  static const identityAsset =
      'assets/images/questwell/avatar/base/paper_doll_male_identity_v3.webp';

  Widget _layer(String asset) => Image.asset(
        asset,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
      );

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          if (showRobe) _layer(robeAsset(robeArchetype, 'rear')),
          _layer(baseAsset),
          if (showEveryday || showRobe) ...[
            QuestwellMaleEverydayGarment(underRobe: showRobe),
            if (showRobe) _layer(robeAsset(robeArchetype, 'front')),
            const QuestwellMaleIdentity(),
            if (showRobe) ...[
              _layer(robeAsset(robeArchetype, 'collar')),
              _layer(robeAsset(robeArchetype, 'cuffs')),
            ],
          ],
        ],
      );
}

/// One unchanged Everyday overlay. The robe hides only its trouser pixels
/// beside the thumbs; the complete body is a separate, unclipped sibling.
class QuestwellMaleEverydayGarment extends StatelessWidget {
  const QuestwellMaleEverydayGarment({super.key, this.underRobe = false});
  final bool underRobe;

  @override
  Widget build(BuildContext context) {
    final garment = Image.asset(QuestwellMalePaperDoll.everydayAsset,
        fit: BoxFit.contain, alignment: Alignment.bottomCenter,
        filterQuality: FilterQuality.high, gaplessPlayback: true);
    return underRobe
        ? ClipPath(clipper: const MaleRobeUnderlayClipper(), child: garment)
        : garment;
  }
}

/// Same connected contour as underrobe_occlusion.svg, registered to the
/// authored canvas. This clip must only wrap the Everyday garment image.
class MaleRobeUnderlayClipper extends CustomClipper<Path> {
  const MaleRobeUnderlayClipper();

  @override
  Path getClip(Size size) {
    final hidden = Path()
      ..moveTo(74, 179)
      ..cubicTo(77, 181, 81, 180, 87, 179)
      ..lineTo(91, 179)..lineTo(91, 203)..lineTo(79, 203)
      ..cubicTo(80, 198, 77, 195, 74, 191)
      ..cubicTo(71, 188, 71, 182, 74, 179)..close()
      ..moveTo(166, 179)
      ..cubicTo(163, 181, 159, 180, 153, 179)
      ..lineTo(149, 179)..lineTo(149, 203)..lineTo(161, 203)
      ..cubicTo(160, 198, 163, 195, 166, 191)
      ..cubicTo(169, 188, 169, 182, 166, 179)..close();
    final visible = Path.combine(PathOperation.difference,
        Path()..addRect(const Rect.fromLTWH(0, 0, 240, 320)), hidden);
    final scale = math.min(size.width / 240, size.height / 320);
    return visible.transform((Matrix4.identity()..scale(scale, scale)).storage)
        .shift(Offset((size.width - 240 * scale) / 2, size.height - 320 * scale));
  }

  @override
  bool shouldReclip(covariant MaleRobeUnderlayClipper oldClipper) => false;
}

/// Exact original visible identity pixels sampled from the full locked image.
/// The separate identity export has the same visible rows0..73. Sampling the
/// complete image before clipping avoids its encoded transparent cutoff edge.
/// The primary full body remains an unclipped sibling below the garments.
class QuestwellMaleIdentity extends StatelessWidget {
  const QuestwellMaleIdentity({super.key});
  @override
  Widget build(BuildContext context) => ClipPath(
    clipper: const MaleIdentityClipper(),
    child: Image.asset(QuestwellMalePaperDoll.baseAsset,
      fit: BoxFit.contain, alignment: Alignment.bottomCenter,
      filterQuality: FilterQuality.high, gaplessPlayback: true),
  );
}

class MaleIdentityClipper extends CustomClipper<Path> {
  const MaleIdentityClipper();
  @override
  Path getClip(Size size) {
    final scale = math.min(size.width / 240, size.height / 320);
    return (Path()..addRect(const Rect.fromLTRB(0,0,240,74)))
      .transform((Matrix4.identity()..scale(scale,scale)).storage)
      .shift(Offset((size.width-240*scale)/2,size.height-320*scale));
  }
  @override
  bool shouldReclip(covariant MaleIdentityClipper oldClipper) => false;
}
