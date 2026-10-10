import 'package:flutter/material.dart';
import 'questwell_room_geometry.dart';

/// Two architectural maps. Artistic room skins never override their geometry.
/// Positions, floor contacts and family heights are in source-art coordinates;
/// the entire arrangement follows the room camera as one spatial composition.
class QuestwellHearthRoomPlan {
  const QuestwellHearthRoomPlan._({
    required this.layout,
    required this.left,
    required this.right,
    required this.rearFloor,
    required this.rearRightFloor,
    required this.seatFloor,
    required this.seatHeight,
    required this.tableHeight,
  });

  final QuestwellRoomLayout layout;
  final double left,
      right,
      rearFloor,
      rearRightFloor,
      seatFloor,
      seatHeight,
      tableHeight;
  double get seatLeft => .285;
  double get seatRight => .715;

  // Standard: the flat rear wall begins beyond the fireplace/post at x=.245.
  // A wide cabinet must start there, not straddle that post or the hearth.
  static const standard = QuestwellHearthRoomPlan._(
    layout: QuestwellRoomLayout.standard,
    left: .38,
    right: .68,
    rearFloor: .615,
    rearRightFloor: .615,
    seatFloor: .78,
    seatHeight: .28,
    tableHeight: .16,
  );

  // Hallowed: the chimney occupies the middle-left rear wall. Keep cabinets
  // in the left alcove and right window bay, clear of the fire opening.
  static const hallowed = QuestwellHearthRoomPlan._(
    layout: QuestwellRoomLayout.hallowed,
    left: .145,
    right: .775,
    rearFloor: .60,
    rearRightFloor: .59,
    seatFloor: .82,
    seatHeight: .42,
    tableHeight: .24,
  );

  static QuestwellHearthRoomPlan forSetting(String? slug) =>
      QuestwellRoomGeometry.layoutForSetting(slug) ==
              QuestwellRoomLayout.hallowed
          ? hallowed
          : standard;

  double center(
    String profile,
    String slot, {
    required bool chairOnLeft,
    bool chairOnRight = false,
    bool largeOnRight = false,
  }) =>
      switch (profile) {
        'large_furniture' => slot == 'right' ? right : left,
        'seating' => slot == 'right' ? seatRight : seatLeft,
        // A compact table sits outside its chair, with a small arm-edge
        // overlap only. It must not cover the chair's sitting surface.
        'side_table' =>
          chairOnLeft || (!chairOnRight && largeOnRight) ? .075 : .925,
        _ => slot == 'front'
            ? .18
            : slot == 'right'
                ? (layout == QuestwellRoomLayout.hallowed ? .86 : .79)
                : (layout == QuestwellRoomLayout.hallowed ? .16 : .29),
      };

  bool isRear(String profile, String slot) =>
      profile == 'large_furniture' ||
      profile == 'pedestal_light' ||
      ((profile == 'plant' || profile == 'relic_display') && slot != 'front');

  /// Relative to source height, not avatar or viewport height. Cabinet backs
  /// meet the wall; lower objects can occupy the floor beside the hearth.
  double height(String profile, String slot) => switch (profile) {
        'large_furniture' => .235,
        'pedestal_light' => .264,
        'seating' => seatHeight,
        'side_table' => tableHeight,
        'plant' => slot == 'front' ? seatHeight * .72 : .203,
        'relic_display' => slot == 'front' ? seatHeight * .78 : .203,
        _ => .203,
      };

  double floor(String profile, String slot) => switch (profile) {
        'large_furniture' => slot == 'right' ? rearRightFloor : rearFloor,
        'pedestal_light' => rearFloor + .015,
        'plant' || 'relic_display' when slot != 'front' => rearFloor + .02,
        'side_table' => seatFloor + .015,
        _ => seatFloor,
      };

  Offset anchor(
    String profile,
    String slot,
    Size scene,
    String? setting, {
    required double centerX,
  }) {
    final geometry = QuestwellRoomGeometry.forSetting(setting, scene);
    final source = QuestwellRoomGeometry.sourceForSetting(setting);
    return geometry.point(
      Offset(centerX * source.width, floor(profile, slot) * source.height),
    );
  }

  static const enabled = bool.fromEnvironment('QUESTWELL_DECORATE_HEARTH');
  static Alignment marker(Rect bounds, Size scene) => Alignment(
        (bounds.center.dx / scene.width * 2 - 1).clamp(-.85, .85),
        (bounds.center.dy / scene.height * 2 - 1).clamp(-.8, .8),
      );
}
