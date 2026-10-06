import 'dart:convert';

import 'questwell_boss_creation_recovery.dart';
import 'questwell_boss_list.dart';
import '/backend/supabase/supabase.dart';
import '/backend/supabase/questwell_network.dart';

import '../models/questwell_boss.dart';
export '../models/questwell_boss.dart';

class QuestwellBossService {
  const QuestwellBossService._();
  static final _creationRecovery = QuestwellBossCreationRecovery();

  static String? currentOwner() => SupaFlow.client.auth.currentUser?.id;

  static Future<List<QuestwellBossBattle>> loadBattles() async {
    final battles = await QuestwellBossList(
      database: SupaFlow.client.rest,
      currentOwner: currentOwner,
    ).load();
    _creationRecovery.acknowledge(battles.map((battle) => battle.id));
    return battles;
  }

  static Future<String> createBattle({
    required String title,
    required List<String> steps,
    String bossType = 'inbox_hydra',
    String? expectedOwnerId,
    String? requestId,
  }) async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) throw StateError('Authentication required.');
    if (expectedOwnerId != null && expectedOwnerId != uid) {
      throw StateError('Boss account changed.');
    }
    return _creationRecovery.create(
      key: jsonEncode([uid, requestId, title, steps, bossType]),
      requestId: requestId,
      send: (requestId) async {
        if (SupaFlow.client.auth.currentUser?.id != uid) {
          throw StateError('Boss account changed.');
        }
        final response = await SupaFlow.client.rpc(
          'create_boss_once',
          params: {
            'p_request_id': requestId,
            'p_expected_user_id': uid,
            'p_title': title,
            'p_steps': steps,
            'p_boss_type': bossType,
          },
        );
        if (SupaFlow.client.auth.currentUser?.id != uid) {
          throw StateError('Boss account changed.');
        }
        if (response is! String) {
          throw const QuestwellNetworkException(
            'Your battle was not confirmed. Retry this draft or check your battles.',
          );
        }
        return response;
      },
    );
  }

  static Future<BossStepCompletionResult> completeStep(String stepId) async {
    final response = await QuestwellNetwork.write(
      () => SupaFlow.client.rpc(
        'complete_boss_step',
        params: {'p_step_id': stepId},
      ),
    );

    if (response is! List || response.isEmpty) {
      throw StateError('No boss step result returned.');
    }

    final row = Map<String, dynamic>.from(response.first as Map);
    return BossStepCompletionResult(
      bossCompleted: row['boss_completed'] == true,
      xpAwarded: (row['xp_awarded'] as num?)?.toInt() ?? 0,
      coinsAwarded: (row['coins_awarded'] as num?)?.toInt() ?? 0,
      totalXp: (row['total_xp'] as num?)?.toInt() ?? 0,
      coinBalance: (row['coin_balance'] as num?)?.toInt() ?? 0,
    );
  }
}
