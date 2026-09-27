import '/backend/supabase/supabase.dart';

class QuestwellTaskCompletionResult {
  const QuestwellTaskCompletionResult({
    required this.taskId,
    required this.xpAwarded,
    required this.coinsAwarded,
    required this.totalXp,
    required this.coinBalance,
  });

  final String taskId;
  final int xpAwarded;
  final int coinsAwarded;
  final int totalXp;
  final int coinBalance;

  factory QuestwellTaskCompletionResult.fromJson(Map<String, dynamic> json) {
    return QuestwellTaskCompletionResult(
      taskId: json['task_id']?.toString() ?? '',
      xpAwarded: (json['xp_awarded'] as num?)?.toInt() ?? 0,
      coinsAwarded: (json['coins_awarded'] as num?)?.toInt() ?? 0,
      totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
      coinBalance: (json['coin_balance'] as num?)?.toInt() ?? 0,
    );
  }
}

class QuestwellTaskService {
  const QuestwellTaskService._();

  static Future<QuestwellTaskCompletionResult> completeTask(
    String taskId,
  ) async {
    final response = await SupaFlow.client.rpc(
      'complete_task',
      params: {'p_task_id': taskId},
    );

    if (response is! List || response.isEmpty) {
      throw StateError('Questwell did not receive a completion result.');
    }

    final row = Map<String, dynamic>.from(response.first as Map);
    return QuestwellTaskCompletionResult.fromJson(row);
  }
}
