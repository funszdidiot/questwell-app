import '/backend/supabase/supabase.dart';

class QuestwellProfile {
  const QuestwellProfile({
    required this.level,
    required this.totalXp,
    required this.coinBalance,
    required this.currentEnergyMode,
    required this.onboardingCompleted,
  });

  final int level;
  final int totalXp;
  final int coinBalance;
  final String currentEnergyMode;
  final bool onboardingCompleted;

  bool get campfireMode => currentEnergyMode == 'campfire';

  factory QuestwellProfile.fromJson(Map<String, dynamic> json) {
    return QuestwellProfile(
      level: (json['level'] as num?)?.toInt() ?? 1,
      totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
      coinBalance: (json['coin_balance'] as num?)?.toInt() ?? 0,
      currentEnergyMode:
          json['current_energy_mode']?.toString() ?? 'normal',
      onboardingCompleted: json['onboarding_completed'] == true,
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
    required this.owned,
    required this.equipped,
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
  final bool owned;
  final bool equipped;

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
      owned: owned ?? this.owned,
      equipped: equipped ?? this.equipped,
    );
  }

  factory QuestwellCosmetic.fromJson(
    Map<String, dynamic> json, {
    bool owned = false,
    bool equipped = false,
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
      owned: owned,
      equipped: equipped,
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
          .select('level,total_xp,coin_balance,current_energy_mode,onboarding_completed')
          .eq('id', uid)
          .single(),
      SupaFlow.client
          .from('cosmetics')
          .select('id,slug,name,category,rarity,description,price,premium,asset_key')
          .eq('active', true)
          .order('price'),
      SupaFlow.client
          .from('user_cosmetics')
          .select('cosmetic_id,equipped')
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

  static Future<void> equip(String cosmeticId) async {
    await SupaFlow.client.rpc(
      'equip_cosmetic',
      params: {'p_cosmetic_id': cosmeticId},
    );
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
}
