import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Clean anatomy plus immutable identity. Clothing is a separate layer.
class QuestwellCleanBase extends StatelessWidget {
  const QuestwellCleanBase({super.key, required this.body, this.withTrousers = false});
  final String body;
  final bool withTrousers;
  Widget _image(String path) => Image.asset(path, fit: BoxFit.contain,
    alignment: Alignment.bottomCenter, filterQuality: FilterQuality.high,
    gaplessPlayback: true);
  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
    ClipPath(clipper: CleanBaseClipper(body, withTrousers ? 'dressedAnatomy' : 'anatomy'),
      child: _image('assets/images/questwell/avatar/base/clean_${body}_v1.webp')),
    ClipPath(clipper: CleanBaseClipper(body, withTrousers ? 'dressedIdentity' : 'identity'),
      child: _image('assets/images/questwell/avatar/base/base_$body.webp')),
    if (withTrousers) ClipPath(clipper: CleanBaseClipper(body, 'trousers'),
      child: _image('assets/images/questwell/avatar/base/base_$body.webp')),
  ]);
}

/// Coordinates from tool/clean_base_layers.json on the shared 240 x 320 canvas.
class CleanBaseClipper extends CustomClipper<Path> {
  const CleanBaseClipper(this.body, this.part);
  final String body;
  final String part;
  static const polygons = <String, List<List<Offset>>>{
    'neutral:dressedIdentity': [
[Offset(0, 0), Offset(240, 0), Offset(240, 74), Offset(0, 74)],
[Offset(65, 171), Offset(80, 171), Offset(84, 178), Offset(88, 183), Offset(88, 199), Offset(58, 199), Offset(58, 184), Offset(64, 178)],
[Offset(157, 171), Offset(177, 171), Offset(183, 199), Offset(152, 199), Offset(152, 182), Offset(156, 177)]
    ],
    'male:dressedIdentity': [
[Offset(0, 0), Offset(240, 0), Offset(240, 74), Offset(0, 74)],
[Offset(64, 171), Offset(79, 171), Offset(82, 178), Offset(85, 183), Offset(85, 200), Offset(56, 200), Offset(56, 181), Offset(62, 176)],
[Offset(158, 171), Offset(179, 171), Offset(184, 200), Offset(153, 200), Offset(153, 183), Offset(157, 176)]
    ],
    'female:dressedIdentity': [
[Offset(0, 0), Offset(240, 0), Offset(240, 74), Offset(0, 74)],
[Offset(65, 65), Offset(110, 65), Offset(108, 77), Offset(99, 81), Offset(89, 85), Offset(87, 90), Offset(83, 95), Offset(81, 106), Offset(77, 112), Offset(68, 113)],
[Offset(132, 65), Offset(174, 65), Offset(174, 116), Offset(156, 116), Offset(153, 104), Offset(154, 96), Offset(150, 86), Offset(140, 80), Offset(134, 78)],
[Offset(62, 167), Offset(87, 167), Offset(87, 195), Offset(62, 195)],
[Offset(151, 167), Offset(179, 167), Offset(179, 195), Offset(151, 195)]
    ],
    'female:identity': [
[Offset(0, 0), Offset(240, 0), Offset(240, 74), Offset(0, 74)],
[Offset(65, 65), Offset(110, 65), Offset(108, 77), Offset(99, 81), Offset(89, 85), Offset(87, 90), Offset(83, 95), Offset(81, 106), Offset(77, 112), Offset(68, 113)],
[Offset(132, 65), Offset(174, 65), Offset(174, 116), Offset(156, 116), Offset(153, 104), Offset(154, 96), Offset(150, 86), Offset(140, 80), Offset(134, 78)],
[Offset(67, 174), Offset(80, 174), Offset(84, 186), Offset(80, 193), Offset(68, 193), Offset(64, 183)],
[Offset(156, 174), Offset(170, 174), Offset(175, 186), Offset(168, 193), Offset(155, 192), Offset(152, 181)]
    ],
    'female:anatomy': [
[Offset(110, 68), Offset(130, 68), Offset(131, 80), Offset(149, 86), Offset(155, 95), Offset(158, 116), Offset(177, 164), Offset(190, 202), Offset(240, 202), Offset(240, 320), Offset(0, 320), Offset(0, 202), Offset(50, 202), Offset(65, 164), Offset(80, 117), Offset(84, 94), Offset(91, 85), Offset(109, 80)]
    ],
    'female:trousers': [
[Offset(105, 148), Offset(140, 148), Offset(145, 177), Offset(155, 196), Offset(240, 196), Offset(240, 320), Offset(0, 320), Offset(0, 196), Offset(90, 196), Offset(99, 176)]
    ],
    'male:identity': [
[Offset(0, 0), Offset(240, 0), Offset(240, 74), Offset(0, 74)],
[Offset(62, 177), Offset(77, 177), Offset(82, 181), Offset(83, 191), Offset(80, 198), Offset(65, 198), Offset(59, 187)],
[Offset(160, 177), Offset(178, 177), Offset(181, 190), Offset(175, 197), Offset(158, 197), Offset(155, 189)]
    ],
    'male:anatomy': [
[Offset(108, 68), Offset(134, 68), Offset(134, 79), Offset(168, 88), Offset(190, 202), Offset(240, 202), Offset(240, 320), Offset(0, 320), Offset(0, 202), Offset(52, 202), Offset(72, 90), Offset(108, 79)]
    ],
    'male:trousers': [
[Offset(106, 154), Offset(140, 154), Offset(145, 180), Offset(154, 200), Offset(240, 200), Offset(240, 320), Offset(0, 320), Offset(0, 200), Offset(92, 200), Offset(101, 179)]
    ],
    'neutral:identity': [
[Offset(0, 0), Offset(240, 0), Offset(240, 74), Offset(0, 74)],
[Offset(66, 176), Offset(79, 176), Offset(84, 182), Offset(85, 191), Offset(81, 197), Offset(66, 197), Offset(62, 187)],
[Offset(159, 176), Offset(177, 176), Offset(182, 190), Offset(176, 197), Offset(158, 197), Offset(155, 189)]
    ],
    'neutral:anatomy': [
[Offset(108, 68), Offset(134, 68), Offset(134, 79), Offset(168, 88), Offset(190, 202), Offset(240, 202), Offset(240, 320), Offset(0, 320), Offset(0, 202), Offset(52, 202), Offset(72, 90), Offset(108, 79)]
    ],
    'neutral:trousers': [
[Offset(106, 153), Offset(141, 153), Offset(147, 180), Offset(155, 200), Offset(240, 200), Offset(240, 320), Offset(0, 320), Offset(0, 200), Offset(91, 200), Offset(100, 181)]
    ],
  };
  @override
  Path getClip(Size size) {
    final path = Path();
    for (final polygon in polygons['$body:${part == 'dressedAnatomy' ? 'anatomy' : part}'] ?? polygons['neutral:${part == 'dressedAnatomy' ? 'anatomy' : part}']!) {
      path.addPolygon(polygon, true);
    }
    var result = path;
    if (part == 'anatomy' || part == 'dressedAnatomy') {
      final y = body == 'female' ? 174.0 : body == 'male' ? 177.0 : 176.0;
      result = Path.combine(PathOperation.difference, path, Path()
        ..addRect(Rect.fromLTRB(0, y, 90, 202))
        ..addRect(Rect.fromLTRB(150, y, 240, 202)));
    }
    if (part == 'dressedAnatomy') {
      final waist = body == 'female' ? 148.0 : body == 'male' ? 154.0 : 153.0;
      result = Path.combine(PathOperation.intersect, result,
        Path()..addRect(Rect.fromLTRB(0, 0, 240, waist)));
    }
    final scale = math.min(size.width / 240, size.height / 320);
    final dx = (size.width - 240 * scale) / 2;
    final dy = size.height - 320 * scale;
    return result.transform((Matrix4.identity()..scale(scale, scale)).storage)
      .shift(Offset(dx, dy));
  }
  @override
  bool shouldReclip(covariant CleanBaseClipper oldClipper) =>
    body != oldClipper.body || part != oldClipper.part;
}
