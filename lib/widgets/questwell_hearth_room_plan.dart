import 'package:flutter/material.dart';

/// Room architecture sets anchors; family geometry keeps every sprite its size.
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
            .19,
            .84,
            .25,
            .75,
            .75,
            .76,
          ),
        'enchanted-library' => const QuestwellHearthRoomPlan(
            .18,
            .83,
            .25,
            .75,
            .74,
            .75,
          ),
        'emberglass-conservatory' => const QuestwellHearthRoomPlan(
            .18,
            .83,
            .25,
            .75,
            .75,
            .76,
          ),
        'hallowed-hearth' ||
        'midnight-harvest' =>
          const QuestwellHearthRoomPlan(
            .18,
            .84,
            .25,
            .75,
            .75,
            .77,
          ),
        'woodland-cottage' => const QuestwellHearthRoomPlan(
            .18,
            .82,
            .25,
            .75,
            .74,
            .75,
          ),
        'alchemists-workshop' => const QuestwellHearthRoomPlan(
            .19,
            .83,
            .25,
            .75,
            .75,
            .76,
          ),
        'midnight-observatory' => const QuestwellHearthRoomPlan(
            .19,
            .82,
            .25,
            .75,
            .74,
            .75,
          ),
        _ => const QuestwellHearthRoomPlan(.18, .83, .25, .75, .74, .75),
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

  double? floor(String profile, String slot) => switch (profile) {
        'large_furniture' => slot == 'right' ? rearRightFloor : rearLeftFloor,
        'seating' => .88,
        'side_table' => .91,
        _ => null,
      };

  static const enabled = bool.fromEnvironment('QUESTWELL_DECORATE_HEARTH');
  static Alignment marker(Rect bounds, Size scene) => Alignment(
        (bounds.center.dx / scene.width * 2 - 1).clamp(-.85, .85),
        (bounds.center.dy / scene.height * 2 - 1).clamp(-.8, .8),
      );
}
