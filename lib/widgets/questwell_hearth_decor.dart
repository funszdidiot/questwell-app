import 'dart:math' as math;
import 'questwell_room_geometry.dart';
import 'questwell_mastery_relic.dart';
import 'package:flutter/material.dart';
import 'questwell_bookshelf.dart';
import 'questwell_potion_workbench.dart';
import 'questwell_harvest_display.dart';
import 'questwell_autumn_lantern.dart';
import 'questwell_fern.dart';
import 'questwell_reading_chair.dart';
import 'questwell_reading_table.dart';
import 'questwell_wall_art.dart';
import 'questwell_contact_shadow.dart';
import 'questwell_first_journey.dart';
import 'questwell_starlit_orrery.dart';
import 'questwell_warding_lantern.dart';
import 'questwell_hearth_layout.dart';
import 'questwell_hearth_catalog_sprite.dart';
import '../services/questwell_cosmetic_models.dart';

/// Authored furniture proportions and floor anchors shared by every Hearth view.
class QuestwellHearthDecor {
  static Map<String, String> choices(String slug, {bool knownOnly = false}) =>
      QuestwellMasteryRelic.supports(slug)
          ? const {
              'mantel': 'On the fireplace mantel',
              'bookshelf_top': 'On the bookcase',
              'left': 'Back left pedestal',
              'right': 'Back right pedestal',
              'front': 'Front left pedestal'
            }
          : QuestwellHearthLayout.fallbackChoices(slug) ??
              switch (slug) {
                'woodland-cottage' ||
                'midnight-harvest' ||
                'enchanted-library' ||
                'midnight-observatory' ||
                'alchemists-workshop' ||
                'astral-sanctuary' ||
                'emberglass-conservatory' =>
                  const {'setting': 'Hearth setting'},
                'emerald-wayfarer-rug' => const {
                    'floor': 'Beneath the adventurer'
                  },
                'rainy-window' => const {'window': 'Window alcove'},
                QuestwellFirstJourney.slug ||
                QuestwellStarlitOrrery.slug =>
                  const {
                    'bookshelf_top': 'On the bookcase',
                    'mantel': 'Fireplace mantel'
                  },
                QuestwellWallArt.fern || QuestwellWallArt.celestial => const {
                    'wall_left': 'Left wall',
                    'wall_right': 'Right wall'
                  },
                QuestwellReadingTable.slug => const {
                    'side': 'Beside the chair'
                  },
                QuestwellWardingLantern.slug => const {
                    'left': 'Left wall',
                    'right': 'Right wall',
                    'front': 'Foreground'
                  },
                QuestwellBookshelf.slug ||
                QuestwellPotionWorkbench.slug ||
                QuestwellHarvestDisplay.slug ||
                QuestwellAutumnLantern.slug =>
                  const {'left': 'Left wall', 'right': 'Right wall'},
                QuestwellReadingChair.slug => const {
                    'front': 'Left floor',
                    'right': 'Right floor'
                  },
                _ => knownOnly
                    ? const {}
                    : const {
                        'left': 'Beside the fireplace',
                        'right': 'Near the window',
                        'front': 'Foreground'
                      },
              };
  static double floorDepth(
    String slug,
    String slot, {
    String? profileKey,
  }) {
    final resolved = QuestwellHearthLayout.resolvedProfile(slug, profileKey);
    if (resolved != null) {
      return QuestwellHearthLayout.floorDepthFor(resolved, slot);
    }
    return QuestwellMasteryRelic.supports(slug)
        ? (slot == 'front' ? .89 : .68)
        : .86;
  }

  static List<String> backToFront(
    Map<String, String> equipment, {
    Map<String, String> profileBySlug = const {},
  }) {
    String slug(String slot) =>
        equipment['room:$slot'] ??
        (slot == 'right' ? equipment['room'] : null) ??
        '';
    return ['left', 'right', 'front', 'side']..sort((a, b) {
        final aSlug = slug(a);
        final bSlug = slug(b);
        final depth = floorDepth(
          aSlug,
          a,
          profileKey: profileBySlug[aSlug],
        ).compareTo(floorDepth(
          bSlug,
          b,
          profileKey: profileBySlug[bSlug],
        ));
        return depth != 0
            ? depth
            : ['left', 'right', 'front', 'side']
                .indexOf(a)
                .compareTo(['left', 'right', 'front', 'side'].indexOf(b));
      });
  }

  /// Two founder-selected architectural standards, in source-art coordinates.
  /// Both use the background's cover crop and preserve each frame aspect ratio.
  static Rect wallArtBounds(Size scene, String slot,
      {bool hallowed = false, String? profileKey, bool galleryWall = false}) {
    if (galleryWall) {
      // A statement textile and two companion frames form one gallery.
      // Fit the whole group to the available wall, not each item in isolation.
      final source = hallowed ? const Size(1536, 1024) : const Size(1024, 1024);
      final geometry = QuestwellRoomGeometry(source, scene);
      final rect = hallowed
          ? (slot == 'wall_center'
              ? const Rect.fromLTWH(444, 66, 248, 186)
              : slot == 'wall_left'
                  ? const Rect.fromLTWH(393, 110, 44, 86)
                  : const Rect.fromLTWH(699, 110, 44, 86))
          : (slot == 'wall_center'
              ? const Rect.fromLTWH(392, 16, 240, 160)
              : slot == 'wall_left'
                  ? const Rect.fromLTWH(310, 50, 70, 120)
                  : const Rect.fromLTWH(644, 50, 70, 120));
      return Rect.fromLTWH(
          geometry.point(rect.topLeft).dx,
          geometry.point(rect.topLeft).dy,
          rect.width * geometry.scale,
          rect.height * geometry.scale);
    }
    if (profileKey == 'wall_textile') {
      // One textile envelope per architectural map. Artwork is contained,
      // never stretched; legacy framed-art envelopes remain unchanged.
      final source = hallowed ? const Size(1536, 1024) : const Size(1024, 1024);
      final geometry = QuestwellRoomGeometry(source, scene);
      final center = slot == 'wall_center';
      final rect = hallowed
          ? (center
              ? const Rect.fromLTWH(418, 42, 300, 216)
              : slot == 'wall_left'
                  ? const Rect.fromLTWH(170, 320, 140, 110)
                  : const Rect.fromLTWH(1294, 210, 112, 90))
          : (center
              ? const Rect.fromLTWH(392, 16, 240, 160)
              : slot == 'wall_left'
                  ? const Rect.fromLTWH(300, 142, 100, 80)
                  : const Rect.fromLTWH(624, 142, 100, 80));
      return Rect.fromLTWH(
        geometry.point(rect.topLeft).dx,
        geometry.point(rect.topLeft).dy,
        rect.width * geometry.scale,
        rect.height * geometry.scale,
      );
    }

    final center = slot == 'wall_center';
    final source = hallowed ? const Size(1536, 1024) : const Size(1024, 1024);
    final scale = math.max(
      scene.width / source.width,
      scene.height / source.height,
    );
    final origin = Offset(
      (scene.width - source.width * scale) / 2,
      (scene.height - source.height * scale) * .52,
    );
    final double x;
    final double y;
    final double width;
    if (hallowed) {
      // All three frames fit the chimney above the mantel, clear of the window.
      x = slot == 'wall_left'
          ? 453
          : slot == 'wall_right'
              ? 683
              : 568;
      y = 118;
      width = center ? 138 : 58;
    } else {
      // The open back wall is shared by every Original Hearth surface variant.
      x = source.width *
          (slot == 'wall_left'
              ? .365
              : slot == 'wall_right'
                  ? .635
                  : .50);
      y = source.height * .23;
      width = source.width * (center ? .14 : .065);
    }
    var frameCenter = origin + Offset(x, y) * scale;
    var frameWidth = width * scale;
    var frameHeight = frameWidth / (center ? 1.4 : .58);
    if (!hallowed && !center) {
      // The legacy relic picker has a shorter camera: keep frame tops visible.
      frameCenter =
          Offset(frameCenter.dx, math.max(frameCenter.dy, frameHeight / 2 + 3));
    }
    if (!hallowed && center) {
      // Tall views bring the avatar's head closer to the gallery. Raise only
      // the landscape; keep the portraits readable beside the head. The
      // earliest locked body silhouette begins at row 9 of the 320px canvas.
      final avatarHeight =
          math.min(scene.height * .76, scene.width * .62 * 4 / 3);
      final headTop = scene.height * .88 - avatarHeight * (310 - 9) / 320;
      final ceiling = headTop - 3;
      final wallTop = math.max(3.0, origin.dy + source.height * .07 * scale);
      frameHeight = math.min(frameHeight, math.max(1.0, ceiling - wallTop));
      frameWidth = frameHeight * 1.4;
      frameCenter = Offset(
          frameCenter.dx, math.min(frameCenter.dy, ceiling - frameHeight / 2));
    }
    return Rect.fromCenter(
        center: frameCenter, width: frameWidth, height: frameHeight);
  }

  static Positioned wallArtPositioned({
    required String slug,
    required String side,
    required Size scene,
    bool hallowed = false,
    String? profileKey,
    bool galleryWall = false,
    QuestwellHearthRenderSpec? renderSpec,
  }) {
    final rect = wallArtBounds(scene, side,
        hallowed: hallowed, profileKey: profileKey, galleryWall: galleryWall);
    return Positioned(
      key: ValueKey(side == 'wall_center'
          ? 'hearth-wall-art-bounds'
          : 'hearth-$side-art-bounds'),
      top: rect.top,
      left: rect.left,
      width: rect.width,
      height: rect.height,
      child: QuestwellWallArt(
        artSlug: slug,
        renderSpec: renderSpec,
        wallSlot: side,
      ),
    );
  }

  static Rect bounds({
    required String slug,
    required String slot,
    required Size scene,
    Map<String, String> equipment = const {},
    Map<String, String> profileBySlug = const {},
    String? profileKey,
    QuestwellHearthRenderSpec? renderSpec,
  }) {
    final resolvedProfile =
        QuestwellHearthLayout.resolvedProfile(slug, profileKey);
    if (resolvedProfile != null &&
        (renderSpec != null || QuestwellHearthLayout.assetSpec(slug) != null)) {
      return QuestwellHearthLayout.bounds(
        slug: slug,
        profileKey: resolvedProfile,
        slot: slot,
        scene: scene,
        equipment: equipment,
        profileBySlug: profileBySlug,
        renderSpec: renderSpec,
      );
    }
    if (slug == QuestwellAutumnLantern.slug)
      return QuestwellAutumnLantern.bounds(scene, slot);
    if (slug == QuestwellWardingLantern.slug)
      return QuestwellWardingLantern.bounds(scene, slot);
    if (slug == QuestwellHarvestDisplay.slug)
      return QuestwellHarvestDisplay.bounds(scene, slot);
    if (slug == QuestwellPotionWorkbench.slug)
      return QuestwellPotionWorkbench.bounds(scene, slot);
    final relic = QuestwellMasteryRelic.supports(slug);
    final shelf = slug == QuestwellBookshelf.slug;
    final fern = slug == QuestwellFern.slug;
    final front = slot == 'front';
    final table = slug == QuestwellReadingTable.slug;
    final chair = slug == QuestwellReadingChair.slug;
    final hasTable = equipment['room:side'] == QuestwellReadingTable.slug;
    final chairOnLeft = equipment['room:front'] == QuestwellReadingChair.slug ||
        equipment['room:left'] == QuestwellReadingChair.slug;
    final ratio = relic
        ? 2 / 3
        : shelf
            ? 1225 / 1284
            : fern
                ? 1244 / 1264
                : table
                    ? 1213 / 1296
                    : 1312 / 1199;
    // Use the same authored avatar scale as the scene. A chair is adult-sized;
    // its seat is near knee height. Overlap is intentional, never a reason to
    // shrink furniture. Width limits only protect the outer frame.
    final avatarHeight =
        math.min(scene.height * .76, scene.width * .62 * 4 / 3);
    final height = math.min(
          avatarHeight *
              (relic
                  ? (front ? .49 : .40)
                  : table
                      ? .49
                      : shelf
                          ? .65
                          : fern
                              ? (front ? .43 : .40)
                              : .62),
          scene.width *
              (relic
                  ? .23
                  : table
                      ? .28
                      : shelf
                          ? .44
                          : fern
                              ? .30
                              : .50) /
              ratio,
        ) *
        (shelf ? .90 : 1.0);
    final width = height * ratio;
    final center = relic
        ? scene.width *
            (front
                ? .18
                : slot == 'left'
                    ? .24
                    : .81)
        : table
            ? scene.width * (chairOnLeft ? .15 : .85)
            : shelf
                ? (slot == 'right'
                    ? scene.width * .98 - width / 2
                    : scene.width * .17 + width / 2)
                : scene.width *
                    (chair
                        ? (slot == 'right'
                            ? (hasTable ? .64 : .73)
                            : (hasTable ? .36 : .27))
                        : front
                            ? .20
                            : slot == 'left'
                                ? .28
                                : .81);
    // The back wall meets the floor around .67; the avatar's boots are at .88.
    // Furniture rests between those planes and is painted behind the avatar.
    // Ground the rear pedestals on the first clear floorboards, below the
    // wall trim. Follow the texture crop in shorter placement previews.
    final roomSide = math.max(scene.width, scene.height);
    final floor = relic && !front
        ? roomSide * .68 + (scene.height - roomSide) * .52
        : scene.height * floorDepth(slug, slot, profileKey: profileKey);
    return Rect.fromLTWH(center - width / 2,
        floor - height * (shelf ? 1200 / 1284 : 1), width, height);
  }

  /// Compact surface collectibles use the artifact alone, without the floor stand.
  static Positioned relicSurfacePositioned(
      {required String slug,
      required String slot,
      required Size scene,
      Offset? mantelAnchor,
      required Map<String, String> equipment}) {
    final onShelf = slot == 'bookshelf_top';
    final shelfSlot =
        equipment['room:right'] == QuestwellBookshelf.slug ? 'right' : 'left';
    final shelf = bounds(
        slug: QuestwellBookshelf.slug,
        slot: shelfSlot,
        scene: scene,
        equipment: equipment);
    final height = onShelf
        ? shelf.height * .25
        : math.min(scene.height * .12, scene.width * .10);
    final width = height * .90;
    final roomSide = math.max(scene.width, scene.height);
    final center = onShelf
        ? shelf.left + shelf.width * (shelfSlot == 'right' ? .75 : .25)
        : mantelAnchor?.dx ?? roomSide * .084 + (scene.width - roomSide) / 2;
    final surface = onShelf
        ? shelf.top + shelf.height * .078
        : mantelAnchor?.dy ?? roomSide * .337 + (scene.height - roomSide) * .52;
    return Positioned(
        key: ValueKey('hearth-$slug-surface-bounds'),
        left: center - width / 2,
        top: surface - height,
        width: width,
        height: height,
        child: QuestwellMasteryDisplay(
            archetype: QuestwellMasteryRelic.classFor(slug), surface: true));
  }

  static Positioned trophyPositioned(
      {String slug = QuestwellFirstJourney.slug,
      required String slot,
      required Size scene,
      Offset? mantelAnchor,
      required Map<String, String> equipment}) {
    final shelfSlot =
        equipment['room:right'] == QuestwellBookshelf.slug ? 'right' : 'left';
    final shelf = bounds(
        slug: QuestwellBookshelf.slug,
        slot: shelfSlot,
        scene: scene,
        equipment: equipment);
    final orrery = slug == QuestwellStarlitOrrery.slug;
    final onShelf = slot == 'bookshelf_top';
    final compassOnMantel = !orrery && !onShelf;
    // The Orrery's broad plinth needs a furniture-relative scale. Its rear
    // feet sit higher in the image than the front foot, so anchor the latter
    // inside the visible top plane rather than on the rear edge of the wood.
    final height = orrery
        ? (onShelf
            ? shelf.height * .23
            : math.min(scene.height * .095, scene.width * .085))
        : (onShelf
            ? math.min(scene.height * .105, scene.width * .10)
            : math.min(scene.height * .085, scene.width * .080));
    final width = height * 1312 / 1199;
    // The mantel belongs to the square room texture. Follow its BoxFit.cover
    // crop and Alignment(0, .04), so the base stays on the wood at any aspect ratio.
    final roomSide = math.max(scene.width, scene.height);
    final center = onShelf
        ? shelf.left +
            shelf.width *
                (shelfSlot == 'right'
                    ? (orrery ? .75 : .78)
                    : (orrery ? .25 : .23))
        : mantelAnchor?.dx ?? roomSide * .082 + (scene.width - roomSide) / 2;
    final surface = onShelf
        ? shelf.top + shelf.height * .078
        : mantelAnchor?.dy ??
            roomSide * (compassOnMantel ? .340 : .345) +
                (scene.height - roomSide) * .52;
    // Keep the First Journey trophy in its authored facing. Mirroring the
    // angled source art on the mantel made the milestone read as skewed or
    // pointed unnaturally relative to the room. The surface anchor handles
    // room placement; the asset itself owns its perspective.
    // Align its visible wood edge (.955), not the transparent shadow below it.
    final baseX = orrery ? .49 : .52;
    final baseY = compassOnMantel
        ? .955
        : orrery
            ? .98
            : .94;
    return Positioned(
        key: ValueKey(orrery ? 'hearth-orrery-bounds' : 'hearth-trophy-bounds'),
        left: center - width * baseX,
        top: surface - height * baseY,
        width: width,
        height: height,
        child: Stack(fit: StackFit.expand, children: [
          Positioned(
              left: width * .20,
              right: width * (orrery ? .20 : .10),
              top: height * (orrery || !onShelf ? .89 : .90),
              height: height * (orrery ? .09 : .06),
              child: DecoratedBox(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: const RadialGradient(
                          radius: .6,
                          colors: [Color(0x550E0906), Color(0x000E0906)])))),
          if (orrery)
            const QuestwellStarlitOrrery()
          else
            const KeyedSubtree(
                key: ValueKey('hearth-trophy-facing'),
                child: QuestwellFirstJourney()),
        ]));
  }

  static Positioned positioned({
    required String slug,
    required String slot,
    required Size scene,
    Map<String, String> equipment = const {},
    Map<String, String> profileBySlug = const {},
    String? profileKey,
    QuestwellHearthRenderSpec? renderSpec,
  }) {
    final relic = QuestwellMasteryRelic.supports(slug);
    final shelf = slug == QuestwellBookshelf.slug;
    final fern = slug == QuestwellFern.slug;
    final table = slug == QuestwellReadingTable.slug;
    final chair = slug == QuestwellReadingChair.slug;
    final rect = bounds(
      slug: slug,
      slot: slot,
      scene: scene,
      equipment: equipment,
      profileBySlug: profileBySlug,
      profileKey: profileKey,
      renderSpec: renderSpec,
    );
    final art = renderSpec?.renderKind == 'static_sprite'
        ? QuestwellHearthCatalogSprite(spec: renderSpec!)
        : slug == QuestwellAutumnLantern.slug
            ? const QuestwellAutumnLantern()
            : slug == QuestwellWardingLantern.slug
                ? const QuestwellWardingLantern()
                : slug == QuestwellHarvestDisplay.slug
                    ? const QuestwellHarvestDisplay()
                    : slug == QuestwellPotionWorkbench.slug
                        ? const QuestwellPotionWorkbench()
                        : relic
                            ? QuestwellMasteryDisplay(
                                archetype: QuestwellMasteryRelic.classFor(slug))
                            : shelf
                                ? const QuestwellBookshelf()
                                : fern
                                    ? const QuestwellFern()
                                    : table
                                        ? const QuestwellReadingTable()
                                        : const QuestwellReadingChair();
    return Positioned(
      key: ValueKey(renderSpec != null
          ? 'hearth-$slug-bounds'
          : slug == QuestwellAutumnLantern.slug
              ? 'hearth-autumn-lantern-bounds'
              : slug == QuestwellWardingLantern.slug
                  ? 'hearth-warding-lantern-bounds'
                  : slug == QuestwellHarvestDisplay.slug
                      ? 'hearth-harvest-display-bounds'
                      : slug == QuestwellPotionWorkbench.slug
                          ? 'hearth-workbench-bounds'
                          : relic
                              ? 'hearth-$slug-bounds'
                              : shelf
                                  ? 'hearth-bookshelf-bounds'
                                  : fern
                                      ? 'hearth-fern-bounds'
                                      : table
                                          ? 'hearth-table-bounds'
                                          : 'hearth-chair-bounds'),
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Transform.flip(
        key: ValueKey('hearth-$slug-facing'),
        // The authored pedestal faces left. Mirror left-side placements so
        // its front panel faces the room center; right-side art stays unmirrored.
        flipX: ((profileKey == 'seating') || chair || relic) && slot != 'right',
        child: Stack(fit: StackFit.expand, children: [
          IgnorePointer(
              child: CustomPaint(
                  key: ValueKey('hearth-$slug-contact-shadow'),
                  painter: QuestwellContactShadowPainter(
                    slug,
                    shadowProfile: renderSpec?.shadowProfile,
                    visibleBase: renderSpec?.visibleBase ?? 1,
                  ))),
          art,
        ]),
      ),
    );
  }
}
