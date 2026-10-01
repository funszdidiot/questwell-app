import '/backend/supabase/supabase.dart';
import '/backend/supabase/questwell_network.dart';

class QuestwellBossStep {
  const QuestwellBossStep({
    required this.id,
    required this.title,
    required this.position,
    required this.completed,
  });

  final String id;
  final String title;
  final int position;
  final bool completed;

  factory QuestwellBossStep.fromJson(Map<String, dynamic> json) {
    return QuestwellBossStep(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Step',
      position: (json['position'] as num?)?.toInt() ?? 0,
      completed: json['completed'] == true,
    );
  }
}

class QuestwellBossBattle {
  const QuestwellBossBattle({
    required this.id,
    required this.title,
    required this.status,
    required this.rewardXp,
    required this.rewardCoins,
    required this.bossType,
    required this.steps,
  });

  final String id;
  final String title;
  final String status;
  final int rewardXp;
  final int rewardCoins;
  final String bossType;
  final List<QuestwellBossStep> steps;

  int get completedSteps => steps.where((step) => step.completed).length;
  int get totalSteps => steps.length;
  double get progress =>
      totalSteps == 0 ? 0 : completedSteps / totalSteps.toDouble();
  bool get completed => status == 'completed';

  factory QuestwellBossBattle.fromJson(
    Map<String, dynamic> json,
    List<QuestwellBossStep> steps,
  ) {
    return QuestwellBossBattle(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Boss Battle',
      status: json['status']?.toString() ?? 'open',
      rewardXp: (json['reward_xp'] as num?)?.toInt() ?? 100,
      rewardCoins: (json['reward_coins'] as num?)?.toInt() ?? 50,
      bossType: json['boss_type']?.toString() ?? 'inbox_hydra',
      steps: steps,
    );
  }
}

class BossStepCompletionResult {
  const BossStepCompletionResult({
    required this.bossCompleted,
    required this.xpAwarded,
    required this.coinsAwarded,
    required this.totalXp,
    required this.coinBalance,
  });

  final bool bossCompleted;
  final int xpAwarded;
  final int coinsAwarded;
  final int totalXp;
  final int coinBalance;
}

class QuestwellBossService {
  const QuestwellBossService._();

  static Future<List<QuestwellBossBattle>> loadBattles() async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) throw StateError('Authentication required.');

    final responses = await QuestwellNetwork.read(() => Future.wait([
      SupaFlow.client
          .from('boss_battles')
          .select('id,title,status,reward_xp,reward_coins,boss_type,created_at')
          .eq('user_id', uid)
          .order('created_at', ascending: true),
      SupaFlow.client
          .from('boss_steps')
          .select('id,boss_id,title,position,completed')
          .eq('user_id', uid)
          .order('position', ascending: true),
    ]));

    final battleRows = List<Map<String, dynamic>>.from(
      (responses[0] as List).map((row) => Map<String, dynamic>.from(row as Map)),
    );
    final stepRows = List<Map<String, dynamic>>.from(
      (responses[1] as List).map((row) => Map<String, dynamic>.from(row as Map)),
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
    final response = await QuestwellNetwork.write(() => SupaFlow.client.rpc(
      'create_boss_battle',
      params: {
        'p_title': title,
        'p_steps': steps,
        'p_reward_xp': 100,
        'p_reward_coins': 50,
        'p_boss_type': bossType,
      },
    ));
    return response?.toString() ?? '';
  }

  static Future<BossStepCompletionResult> completeStep(String stepId) async {
    final response = await QuestwellNetwork.write(() => SupaFlow.client.rpc(
      'complete_boss_step',
      params: {'p_step_id': stepId},
    ));

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
