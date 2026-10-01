import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Continuous front drapes wrap over the outfit; forearms are restored above them.
class QuestwellCloak extends StatelessWidget {
  const QuestwellCloak({super.key, required this.slug, required this.bodyType,
    this.rear = false});
  final String slug;
  final String bodyType;
  final bool rear;
  static bool supports(String? slug) =>
    slug == 'moss-green-cloak' || slug == 'hearthguard-mantle';
  static String asset(String slug) => slug == 'hearthguard-mantle'
    ? 'assets/images/questwell_guardian_mantle_v1.webp'
    : 'assets/images/questwell_moss_cloak_v1.webp';
  static Rect bounds(String body, String slug) {
    final mantle = slug == 'hearthguard-mantle';
    return switch (body) {
      'female' => Rect.fromLTWH(mantle ? 43 : 41, 76, mantle ? 150 : 154, 212),
      'male' => Rect.fromLTWH(mantle ? 38 : 36, 75, mantle ? 164 : 168, 216),
      _ => Rect.fromLTWH(mantle ? 42 : 40, 77, mantle ? 156 : 160, 211),
    };
  }
  static Matrix4 drapeTransform(double width, double height, double lean) {
    const taper = .93;
    final perspective = (1/taper - 1)/height;
    return Matrix4.identity()
      ..setEntry(3, 1, perspective)
      ..setEntry(0, 1, width*perspective/2 + lean/(height*taper))
      ..setEntry(1, 1, 1/taper);
  }
  @override
  Widget build(BuildContext context) => IgnorePointer(child: ExcludeSemantics(
    child: LayoutBuilder(builder: (context, constraints) {
      final scale = math.min(constraints.maxWidth / 240, constraints.maxHeight / 320);
      final fit = bounds(bodyType, slug);
      final artwork = Image.asset(asset(slug), fit: BoxFit.fill,
        filterQuality: FilterQuality.high, gaplessPlayback: true);

      return Stack(clipBehavior: Clip.none, children: [Positioned(
        left: (constraints.maxWidth - 240*scale)/2 + fit.left*scale,
        top: constraints.maxHeight - 320*scale + fit.top*scale,
        width: fit.width*scale, height: fit.height*scale,
        child: Transform(
          // Keep the neckline registered; taper the hem without cropping its
          // embroidery. A tiny lateral fall avoids a perfectly mirrored skirt.
          transform: drapeTransform(fit.width*scale, fit.height*scale,
            slug == 'hearthguard-mantle' ? -1.2*scale : 1.2*scale),
          child: artwork))]);
    }),
  ));
}

/// Head and forearms overlap the cloak, making the cloth fall behind the arms
/// while its uninterrupted front panels cover the sides of the torso and hips.
class QuestwellCloakForegroundClipper extends CustomClipper<Path> {
  const QuestwellCloakForegroundClipper(this.body);
  final String body;
  @override
  Path getClip(Size size) {
    final scale=math.min(size.width/240,size.height/320);
    final left=(size.width-240*scale)/2, top=size.height-320*scale;
    final female=body=='female';
    final path=Path()..addRect(const Rect.fromLTRB(0,0,240,73));
    // Restore the actual skin contour down into the collar opening. Never
    // restore a horizontal strip of the shirt or cut the neck off at the jaw.
    final neckLeft = female ? 111.0 : 109.0;
    final neckRight = female ? 127.0 : 129.0;
    path.moveTo(neckLeft,70);
    path.lineTo(neckLeft,76);
    path.quadraticBezierTo(neckLeft+1,80,120,female ? 83 : 84);
    path.quadraticBezierTo(neckRight-1,80,neckRight,75);
    path.lineTo(neckRight,70);path.close();
    // The sleeves emerge below the shoulder cape. Follow the angled forearms,
    // not a horizontal cut across the entire cloak.
    if (female) {
      path.moveTo(73,141);path.quadraticBezierTo(80,137,88,142);
      path.lineTo(84,163);path.quadraticBezierTo(91,180,85,192);
      path.lineTo(69,197);path.lineTo(63,183);path.lineTo(69,162);path.close();
      path.moveTo(152,142);path.quadraticBezierTo(159,137,167,142);
      path.lineTo(171,163);path.lineTo(179,180);path.lineTo(175,194);
      path.lineTo(158,197);path.lineTo(151,181);path.lineTo(155,164);path.close();
    } else {
      final dy=body=='male'?3.0:0.0;
      path.moveTo(67,140+dy);path.quadraticBezierTo(76,136+dy,85,142+dy);
      path.lineTo(80,167+dy);path.lineTo(85,186+dy);path.lineTo(77,198+dy);
      path.lineTo(62,197+dy);path.lineTo(57,183+dy);path.lineTo(63,167+dy);path.close();
      path.moveTo(154,142+dy);path.quadraticBezierTo(161,137+dy,170,142+dy);
      path.lineTo(175,167+dy);path.lineTo(182,184+dy);path.lineTo(177,198+dy);
      path.lineTo(162,201+dy);path.lineTo(153,188+dy);path.lineTo(157,169+dy);path.close();
    }
    return path.transform((Matrix4.identity()..scale(scale,scale)).storage)
      .shift(Offset(left,top));
  }
  @override
  bool shouldReclip(covariant QuestwellCloakForegroundClipper oldClipper) => oldClipper.body!=body;
}

/// Upper sleeves remain underneath the capelet; only the lower forearms and
/// the contoured neck emerge above it. Source shading supplies the overlap.
class QuestwellCloakForeground extends StatelessWidget {
  const QuestwellCloakForeground({super.key, required this.body, required this.children});
  final String body;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => IgnorePointer(child:
    ClipPath(clipper: QuestwellCloakForegroundClipper(body),
      child: Stack(fit: StackFit.expand, children: children)));
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
    final female = body=='female';
    final path = Path()
      ..moveTo(106,94)..lineTo(136,94)
      ..quadraticBezierTo(146,102,female ? 154 : 157,118)
      // Sleeves remain whole beneath the outer capelet, avoiding cut shoulders.
      ..quadraticBezierTo(162,123,180,123)
      ..lineTo(240,123)..lineTo(240,202)..lineTo(153,202)
      // The undercoat finishes inside the outer drapes, above the boot line.
      ..quadraticBezierTo(144,236,136,265)
      ..quadraticBezierTo(121,271,104,265)
      ..quadraticBezierTo(97,238,89,202)
      ..lineTo(0,202)..lineTo(0,123)..lineTo(60,123)
      ..quadraticBezierTo(76,123,female ? 84 : 81,118)
      ..quadraticBezierTo(96,102,106,94)..close();
    return path.transform((Matrix4.identity()..scale(scale,scale)).storage)
      .shift(Offset(dx,dy));
  }
  @override
  bool shouldReclip(covariant QuestwellCloakUnderlayerClipper oldClipper) => oldClipper.body!=body;
}
