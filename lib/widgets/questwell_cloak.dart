import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Individually fitted full-canvas cloth covers the complete locked paper doll.
class QuestwellCloak extends StatelessWidget {
  const QuestwellCloak({super.key, required this.slug, required this.bodyType});
  final String slug;
  final String bodyType;
  static bool supports(String? slug) =>
      slug == 'moss-green-cloak' || slug == 'hearthguard-mantle';
  static String asset(String slug, String body) {
    final fittedBody = const {'male', 'female'}.contains(body) ? body : 'neutral';
    final family = slug == 'hearthguard-mantle' ? 'hearthguard_mantle' : 'moss_cloak';
    return 'assets/images/questwell/avatar/${family}_${fittedBody}_v3.webp';
  }
  @override
  Widget build(BuildContext context) => IgnorePointer(child: ExcludeSemantics(
    child: Image.asset(asset(slug, bodyType), fit: BoxFit.contain,
      alignment: Alignment.bottomCenter, filterQuality: FilterQuality.high,
      gaplessPlayback: true),
  ));
}

/// Apply only to the original identity duplicate, never to the primary body.
/// Neutral identity includes a square neck tail; a collar must occlude that
/// neck normally while the original hair remains in front of the cloth.
class QuestwellCloakHairClipper extends CustomClipper<Path> {
  const QuestwellCloakHairClipper(this.body);
  final String body;
  @override
  Path getClip(Size size) {
    final scale = math.min(size.width / 240, size.height / 320);
    var path = Path()..addRect(const Rect.fromLTWH(0, 0, 240, 320));
    if (body == 'neutral') {
      path = Path.combine(PathOperation.difference, path,
        Path()..addRect(const Rect.fromLTRB(108, 74, 140, 320)));
    }
    return path.transform((Matrix4.identity()..scale(scale, scale)).storage)
      .shift(Offset((size.width - 240 * scale) / 2, size.height - 320 * scale));
  }
  @override
  bool shouldReclip(covariant QuestwellCloakHairClipper oldClipper) => oldClipper.body != body;
}

/// The outer cloak replaces class lapels and epaulettes. Preserve the central
/// outfit and sleeves, but tuck its shoulder silhouette beneath the capelet.
class QuestwellCloakUnderlayerClipper extends CustomClipper<Path> {
  const QuestwellCloakUnderlayerClipper(this.body);
  final String body;
  @override
  Path getClip(Size size) {
    final scale = math.min(size.width/240,size.height/320);
    final dx = (size.width-240*scale)/2, dy = size.height-320*scale;
    final path = Path()
      ..moveTo(106,94)..lineTo(136,94)
      ..quadraticBezierTo(142,145,145,190)
      ..quadraticBezierTo(144,236,136,265)
      ..quadraticBezierTo(121,271,104,265)
      ..quadraticBezierTo(97,238,98,190)
      ..quadraticBezierTo(99,145,106,94)..close();
    return path.transform((Matrix4.identity()..scale(scale,scale)).storage)
      .shift(Offset(dx,dy));
  }
  @override
  bool shouldReclip(covariant QuestwellCloakUnderlayerClipper oldClipper) => oldClipper.body!=body;
}
