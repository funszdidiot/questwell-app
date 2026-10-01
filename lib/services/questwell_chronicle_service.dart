import '/backend/supabase/supabase.dart';
import '/backend/supabase/questwell_network.dart';

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
  });

  final String kind;
  final String title;
  final DateTime completedAt;
  final int xp;
  final int coins;
  final String? cosmeticSlug, source;
  final int? level;
  bool get isActivity => kind == 'quest' || kind == 'boss';

  factory ChronicleWin.fromProgression(Map<String, dynamic> row) => ChronicleWin(
    kind: row['kind'].toString(), title: row['title'].toString(),
    completedAt: DateTime.parse(row['occurred_at'].toString()), xp: 0, coins: 0,
    cosmeticSlug: row['cosmetic_slug']?.toString(), source: row['source']?.toString(),
    level: (row['level'] as num?)?.toInt());
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

  factory ChronicleSnapshot.fromWins(List<ChronicleWin> entries, {DateTime? now}) {
    final wins = List<ChronicleWin>.from(entries)
      ..sort((a,b) {
        final date = b.completedAt.compareTo(a.completedAt);
        return date != 0 ? date : a.kind.compareTo(b.kind);
      });
    final activities = wins.where((win) => win.isActivity);
    final today = (now ?? DateTime.now()).toLocal();
    final startOfWeek = DateTime(today.year, today.month, today.day)
      .subtract(Duration(days: today.weekday - 1));
    return ChronicleSnapshot(wins: wins,
      totalXpEarned: activities.fold<int>(0, (total, win) => total + win.xp),
      totalCoinsEarned: activities.fold<int>(0, (total, win) => total + win.coins),
      weekWins: activities.where((win) => !win.completedAt.isBefore(startOfWeek)).length,
      bossesDefeated: activities.where((win) => win.kind == 'boss').length);
  }
}

class QuestwellChronicleService {
  const QuestwellChronicleService._();

  static Future<ChronicleSnapshot> load() async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) throw StateError('Authentication required.');

    final responses = await QuestwellNetwork.read(() => Future.wait([
      SupaFlow.client
          .from('tasks')
          .select('id,title,xp_value,coin_value,completed_at')
          .eq('user_id', uid)
          .eq('status', 'completed')
          .order('completed_at', ascending: false),
      SupaFlow.client
          .from('boss_battles')
          .select('id,title,reward_xp,reward_coins,completed_at,status')
          .eq('user_id', uid)
          .eq('status', 'completed')
          .order('completed_at', ascending: false),
      SupaFlow.client.from('progression_events')
          .select('kind,title,level,cosmetic_slug,source,occurred_at')
          .eq('user_id', uid)
          .order('occurred_at', ascending: false),
    ]));

    final wins = <ChronicleWin>[];

    for (final raw in responses[0] as List) {
      final row = Map<String, dynamic>.from(raw as Map);
      final completed = DateTime.tryParse(row['completed_at']?.toString() ?? '');
      if (completed == null) continue;
      wins.add(
        ChronicleWin(
          kind: 'quest',
          title: (row['title']?.toString().trim().isNotEmpty ?? false)
              ? row['title'].toString()
              : 'Completed quest',
          completedAt: completed,
          xp: (row['xp_value'] as num?)?.toInt() ?? 0,
          coins: (row['coin_value'] as num?)?.toInt() ?? 0,
        ),
      );
    }

    for (final raw in responses[1] as List) {
      final row = Map<String, dynamic>.from(raw as Map);
      final completed = DateTime.tryParse(row['completed_at']?.toString() ?? '');
      if (completed == null) continue;
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

    for (final raw in responses[2] as List) {
      wins.add(ChronicleWin.fromProgression(Map<String, dynamic>.from(raw as Map)));
    }
    return ChronicleSnapshot.fromWins(wins);
  }
}
