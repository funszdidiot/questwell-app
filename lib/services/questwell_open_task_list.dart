import 'package:postgrest/postgrest.dart';

import '/backend/supabase/supabase.dart';
import '/backend/supabase/questwell_network.dart';

/// Owns the open-quest read shared by the board and Hearth.
class QuestwellOpenTaskList {
  QuestwellOpenTaskList({required this.database, required this.currentOwner});

  final PostgrestClient database;
  final String? Function() currentOwner;

  static Future<List<TasksRow>> loadCurrent() => QuestwellOpenTaskList(
    database: SupaFlow.client.rest,
    currentOwner: () => SupaFlow.client.auth.currentUser?.id,
  ).load();

  Future<List<TasksRow>> load() async {
    final owner = currentOwner();
    if (owner == null || owner.isEmpty) return [];
    // Historical single-page behavior, retained for characterization first.
    final rows = await QuestwellNetwork.read(
      () => database
          .from('tasks')
          .select()
          .eq('user_id', owner)
          .eq('status', 'open')
          .order('created_at', ascending: false)
          .limit(50),
    );
    return rows.map(TasksRow.new).toList();
  }
}
