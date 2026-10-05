import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Visual geometry for backend-defined Hearth layout profiles.
///
/// Supabase owns semantic placement (hearth_profile_key and allowed slots).
/// Flutter owns only the visual envelope for each profile plus per-asset canvas
/// metadata. Live account flows must pass the backend profile key; the local
/// slug fallback exists only for previews/tests and legacy fixtures.
class QuestwellHearthAssetSpec {
  const QuestwellHearthAssetSpec({
    required this.aspectRatio,
    this.visibleBase = 1.0,
  });

  /// Authored canvas width / height.
  final double aspectRatio;

  /// Fractional source-row position of the visible ground-contact edge.
  final double visibleBase;
}

abstract final class QuestwellHearthLayout {
  /// Artwork metadata only. This does NOT decide where an item may be placed.
  static const assetSpecs = <String, QuestwellHearthAssetSpec>{
    'walnut-bookshelf': QuestwellHearthAssetSpec(
      aspectRatio: 1225 / 1284,
      visibleBase: 1200 / 1284,
    ),
    'copper-potion-workbench': QuestwellHearthAssetSpec(
      aspectRatio: 1341 / 1173,
      visibleBase: 1119 / 1173,
    ),
    'harvest-apothecary-display': QuestwellHearthAssetSpec(
      aspectRatio: 1312 / 1199,
      visibleBase: 1095 / 1199,
    ),
    'autumn-ember-lantern': QuestwellHearthAssetSpec(
      aspectRatio: 935 / 1681 * 1.55,
      visibleBase: 1605 / 1681,
    ),
    'warding-lantern': QuestwellHearthAssetSpec(
      aspectRatio: 960 / 1680,
      visibleBase: .965,
    ),
    'burgundy-reading-chair': QuestwellHearthAssetSpec(
      aspectRatio: 1312 / 1199,
    ),
    'hearth-fern': QuestwellHearthAssetSpec(
      aspectRatio: 1244 / 1264,
    ),
    'walnut-reading-table': QuestwellHearthAssetSpec(
      aspectRatio: 1213 / 1296,
    ),
  };

  /// Compatibility only for review routes/tests that do not load Supabase.
  /// Production account flows pass hearth_profile_key from the backend.
  static const fallbackProfileBySlug = <String, String>{
    'walnut-bookshelf': 'large_furniture',
    'copper-potion-workbench': 'large_furniture',
    'harvest-apothecary-display': 'large_furniture',
    'autumn-ember-lantern': 'pedestal_light',
    'warding-lantern': 'pedestal_light',
    'burgundy-reading-chair': 'seating',
    'hearth-fern': 'plant',
    'walnut-reading-table': 'side_table',
    'scholar-seal': 'relic_display',
    'scout-compass': 'relic_display',
    'alchemist-phial': 'relic_display',
    'guardian-crest': 'relic_display',
    'wanderer-star-map': 'relic_display',
  };

  static String? resolvedProfile(String slug, [String? backendProfile]) =>
      backendProfile ?? fallbackProfileBySlug[slug];

  static QuestwellHearthAssetSpec? assetSpec(String slug) => assetSpecs[slug];

  static Map<String, String>? fallbackChoices(String slug) {
    final profile = fallbackProfileBySlug[slug];
    if (profile == null) return null;
    return switch (profile) {
      'large_furniture' || 'pedestal_light' =>
        const {'left': 'Back left', 'right': 'Back right'},
      'seating' => const {'front': 'Left floor', 'right': 'Right floor'},
      'plant' => const {
          'left': 'Back left',
          'right': 'Back right',
          'front': 'Foreground',
        },
      'side_table' => const {'side': 'Beside the chair'},
      'relic_display' => const {
          'mantel': 'On the fireplace mantel',
          'bookshelf_top': 'On the bookcase',
          'left': 'Back left pedestal',
          'right': 'Back right pedestal',
          'front': 'Front left pedestal',
        },
      _ => null,
    };
  }

  static double floorDepthFor(String profileKey, String slot) => switch (profileKey) {
        'large_furniture' => .69,
        'pedestal_light' => .72,
        'side_table' => .89,
        'relic_display' => slot == 'front' ? .89 : .68,
        'plant' => slot == 'front' ? .86 : .70,
        'seating' => .86,
        _ => .86,
      };

  /// Canonical slot envelope. Same backend profile + same slot = same visual
  /// height, ground line and depth. Aspect ratio only changes contained width.
  static Rect bounds({
    required String slug,
    required String profileKey,
    required String slot,
    required Size scene,
    Map<String, String> equipment = const {},
  }) {
    final spec = assetSpecs[slug];
    if (spec == null) return Rect.zero;

    final avatarHeight =
        math.min(scene.height * .76, scene.width * .62 * 4 / 3);

    final heightFactor = switch (profileKey) {
      'large_furniture' => .50,
      'pedestal_light' => .52,
      'seating' => .62,
      'plant' => slot == 'front' ? .43 : .40,
      'side_table' => .49,
      'relic_display' => slot == 'front' ? .49 : .40,
      _ => .40,
    };

    // Family scale is height-based and never shrinks because one asset is
    // wider. That guarantees a stable visual scale when users swap items.
    // Artwork must be authored to the family's envelope instead of forcing the
    // room to compensate for an oversized sprite.
    final height = avatarHeight * heightFactor;
    final width = height * spec.aspectRatio;

    final hasTable = equipment['room:side'] == 'walnut-reading-table';
    final chairOnLeft =
        equipment['room:front'] == 'burgundy-reading-chair' ||
        equipment['room:left'] == 'burgundy-reading-chair';

    final center = switch (profileKey) {
      'large_furniture' => slot == 'right'
          ? scene.width * .98 - width / 2
          : scene.width * .14 + width / 2,
      'pedestal_light' => scene.width * (slot == 'left' ? .22 : .80),
      'side_table' => scene.width * (chairOnLeft ? .18 : .82),
      'seating' => scene.width *
          (slot == 'right'
              ? (hasTable ? .64 : .73)
              : (hasTable ? .36 : .27)),
      'plant' => scene.width *
          (slot == 'front' ? .20 : slot == 'left' ? .28 : .81),
      'relic_display' => scene.width *
          (slot == 'front' ? .18 : slot == 'left' ? .24 : .81),
      _ => scene.width * .50,
    };

    final roomSide = math.max(scene.width, scene.height);
    final floor = profileKey == 'relic_display' && slot != 'front'
        ? roomSide * .68 + (scene.height - roomSide) * .52
        : scene.height * floorDepthFor(profileKey, slot);

    return Rect.fromLTWH(
      center - width / 2,
      floor - height * spec.visibleBase,
      width,
      height,
    );
  }
}
