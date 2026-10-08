import 'questwell_progression.dart';
import 'questwell_loadout_model.dart';

class QuestwellProfile {
  const QuestwellProfile({
    required this.level,
    required this.totalXp,
    this.levelXpOffset = 0,
    required this.coinBalance,
    required this.currentEnergyMode,
    required this.onboardingCompleted,
    required this.adventurerArchetype,
    required this.avatarBodyType,
  });

  final int level;
  final int totalXp;
  final int levelXpOffset;
  int get xpIntoLevel =>
      QuestwellProgression.xpIntoLevel(totalXp, legacyOffset: levelXpOffset);
  final int coinBalance;
  final String currentEnergyMode;
  final bool onboardingCompleted;
  final String adventurerArchetype;
  final String avatarBodyType;

  bool get campfireMode => currentEnergyMode == 'campfire';

  factory QuestwellProfile.fromJson(Map<String, dynamic> json) {
    return QuestwellProfile(
      level: (json['level'] as num?)?.toInt() ?? 1,
      totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
      levelXpOffset: (json['level_xp_offset'] as num?)?.toInt() ?? 0,
      coinBalance: (json['coin_balance'] as num?)?.toInt() ?? 0,
      currentEnergyMode: json['current_energy_mode']?.toString() ?? 'normal',
      onboardingCompleted: json['onboarding_completed'] == true,
      adventurerArchetype:
          json['adventurer_archetype']?.toString() ?? 'wanderer',
      avatarBodyType: json['avatar_body_type']?.toString() ?? 'neutral',
    );
  }
}

class QuestwellHearthPlacementOption {
  const QuestwellHearthPlacementOption({
    required this.slot,
    required this.label,
    required this.sortOrder,
  });

  final String slot;
  final String label;
  final int sortOrder;

  factory QuestwellHearthPlacementOption.fromJson(Map<String, dynamic> json) =>
      QuestwellHearthPlacementOption(
        slot: json['slot_key']?.toString() ?? '',
        label: json['placement_label']?.toString() ?? '',
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      );
}

class QuestwellHearthRenderSpec {
  const QuestwellHearthRenderSpec({
    required this.renderKind,
    required this.assetSource,
    required this.assetPath,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.visibleBase,
    this.shadowProfile,
    this.effectProfile,
    this.filterMode = 'pixel',
    this.assetRevision = 1,
    this.minClientBuild,
  });

  final String renderKind;
  final String assetSource;
  final String assetPath;
  final int canvasWidth;
  final int canvasHeight;
  final double visibleBase;
  final String? shadowProfile;
  final String? effectProfile;
  final String filterMode;
  final int assetRevision;
  final int? minClientBuild;

  double get aspectRatio => canvasWidth / canvasHeight;
  bool get pixelated => filterMode == 'pixel';

  factory QuestwellHearthRenderSpec.fromJson(Map<String, dynamic> json) =>
      QuestwellHearthRenderSpec(
        renderKind: json['render_kind']?.toString() ?? 'static_sprite',
        assetSource: json['asset_source']?.toString() ?? 'bundle',
        assetPath: json['asset_path']?.toString() ?? '',
        canvasWidth: (json['canvas_width'] as num?)?.toInt() ?? 1,
        canvasHeight: (json['canvas_height'] as num?)?.toInt() ?? 1,
        visibleBase: (json['visible_base'] as num?)?.toDouble() ?? 1,
        shadowProfile: json['shadow_profile']?.toString(),
        effectProfile: json['effect_profile']?.toString(),
        filterMode: json['filter_mode']?.toString() ?? 'pixel',
        assetRevision: (json['asset_revision'] as num?)?.toInt() ?? 1,
        minClientBuild: (json['min_client_build'] as num?)?.toInt(),
      );
}

class QuestwellCosmetic {
  const QuestwellCosmetic({
    required this.id,
    required this.slug,
    required this.name,
    required this.category,
    required this.rarity,
    required this.description,
    required this.price,
    required this.premium,
    required this.assetKey,
    required this.requiredArchetype,
    required this.unlockMethod,
    required this.owned,
    required this.equipped,
    this.roomSlot,
    this.milestoneLevel,
    this.unlockedAt,
    this.source,
    this.collectionKey,
    this.editionType = 'standard',
    this.availabilityStart,
    this.availabilityEnd,
    this.hearthProfileKey,
    this.hearthPlacements = const [],
    this.hearthRenderSpec,
  });

  final String id;
  final String slug;
  final String name;
  final String category;
  final String rarity;
  final String description;
  final int price;
  final bool premium;
  final String? assetKey;
  final String? requiredArchetype;
  final String unlockMethod;
  final bool owned;
  final bool equipped;
  final String? roomSlot;
  final int? milestoneLevel;
  final DateTime? unlockedAt;
  final String? source;
  final String? collectionKey;
  final String editionType;
  final DateTime? availabilityStart, availabilityEnd;
  final String? hearthProfileKey;
  final List<QuestwellHearthPlacementOption> hearthPlacements;
  final QuestwellHearthRenderSpec? hearthRenderSpec;
  bool availableForPurchaseAt(DateTime now) =>
      (availabilityStart == null || !now.isBefore(availabilityStart!)) &&
      (availabilityEnd == null || now.isBefore(availabilityEnd!));

  bool get specialEdition => editionType != 'standard';
  String get renderKey => QuestwellLoadoutModel.renderKey(
        category: category,
        roomSlot: roomSlot,
      );

  QuestwellCosmetic copyWith({
    bool? owned,
    bool? equipped,
  }) {
    return QuestwellCosmetic(
      id: id,
      slug: slug,
      name: name,
      category: category,
      rarity: rarity,
      description: description,
      price: price,
      premium: premium,
      assetKey: assetKey,
      requiredArchetype: requiredArchetype,
      unlockMethod: unlockMethod,
      owned: owned ?? this.owned,
      equipped: equipped ?? this.equipped,
      roomSlot: roomSlot,
      milestoneLevel: milestoneLevel,
      unlockedAt: unlockedAt,
      source: source,
      collectionKey: collectionKey,
      editionType: editionType,
      availabilityStart: availabilityStart,
      availabilityEnd: availabilityEnd,
      hearthProfileKey: hearthProfileKey,
      hearthPlacements: hearthPlacements,
      hearthRenderSpec: hearthRenderSpec,
    );
  }

  factory QuestwellCosmetic.fromJson(
    Map<String, dynamic> json, {
    bool owned = false,
    bool equipped = false,
    String? roomSlot,
    DateTime? unlockedAt,
    String? source,
    List<QuestwellHearthPlacementOption> hearthPlacements = const [],
    QuestwellHearthRenderSpec? hearthRenderSpec,
  }) {
    return QuestwellCosmetic(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Cosmetic',
      category: json['category']?.toString() ?? 'accessory',
      rarity: json['rarity']?.toString() ?? 'common',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      premium: json['premium'] == true,
      assetKey: json['asset_key']?.toString(),
      requiredArchetype: json['required_archetype']?.toString(),
      unlockMethod: json['unlock_method']?.toString() ?? 'shop',
      owned: owned,
      equipped: equipped,
      roomSlot: roomSlot,
      milestoneLevel: (json['milestone_level'] as num?)?.toInt(),
      unlockedAt: unlockedAt,
      source: source,
      collectionKey: json['collection_key']?.toString(),
      editionType: json['edition_type']?.toString() ?? 'standard',
      availabilityStart:
          DateTime.tryParse(json['availability_start']?.toString() ?? ''),
      availabilityEnd:
          DateTime.tryParse(json['availability_end']?.toString() ?? ''),
      hearthProfileKey: json['hearth_profile_key']?.toString(),
      hearthPlacements: hearthPlacements,
      hearthRenderSpec: hearthRenderSpec,
    );
  }
}

/// A saved slot occupant may be absent from the active catalog. Keep its ID
/// for explicit replacement confirmation and the server's concurrency guard.
class RoomOccupant {
  const RoomOccupant(this.id, this.name);
  final String id, name;
}

class QuestwellCosmeticsSnapshot {
  const QuestwellCosmeticsSnapshot({
    required this.profile,
    required this.cosmetics,
    this.hearthOccupants = const {},
  });

  final QuestwellProfile profile;
  final List<QuestwellCosmetic> cosmetics;
  final Map<String, RoomOccupant> hearthOccupants;
}
