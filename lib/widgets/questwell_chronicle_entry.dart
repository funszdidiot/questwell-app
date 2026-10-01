import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/questwell_chronicle_service.dart';
import 'questwell_pixel_art.dart';
import 'questwell_typography.dart';

class QuestwellChronicleEntry extends StatelessWidget {
  const QuestwellChronicleEntry({super.key, required this.win, this.embedded = false});
  final ChronicleWin win;
  final bool embedded;
  TextStyle _text(double size, {bool bold = false, Color color = const Color(0xFF443426)}) =>
    QuestwellTypography.body(fontSize: size, height: 1.4, color: color,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400);
  @override
  Widget build(BuildContext context) {
    final isReward = win.kind == 'milestone_reward';
    final preview = isReward && win.source != 'level_milestone';
    final label = switch(win.kind) {
      'boss' => 'BOSS DEFEATED',
      'level_up' => 'LEVEL UP',
      'milestone_reward' => preview ? 'ADDED TO COLLECTION' : 'MILESTONE REWARD',
      _ => 'QUEST COMPLETE',
    };
    final ink = switch (win.kind) {
      'boss' => const Color(0xFF854534),
      'level_up' => const Color(0xFF655079),
      'milestone_reward' => const Color(0xFF805D24),
      _ => const Color(0xFF3C6757),
    };
    final content = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 40, height: 44, alignment: Alignment.center,
        decoration: BoxDecoration(color: ink.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(4), border: Border.all(color: ink.withValues(alpha: .25))),
        child: isReward && win.cosmeticSlug != null
          ? QuestwellItemPixelArt(slug: win.cosmeticSlug!, category: 'room', size: 36)
          : Icon(switch (win.kind) { 'boss' => Icons.shield_outlined,
            'level_up' => Icons.auto_awesome, _ => Icons.check_rounded }, size: 26, color: ink)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: _text(12, bold: true, color: ink)),
        const SizedBox(height: 4),
        Text(win.title, style: _text(17, bold: true, color: const Color(0xFF352B23))),
        const SizedBox(height: 5),
        Text(DateFormat(embedded ? 'h:mm a' : 'MMM d, yyyy · h:mm a').format(win.completedAt.toLocal()),
          style: _text(12, color: const Color(0xFF78634D))),
        const SizedBox(height: 8),
        if (win.isActivity) Wrap(spacing: 10, runSpacing: 5, children: [
          for (final reward in [('xp', '+${win.xp} XP'), ('coin', '+${win.coins} coins')])
            Row(mainAxisSize: MainAxisSize.min, children: [
              QuestwellCurrencyPixelIcon(kind: reward.$1, size: 14),
              const SizedBox(width: 4), Text(reward.$2, style: _text(12, bold: true)),
            ]),
        ]) else Text(preview ? 'A preview copy for your Hearth.' : isReward
          ? 'Level ${win.level} trophy unlocked. Yours to keep.'
          : 'Another step in your journey.', style: _text(13)),
      ])),
    ]);
    if (embedded) return Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: content);
    return QuestwellParchmentPanel(padding: const EdgeInsets.all(14),
      selected: win.kind != 'quest', child: content);
  }
}
