import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/questwell_chronicle_service.dart';
import 'questwell_pixel_art.dart';

class QuestwellChronicleEntry extends StatelessWidget {
  const QuestwellChronicleEntry({super.key, required this.win});
  final ChronicleWin win;
  TextStyle _text(double size, {bool bold = false, Color color = const Color(0xFF443426)}) =>
    GoogleFonts.roboto(fontSize: size, height: 1.4, color: color,
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
    return QuestwellParchmentPanel(padding: const EdgeInsets.all(14),
      selected: win.kind != 'quest', child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (isReward && win.cosmeticSlug != null)
          QuestwellItemPixelArt(slug: win.cosmeticSlug!, category: 'room', size: 48)
        else if (win.kind == 'level_up')
          const Icon(Icons.auto_awesome, size: 38, color: Color(0xFF8E6B35))
        else QuestwellNavPixelIcon(kind: win.kind == 'boss' ? 'boss' : 'quest', size: 42),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: _text(11, bold: true, color: const Color(0xFF6E3B2C))),
          const SizedBox(height: 4),
          Text(win.title, style: _text(17, bold: true)),
          const SizedBox(height: 6),
          Text(DateFormat('MMM d, yyyy').format(win.completedAt.toLocal()), style: _text(12)),
          const SizedBox(height: 8),
          if (win.isActivity) Wrap(spacing: 12, runSpacing: 6, children: [
            for (final reward in [('xp', '+${win.xp} XP'), ('coin', '+${win.coins} coins')])
              Row(mainAxisSize: MainAxisSize.min, children: [
                QuestwellCurrencyPixelIcon(kind: reward.$1, size: 16),
                const SizedBox(width: 5), Text(reward.$2, style: _text(13, bold: true)),
              ]),
          ]) else Text(preview ? 'A preview copy for your Hearth.' : isReward
            ? 'Level ${win.level} trophy unlocked. Yours to keep.'
            : 'Another step in your journey.', style: _text(13)),
        ])),
      ]));
  }
}
