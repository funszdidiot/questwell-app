import 'package:flutter/material.dart';

class QuestwellFirstJourney extends StatelessWidget {
  const QuestwellFirstJourney({super.key});
  static const slug = 'first-journey-trophy';
  static const asset = 'assets/images/questwell/hearth/first_journey_trophy.webp';
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'First Journey bronze compass trophy', image: true,
    child: IgnorePointer(child: Image.asset(asset, fit: BoxFit.contain,
      filterQuality: FilterQuality.high, excludeFromSemantics: true)));
}

class FirstJourneyUnlockDialog extends StatelessWidget {
  const FirstJourneyUnlockDialog({super.key, required this.level,
    required this.xpAwarded, required this.coinsAwarded});
  final int level, xpAwarded, coinsAwarded;
  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: const Color(0xFF19232D),
    title: Text('Level $level reached!'),
    content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 150, width: 180, child: QuestwellFirstJourney()),
      const SizedBox(height: 12),
      const Text('First Journey', style: TextStyle(fontSize: 21, color: Color(0xFFE4C586), fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Your level 5 milestone trophy is now in your inventory. A keepsake for the progress you made, one quest at a time.', textAlign: TextAlign.center),
      const SizedBox(height: 12),
      Text('+$xpAwarded XP · +$coinsAwarded coins'),
    ])),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep in inventory')),
      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Place in Hearth')),
    ],
  );
}
