import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Separate cape and shoulder layers keep the approved outfit and hands visible.
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
      'female' => Rect.fromLTWH(mantle ? 38 : 36, 74, mantle ? 164 : 168, 210),
      'male' => Rect.fromLTWH(mantle ? 32 : 30, 73, mantle ? 177 : 181, 217),
      _ => Rect.fromLTWH(mantle ? 36 : 34, 76, mantle ? 170 : 174, 211),
    };
  }
  @override
  Widget build(BuildContext context) => IgnorePointer(child: ExcludeSemantics(
    child: LayoutBuilder(builder: (context, constraints) {
      final scale = math.min(constraints.maxWidth / 240, constraints.maxHeight / 320);
      final fit = bounds(bodyType, slug);
      Widget artwork = Image.asset(asset(slug), fit: BoxFit.fill,
        filterQuality: FilterQuality.high, gaplessPlayback: true);
      if (!rear) artwork = ClipPath(
        clipper: _ShoulderCapeletClipper(slug == 'hearthguard-mantle'), child: artwork);
      return Stack(clipBehavior: Clip.none, children: [Positioned(
        left: (constraints.maxWidth - 240*scale)/2 + fit.left*scale,
        top: constraints.maxHeight - 320*scale + fit.top*scale,
        width: fit.width*scale, height: fit.height*scale, child: artwork)]);
    }),
  ));
}

/// Follows each generated capelet hem, rather than a horizontal torso cut.
class _ShoulderCapeletClipper extends CustomClipper<Path> {
  const _ShoulderCapeletClipper(this.mantle);
  final bool mantle;
  @override
  Path getClip(Size size) {
    final points = mantle ? const [
      Offset(0,0),Offset(1,0),Offset(1,.23),Offset(.84,.23),
      Offset(.73,.218),Offset(.68,.235),Offset(.59,.208),Offset(.55,.119),
      Offset(.45,.119),Offset(.40,.205),Offset(.32,.235),Offset(.24,.218),
      Offset(.16,.23),Offset(0,.23),
    ] : const [
      Offset(0,0),Offset(1,0),Offset(1,.176),Offset(.8,.176),
      Offset(.72,.2),Offset(.592,.224),Offset(.56,.122),Offset(.54,.115),
      Offset(.46,.115),Offset(.44,.122),Offset(.41,.224),Offset(.3,.207),
      Offset(.2,.178),Offset(0,.178),
    ];
    return Path()..addPolygon(points.map((p)=>Offset(p.dx*size.width,p.dy*size.height)).toList(),true);
  }
  @override
  bool shouldReclip(covariant _ShoulderCapeletClipper oldClipper) => oldClipper.mantle != mantle;
}
