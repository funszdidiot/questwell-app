import 'package:flutter/material.dart';
import 'questwell_room_geometry.dart';

/// Normalized source-art anchors, before the room cover crop.
/// Family scale and contact metadata remain independent of item artwork.
class QuestwellHearthRoomPlan {
  const QuestwellHearthRoomPlan(
    this.left,
    this.right,
    this.seatLeft,
    this.seatRight,
    this.rearLeftFloor,
    this.rearRightFloor,
  );
  final double left, right, seatLeft, seatRight;
  final double rearLeftFloor, rearRightFloor;

  static QuestwellHearthRoomPlan forSetting(String? slug) => switch (slug) {
        'astral-sanctuary' => const QuestwellHearthRoomPlan(
            .25,
            .78,
            .25,
            .75,
            .64,
            .65,
          ),
        'enchanted-library' => const QuestwellHearthRoomPlan(
            .25,
            .78,
            .25,
            .75,
            .64,
            .65,
          ),
        'emberglass-conservatory' => const QuestwellHearthRoomPlan(
            .25,
            .78,
            .25,
            .75,
            .64,
            .65,
          ),
        'hallowed-hearth' => const QuestwellHearthRoomPlan(
            .18,
            .77,
            .25,
            .75,
            .63,
            .63,
          ),
        'woodland-cottage' => const QuestwellHearthRoomPlan(
            .25,
            .78,
            .25,
            .75,
            .64,
            .65,
          ),
        'alchemists-workshop' => const QuestwellHearthRoomPlan(
            .25,
            .78,
            .25,
            .75,
            .64,
            .65,
          ),
        'midnight-observatory' => const QuestwellHearthRoomPlan(
            .25,
            .78,
            .25,
            .75,
            .64,
            .65,
          ),
        _ => const QuestwellHearthRoomPlan(.25, .78, .25, .75, .64, .65),
      };

  double center(
    String profile,
    String slot, {
    required bool chairOnLeft,
    bool chairOnRight = false,
    bool largeOnRight = false,
  }) =>
      switch (profile) {
        'seating' => slot == 'right' ? seatRight : seatLeft,
        // The table belongs beside its chair. Without a chair, use the
        // foreground opposite the right-hand cabinet instead of stacking them.
        'side_table' => chairOnLeft
            ? seatLeft - .13
            : chairOnRight
                ? seatRight + .13
                : largeOnRight
                    ? seatLeft - .13
                    : seatRight + .13,
        _ => slot == 'front'
            ? .18
            : slot == 'right'
                ? right
                : left,
      };

  bool isRear(String profile, String slot) =>
      profile == 'large_furniture' ||
      profile == 'pedestal_light' ||
      ((profile == 'plant' || profile == 'relic_display') && slot != 'front');

  double floor(String profile, String slot) => isRear(profile, slot)
      ? (slot == 'right' ? rearRightFloor : rearLeftFloor)
      : profile == 'side_table'
          ? .91
          : .88;

  /// Wall fixtures follow the room's actual source crop. Floor seating is
  /// composed inside the visible floor, so portrait crops cannot lose a chair.
  Offset anchor(
    String profile,
    String slot,
    Size scene,
    String? setting, {
    required double centerX,
  }) {
    final geometry = QuestwellRoomGeometry.forSetting(setting, scene);
    final source = QuestwellRoomGeometry.sourceForSetting(setting);
    if (isRear(profile, slot)) {
      return geometry.point(
        Offset(centerX * source.width, floor(profile, slot) * source.height),
      );
    }
    final wall = geometry.point(Offset(0, .60 * source.height)).dy;
    final contact =
        wall + (scene.height - wall) * (profile == 'side_table' ? .79 : .70);
    return Offset(scene.width * centerX, contact);
  }

  static const enabled = bool.fromEnvironment('QUESTWELL_DECORATE_HEARTH');
  static Alignment marker(Rect bounds, Size scene) => Alignment(
        (bounds.center.dx / scene.width * 2 - 1).clamp(-.85, .85),
        (bounds.center.dy / scene.height * 2 - 1).clamp(-.8, .8),
      );
}
