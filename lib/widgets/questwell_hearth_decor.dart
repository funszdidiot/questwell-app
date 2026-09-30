import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'questwell_bookshelf.dart';
import 'questwell_fern.dart';
import 'questwell_reading_chair.dart';

/// Authored furniture proportions and floor anchors shared by every Hearth view.
class QuestwellHearthDecor {
  static Map<String, String> choices(String slug) => switch (slug) {
    QuestwellBookshelf.slug => const {'left': 'Left wall', 'right': 'Right wall'},
    QuestwellReadingChair.slug => const {'front': 'Left floor', 'right': 'Right floor'},
    _ => const {'left': 'Beside the fireplace', 'right': 'Near the window', 'front': 'Foreground'},
  };
  static double floorDepth(String slug, String slot) =>
    slug == QuestwellBookshelf.slug ? .68
      : slug == QuestwellFern.slug && slot != 'front' ? .70 : .86;

  static List<String> backToFront(Map<String, String> equipment) {
    String slug(String slot) => equipment['room:$slot'] ??
      (slot == 'right' ? equipment['room'] : null) ?? '';
    return ['left', 'right', 'front']..sort((a, b) {
      final depth = floorDepth(slug(a), a).compareTo(floorDepth(slug(b), b));
      return depth != 0 ? depth : ['left', 'right', 'front'].indexOf(a)
        .compareTo(['left', 'right', 'front'].indexOf(b));
    });
  }

  static Positioned positioned({
    required String slug, required String slot, required Size scene,
  }) {
    final shelf = slug == QuestwellBookshelf.slug;
    final fern = slug == QuestwellFern.slug;
    final front = slot == 'front';
    final chair = !shelf && !fern;
    final ratio = shelf ? 1225 / 1284 : fern ? 1244 / 1264 : 1312 / 1199;
    // Use the same authored avatar scale as the scene. A chair is adult-sized;
    // its seat is near knee height. Overlap is intentional, never a reason to
    // shrink furniture. Width limits only protect the outer frame.
    final avatarHeight = math.min(scene.height * .76, scene.width * .62 * 4 / 3);
    final height = math.min(
      avatarHeight * (shelf ? .65 : fern ? (front ? .43 : .40) : .62),
      scene.width * (shelf ? .44 : fern ? .30 : .50) / ratio,
    );
    final width = height * ratio;
    final center = shelf
      ? (slot == 'right' ? scene.width * .98 - width / 2 : scene.width * .17 + width / 2)
      : scene.width * (chair ? (slot == 'right' ? .73 : .27)
        : front ? .20 : slot == 'left' ? .28 : .81);
    // The back wall meets the floor around .67; the avatar's boots are at .88.
    // Furniture rests between those planes and is painted behind the avatar.
    final floor = scene.height * floorDepth(slug, slot);
    final art = shelf ? const QuestwellBookshelf()
      : fern ? const QuestwellFern() : const QuestwellReadingChair();
    return Positioned(
      key: ValueKey(shelf ? 'hearth-bookshelf-bounds'
        : fern ? 'hearth-fern-bounds' : 'hearth-chair-bounds'),
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
          flipX: !shelf && !fern && slot != 'right',
          child: art,
        ),
      ]),
    );
  }
}
