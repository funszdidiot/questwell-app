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
    : 'assets/images/questwell_moss_cloak_v2.webp';
  static Rect bounds(String body, String slug) {
    final mantle = slug == 'hearthguard-mantle';
    final width = switch (body) {
      'male' => 258.0,
      'female' => 214.0,
      _ => 226.0,
    };
    final top = switch (body) {
      'male' => 75.0,
      'female' => 76.0,
      _ => 77.0,
    };
    final height = body == 'male' ? 216.0 : 211.0;
    // Continuous cloth covers the intact arms. The raised mantle collar needs
    // its own registration; body/identity pixels are never clipped to fit it.
    return Rect.fromLTWH((240 - width) / 2, top - (mantle ? 8 : 0),
      width, height + (mantle ? 8 : 0));
  }
  static Matrix4 drapeTransform(double width, double height, double lean) {
    const taper = .70;
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

/// Only the head and curved neck emerge above a closed cloak.
class QuestwellCloakForegroundClipper extends CustomClipper<Path> {
  const QuestwellCloakForegroundClipper(this.body);
  final String body;
  @override
  Path getClip(Size size) {
    final scale=math.min(size.width/240,size.height/320);
    final left=(size.width-240*scale)/2, top=size.height-320*scale;
    final female=body=='female';
    // Restore the actual skin contour down into the collar opening. Never
    // restore a horizontal strip of the shirt or cut the neck off at the jaw.
    final head = Path()..addRect(const Rect.fromLTRB(0,0,240,73));
    final path = Path();
    if (body == 'neutral') {
      path.moveTo(112,73);
      path.lineTo(111,80);
      path.quadraticBezierTo(114,87,123,89);
      path.quadraticBezierTo(133,88,135,80);
      path.lineTo(133,73);
    } else if (female) {
      path.moveTo(112,73);
      path.lineTo(110,80);
      path.quadraticBezierTo(113,85,120,86);
      path.quadraticBezierTo(128,85,131,79);
      path.lineTo(129,73);
    } else {
      path.moveTo(108,71);
      path.lineTo(106,77);
      path.quadraticBezierTo(110,85,120,86);
      path.quadraticBezierTo(131,85,135,77);
      path.lineTo(132,71);
    }
    path.close();
    // Union preserves both contours regardless of winding. Appending the
    // opposite-winding neck to the head cuts a hole through their overlap.
    return Path.combine(PathOperation.union, head, path)
      .transform((Matrix4.identity()..scale(scale,scale)).storage)
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

/// Keep the original face, hair, central outfit and legs; hide arms and hands
/// inside the full outer drape without changing the approved source assets.
class QuestwellClosedCloakBodyClipper extends CustomClipper<Path> {
  const QuestwellClosedCloakBodyClipper(this.body);
  final String body;
  @override
  Path getClip(Size size) {
    final scale = math.min(size.width/240,size.height/320);
    final path = Path()
      ..addRect(const Rect.fromLTRB(0,0,240,77))
      ..addRect(const Rect.fromLTRB(100,70,140,205))
      ..addRect(const Rect.fromLTRB(0,205,240,320));
    if (body=='female') {
      path.moveTo(65,70);path.lineTo(107,70);path.lineTo(106,82);
      path.lineTo(93,86);path.lineTo(86,100);path.lineTo(84,117);
      path.lineTo(68,117);path.close();
      path.moveTo(136,70);path.lineTo(174,70);path.lineTo(174,115);
      path.lineTo(156,115);path.lineTo(155,99);path.lineTo(149,90);
      path.lineTo(137,84);path.close();
    }
    return path.transform((Matrix4.identity()..scale(scale,scale)).storage)
      .shift(Offset((size.width-240*scale)/2,size.height-320*scale));
  }
  @override
  bool shouldReclip(covariant QuestwellClosedCloakBodyClipper oldClipper) => oldClipper.body!=body;
}
