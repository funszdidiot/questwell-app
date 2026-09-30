import 'package:flutter/material.dart';
import 'questwell_first_journey.dart';
import 'questwell_starlit_orrery.dart';

class QuestwellMilestoneReward {
  const QuestwellMilestoneReward(this.slug, this.name, this.level);
  final String slug, name;
  final int level;
  static const all = [
    QuestwellMilestoneReward(QuestwellFirstJourney.slug, 'First Journey', 5),
    QuestwellMilestoneReward(QuestwellStarlitOrrery.slug, 'Starlit Orrery', 10),
  ];
  static List<QuestwellMilestoneReward> crossed(int previousLevel, int level) =>
    all.where((r) => previousLevel < r.level && level >= r.level).toList();
  static bool isTrophy(String? slug) => all.any((r) => r.slug == slug);
  Widget get art => slug == QuestwellStarlitOrrery.slug
    ? const QuestwellStarlitOrrery() : const QuestwellFirstJourney();
}

/// One celebration per completed activity, even when it crosses both milestones.
class QuestwellMilestoneUnlockDialog extends StatelessWidget {
  const QuestwellMilestoneUnlockDialog({super.key, required this.rewards,
    required this.level, required this.xpAwarded, required this.coinsAwarded});
  final List<QuestwellMilestoneReward> rewards;
  final int level, xpAwarded, coinsAwarded;
  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: const Color(0xFF19232D),
    title: Text('Level $level reached!'),
    content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      for (final reward in rewards) ...[
        SizedBox(height: 150, width: 180, child: reward.art),
        const SizedBox(height: 12),
        Text(reward.name, style: const TextStyle(fontSize: 21,
          color: Color(0xFFE4C586), fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Your level ${reward.level} milestone trophy is in your inventory. Yours to keep.',
          textAlign: TextAlign.center),
        const SizedBox(height: 12),
      ],
      Text('+$xpAwarded XP · +$coinsAwarded coins'),
    ])),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep in inventory')),
      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Place in Hearth')),
    ],
  );
}
