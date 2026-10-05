import '/backend/supabase/supabase.dart';
import '/backend/supabase/questwell_network.dart';
import 'questwell_equipment_policy.dart';
import 'questwell_cosmetic_sync.dart';
import 'questwell_cosmetic_models.dart';
import 'questwell_purchase_recovery.dart';
export 'questwell_cosmetic_models.dart';

class QuestwellCosmeticService {
  const QuestwellCosmeticService._();

  static final changes = QuestwellCosmeticSync();

  static Future<QuestwellCosmeticsSnapshot> load() {
    final uid = SupaFlow.client.auth.currentUser?.id;
    return changes.read(() async {
      if (uid == null || SupaFlow.client.auth.currentUser?.id != uid) {
        throw StateError('Authentication changed.');
      }
      final snapshot = await _load();
      if (SupaFlow.client.auth.currentUser?.id != uid) {
        throw StateError('Authentication changed.');
      }
      return snapshot;
    });
  }

  static Future<T> _write<T>(Future<T> Function() operation) {
    final uid = SupaFlow.client.auth.currentUser?.id;
    return changes.write(() {
      if (uid == null || SupaFlow.client.auth.currentUser?.id != uid) {
        throw StateError('Authentication changed.');
      }
      return QuestwellNetwork.write(operation);
    });
  }

  static Future<QuestwellCosmeticsSnapshot> _load() async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('Authentication required.');
    }

    final responses = await QuestwellNetwork.read(() => Future.wait([
      SupaFlow.client
          .from('users')
          .select('level,total_xp,level_xp_offset,coin_balance,current_energy_mode,onboarding_completed,adventurer_archetype,avatar_body_type')
          .eq('id', uid)
          .single(),
      SupaFlow.client
          .from('cosmetics')
          .select('id,slug,name,category,rarity,description,price,premium,asset_key,required_archetype,unlock_method,milestone_level,collection_key,edition_type,availability_start,availability_end,hearth_profile_key')
          .eq('active', true)
          .order('price'),
      SupaFlow.client
          .from('user_cosmetics')
          .select('cosmetic_id,equipped,room_slot,unlocked_at,source')
          .eq('user_id', uid),
      SupaFlow.client
          .from('hearth_profile_slots')
          .select('profile_key,slot_key,placement_label,sort_order'),
      SupaFlow.client
          .from('hearth_render_registry')
          .select('cosmetic_id,render_kind,asset_source,asset_path,canvas_width,canvas_height,visible_base,shadow_profile,effect_profile,filter_mode,asset_revision,min_client_build'),
    ]));

    final profile =
        QuestwellProfile.fromJson(Map<String, dynamic>.from(responses[0] as Map));

    final ownedRows = List<Map<String, dynamic>>.from(
      (responses[2] as List).map((row) => Map<String, dynamic>.from(row as Map)),
    );

    final ownedById = <String, bool>{};
    for (final row in ownedRows) {
      ownedById[row['cosmetic_id']?.toString() ?? ''] = row['equipped'] == true;
    }

    final placementRows = List<Map<String, dynamic>>.from(
      (responses[3] as List).map((row) => Map<String, dynamic>.from(row as Map)),
    );
    final placementsByProfile =
        <String, List<QuestwellHearthPlacementOption>>{};
    for (final row in placementRows) {
      final profile = row['profile_key']?.toString();
      if (profile == null || profile.isEmpty) continue;
      placementsByProfile
          .putIfAbsent(profile, () => <QuestwellHearthPlacementOption>[])
          .add(QuestwellHearthPlacementOption.fromJson(row));
    }
    for (final placements in placementsByProfile.values) {
      placements.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    final renderByCosmeticId = <String, QuestwellHearthRenderSpec>{};
    for (final raw in (responses[4] as List)) {
      final row = Map<String, dynamic>.from(raw as Map);
      final cosmeticId = row['cosmetic_id']?.toString();
      if (cosmeticId == null || cosmeticId.isEmpty) continue;
      renderByCosmeticId[cosmeticId] =
          QuestwellHearthRenderSpec.fromJson(row);
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
            hearthPlacements: placementsByProfile[
                  row['hearth_profile_key']?.toString()
                ] ??
                const [],
            hearthRenderSpec:
                renderByCosmeticId[row['id']?.toString() ?? ''],
          ),
        )
        .where((item) => !QuestwellEquipmentPolicy.isRetired(item.slug))
        .toList();

    return QuestwellCosmeticsSnapshot(
      profile: profile,
      cosmetics: cosmetics,
    );
  }

  static Future<int> purchase(String cosmeticId) async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    void checkAccount() {
      if (uid == null || SupaFlow.client.auth.currentUser?.id != uid) {
        throw StateError('Authentication changed.');
      }
    }
    return changes.write(() async {
      checkAccount();
      final balance = await QuestwellPurchaseRecovery.run(
        attempt: () async {
          final response = await QuestwellNetwork.write(() => SupaFlow.client.rpc(
            'purchase_cosmetic', params: {'p_cosmetic_id': cosmeticId}));
          checkAccount();
          if (response is! List || response.isEmpty) {
            throw StateError('No purchase result returned.');
          }
          final row = Map<String, dynamic>.from(response.first as Map);
          if (row['remaining_coins'] is! num) {
            throw StateError('No coin balance returned.');
          }
          return (row['remaining_coins'] as num).toInt();
        },
        confirmOwned: () => QuestwellNetwork.read<int?>(() async {
          checkAccount();
          final owned = await SupaFlow.client.from('user_cosmetics')
              .select('cosmetic_id').eq('user_id', uid!)
              .eq('cosmetic_id', cosmeticId).maybeSingle();
          checkAccount();
          if (owned == null) return null;
          // Read the balance after ownership is visible, not in parallel with it.
          final profile = await SupaFlow.client.from('users')
              .select('coin_balance').eq('id', uid!).single();
          checkAccount();
          return (profile['coin_balance'] as num).toInt();
        }),
      );
      checkAccount();
      return balance;
    });
  }

  static Future<void> equip(QuestwellCosmetic cosmetic, {String? expectedConflict}) async {
    if (!cosmetic.owned || !QuestwellEquipmentPolicy.isReady(cosmetic.slug, cosmetic.category)) {
      throw StateError('This item is not ready to equip.');
    }
    final cosmeticId = cosmetic.id;
    await _write(() => SupaFlow.client.rpc(
      'equip_cosmetic_loadout',
      params: {'p_cosmetic_id': cosmeticId, 'p_expected_conflict': expectedConflict},
    ));
  }

  static Future<void> place(String id, String slot, String? expectedOccupant) async {
    await _write(() => SupaFlow.client.rpc('place_hearth_cosmetic', params: {
      'p_cosmetic_id': id, 'p_slot': slot, 'p_expected_occupant': expectedOccupant,
    }));
  }

  static Future<void> unequip(String cosmeticId) async {
    await _write(() => SupaFlow.client.rpc(
      'unequip_cosmetic',
      params: {'p_cosmetic_id': cosmeticId},
    ));
  }

  static Future<void> setEnergyMode(String mode) async {
    if (mode != 'normal' && mode != 'campfire') {
      throw ArgumentError.value(mode, 'mode', 'Unsupported energy mode');
    }

    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('Authentication required.');
    }

    await _write(() => SupaFlow.client
        .from('users')
        .update({'current_energy_mode': mode})
        .eq('id', uid));
  }

  static Future<void> completeOnboarding() async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('Authentication required.');
    }

    await _write(() => SupaFlow.client
        .from('users')
        .update({'onboarding_completed': true})
        .eq('id', uid));
  }

  static Future<String> claimClassMasteryReward() async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('Authentication required.');
    }

    final response = await _write(() => SupaFlow.client.rpc('claim_class_mastery_reward'));
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

    await _write(() => SupaFlow.client.rpc(
      'set_avatar_body_type',
      params: {'p_body_type': bodyType},
    ));
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

    await _write(() => SupaFlow.client.rpc(
      'set_adventurer_archetype',
      params: {'p_archetype': archetype},
    ));
  }
}
