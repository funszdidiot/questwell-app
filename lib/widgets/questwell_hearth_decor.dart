import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'questwell_bookshelf.dart';
import 'questwell_fern.dart';
import 'questwell_reading_chair.dart';
import 'questwell_reading_table.dart';
import 'questwell_wall_art.dart';
import 'questwell_contact_shadow.dart';
import 'questwell_first_journey.dart';
import 'questwell_starlit_orrery.dart';

/// Authored furniture proportions and floor anchors shared by every Hearth view.
class QuestwellHearthDecor {
  static Map<String, String> choices(String slug) => switch (slug) {
    QuestwellFirstJourney.slug || QuestwellStarlitOrrery.slug => const {'bookshelf_top': 'On the bookcase', 'mantel': 'Fireplace mantel'},
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

  /// A single gallery composition: common centerline and equal frame-edge gaps.
  /// Furniture and the foreground avatar can overlap it without shifting the art.
  static Rect wallArtBounds(Size scene, String slot) {
    final centerWidth = math.min(scene.height * .17 * 1.4, scene.width * .21);
    final sideHeight = math.min(scene.height * .195, scene.width * .12 / .58);
    final sideWidth = sideHeight * .58;
    final middle = Offset(scene.width * .54, scene.height * .175);
    if (slot == 'wall_center') {
      return Rect.fromCenter(center: middle, width: centerWidth, height: centerWidth / 1.4);
    }
    final offset = centerWidth / 2 + scene.width * .035 + sideWidth / 2;
    return Rect.fromCenter(
      center: middle + Offset(slot == 'wall_left' ? -offset : offset, 0),
      width: sideWidth, height: sideHeight);
  }

  static Positioned wallArtPositioned({required String slug, required String side,
    required Size scene}) {
    final rect = wallArtBounds(scene, side);
    return Positioned(key: ValueKey(side == 'wall_center' ? 'hearth-wall-art-bounds' : 'hearth-$side-art-bounds'),
      top: rect.top, left: rect.left, width: rect.width, height: rect.height,
      child: QuestwellWallArt(artSlug: slug));
  }

  static Rect bounds({
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
    ) * (shelf ? .90 : 1.0);
    final width = height * ratio;
    final center = table ? scene.width * (chairOnLeft ? .15 : .85) : shelf
      ? (slot == 'right' ? scene.width * .98 - width / 2 : scene.width * .17 + width / 2)
      : scene.width * (chair ? (slot == 'right' ? (hasTable ? .64 : .73) : (hasTable ? .36 : .27))
        : front ? .20 : slot == 'left' ? .28 : .81);
    // The back wall meets the floor around .67; the avatar's boots are at .88.
    // Furniture rests between those planes and is painted behind the avatar.
    final floor = scene.height * floorDepth(slug, slot);
    return Rect.fromLTWH(center - width / 2, floor - height, width, height);
  }

  static Positioned trophyPositioned({String slug = QuestwellFirstJourney.slug, required String slot, required Size scene,
    required Map<String, String> equipment}) {
    final shelfSlot = equipment['room:right'] == QuestwellBookshelf.slug ? 'right' : 'left';
    final shelf = bounds(slug: QuestwellBookshelf.slug, slot: shelfSlot, scene: scene, equipment: equipment);
    final orrery = slug == QuestwellStarlitOrrery.slug;
    final height = math.min(scene.height * (orrery ? .13 : .105), scene.width * (orrery ? .12 : .10));
    final width = height * 1312 / 1199;
    final onShelf = slot == 'bookshelf_top';
    // The mantel belongs to the square room texture. Follow its BoxFit.cover
    // crop and Alignment(0, .04), so the base stays on the wood at any aspect ratio.
    final roomSide = math.max(scene.width, scene.height);
    final center = onShelf ? shelf.left + shelf.width * (shelfSlot == 'right' ? .78 : .23)
      : roomSide * .075 + (scene.width - roomSide) / 2;
    final surface = onShelf ? shelf.top + shelf.height * .12
      : roomSide * .338 + (scene.height - roomSide) * .52;
    return Positioned(key: ValueKey(orrery ? 'hearth-orrery-bounds' : 'hearth-trophy-bounds'),
      left: center - width * (orrery ? .50 : .52), top: surface - height * (orrery ? .98 : .94),
      width: width, height: height,
      child: Stack(fit: StackFit.expand, children: [
        Positioned(left: width * .20, right: width * .10, top: height * (orrery ? .95 : .90), height: height * .06,
          child: DecoratedBox(decoration: BoxDecoration(borderRadius: BorderRadius.circular(100),
            gradient: const RadialGradient(radius: .6, colors: [Color(0x550E0906),Color(0x000E0906)])))),
        if (orrery) const QuestwellStarlitOrrery() else const QuestwellFirstJourney(),
      ]));
  }

  static Positioned positioned({required String slug, required String slot, required Size scene,
    Map<String, String> equipment = const {}}) {
    final shelf = slug == QuestwellBookshelf.slug;
    final fern = slug == QuestwellFern.slug;
    final table = slug == QuestwellReadingTable.slug;
    final chair = slug == QuestwellReadingChair.slug;
    final rect = bounds(slug: slug, slot: slot, scene: scene, equipment: equipment);
    final art = shelf ? const QuestwellBookshelf()
      : fern ? const QuestwellFern() : table ? const QuestwellReadingTable() : const QuestwellReadingChair();
    return Positioned(
      key: ValueKey(shelf ? 'hearth-bookshelf-bounds'
        : fern ? 'hearth-fern-bounds' : table ? 'hearth-table-bounds' : 'hearth-chair-bounds'),
      left: rect.left, top: rect.top,
      width: rect.width, height: rect.height,
      child: Transform.flip(
        key: ValueKey('hearth-$slug-facing'),
        flipX: chair && slot != 'right',
        child: Stack(fit: StackFit.expand, children: [
          IgnorePointer(child: CustomPaint(
            key: ValueKey('hearth-$slug-contact-shadow'),
            painter: QuestwellContactShadowPainter(slug))),
          art,
        ]),
      ),
    );
  }
}
