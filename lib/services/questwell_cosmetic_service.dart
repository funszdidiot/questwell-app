import '/backend/supabase/supabase.dart';
import 'questwell_equipment_policy.dart';
import 'questwell_progression.dart';

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
  String get renderKey => category == 'room' ? 'room:${roomSlot ?? "right"}'
    : category == 'wall_art' && roomSlot != null && roomSlot != 'wall_center' ? 'wall_art:$roomSlot' : category;

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

class QuestwellCosmeticService {
  const QuestwellCosmeticService._();

  static Future<QuestwellCosmeticsSnapshot> load() async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('Authentication required.');
    }

    final responses = await Future.wait([
      SupaFlow.client
          .from('users')
          .select('level,total_xp,level_xp_offset,coin_balance,current_energy_mode,onboarding_completed,adventurer_archetype,avatar_body_type')
          .eq('id', uid)
          .single(),
      SupaFlow.client
          .from('cosmetics')
          .select('id,slug,name,category,rarity,description,price,premium,asset_key,required_archetype,unlock_method,milestone_level')
          .eq('active', true)
          .order('price'),
      SupaFlow.client
          .from('user_cosmetics')
          .select('cosmetic_id,equipped,room_slot,unlocked_at,source')
          .eq('user_id', uid),
    ]);

    final profile =
        QuestwellProfile.fromJson(Map<String, dynamic>.from(responses[0] as Map));

    final ownedRows = List<Map<String, dynamic>>.from(
      (responses[2] as List).map((row) => Map<String, dynamic>.from(row as Map)),
    );

    final ownedById = <String, bool>{};
    for (final row in ownedRows) {
      ownedById[row['cosmetic_id']?.toString() ?? ''] = row['equipped'] == true;
    }

    final cosmetics = List<Map<String, dynamic>>.from(
      (responses[1] as List).map((row) => Map<String, dynamic>.from(row as Map)),
    )
        .map(
          (row) => QuestwellCosmetic.fromJson(
            row,
            owned: ownedById.containsKey(row['id']?.toString() ?? ''),
            equipped: ownedById[row['id']?.toString() ?? ''] == true,
            roomSlot: ownedRows.where((owned) => owned['cosmetic_id'] == row['id']).map((owned) => owned['room_slot']?.toString()).firstOrNull,
            unlockedAt: DateTime.tryParse(ownedRows.where((owned) => owned['cosmetic_id'] == row['id']).map((owned) => owned['unlocked_at']?.toString()).firstOrNull ?? ''),
            source: ownedRows.where((owned) => owned['cosmetic_id'] == row['id']).map((owned) => owned['source']?.toString()).firstOrNull,
          ),
        )
        .toList();

    return QuestwellCosmeticsSnapshot(
      profile: profile,
      cosmetics: cosmetics,
    );
  }

  static Future<int> purchase(String cosmeticId) async {
    final response = await SupaFlow.client.rpc(
      'purchase_cosmetic',
      params: {'p_cosmetic_id': cosmeticId},
    );

    if (response is! List || response.isEmpty) {
      throw StateError('No purchase result returned.');
    }

    final row = Map<String, dynamic>.from(response.first as Map);
    return (row['remaining_coins'] as num?)?.toInt() ?? 0;
  }

  static Future<void> equip(QuestwellCosmetic cosmetic) async {
    if (!cosmetic.owned || !QuestwellEquipmentPolicy.isReady(cosmetic.slug, cosmetic.category)) {
      throw StateError('This item is not ready to equip.');
    }
    final cosmeticId = cosmetic.id;
    await SupaFlow.client.rpc(
      'equip_cosmetic',
      params: {'p_cosmetic_id': cosmeticId},
    );
  }

  static Future<void> place(String id, String slot, String? expectedOccupant) async {
    await SupaFlow.client.rpc('place_hearth_cosmetic', params: {
      'p_cosmetic_id': id, 'p_slot': slot, 'p_expected_occupant': expectedOccupant,
    });
  }

  static Future<void> unequip(String cosmeticId) async {
    await SupaFlow.client.rpc(
      'unequip_cosmetic',
      params: {'p_cosmetic_id': cosmeticId},
    );
  }

  static Future<void> setEnergyMode(String mode) async {
    if (mode != 'normal' && mode != 'campfire') {
      throw ArgumentError.value(mode, 'mode', 'Unsupported energy mode');
    }

    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('Authentication required.');
    }

    await SupaFlow.client
        .from('users')
        .update({'current_energy_mode': mode})
        .eq('id', uid);
  }

  static Future<void> completeOnboarding() async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('Authentication required.');
    }

    await SupaFlow.client
        .from('users')
        .update({'onboarding_completed': true})
        .eq('id', uid);
  }

  static Future<String> claimClassMasteryReward() async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('Authentication required.');
    }

    final response = await SupaFlow.client.rpc('claim_class_mastery_reward');
    return response.toString();
  }

  static Future<void> setAvatarBodyType(String bodyType) async {
    const allowed = {'male', 'female', 'neutral'};
    if (!allowed.contains(bodyType)) {
      throw ArgumentError.value(bodyType, 'bodyType', 'Unsupported avatar body type');
    }

    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('Authentication required.');
    }

    await SupaFlow.client.rpc(
      'set_avatar_body_type',
      params: {'p_body_type': bodyType},
    );
  }

  static Future<void> setAdventurerArchetype(String archetype) async {
    const allowed = {
      'scholar',
      'scout',
      'alchemist',
      'guardian',
      'wanderer',
    };

    if (!allowed.contains(archetype)) {
      throw ArgumentError.value(
        archetype,
        'archetype',
        'Unsupported adventurer archetype',
      );
    }

    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('Authentication required.');
    }

    await SupaFlow.client.rpc(
      'set_adventurer_archetype',
      params: {'p_archetype': archetype},
    );
  }
}
