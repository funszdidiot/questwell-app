import 'dart:math' as math;
import 'questwell_mastery_relic.dart';
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
  static Map<String, String> choices(String slug) => QuestwellMasteryRelic.supports(slug)
    ? const {'mantel': 'On the fireplace mantel', 'bookshelf_top': 'On the bookcase',
      'left': 'Back left pedestal', 'right': 'Back right pedestal',
      'front': 'Front left pedestal'}
    : switch (slug) {
    'woodland-cottage' || 'midnight-harvest' || 'enchanted-library' || 'midnight-observatory' || 'alchemists-workshop' || 'astral-sanctuary' || 'emberglass-conservatory' => const {'setting': 'Hearth setting'},
    'emerald-wayfarer-rug' => const {'floor': 'Beneath the adventurer'},
    'rainy-window' => const {'window': 'Window alcove'},
    QuestwellFirstJourney.slug || QuestwellStarlitOrrery.slug => const {'bookshelf_top': 'On the bookcase', 'mantel': 'Fireplace mantel'},
    QuestwellWallArt.fern || QuestwellWallArt.celestial => const {'wall_left': 'Left wall', 'wall_right': 'Right wall'},
    QuestwellReadingTable.slug => const {'side': 'Beside the chair'},
    QuestwellBookshelf.slug => const {'left': 'Left wall', 'right': 'Right wall'},
    QuestwellReadingChair.slug => const {'front': 'Left floor', 'right': 'Right floor'},
    _ => const {'left': 'Beside the fireplace', 'right': 'Near the window', 'front': 'Foreground'},
  };
  static double floorDepth(String slug, String slot) =>
    QuestwellMasteryRelic.supports(slug) ? (slot == 'front' ? .89 : .68) : slug == QuestwellReadingTable.slug ? .89
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
  static Rect wallArtBounds(Size scene, String slot, {bool library = false}) {
    if (library) {
      // Keep the gallery inside the emerald arch, following the square room's
      // BoxFit.cover crop instead of the generic room's wider wall anchors.
      final roomSide = math.max(scene.width, scene.height);
      final origin = Offset((scene.width - roomSide) / 2,
        (scene.height - roomSide) * .52);
      final center = slot == 'wall_center';
      final width = roomSide * (center ? .14 : .065);
      final x = slot == 'wall_left' ? .365 : slot == 'wall_right' ? .635 : .50;
      return Rect.fromCenter(center: origin + Offset(roomSide * x, roomSide * .205),
        width: width, height: width / (center ? 1.4 : .58));
    }
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
    required Size scene, bool library = false}) {
    final rect = wallArtBounds(scene, side, library: library);
    return Positioned(key: ValueKey(side == 'wall_center' ? 'hearth-wall-art-bounds' : 'hearth-$side-art-bounds'),
      top: rect.top, left: rect.left, width: rect.width, height: rect.height,
      child: QuestwellWallArt(artSlug: slug));
  }

  static Rect bounds({
    required String slug, required String slot, required Size scene,
    Map<String, String> equipment = const {},
  }) {
    final relic = QuestwellMasteryRelic.supports(slug);
    final shelf = slug == QuestwellBookshelf.slug;
    final fern = slug == QuestwellFern.slug;
    final front = slot == 'front';
    final table = slug == QuestwellReadingTable.slug;
    final chair = slug == QuestwellReadingChair.slug;
    final hasTable = equipment['room:side'] == QuestwellReadingTable.slug;
    final chairOnLeft = equipment['room:front'] == QuestwellReadingChair.slug ||
      equipment['room:left'] == QuestwellReadingChair.slug;
    final ratio = relic ? 2 / 3 : shelf ? 1225 / 1284 : fern ? 1244 / 1264 : table ? 1213 / 1296 : 1312 / 1199;
    // Use the same authored avatar scale as the scene. A chair is adult-sized;
    // its seat is near knee height. Overlap is intentional, never a reason to
    // shrink furniture. Width limits only protect the outer frame.
    final avatarHeight = math.min(scene.height * .76, scene.width * .62 * 4 / 3);
    final height = math.min(
      avatarHeight * (relic ? (front ? .49 : .40) : table ? .49 : shelf ? .65 : fern ? (front ? .43 : .40) : .62),
      scene.width * (relic ? .23 : table ? .28 : shelf ? .44 : fern ? .30 : .50) / ratio,
    ) * (shelf ? .90 : 1.0);
    final width = height * ratio;
    final center = relic ? scene.width * (front ? .18 : slot == 'left' ? .24 : .81) : table ? scene.width * (chairOnLeft ? .15 : .85) : shelf
      ? (slot == 'right' ? scene.width * .98 - width / 2 : scene.width * .17 + width / 2)
      : scene.width * (chair ? (slot == 'right' ? (hasTable ? .64 : .73) : (hasTable ? .36 : .27))
        : front ? .20 : slot == 'left' ? .28 : .81);
    // The back wall meets the floor around .67; the avatar's boots are at .88.
    // Furniture rests between those planes and is painted behind the avatar.
    // Ground the rear pedestals on the first clear floorboards, below the
    // wall trim. Follow the texture crop in shorter placement previews.
    final roomSide = math.max(scene.width, scene.height);
    final floor = relic && !front
      ? roomSide * .68 + (scene.height - roomSide) * .52
      : scene.height * floorDepth(slug, slot);
    return Rect.fromLTWH(center - width / 2, floor - height * (shelf ? 1200 / 1284 : 1), width, height);
  }

  /// Compact surface collectibles use the artifact alone, without the floor stand.
  static Positioned relicSurfacePositioned({required String slug, required String slot,
    required Size scene, required Map<String, String> equipment}) {
    final onShelf = slot == 'bookshelf_top';
    final shelfSlot = equipment['room:right'] == QuestwellBookshelf.slug ? 'right' : 'left';
    final shelf = bounds(slug: QuestwellBookshelf.slug, slot: shelfSlot, scene: scene, equipment: equipment);
    final height = onShelf ? shelf.height * .25 : math.min(scene.height * .12, scene.width * .10);
    final width = height * .90;
    final roomSide = math.max(scene.width, scene.height);
    final center = onShelf ? shelf.left + shelf.width * (shelfSlot == 'right' ? .75 : .25)
      : roomSide * .084 + (scene.width - roomSide) / 2;
    final surface = onShelf ? shelf.top + shelf.height * .078
      : roomSide * .337 + (scene.height - roomSide) * .52;
    return Positioned(key: ValueKey('hearth-$slug-surface-bounds'),
      left: center - width / 2, top: surface - height, width: width, height: height,
      child: QuestwellMasteryDisplay(archetype: QuestwellMasteryRelic.classFor(slug), surface: true));
  }

  static Positioned trophyPositioned({String slug = QuestwellFirstJourney.slug, required String slot, required Size scene,
    required Map<String, String> equipment}) {
    final shelfSlot = equipment['room:right'] == QuestwellBookshelf.slug ? 'right' : 'left';
    final shelf = bounds(slug: QuestwellBookshelf.slug, slot: shelfSlot, scene: scene, equipment: equipment);
    final orrery = slug == QuestwellStarlitOrrery.slug;
    final onShelf = slot == 'bookshelf_top';
    final compassOnMantel = !orrery && !onShelf;
    // The Orrery's broad plinth needs a furniture-relative scale. Its rear
    // feet sit higher in the image than the front foot, so anchor the latter
    // inside the visible top plane rather than on the rear edge of the wood.
    final height = orrery
      ? (onShelf ? shelf.height * .23
        : math.min(scene.height * .095, scene.width * .085))
      : (onShelf ? math.min(scene.height * .105, scene.width * .10)
        : math.min(scene.height * .085, scene.width * .080));
    final width = height * 1312 / 1199;
    // The mantel belongs to the square room texture. Follow its BoxFit.cover
    // crop and Alignment(0, .04), so the base stays on the wood at any aspect ratio.
    final roomSide = math.max(scene.width, scene.height);
    final center = onShelf ? shelf.left + shelf.width * (shelfSlot == 'right' ? (orrery ? .75 : .78) : (orrery ? .25 : .23))
      : roomSide * .082 + (scene.width - roomSide) / 2;
    final surface = onShelf ? shelf.top + shelf.height * .078
      : roomSide * (compassOnMantel ? .340 : .345) + (scene.height - roomSide) * .52;
    // The mantel recedes toward the left. The compass artwork's plinth
    // recedes toward the right, so face it into the room on this surface.
    // Align its visible wood edge (.955), not the transparent shadow below it.
    final baseX = compassOnMantel ? .48 : orrery ? .49 : .52;
    final baseY = compassOnMantel ? .955 : orrery ? .98 : .94;
    return Positioned(key: ValueKey(orrery ? 'hearth-orrery-bounds' : 'hearth-trophy-bounds'),
      left: center - width * baseX, top: surface - height * baseY,
      width: width, height: height,
      child: Stack(fit: StackFit.expand, children: [
        Positioned(left: width * .20, right: width * (orrery ? .20 : .10),
          top: height * (orrery || !onShelf ? .89 : .90), height: height * (orrery ? .09 : .06),
          child: DecoratedBox(decoration: BoxDecoration(borderRadius: BorderRadius.circular(100),
            gradient: const RadialGradient(radius: .6, colors: [Color(0x550E0906),Color(0x000E0906)])))),
        if (orrery) const QuestwellStarlitOrrery()
        else Transform.flip(
          key: const ValueKey('hearth-compass-facing'),
          flipX: compassOnMantel,
          child: const QuestwellFirstJourney()),
      ]));
  }

  static Positioned positioned({required String slug, required String slot, required Size scene,
    Map<String, String> equipment = const {}}) {
    final relic = QuestwellMasteryRelic.supports(slug);
    final shelf = slug == QuestwellBookshelf.slug;
    final fern = slug == QuestwellFern.slug;
    final table = slug == QuestwellReadingTable.slug;
    final chair = slug == QuestwellReadingChair.slug;
    final rect = bounds(slug: slug, slot: slot, scene: scene, equipment: equipment);
    final art = relic ? QuestwellMasteryDisplay(archetype: QuestwellMasteryRelic.classFor(slug)) : shelf ? const QuestwellBookshelf()
      : fern ? const QuestwellFern() : table ? const QuestwellReadingTable() : const QuestwellReadingChair();
    return Positioned(
      key: ValueKey(relic ? 'hearth-$slug-bounds' : shelf ? 'hearth-bookshelf-bounds'
        : fern ? 'hearth-fern-bounds' : table ? 'hearth-table-bounds' : 'hearth-chair-bounds'),
      left: rect.left, top: rect.top,
      width: rect.width, height: rect.height,
      child: Transform.flip(
        key: ValueKey('hearth-$slug-facing'),
        // The authored pedestal faces left. Mirror left-side placements so
        // its front panel faces the room center; right-side art stays unmirrored.
        flipX: (chair || relic) && slot != 'right',
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

