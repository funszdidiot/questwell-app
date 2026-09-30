import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'questwell_bookshelf.dart';
import 'questwell_fern.dart';
import 'questwell_reading_chair.dart';
import 'questwell_reading_table.dart';
import 'questwell_wall_art.dart';

/// Authored furniture proportions and floor anchors shared by every Hearth view.
class QuestwellHearthDecor {
  static Map<String, String> choices(String slug) => switch (slug) {
    QuestwellWallArt.fern || QuestwellWallArt.celestial => const {'wall_left': 'Left wall', 'wall_right': 'Right wall'},
    QuestwellReadingTable.slug => const {'side': 'Beside the chair'},
    QuestwellBookshelf.slug => const {'left': 'Left wall', 'right': 'Right wall'},
    QuestwellReadingChair.slug => const {'front': 'Left floor', 'right': 'Right floor'},
    _ => const {'left': 'Beside the fireplace', 'right': 'Near the window', 'front': 'Foreground'},
  };
  static double floorDepth(String slug, String slot) =>
    slug == QuestwellReadingTable.slug ? .89
      : slug == QuestwellBookshelf.slug ? .68
      : slug == QuestwellFern.slug && slot != 'front' ? .70 : .86;

  static List<String> backToFront(Map<String, String> equipment) {
    String slug(String slot) => equipment['room:$slot'] ??
      (slot == 'right' ? equipment['room'] : null) ?? '';
    return ['left', 'right', 'front', 'side']..sort((a, b) {
      final depth = floorDepth(slug(a), a).compareTo(floorDepth(slug(b), b));
      return depth != 0 ? depth : ['left', 'right', 'front', 'side'].indexOf(a)
        .compareTo(['left', 'right', 'front', 'side'].indexOf(b));
    });
  }

  static Positioned positioned({
    required String slug, required String slot, required Size scene,
    Map<String, String> equipment = const {},
  }) {
    final shelf = slug == QuestwellBookshelf.slug;
    final fern = slug == QuestwellFern.slug;
    final front = slot == 'front';
    final table = slug == QuestwellReadingTable.slug;
    final chair = slug == QuestwellReadingChair.slug;
    final hasTable = equipment['room:side'] == QuestwellReadingTable.slug;
    final chairOnLeft = equipment['room:front'] == QuestwellReadingChair.slug ||
      equipment['room:left'] == QuestwellReadingChair.slug;
    final ratio = shelf ? 1225 / 1284 : fern ? 1244 / 1264 : table ? 1213 / 1296 : 1312 / 1199;
    // Use the same authored avatar scale as the scene. A chair is adult-sized;
    // its seat is near knee height. Overlap is intentional, never a reason to
    // shrink furniture. Width limits only protect the outer frame.
    final avatarHeight = math.min(scene.height * .76, scene.width * .62 * 4 / 3);
    final height = math.min(
      avatarHeight * (table ? .49 : shelf ? .65 : fern ? (front ? .43 : .40) : .62),
      scene.width * (table ? .28 : shelf ? .44 : fern ? .30 : .50) / ratio,
    );
    final width = height * ratio;
    final center = table ? scene.width * (chairOnLeft ? .15 : .85) : shelf
      ? (slot == 'right' ? scene.width * .98 - width / 2 : scene.width * .17 + width / 2)
      : scene.width * (chair ? (slot == 'right' ? (hasTable ? .64 : .73) : (hasTable ? .36 : .27))
        : front ? .20 : slot == 'left' ? .28 : .81);
    // The back wall meets the floor around .67; the avatar's boots are at .88.
    // Furniture rests between those planes and is painted behind the avatar.
    final floor = scene.height * floorDepth(slug, slot);
    final art = shelf ? const QuestwellBookshelf()
      : fern ? const QuestwellFern() : table ? const QuestwellReadingTable() : const QuestwellReadingChair();
    return Positioned(
      key: ValueKey(shelf ? 'hearth-bookshelf-bounds'
        : fern ? 'hearth-fern-bounds' : table ? 'hearth-table-bounds' : 'hearth-chair-bounds'),
      left: center - width / 2, top: floor - height,
      width: width, height: height,
      child: Stack(fit: StackFit.expand, children: [
        Positioned(left: width * .15, right: width * .15, bottom: 0,
          height: height * (chair ? .10 : .055),
          child: DecoratedBox(decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: const RadialGradient(radius: .65, colors: [
              Color(0x700E0906), Color(0x000E0906),
            ]),
          ))),
        // The source chair opens toward the left. On the left side of the room
        // mirror only its artwork so the seat opens toward the room's center.
        Transform.flip(
          key: ValueKey('hearth-$slug-facing'),
          flipX: chair && slot != 'right',
          child: art,
        ),
      ]),
    );
  }
}
