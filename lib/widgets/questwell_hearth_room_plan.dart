import 'package:flutter/material.dart';

/// Positions, never per-room sprite scaling. Backend slot IDs stay canonical.
class QuestwellHearthRoomPlan {
  const QuestwellHearthRoomPlan(
      this.left, this.right, this.seatLeft, this.seatRight);
  final double left, right, seatLeft, seatRight;
  static QuestwellHearthRoomPlan forSetting(String? slug) => switch (slug) {
        'astral-sanctuary' => const QuestwellHearthRoomPlan(.30, .83, .27, .73),
        'enchanted-library' =>
          const QuestwellHearthRoomPlan(.17, .83, .26, .74),
        'emberglass-conservatory' =>
          const QuestwellHearthRoomPlan(.20, .81, .26, .74),
        'hallowed-hearth' ||
        'midnight-harvest' =>
          const QuestwellHearthRoomPlan(.19, .82, .26, .74),
        'alchemists-workshop' =>
          const QuestwellHearthRoomPlan(.21, .81, .26, .74),
        'midnight-observatory' =>
          const QuestwellHearthRoomPlan(.22, .80, .26, .74),
        _ => const QuestwellHearthRoomPlan(.20, .82, .26, .74),
      };
  double center(String profile, String slot, {required bool chairOnLeft}) =>
      switch (profile) {
        'seating' => slot == 'right' ? seatRight : seatLeft,
        'side_table' => chairOnLeft ? .13 : .87,
        _ => slot == 'front'
            ? .18
            : slot == 'right'
                ? right
                : left,
      };
  static const enabled = bool.fromEnvironment('QUESTWELL_DECORATE_HEARTH');
  static Alignment marker(Rect bounds, Size scene) => Alignment(
      (bounds.center.dx / scene.width * 2 - 1).clamp(-.85, .85),
      (bounds.center.dy / scene.height * 2 - 1).clamp(-.8, .8));
}
