import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// The room plate and its registered overlays share one cover transform.
class QuestwellRoomGeometry {
  QuestwellRoomGeometry(Size source, Size scene)
      : scale = math.max(
          scene.width / source.width,
          scene.height / source.height,
        ),
        _source = source,
        _scene = scene;

  static const alignment = Alignment(0, .04);
  final double scale;
  final Size _source, _scene;

  static Size sourceForSetting(String? setting) => setting == 'hallowed-hearth'
      ? const Size(1536, 1024)
      : const Size(1254, 1254);

  factory QuestwellRoomGeometry.forSetting(String? setting, Size scene) =>
      QuestwellRoomGeometry(sourceForSetting(setting), scene);

  Offset get origin => Offset(
        (_scene.width - _source.width * scale) / 2,
        (_scene.height - _source.height * scale) * .52,
      );

  Offset point(Offset sourcePoint) => origin + sourcePoint * scale;

  Float64List get matrix => Float64List.fromList([
        scale,
        0,
        0,
        0,
        0,
        scale,
        0,
        0,
        0,
        0,
        1,
        0,
        origin.dx,
        origin.dy,
        0,
        1,
      ]);
}
