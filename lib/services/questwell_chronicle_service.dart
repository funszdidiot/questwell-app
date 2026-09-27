import '/backend/supabase/supabase.dart';

class ChronicleWin {
  const ChronicleWin({
    required this.kind,
    required this.title,
    required this.completedAt,
    required this.xp,
    required this.coins,
  });

  final String kind;
  final String title;
  final DateTime completedAt;
  final int xp;
  final int coins;
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
}

class QuestwellChronicleService {
  const QuestwellChronicleService._();

  static Future<ChronicleSnapshot> load() async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null) throw StateError('Authentication required.');

    final responses = await Future.wait([
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
      SupaFlow.client
          .from('reward_events')
          .select('event_type,xp_amount,coin_amount,created_at')
          .eq('user_id', uid)
          .order('created_at', ascending: false),
    ]);

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

    wins.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    var totalXpEarned = 0;
    var totalCoinsEarned = 0;
    for (final raw in responses[2] as List) {
      final row = Map<String, dynamic>.from(raw as Map);
      final xp = (row['xp_amount'] as num?)?.toInt() ?? 0;
      final coins = (row['coin_amount'] as num?)?.toInt() ?? 0;
      if (xp > 0) totalXpEarned += xp;
      if (coins > 0) totalCoinsEarned += coins;
    }

    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final weekWins =
        wins.where((win) => !win.completedAt.isBefore(startOfWeek)).length;
    final bossesDefeated = wins.where((win) => win.kind == 'boss').length;

    return ChronicleSnapshot(
      wins: wins,
      totalXpEarned: totalXpEarned,
      totalCoinsEarned: totalCoinsEarned,
      weekWins: weekWins,
      bossesDefeated: bossesDefeated,
    );
  }
}
