/// One reward per completed battle, never multiplied by its task steps.
class QuestwellBossRewards {
  const QuestwellBossRewards._();
  static const victoryXp = 25;
  static const victoryCoins = 50;
}

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
      rewardXp: (json['reward_xp'] as num?)?.toInt() ?? QuestwellBossRewards.victoryXp,
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

