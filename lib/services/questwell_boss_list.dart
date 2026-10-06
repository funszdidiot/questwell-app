import '/backend/supabase/supabase.dart';
import '/backend/supabase/questwell_network.dart';
import '../models/questwell_boss.dart';

/// Fetches both owner-bound collections completely before exposing a result.
class QuestwellBossList {
  QuestwellBossList({required this.database, required this.currentOwner});

  final PostgrestClient database;
  final String? Function() currentOwner;
  static final _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  );

  Future<List<QuestwellBossBattle>> load() async {
    final owner = currentOwner();
    if (owner == null || owner.isEmpty) {
      throw StateError('Authentication required.');
    }
    void checkOwner() {
      if (currentOwner() != owner) {
        throw StateError('Boss account changed. Reload your battles.');
      }
    }

    Future<List<Map<String, dynamic>>> collect(
      String table,
      String fields,
    ) async {
      final result = <Map<String, dynamic>>[];
      String? cursor;
      // Immutable UUID keysets avoid offset skips when earlier rows disappear.
      // An empty page, not a short page, establishes the end of each collection.
      while (true) {
        final rows = await QuestwellNetwork.read(() {
          checkOwner();
          var query = database.from(table).select(fields).eq('user_id', owner);
          if (cursor != null) query = query.gt('id', cursor);
          return query.order('id', ascending: true).limit(100);
        });
        checkOwner();
        if (rows.isEmpty) return result;
        for (final row in rows) {
          final id = row['id'];
          if (row['user_id'] != owner ||
              id is! String ||
              !_uuid.hasMatch(id) ||
              (cursor != null && id.compareTo(cursor) <= 0)) {
            throw StateError('The boss list could not be verified. Try again.');
          }
          cursor = id;
          result.add(row);
        }
      }
    }

    final battleRows = await collect(
      'boss_battles',
      'id,user_id,title,status,reward_xp,reward_coins,boss_type,created_at,completed_at',
    );
    final stepRows = await collect(
      'boss_steps',
      'id,user_id,boss_id,title,position,completed',
    );
    checkOwner();
    final times = <String, BigInt>{};
    for (final row in battleRows) {
      times[row['id'] as String] = _timestampMicros(row['created_at']);
    }
    battleRows.sort((a, b) {
      final order = times[a['id']]!.compareTo(times[b['id']]!);
      return order != 0
          ? order
          : (a['id'] as String).compareTo(b['id'] as String);
    });
    final stepsByBoss = <String, List<QuestwellBossStep>>{};
    for (final row in stepRows) {
      final bossId = row['boss_id'];
      final position = row['position'];
      if (bossId is! String ||
          !_uuid.hasMatch(bossId) ||
          position is! int ||
          position < 0 ||
          row['completed'] is! bool) {
        throw StateError('The boss steps could not be verified. Try again.');
      }
      stepsByBoss
          .putIfAbsent(bossId, () => [])
          .add(QuestwellBossStep.fromJson(row));
    }
    for (final steps in stepsByBoss.values) {
      steps.sort((a, b) {
        final order = a.position.compareTo(b.position);
        return order != 0 ? order : a.id.compareTo(b.id);
      });
    }
    return battleRows
        .map(
          (row) => QuestwellBossBattle.fromJson(
            row,
            stepsByBoss[row['id']] ?? const [],
          ),
        )
        .toList();
  }

  // DateTime on web truncates sub-millisecond digits. Keep chronological order
  // at database precision even when UUID order differs from creation order.
  static BigInt _timestampMicros(Object? value) {
    final match = value is String
        ? RegExp(
            r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.(\d{1,6}))?(?:Z|[+-]\d{2}:\d{2})$',
          ).firstMatch(value)
        : null;
    final time = match != null ? DateTime.tryParse(value as String) : null;
    if (time == null) {
      throw StateError('The boss dates could not be verified. Try again.');
    }
    final fraction = (match!.group(1) ?? '').padRight(6, '0');
    return BigInt.from(time.millisecondsSinceEpoch) * BigInt.from(1000) +
        BigInt.from(int.parse(fraction.substring(3)));
  }
}
