import '/backend/supabase/supabase.dart';
import '/backend/supabase/questwell_network.dart';

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

  static Future<void> setAside(String taskId) => _changeStatus(taskId, 'open', 'set_aside');
  static Future<void> restore(String taskId) => _changeStatus(taskId, 'set_aside', 'open');

  static Future<void> _changeStatus(String taskId, String from, String to) async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) throw StateError('Authentication required.');
    final rows = await TasksTable().update(data: {'status': to},
      matchingRows: (q) => q.eqOrNull('id', taskId)
        .eqOrNull('user_id', uid).eqOrNull('status', from), returnRows: true);
    if (rows.length != 1) throw StateError('This quest has changed. Refresh the board.');
  }

  static Future<QuestwellTaskCompletionResult> completeTask(
    String taskId,
  ) async {
    final response = await QuestwellNetwork.write(() => SupaFlow.client.rpc(
      'complete_task',
      params: {'p_task_id': taskId},
    ));

    if (response is! List || response.isEmpty) {
      throw StateError('Questwell did not receive a completion result.');
    }

    final row = Map<String, dynamic>.from(response.first as Map);
    return QuestwellTaskCompletionResult.fromJson(row);
  }
}
