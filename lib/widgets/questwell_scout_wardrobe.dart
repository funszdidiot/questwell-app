import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'questwell_clean_base.dart';
import 'questwell_neutral_paper_doll.dart';
import 'questwell_male_paper_doll.dart';

/// Registered garments on the approved paper dolls. Male Everyday is unified.
class QuestwellScoutWardrobeFoundation extends StatelessWidget {
  const QuestwellScoutWardrobeFoundation({super.key, required this.body, required this.layers});
  final String body;
  final Set<String> layers;
  static const femaleBaseAsset =
      'assets/images/questwell/avatar/base/paper_doll_female_v1.webp';
  static const femaleIdentityAsset =
      'assets/images/questwell/avatar/base/paper_doll_female_identity_v1.webp';

  static String asset(String body, String part, {String archetype = 'scout'}) {
    if (body == 'male') {
      return part.startsWith('robe')
          ? QuestwellMalePaperDoll.robeAsset(archetype, switch (part) {
              'robe_rear' => 'rear', 'robe_collar' => 'collar',
              'robe_cuff_front' => 'cuffs', _ => 'front',
            })
          : QuestwellMalePaperDoll.everydayAsset;
    }
    if (body == 'neutral') {
      if (part.startsWith('robe')) {
        return 'assets/images/questwell/avatar/classes/$archetype/${archetype}_${part}_neutral_v1.webp';
      }
      return 'assets/images/questwell/avatar/everyday_${part}_neutral_v3.webp';
    }
    final version = body == 'female'
        ? (part.startsWith('robe') ? 'v8' : 'v6')
        : part.startsWith('robe') ? 'v4' : 'v1';
    return 'assets/images/questwell/avatar/scout_${part}_${body}_$version.webp';
  }
  static Widget image(String path) => Image.asset(path, fit: BoxFit.contain,
      alignment: Alignment.bottomCenter, filterQuality: FilterQuality.high,
      gaplessPlayback: true);
  @override
  Widget build(BuildContext context) {
    if (body == 'male') {
      return Stack(fit: StackFit.expand, children: [
        image(QuestwellMalePaperDoll.baseAsset),
        // Even development subset controls must never split this outfit.
        if (layers.isNotEmpty)
          QuestwellMaleEverydayGarment(underRobe: layers.contains('robe')),
      ]);
    }
    if (body == 'neutral') {
      return Stack(fit: StackFit.expand, children: [
        const QuestwellNeutralPaperDoll(),
        // Approved trouser hems overlap the boot shafts.
        if (layers.contains('boots')) image(asset(body, 'boots')),
        if (layers.contains('trousers')) image(asset(body, 'trousers')),
        if (layers.contains('top')) image(asset(body, 'top')),
      ]);
    }
    if (body == 'female') {
      // Every garment shares this body's complete canvas. Clothing only adds
      // pixels: it never replaces, clips, translates, or rescales body parts.
      return Stack(fit: StackFit.expand, children: [
        image(femaleBaseAsset),
        if (layers.contains('trousers')) image(asset(body, 'trousers')),
        if (layers.contains('top')) image(asset(body, 'top')),
        if (layers.contains('boots')) image(asset(body, 'boots')),
      ]);
    }

    // The existing male candidate remains separate until it has
    // its own accepted paper-doll base and fitted clothing assets.
    final contents = Stack(fit: StackFit.expand, children: [
      ClipPath(clipper: ScoutWardrobeClipper(body, layers.contains('trousers') ? 'lowerReplacement' : 'all'),
          child: QuestwellCleanBase(body: body)),
      if (layers.contains('top')) ClipPath(clipper: ScoutWardrobeClipper(body, 'top'),
          child: image(asset(body, 'top'))),
      if (layers.contains('trousers')) image(asset(body, 'trousers')),
    ]);
    return layers.contains('robe')
        ? ClipPath(clipper: ScoutWardrobeClipper(body, 'robeUnder'), child: contents)
        : contents;
  }
}

/// Legacy fitting clips, registered to the 240x320 canvas.
/// Approved female and neutral paper dolls bypass these anatomy masks.
class ScoutWardrobeClipper extends CustomClipper<Path> {
  const ScoutWardrobeClipper(this.body, this.part);
  final String body;
  final String part;
  @override
  Path getClip(Size size) {
    var p = Path()..addRect(const Rect.fromLTWH(0, 0, 240, 320));
    if (part == 'lowerReplacement') {
      final waist = body == 'female' ? 147.0 : body == 'male' ? 151.0 : 150.0;
      final removed = Path()..addPolygon([Offset(91, waist), Offset(147, waist),
        const Offset(155, 202), const Offset(240, 202), const Offset(240, 320),
        const Offset(0, 320), const Offset(0, 202), const Offset(85, 202)], true);
      p = Path.combine(PathOperation.difference, p, removed);
    } else if (part == 'robeUnder') {
      final wristTop = body == 'female' ? 166.0 : 169.0;
      p = Path()..addRect(const Rect.fromLTRB(0, 0, 240, 77))
        ..addRect(const Rect.fromLTRB(104, 73, 139, 196))
        ..addRect(const Rect.fromLTRB(0, 196, 240, 320))
        ..addRect(Rect.fromLTRB(60, wristTop, 89, 200))
        ..addRect(Rect.fromLTRB(151, wristTop, 183, 200));
      // Hands and hair remain in their original registration.
      for (final poly in CleanBaseClipper.polygons['$body:identity']!) {
        if (poly.first.dy >= 167) p.addPolygon(poly, true);
      }
    } else if (part == 'identityHead') {
      p = Path();
      for (final poly in CleanBaseClipper.polygons['$body:identity']!) {
        if (poly.first.dy < 167) p.addPolygon(poly, true);
      }
    } else if (part == 'robe' && body != 'female') {
      p = Path.combine(PathOperation.difference, p,
          Path()..addRect(const Rect.fromLTRB(109, 0, 134, 84)));
    } else if (part == 'top' && body != 'female') {
      final neck = Path()..moveTo(108, 0)..lineTo(135, 0)..lineTo(134, 80)
        ..quadraticBezierTo(121, 88, 109, 80)..close();
      p = Path.combine(PathOperation.difference, p, neck);
    }
    final scale = math.min(size.width / 240, size.height / 320);
    return p.transform((Matrix4.identity()..scale(scale, scale)).storage)
        .shift(Offset((size.width - 240 * scale) / 2, size.height - 320 * scale));
  }
  @override
  bool shouldReclip(covariant ScoutWardrobeClipper oldClipper) =>
      oldClipper.body != body || oldClipper.part != part;
}
