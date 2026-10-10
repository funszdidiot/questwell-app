import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/questwell_cosmetic_models.dart';
import 'questwell_hearth_room_plan.dart';
import 'questwell_room_geometry.dart';

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
    'hearth-fern': QuestwellHearthAssetSpec(aspectRatio: 1244 / 1264),
    'walnut-reading-table': QuestwellHearthAssetSpec(aspectRatio: 1213 / 1296),
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
      'large_furniture' || 'pedestal_light' => const {
          'left': 'Back left',
          'right': 'Back right'
        },
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

  static double floorDepthFor(String profileKey, String slot) =>
      switch (profileKey) {
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
    Map<String, String> profileBySlug = const {},
    QuestwellHearthRenderSpec? renderSpec,
  }) {
    final fallback = assetSpecs[slug];
    final aspectRatio = renderSpec?.aspectRatio ?? fallback?.aspectRatio;
    final visibleBase = renderSpec?.visibleBase ?? fallback?.visibleBase;
    if (aspectRatio == null || visibleBase == null) return Rect.zero;

    final avatarHeight = math.min(
      scene.height * .76,
      scene.width * .62 * 4 / 3,
    );

    final heightFactor = switch (profileKey) {
      'large_furniture' => .50,
      'pedestal_light' => .52,
      'seating' => .62,
      'plant' => slot == 'front' ? .43 : .40,
      'side_table' => .49,
      'relic_display' => slot == 'front' ? .49 : .40,
      _ => .40,
    };

    // Family envelopes are fixed in each architectural map; swapping an
    // artistic skin or same-family item cannot change the room composition.
    final plan = QuestwellHearthRoomPlan.forSetting(equipment['room:setting']);
    final geometry =
        QuestwellRoomGeometry.forSetting(equipment['room:setting'], scene);
    final source =
        QuestwellRoomGeometry.sourceForSetting(equipment['room:setting']);
    final height = QuestwellHearthRoomPlan.enabled
        ? source.height * geometry.scale * plan.height(profileKey, slot)
        : avatarHeight * heightFactor;
    final width = height * aspectRatio;

    String? profileAt(String slot) {
      final occupant = equipment['room:$slot'];
      return occupant == null
          ? null
          : resolvedProfile(occupant, profileBySlug[occupant]);
    }

    final hasTable = profileAt('side') == 'side_table';
    final chairOnLeft =
        profileAt('front') == 'seating' || profileAt('left') == 'seating';

    final center = QuestwellHearthRoomPlan.enabled
        ? scene.width *
            plan.center(
              profileKey,
              slot,
              chairOnLeft: chairOnLeft,
              chairOnRight: profileAt('right') == 'seating',
              largeOnRight: profileAt('right') == 'large_furniture',
            )
        : switch (profileKey) {
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
                (slot == 'front'
                    ? .20
                    : slot == 'left'
                        ? .28
                        : .81),
            'relic_display' => scene.width *
                (slot == 'front'
                    ? .18
                    : slot == 'left'
                        ? .24
                        : .81),
            _ => scene.width * .50,
          };

    if (QuestwellHearthRoomPlan.enabled) {
      final anchor = plan.anchor(
        profileKey,
        slot,
        scene,
        equipment['room:setting'],
        centerX: center / scene.width,
      );
      // Cropping may remove a side wall. Keep the whole family envelope inside
      // the nearest visible wall zone, without stretching or rescaling it.
      final safeCenter = anchor.dx.clamp(
        width / 2 + 3,
        scene.width - width / 2 - 3,
      );
      return Rect.fromLTWH(
        safeCenter - width / 2,
        anchor.dy - height * visibleBase,
        width,
        height,
      );
    }
    final roomSide = math.max(scene.width, scene.height);
    final floor = profileKey == 'relic_display' && slot != 'front'
        ? roomSide * .68 + (scene.height - roomSide) * .52
        : scene.height * floorDepthFor(profileKey, slot);

    return Rect.fromLTWH(
      center - width / 2,
      floor - height * visibleBase,
      width,
      height,
    );
  }
}
