import 'package:flutter/material.dart';
import '../models/questwell_boss_unlocks.dart';
import 'questwell_boss_board.dart';

class QuestwellBossUnlockProgress extends StatelessWidget {
  const QuestwellBossUnlockProgress(
      {super.key,
      required this.level,
      required this.totalXp,
      this.offset = 0,
      this.known = true});
  final int level, totalXp, offset;
  final bool known;
  @override
  Widget build(BuildContext context) {
    final next = QuestwellBossUnlocks.next(level);
    final label = !known
        ? 'Level unavailable · Inbox Hydra is available'
        : next == null
            ? 'Level $level · All eight bosses unlocked'
            : 'Level $level · Next: ${questwellBossNames[next]} at level ${QuestwellBossUnlocks.levels[next]}';
    return Semantics(
        label: label,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Color(0xFFE4C586), fontSize: 12, height: 1.4)),
              if (known && next != null) ...[
                const SizedBox(height: 6),
                LinearProgressIndicator(
                    value: QuestwellBossUnlocks.progress(next, totalXp, offset),
                    minHeight: 5,
                    color: const Color(0xFFE4C586),
                    backgroundColor: const Color(0xFF344249),
                    semanticsLabel: 'Progress to ${questwellBossNames[next]}'),
                const SizedBox(height: 4),
                Text(
                    '${QuestwellBossUnlocks.xpRemaining(next, totalXp, offset)} XP to unlock',
                    style: const TextStyle(
                        color: Color(0xFFB7C4C9), fontSize: 11)),
              ],
            ]));
  }
}

class QuestwellBossPicker extends StatelessWidget {
  const QuestwellBossPicker(
      {super.key,
      required this.value,
      required this.level,
      required this.onChanged,
      this.now});
  final DateTime? now;
  final String value;
  final int level;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: value,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Boss'),
              items: [
                for (final entry in questwellBossNames.entries)
                  DropdownMenuItem<String>(
                    value: entry.key,
                    enabled: QuestwellBossUnlocks.available(entry.key, level,
                        now: now),
                    child: Text(
                        entry.key == 'hollow_harvest'
                            ? (QuestwellBossUnlocks.harvestOpen(
                                    now ?? DateTime.now())
                                ? 'The Hollow Harvest · Halloween · Lv 1'
                                : 'The Hollow Harvest · Out of season')
                            : QuestwellBossUnlocks.available(entry.key, level,
                                    now: now)
                                ? '${entry.value} · Lv ${QuestwellBossUnlocks.requiredLevel(entry.key)}'
                                : '${entry.value} · Locked: Lv ${QuestwellBossUnlocks.requiredLevel(entry.key)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13,
                            color: QuestwellBossUnlocks.available(
                                    entry.key, level,
                                    now: now)
                                ? null
                                : Colors.grey)),
                  ),
              ],
              onChanged: (type) {
                if (type != null &&
                    QuestwellBossUnlocks.available(type, level, now: now))
                  onChanged(type);
              },
            ),
            const SizedBox(height: 8),
            if (QuestwellBossUnlocks.harvestOpen(now ?? DateTime.now()))
              const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                      'Halloween guest · Summon through November 8. Started battles stay playable.',
                      style: TextStyle(fontSize: 12, height: 1.4))),
            const Text(
                'Any project can use an unlocked boss. Existing battles stay playable.',
                style: TextStyle(fontSize: 12, height: 1.4)),
          ]);
}
