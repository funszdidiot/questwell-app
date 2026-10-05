import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Slot-first layout contract for the Questwell Hearth.
///
/// Artwork fits the space; individual items do not invent their own scale or
/// coordinates. This keeps seasonal/limited releases visually interchangeable
/// while preserving the current Hearth composition.
enum QuestwellHearthDecorFamily {
  largeFurniture,
  pedestalLight,
  seating,
  plant,
  sideTable,
  relicPedestal,
}

class QuestwellHearthProfile {
  const QuestwellHearthProfile({
    required this.family,
    required this.allowedSlots,
    required this.aspectRatio,
    this.visibleBase = 1.0,
  });

  final QuestwellHearthDecorFamily family;
  final Set<String> allowedSlots;

  /// Authored canvas width / height. The slot owns visual height; aspect ratio
  /// only determines the contained width.
  final double aspectRatio;

  /// Fractional source-row position of the visible ground-contact edge.
  /// Transparent padding below the artwork must not move the item off its slot.
  final double visibleBase;
}

abstract final class QuestwellHearthLayout {
  /// Stable family registry. New décor must join an existing family unless a
  /// genuinely new Hearth-space behavior is founder-approved.
  static const profiles = <String, QuestwellHearthProfile>{
    'walnut-bookshelf': QuestwellHearthProfile(
      family: QuestwellHearthDecorFamily.largeFurniture,
      allowedSlots: {'left', 'right'},
      aspectRatio: 1225 / 1284,
      visibleBase: 1200 / 1284,
    ),
    'copper-potion-workbench': QuestwellHearthProfile(
      family: QuestwellHearthDecorFamily.largeFurniture,
      allowedSlots: {'left', 'right'},
      aspectRatio: 1341 / 1173,
      visibleBase: 1119 / 1173,
    ),
    'harvest-apothecary-display': QuestwellHearthProfile(
      family: QuestwellHearthDecorFamily.largeFurniture,
      allowedSlots: {'left', 'right'},
      aspectRatio: 1312 / 1199,
      visibleBase: 1095 / 1199,
    ),
    'autumn-ember-lantern': QuestwellHearthProfile(
      family: QuestwellHearthDecorFamily.pedestalLight,
      allowedSlots: {'left', 'right'},
      aspectRatio: 935 / 1681 * 1.55,
      visibleBase: 1605 / 1681,
    ),
    'warding-lantern': QuestwellHearthProfile(
      family: QuestwellHearthDecorFamily.pedestalLight,
      allowedSlots: {'left', 'right'},
      aspectRatio: 960 / 1680,
      visibleBase: .965,
    ),
    'burgundy-reading-chair': QuestwellHearthProfile(
      family: QuestwellHearthDecorFamily.seating,
      allowedSlots: {'front', 'right'},
      aspectRatio: 1312 / 1199,
    ),
    'hearth-fern': QuestwellHearthProfile(
      family: QuestwellHearthDecorFamily.plant,
      allowedSlots: {'left', 'right', 'front'},
      aspectRatio: 1244 / 1264,
    ),
    'walnut-reading-table': QuestwellHearthProfile(
      family: QuestwellHearthDecorFamily.sideTable,
      allowedSlots: {'side'},
      aspectRatio: 1213 / 1296,
    ),
  };

  static QuestwellHearthProfile? profile(String slug) => profiles[slug];

  static Map<String, String>? choicesFor(String slug) {
    final profile = profiles[slug];
    if (profile == null) return null;

    final order = switch (profile.family) {
      QuestwellHearthDecorFamily.sideTable => const ['side'],
      QuestwellHearthDecorFamily.seating => const ['front', 'right'],
      _ => const ['left', 'right', 'front'],
    };

    const labels = {
      'left': 'Back left',
      'right': 'Back right',
      'front': 'Foreground',
      'side': 'Beside the chair',
    };
    return {
      for (final slot in order)
        if (profile.allowedSlots.contains(slot)) slot: labels[slot]!,
    };
  }

  static double floorDepthFor(String slug, String slot) {
    final family = profiles[slug]?.family;
    return switch (family) {
      QuestwellHearthDecorFamily.largeFurniture => .69,
      QuestwellHearthDecorFamily.pedestalLight => .72,
      QuestwellHearthDecorFamily.sideTable => .89,
      QuestwellHearthDecorFamily.relicPedestal => slot == 'front' ? .89 : .68,
      QuestwellHearthDecorFamily.plant => slot == 'front' ? .86 : .70,
      QuestwellHearthDecorFamily.seating => .86,
      _ => .86,
    };
  }

  /// Canonical slot envelope. Items of the same family receive the same visual
  /// height and floor anchor in the same space.
  static Rect bounds({
    required String slug,
    required String slot,
    required Size scene,
    Map<String, String> equipment = const {},
  }) {
    final p = profiles[slug];
    if (p == null) return Rect.zero;

    final avatarHeight =
        math.min(scene.height * .76, scene.width * .62 * 4 / 3);

    final heightFactor = switch (p.family) {
      QuestwellHearthDecorFamily.largeFurniture => .59,
      QuestwellHearthDecorFamily.pedestalLight => .52,
      QuestwellHearthDecorFamily.seating => .62,
      QuestwellHearthDecorFamily.plant => slot == 'front' ? .43 : .40,
      QuestwellHearthDecorFamily.sideTable => .49,
      QuestwellHearthDecorFamily.relicPedestal =>
        slot == 'front' ? .49 : .40,
    };

    final maxWidthFactor = switch (p.family) {
      QuestwellHearthDecorFamily.largeFurniture => .44,
      QuestwellHearthDecorFamily.pedestalLight => .45,
      QuestwellHearthDecorFamily.seating => .50,
      QuestwellHearthDecorFamily.plant => .30,
      QuestwellHearthDecorFamily.sideTable => .28,
      QuestwellHearthDecorFamily.relicPedestal => .23,
    };

    var height = math.min(
      avatarHeight * heightFactor,
      scene.width * maxWidthFactor / p.aspectRatio,
    );
    final width = height * p.aspectRatio;

    final hasTable = equipment['room:side'] == 'walnut-reading-table';
    final chairOnLeft =
        equipment['room:front'] == 'burgundy-reading-chair' ||
        equipment['room:left'] == 'burgundy-reading-chair';

    final center = switch (p.family) {
      QuestwellHearthDecorFamily.largeFurniture =>
        slot == 'right'
          ? scene.width * .98 - width / 2
          : scene.width * .14 + width / 2,
      QuestwellHearthDecorFamily.pedestalLight =>
        scene.width * (slot == 'left' ? .22 : .80),
      QuestwellHearthDecorFamily.sideTable =>
        scene.width * (chairOnLeft ? .15 : .85),
      QuestwellHearthDecorFamily.seating =>
        scene.width *
            (slot == 'right'
                ? (hasTable ? .64 : .73)
                : (hasTable ? .36 : .27)),
      QuestwellHearthDecorFamily.plant =>
        scene.width *
            (slot == 'front' ? .20 : slot == 'left' ? .28 : .81),
      QuestwellHearthDecorFamily.relicPedestal =>
        scene.width *
            (slot == 'front' ? .18 : slot == 'left' ? .24 : .81),
    };

    final roomSide = math.max(scene.width, scene.height);
    final floor = p.family == QuestwellHearthDecorFamily.relicPedestal &&
            slot != 'front'
        ? roomSide * .68 + (scene.height - roomSide) * .52
        : scene.height * floorDepthFor(slug, slot);

    return Rect.fromLTWH(
      center - width / 2,
      floor - height * p.visibleBase,
      width,
      height,
    );
  }
}
