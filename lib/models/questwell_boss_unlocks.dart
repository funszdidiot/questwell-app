import '../services/questwell_progression.dart';

/// Creation gates only: saved battles are never relocked.
class QuestwellBossUnlocks {
  const QuestwellBossUnlocks._();
  static const levels = <String, int>{
    'inbox_hydra': 1, 'meeting_mimic': 3,
    'spreadsheet_slime': 5, 'calendar_kraken': 7,
    'printer_poltergeist': 10, 'notification_swarm': 13,
    'ticket_troll': 16, 'update_dragon': 20,
  };
  static bool available(String type, int level) =>
      levels.containsKey(type) && level >= levels[type]!;
  static String? next(int level) {
    for (final entry in levels.entries) {
      if (entry.value > level) return entry.key;
    }
    return null;
  }
  static int xpRemaining(String type, int totalXp, int offset) =>
      (QuestwellProgression.totalAtLevel(levels[type] ?? 1) -
          (totalXp < 0 ? 0 : totalXp) - (offset < 0 ? 0 : offset))
          .clamp(0, 1 << 53).toInt();
  static double progress(String type, int totalXp, int offset) {
    final target = levels[type] ?? 1;
    var previous = 1;
    for (final level in levels.values) {
      if (level >= target) break;
      previous = level;
    }
    final start = QuestwellProgression.totalAtLevel(previous);
    final end = QuestwellProgression.totalAtLevel(target);
    if (end <= start) return 1;
    return (((totalXp < 0 ? 0 : totalXp) + (offset < 0 ? 0 : offset) - start) /
        (end - start)).clamp(0.0, 1.0);
  }
}
