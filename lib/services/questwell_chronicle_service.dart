import '/backend/supabase/supabase.dart';
import '/backend/supabase/questwell_network.dart';

DateTime _chronicleWeekStart(DateTime now) {
  final today = now.toLocal();
  return DateTime(today.year, today.month, today.day)
      .subtract(Duration(days: today.weekday - 1));
}

List<ChronicleWin> _sortedChronicleWins(List<ChronicleWin> entries) =>
    List<ChronicleWin>.from(entries)
      ..sort((a, b) {
        final date = b.completedAt.compareTo(a.completedAt);
        return date != 0 ? date : a.kind.compareTo(b.kind);
      });

class _ChronicleTotals {
  _ChronicleTotals(Object? response, String owner, DateTime weekStart) {
    if (response is! Map || response['owner_id'] != owner) {
      throw StateError('Chronicle totals could not be verified. Try again.');
    }
    final boundary = response['week_start'];
    final parsed = boundary is String ? DateTime.tryParse(boundary) : null;
    if (parsed == null ||
        !parsed.isUtc ||
        !parsed.isAtSameMomentAs(weekStart)) {
      throw StateError('Chronicle week could not be verified. Try again.');
    }
    int integer(String field, {bool count = false}) {
      final raw = response[field];
      if (raw is! String || !RegExp(r'^(0|-?[1-9][0-9]*)$').hasMatch(raw)) {
        throw StateError('Chronicle totals could not be verified. Try again.');
      }
      final value = BigInt.tryParse(raw);
      // Match native and browser behavior; never round an aggregate silently.
      final safe = BigInt.parse('9007199254740991');
      if (value == null || value.abs() > safe || (count && value.isNegative)) {
        throw StateError('Chronicle totals are outside the supported range.');
      }
      return value.toInt();
    }

    xp = integer('total_xp_earned');
    coins = integer('total_coins_earned');
    weekWins = integer('week_wins', count: true);
    bosses = integer('bosses_defeated', count: true);
  }

  late final int xp, coins, weekWins, bosses;
}

class ChronicleWin {
  const ChronicleWin({
    required this.kind,
    required this.title,
    required this.completedAt,
    required this.xp,
    required this.coins,
    this.cosmeticSlug,
    this.source,
    this.level,
    this.taskId,
  });

  final String? taskId;
  final String kind;
  final String title;
  final DateTime completedAt;
  final int xp;
  final int coins;
  final String? cosmeticSlug, source;
  final int? level;
  bool get isActivity => kind == 'quest' || kind == 'boss';

  factory ChronicleWin.fromProgression(Map<String, dynamic> row) =>
      ChronicleWin(
        kind: row['kind'].toString(),
        title: row['title'].toString(),
        completedAt: DateTime.parse(row['occurred_at'].toString()),
        xp: 0,
        coins: 0,
        cosmeticSlug: row['cosmetic_slug']?.toString(),
        source: row['source']?.toString(),
        level: (row['level'] as num?)?.toInt(),
      );
}

class ChronicleSnapshot {
  const ChronicleSnapshot({
    required this.wins,
    required this.totalXpEarned,
    required this.totalCoinsEarned,
    required this.weekWins,
    required this.bossesDefeated,
  });

  final List<ChronicleWin> wins;
  final int totalXpEarned;
  final int totalCoinsEarned;
  final int weekWins;
  final int bossesDefeated;

  factory ChronicleSnapshot.fromWins(
    List<ChronicleWin> entries, {
    DateTime? now,
  }) {
    final wins = _sortedChronicleWins(entries);
    final activities = wins.where((win) => win.isActivity);
    final startOfWeek = _chronicleWeekStart(now ?? DateTime.now());
    return ChronicleSnapshot(
      wins: wins,
      totalXpEarned: activities.fold<int>(0, (total, win) => total + win.xp),
      totalCoinsEarned: activities.fold<int>(
        0,
        (total, win) => total + win.coins,
      ),
      weekWins: activities
          .where((win) => !win.completedAt.isBefore(startOfWeek))
          .length,
      bossesDefeated: activities.where((win) => win.kind == 'boss').length,
    );
  }
}

class QuestwellChronicleService {
  const QuestwellChronicleService._();

  /// Creates an open copy only; completion remains the sole reward path.
  static Future<void> repeatQuest(ChronicleWin win) async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null || win.kind != 'quest' || win.taskId == null) {
      throw StateError(
        'A completed quest and signed-in adventurer are required.',
      );
    }
    final originals = await TasksTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('id', win.taskId)
          .eqOrNull('user_id', uid)
          .eqOrNull('status', 'completed'),
      limit: 1,
    );
    if (originals.isEmpty)
      throw StateError('The original quest is unavailable.');
    final original = originals.single;
    await TasksTable().insert({
      'user_id': uid,
      'title': original.title,
      'friction_level': original.frictionLevel,
      'xp_value': original.xpValue,
      'coin_value': original.coinValue,
      'status': 'open',
    });
  }

  static Future<ChronicleSnapshot> load({
    PostgrestClient? database,
    String? Function()? currentOwner,
    DateTime? now,
  }) async {
    final ownerOf = currentOwner ?? () => SupaFlow.client.auth.currentUser?.id;
    final uid = ownerOf();
    if (uid == null || uid.isEmpty)
      throw StateError('Authentication required.');
    final db = database ?? SupaFlow.client.rest;
    final weekStart = _chronicleWeekStart(now ?? DateTime.now());
    final uuid = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    );
    void checkOwner() {
      if (ownerOf() != uid) {
        throw StateError('Chronicle account changed. Reload your history.');
      }
    }

    Future<List<Map<String, dynamic>>> collect(
      String table,
      String fields,
      String dateField, {
      String? status,
    }) async {
      final result = <Map<String, dynamic>>[];
      String? cursor;
      // Immutable IDs avoid offset skips when earlier history is removed.
      // Server caps can be smaller than our requested page size.
      while (true) {
        final rows = await QuestwellNetwork.read(() {
          checkOwner();
          var query = db.from(table).select(fields).eq('user_id', uid);
          if (status != null) query = query.eq('status', status);
          if (cursor != null) query = query.gt('id', cursor);
          return query.order('id', ascending: true).limit(100);
        });
        checkOwner();
        if (rows.isEmpty) return result;
        for (final row in rows) {
          final id = row['id'];
          final date = row[dateField];
          if (row['user_id'] != uid ||
              (status != null && row['status'] != status) ||
              id is! String ||
              !uuid.hasMatch(id) ||
              (cursor != null && id.compareTo(cursor) <= 0) ||
              date is! String ||
              DateTime.tryParse(date) == null) {
            throw StateError(
              'Chronicle history could not be verified. Try again.',
            );
          }
          cursor = id;
          result.add(row);
        }
      }
    }

    // Publish totals only after every collection is complete. A failed page
    // must never produce a plausible-looking partial lifetime total.
    final quests = await collect(
      'tasks',
      'id,user_id,status,title,xp_value,coin_value,completed_at',
      'completed_at',
      status: 'completed',
    );
    final bosses = await collect(
      'boss_battles',
      'id,user_id,title,reward_xp,reward_coins,completed_at,status',
      'completed_at',
      status: 'completed',
    );
    final progression = await collect(
      'progression_events',
      'id,user_id,kind,title,level,cosmetic_slug,source,occurred_at',
      'occurred_at',
    );
    final aside = await collect(
      'tasks',
      'id,user_id,status,title,xp_value,coin_value,created_at',
      'created_at',
      status: 'set_aside',
    );
    checkOwner();
    final wins = <ChronicleWin>[
      for (final row in aside)
        ChronicleWin(
          kind: 'set_aside',
          taskId: row['id']?.toString(),
          title: row['title']?.toString() ?? 'Quest',
          completedAt: DateTime.parse(row['created_at'].toString()),
          xp: (row['xp_value'] as num?)?.toInt() ?? 0,
          coins: (row['coin_value'] as num?)?.toInt() ?? 0,
        ),
    ];

    for (final row in quests) {
      final completed = DateTime.parse(row['completed_at'] as String);
      wins.add(
        ChronicleWin(
          kind: 'quest',
          taskId: row['id']?.toString(),
          title: (row['title']?.toString().trim().isNotEmpty ?? false)
              ? row['title'].toString()
              : 'Completed quest',
          completedAt: completed,
          xp: (row['xp_value'] as num?)?.toInt() ?? 0,
          coins: (row['coin_value'] as num?)?.toInt() ?? 0,
        ),
      );
    }

    for (final row in bosses) {
      final completed = DateTime.parse(row['completed_at'] as String);
      wins.add(
        ChronicleWin(
          kind: 'boss',
          title: (row['title']?.toString().trim().isNotEmpty ?? false)
              ? row['title'].toString()
              : 'Defeated boss',
          completedAt: completed,
          xp: (row['reward_xp'] as num?)?.toInt() ?? 0,
          coins: (row['reward_coins'] as num?)?.toInt() ?? 0,
        ),
      );
    }

    for (final row in progression) {
      wins.add(ChronicleWin.fromProgression(row));
    }
    final response = await QuestwellNetwork.read(() {
      checkOwner();
      return db.rpc('chronicle_totals', params: {
        'p_week_start': weekStart.toUtc().toIso8601String(),
      });
    });
    checkOwner();
    final totals = _ChronicleTotals(response, uid, weekStart);
    return ChronicleSnapshot(
      wins: _sortedChronicleWins(wins),
      totalXpEarned: totals.xp,
      totalCoinsEarned: totals.coins,
      weekWins: totals.weekWins,
      bossesDefeated: totals.bosses,
    );
  }
}
