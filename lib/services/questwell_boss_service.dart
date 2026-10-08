import 'questwell_content_policy.dart';
import 'dart:convert';

import 'questwell_boss_creation_recovery.dart';
import 'questwell_boss_list.dart';
import 'questwell_reward_response.dart';
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
    final error = QuestwellContentPolicy.bossError(title, steps);
    if (error != null) throw ArgumentError(error);
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
    final owner = SupaFlow.client.auth.currentUser?.id;
    if (owner == null) throw StateError('Authentication required.');
    final response = await QuestwellNetwork.write(
      () => SupaFlow.client.rpc(
        'complete_boss_step',
        params: {'p_step_id': stepId},
      ),
    );

    if (SupaFlow.client.auth.currentUser?.id != owner) {
      throw StateError('Reward account changed.');
    }

    final row = QuestwellRewardResponse.singleRow(response);
    final bossCompleted = row['boss_completed'];
    if (bossCompleted is! bool) {
      QuestwellRewardResponse.invalid();
    }
    return BossStepCompletionResult(
      bossCompleted: bossCompleted,
      xpAwarded: QuestwellRewardResponse.integer(row, 'xp_awarded'),
      coinsAwarded: QuestwellRewardResponse.integer(row, 'coins_awarded'),
      totalXp: QuestwellRewardResponse.integer(row, 'total_xp'),
      coinBalance: QuestwellRewardResponse.integer(row, 'coin_balance'),
    );
  }
}
