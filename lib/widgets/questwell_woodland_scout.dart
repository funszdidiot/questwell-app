import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'questwell_scout_wardrobe.dart';

/// Female fitting candidate. A garment may transform; the base never does.
class QuestwellWoodlandScoutFoundation extends StatelessWidget {
  const QuestwellWoodlandScoutFoundation({super.key, required this.layers});

  final Set<String> layers;
  static const parts = ['trousers', 'shirt', 'boots', 'vest'];

  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        QuestwellScoutWardrobeFoundation.image(
          QuestwellScoutWardrobeFoundation.femaleBaseAsset,
        ),
        for (final part in parts)
          if (layers.contains(part)) QuestwellWoodlandGarment(part: part),
      ]);
}

/// Parameters are mirrored in tool/woodland_scout_fit.json.
class WoodlandGarmentFit {
  const WoodlandGarmentFit(this.scaleX, this.offsetX, this.rows);
  final double scaleX;
  final double offsetX;
  // Each point is (source y, fitted y) on a 240 x 320 canvas.
  final List<Offset> rows;

  static const fits = {
    'shirt': WoodlandGarmentFit(.52, 57.6, [Offset(0, 46.7), Offset(320, 184.3)]),
    'vest': WoodlandGarmentFit(.47, 65, [Offset(0, 49), Offset(320, 199.4)]),
    'trousers': WoodlandGarmentFit(.88, 13, [
      Offset(0, 39.6), Offset(112, 140), Offset(153, 178),
      Offset(202, 229), Offset(245, 266), Offset(288, 283), Offset(320, 297),
    ]),
    'boots': WoodlandGarmentFit(.8, 27, [Offset(0, 57), Offset(320, 313)]),
  };
}

/// Static artwork: image loading is cached by Flutter, with no animation ticker.
class QuestwellWoodlandGarment extends StatefulWidget {
  const QuestwellWoodlandGarment({super.key, required this.part});
  final String part;
  static String asset(String part) =>
      'assets/images/questwell/avatar/woodland_scout_${part}_female_v1.png';

  @override
  State<QuestwellWoodlandGarment> createState() => _QuestwellWoodlandGarmentState();
}

class _QuestwellWoodlandGarmentState extends State<QuestwellWoodlandGarment> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  ImageInfo? _image;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant QuestwellWoodlandGarment oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.part != widget.part) _resolve();
  }

  void _resolve() {
    final stream = AssetImage(QuestwellWoodlandGarment.asset(widget.part))
        .resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    if (_listener != null) _stream?.removeListener(_listener!);
    _image?.dispose();
    _image = null;
    _stream = stream;
    _listener = ImageStreamListener((info, synchronousCall) {
      if (!mounted) { info.dispose(); return; }
      setState(() {
        _image?.dispose();
        _image = info;
      });
    });
    stream.addListener(_listener!);
  }

  @override
  void dispose() {
    if (_listener != null) _stream?.removeListener(_listener!);
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: CustomPaint(
          painter: _WoodlandGarmentPainter(_image?.image, WoodlandGarmentFit.fits[widget.part]!),
          size: Size.infinite,
        ),
      );
}

class _WoodlandGarmentPainter extends CustomPainter {
  const _WoodlandGarmentPainter(this.image, this.fit);
  final ui.Image? image;
  final WoodlandGarmentFit fit;

  @override
  void paint(Canvas canvas, Size size) {
    final sprite = image;
    if (sprite == null) return;
    final scale = math.min(size.width / 240, size.height / 320);
    canvas.save();
    canvas.translate((size.width - 240 * scale) / 2, size.height - 320 * scale);
    canvas.scale(scale);
    final paint = Paint()..filterQuality = FilterQuality.high;
    for (var index = 1; index < fit.rows.length; index++) {
      final start = fit.rows[index - 1], end = fit.rows[index];
      canvas.drawImageRect(sprite,
        Rect.fromLTRB(0, start.dx / 320 * sprite.height,
          sprite.width.toDouble(), end.dx / 320 * sprite.height),
        Rect.fromLTRB(fit.offsetX, start.dy,
          fit.offsetX + 240 * fit.scaleX, end.dy), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WoodlandGarmentPainter oldDelegate) =>
      oldDelegate.image != image || oldDelegate.fit != fit;
}
