import 'dart:math' as math;
import 'dart:ui' as ui;
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
    final path=Path()..addRect(Rect.fromLTRB(0,0,240,female?82:79));
    // The sleeves emerge below the shoulder cape. Follow the angled forearms,
    // not a horizontal cut across the entire cloak.
    if (female) {
      path.moveTo(77,124);path.quadraticBezierTo(85,121,91,127);
      path.lineTo(84,163);path.quadraticBezierTo(91,180,85,192);
      path.lineTo(69,197);path.lineTo(63,183);path.lineTo(69,162);path.close();
      path.moveTo(149,127);path.quadraticBezierTo(157,122,163,127);
      path.lineTo(171,163);path.lineTo(179,180);path.lineTo(175,194);
      path.lineTo(158,197);path.lineTo(151,181);path.lineTo(155,164);path.close();
    } else {
      final dy=body=='male'?3.0:0.0;
      path.moveTo(71,126+dy);path.quadraticBezierTo(82,122+dy,89,129+dy);
      path.lineTo(80,167+dy);path.lineTo(85,186+dy);path.lineTo(77,198+dy);
      path.lineTo(62,197+dy);path.lineTo(57,183+dy);path.lineTo(63,167+dy);path.close();
      path.moveTo(150,128+dy);path.quadraticBezierTo(159,122+dy,166,128+dy);
      path.lineTo(175,167+dy);path.lineTo(182,184+dy);path.lineTo(177,198+dy);
      path.lineTo(162,201+dy);path.lineTo(153,188+dy);path.lineTo(157,169+dy);path.close();
    }
    return path.transform((Matrix4.identity()..scale(scale,scale)).storage)
      .shift(Offset(left,top));
  }
  @override
  bool shouldReclip(covariant QuestwellCloakForegroundClipper oldClipper) => oldClipper.body!=body;
}

/// Blend the original sleeves out from beneath the capelet instead of exposing
/// a hard cut edge. The head and hands stay fully opaque.
class QuestwellCloakForeground extends StatelessWidget {
  const QuestwellCloakForeground({super.key, required this.body, required this.children});
  final String body;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => IgnorePointer(child: CustomPaint(
    foregroundPainter: _CloakContactShadow(body),
    child: ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) {
        final scale = math.min(rect.width/240, rect.height/320);
        final top = rect.height-320*scale;
        return ui.Gradient.linear(Offset(0,top), Offset(0,top+320*scale),
          const [Colors.white,Colors.white,Colors.transparent,Colors.white,Colors.white],
          const [0,.30,.375,.425,1]);
      },
      child: ClipPath(clipper: QuestwellCloakForegroundClipper(body),
        child: Stack(fit: StackFit.expand, children: children)),
    ),
  ));
}

class _CloakContactShadow extends CustomPainter {
  const _CloakContactShadow(this.body);
  final String body;
  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width/240,size.height/320);
    canvas.save();
    canvas.clipPath(QuestwellCloakForegroundClipper(body).getClip(size));
    canvas.translate((size.width-240*scale)/2,size.height-320*scale);
    canvas.scale(scale);
    final female = body=='female';
    final dy = body=='male' ? 3.0 : 0.0;
    final shadow = Path()
      ..moveTo(female ? 76 : 70, 127+dy)
      ..quadraticBezierTo(female ? 84 : 80,133+dy,female ? 90 : 88,129+dy)
      ..moveTo(150,130+dy)
      ..quadraticBezierTo(158,133+dy,female ? 165 : 168,129+dy);
    canvas.drawPath(shadow, Paint()
      ..color=const Color(0x350C1114)
      ..style=PaintingStyle.stroke
      ..strokeWidth=3
      ..strokeCap=StrokeCap.round
      ..maskFilter=const MaskFilter.blur(BlurStyle.normal,2));
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _CloakContactShadow oldDelegate) => oldDelegate.body!=body;
}
