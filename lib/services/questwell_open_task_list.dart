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
    final tasks = <TasksRow>[];
    final seen = <String>{};
    String? cursorTime;
    BigInt? cursorMicros;
    String? cursorId;
    void checkOwner() {
      if (currentOwner() != owner) {
        throw StateError('The quest account changed. Reload your quests.');
      }
    }

    // Keyset paging avoids offset skips when earlier quests are removed.
    // Continue to an empty page: the server may cap pages below our limit.
    while (true) {
      final rows = await QuestwellNetwork.read(() {
        checkOwner(); // Also checked when the network helper retries.
        var query = database
            .from('tasks')
            .select()
            .eq('user_id', owner)
            .eq('status', 'open');
        if (cursorTime != null) {
          final time = cursorTime;
          query = query.or(
            'created_at.lt.$time,and(created_at.eq.$time,id.lt.$cursorId)',
          );
        }
        return query
            .order('created_at', ascending: false)
            .order('id', ascending: false)
            .limit(100);
      });
      checkOwner();
      if (rows.isEmpty) return tasks;
      for (final row in rows) {
        final id = row['id'];
        final rawTime = row['created_at'];
        final timestamp = rawTime is String
            ? RegExp(
                r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.(\d{1,6}))?(?:Z|[+-]\d{2}:\d{2})$',
              ).firstMatch(rawTime)
            : null;
        final time = timestamp != null
            ? DateTime.tryParse(rawTime as String)
            : null;
        if (row['user_id'] != owner ||
            row['status'] != 'open' ||
            id is! String ||
            !RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
            ).hasMatch(id) ||
            time == null ||
            !seen.add(id)) {
          throw StateError('The quest list could not be verified. Try again.');
        }
        // Dart web DateTime loses sub-millisecond precision. Preserve the
        // server timestamp in the query and compare the remaining digits too.
        final fraction = (timestamp!.group(1) ?? '').padRight(6, '0');
        final micros =
            BigInt.from(time.millisecondsSinceEpoch) * BigInt.from(1000) +
            BigInt.from(int.parse(fraction.substring(3)));
        if (cursorMicros != null &&
            (micros > cursorMicros ||
                (micros == cursorMicros && id.compareTo(cursorId!) >= 0))) {
          throw StateError('The quest list order changed. Try again.');
        }
        cursorTime = rawTime as String;
        cursorMicros = micros;
        cursorId = id;
        tasks.add(TasksRow(row));
      }
    }
  }
}
