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
  int get xpIntoLevel => QuestwellProgression.xpIntoLevel(totalXp, legacyOffset: levelXpOffset);
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
      currentEnergyMode:
          json['current_energy_mode']?.toString() ?? 'normal',
      onboardingCompleted: json['onboarding_completed'] == true,
      adventurerArchetype:
          json['adventurer_archetype']?.toString() ?? 'wanderer',
      avatarBodyType: json['avatar_body_type']?.toString() ?? 'neutral',
    );
  }
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
    );
  }

  factory QuestwellCosmetic.fromJson(
    Map<String, dynamic> json, {
    bool owned = false,
    bool equipped = false,
    String? roomSlot,
    DateTime? unlockedAt,
    String? source,
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
      availabilityStart: DateTime.tryParse(json['availability_start']?.toString() ?? ''),
      availabilityEnd: DateTime.tryParse(json['availability_end']?.toString() ?? ''),
    );
  }
}

class QuestwellCosmeticsSnapshot {
  const QuestwellCosmeticsSnapshot({
    required this.profile,
    required this.cosmetics,
  });

  final QuestwellProfile profile;
  final List<QuestwellCosmetic> cosmetics;
}

