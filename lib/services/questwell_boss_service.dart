import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import 'questwell_boss_creation_recovery.dart';
import '/backend/supabase/supabase.dart';
import '/backend/supabase/questwell_network.dart';

import '../models/questwell_boss.dart';
export '../models/questwell_boss.dart';

class QuestwellBossService {
  const QuestwellBossService._();
  static final _creationRecovery = QuestwellBossCreationRecovery();

  static Future<List<QuestwellBossBattle>> loadBattles() async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) throw StateError('Authentication required.');

    final responses = await QuestwellNetwork.read(
      () => Future.wait([
        SupaFlow.client
            .from('boss_battles')
            .select(
              'id,title,status,reward_xp,reward_coins,boss_type,created_at,completed_at',
            )
            .eq('user_id', uid)
            .order('created_at', ascending: true),
        SupaFlow.client
            .from('boss_steps')
            .select('id,boss_id,title,position,completed')
            .eq('user_id', uid)
            .order('position', ascending: true),
      ]),
    );

    final battleRows = List<Map<String, dynamic>>.from(
      (responses[0] as List).map(
        (row) => Map<String, dynamic>.from(row as Map),
      ),
    );
    final stepRows = List<Map<String, dynamic>>.from(
      (responses[1] as List).map(
        (row) => Map<String, dynamic>.from(row as Map),
      ),
    );

    final stepsByBoss = <String, List<QuestwellBossStep>>{};
    for (final row in stepRows) {
      final bossId = row['boss_id']?.toString() ?? '';
      stepsByBoss.putIfAbsent(bossId, () => []);
      stepsByBoss[bossId]!.add(QuestwellBossStep.fromJson(row));
    }

    return battleRows
        .map(
          (row) => QuestwellBossBattle.fromJson(
            row,
            stepsByBoss[row['id']?.toString() ?? ''] ?? const [],
          ),
        )
        .toList();
  }

  static Future<String> createBattle({
    required String title,
    required List<String> steps,
    String bossType = 'inbox_hydra',
  }) async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) throw StateError('Authentication required.');
    return _creationRecovery.create(
      key: jsonEncode([uid, title, steps, bossType]),
      rejected: (error) =>
          error is PostgrestException &&
          const {
            'P0001',
            '42501',
            '23502',
            '23514',
            '22023',
            'PGRST301',
            'PGRST302',
            'PGRST303',
          }.contains(error.code),
      send: () async {
        final response = await SupaFlow.client.rpc(
          'create_boss_battle',
          params: {
            'p_title': title,
            'p_steps': steps,
            'p_reward_xp': QuestwellBossRewards.victoryXp,
            'p_reward_coins': QuestwellBossRewards.victoryCoins,
            'p_boss_type': bossType,
          },
        );
        return response?.toString() ?? '';
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
