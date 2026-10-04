import '/backend/supabase/database/tables/tasks.dart';

/// Presentation policy for selecting and ordering quests shown on the Hearth.
///
/// Normal mode shows every open quest, with pinned quests first. Campfire Mode
/// intentionally narrows the Hearth to one gentle quest while preserving pinned
/// precedence.
abstract final class QuestwellHomeQuestPolicy {
  static final _epoch = DateTime.fromMillisecondsSinceEpoch(0);

  static List<TasksRow> visibleTasks(
    Iterable<TasksRow> tasks, {
    required bool campfireMode,
  }) {
    final ordered = List<TasksRow>.from(tasks)
      ..sort((a, b) {
        final aPinned = a.pinnedAt != null;
        final bPinned = b.pinnedAt != null;
        if (aPinned != bPinned) return aPinned ? -1 : 1;
        return (b.createdAt ?? _epoch).compareTo(a.createdAt ?? _epoch);
      });

    if (!campfireMode) return ordered;

    ordered.sort((a, b) {
      final aPinned = a.pinnedAt != null;
      final bPinned = b.pinnedAt != null;
      if (aPinned != bPinned) return aPinned ? -1 : 1;
      final friction = (a.frictionLevel ?? 99).compareTo(b.frictionLevel ?? 99);
      if (friction != 0) return friction;
      return (b.createdAt ?? _epoch).compareTo(a.createdAt ?? _epoch);
    });

    return ordered.take(1).toList();
  }
}
