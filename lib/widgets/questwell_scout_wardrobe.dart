import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'questwell_clean_base.dart';

/// Candidate clothing, explicitly enabled only by the development review.
/// Null in the shared renderer preserves the existing equipped wardrobe.
class QuestwellScoutWardrobeFoundation extends StatelessWidget {
  const QuestwellScoutWardrobeFoundation({super.key, required this.body, required this.layers});
  final String body;
  final Set<String> layers;
  static String asset(String body, String part) {
    if (body == 'female' && part == 'arms') {
      return 'assets/images/questwell/avatar/base/clean_arms_female_v2.webp';
    }
    final version = body == 'female' ? 'v5' : part.startsWith('robe') ? 'v4' : 'v1';
    return 'assets/images/questwell/avatar/scout_${part}_${body}_$version.webp';
  }
  static Widget image(String path) => Image.asset(path, fit: BoxFit.contain,
      alignment: Alignment.bottomCenter, filterQuality: FilterQuality.high,
      gaplessPlayback: true);
  @override
  Widget build(BuildContext context) {
    final contents = Stack(fit: StackFit.expand, children: [
      ClipPath(clipper: ScoutWardrobeClipper(body, layers.contains('trousers') ? 'lowerReplacement' : 'all'),
          child: ClipPath(clipper: ScoutWardrobeClipper(body, body == 'female' ? 'replacedArms' : 'all'),
            child: QuestwellCleanBase(body: body))),
      if (body == 'female') ...[
        ClipPath(clipper: const ScoutWardrobeClipper('female', 'neck'),
          child: image('assets/images/questwell/avatar/base/clean_female_v1.webp')),
        image(asset(body, 'arms')),
      ],
      if (layers.contains('top')) ClipPath(clipper: ScoutWardrobeClipper(body, 'top'),
          child: image(asset(body, 'top'))),
      if (layers.contains('trousers')) image(asset(body, 'trousers')),
    ]);
    return layers.contains('robe')
        ? ClipPath(clipper: ScoutWardrobeClipper(body, 'robeUnder'), child: contents)
        : contents;
  }
}

/// Registered to the shared 240x320 canvas. Clips hidden anatomy and rear
/// collar fabric; never redraws or rescales the approved face or grip.
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
    } else if (part == 'replacedArms') {
      p = Path.combine(PathOperation.difference, p, Path()
        ..addRect(const Rect.fromLTRB(0, 108, 99, 202))
        ..addRect(const Rect.fromLTRB(142, 108, 240, 202)));
    } else if (part == 'neck') {
      p = Path()..addRect(const Rect.fromLTRB(106, 70, 135, 85));
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
