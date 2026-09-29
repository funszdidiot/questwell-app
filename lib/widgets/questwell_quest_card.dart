import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'questwell_pixel_art.dart';

/// Shared by the signed-in board and the account-free visual review.
class QuestwellQuestCard extends StatelessWidget {
  const QuestwellQuestCard({super.key, required this.title, required this.effort,
    required this.xp, required this.coins, required this.favorite,
    required this.onFavorite, required this.onComplete, this.busy = false});
  final String title, effort;
  final int xp, coins;
  final bool favorite, busy;
  final VoidCallback onFavorite;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) => QuestwellRetroPanel(
    padding: const EdgeInsets.all(16),
    accent: favorite ? const Color(0xFFD6A84B) : const Color(0xFF66718A),
    background: const Color(0xFF172335),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(favorite ? 'PINNED QUEST' : 'QUEST', style: GoogleFonts.pressStart2p(
            fontSize: 8, height: 1.6, color: const Color(0xFFE0BE77))),
          const SizedBox(height: 10),
          Text(title.trim().isEmpty ? 'Untitled quest' : title,
            style: GoogleFonts.roboto(fontSize: 19, height: 1.3,
              fontWeight: FontWeight.w800, color: const Color(0xFFF7EAD1))),
        ])),
        IconButton(onPressed: onFavorite,
          tooltip: favorite ? 'Unpin quest' : 'Pin quest',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          icon: Icon(favorite ? Icons.star_rounded : Icons.star_border_rounded,
            color: favorite ? const Color(0xFFF1C75B) : const Color(0xFFBAC7D8))),
      ]),
      const SizedBox(height: 14),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _QuestTag(effort, const Color(0xFFD0DBE7)),
        _QuestTag('+$xp XP', const Color(0xFFC8B1FF)),
        _QuestTag('+$coins coins', const Color(0xFFF1CF81)),
      ]),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, child: FilledButton.icon(
        onPressed: busy ? null : onComplete,
        icon: busy ? const SizedBox(width: 18, height: 18,
          child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check_rounded, size: 20),
        label: Text(busy ? 'Completing…' : 'Complete quest'),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          backgroundColor: const Color(0xFF326F69), foregroundColor: Colors.white,
          textStyle: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w700),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
      )),
    ]),
  );
}

class _QuestTag extends StatelessWidget {
  const _QuestTag(this.text, this.color);
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(color: const Color(0xFF101A29),
      border: Border.all(color: color.withValues(alpha: .25))),
    child: Text(text, style: GoogleFonts.roboto(color: color, fontSize: 12,
      fontWeight: FontWeight.w700)),
  );
}

class QuestwellBoardHeading extends StatelessWidget {
  const QuestwellBoardHeading({super.key, this.completed = 0});
  final int completed;
  @override
  Widget build(BuildContext context) => QuestwellRetroPanel(
    accent: const Color(0xFFD6A84B), background: const Color(0xFF211E29),
    padding: const EdgeInsets.all(18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('QUEST BOARD', style: GoogleFonts.pressStart2p(fontSize: 15,
        height: 1.6, color: const Color(0xFFF2D9A0))),
      const SizedBox(height: 10),
      Text('One small win at a time.', style: GoogleFonts.roboto(
        fontSize: 17, color: const Color(0xFFE0E7EE))),
      const SizedBox(height: 10),
      Text(completed == 0 ? 'Pick a quest that fits your energy.'
        : '$completed ${completed == 1 ? 'quest' : 'quests'} finished this visit. Keep your momentum.',
        style: GoogleFonts.roboto(fontSize: 13, height: 1.4,
          color: const Color(0xFFB7C4D4))),
    ]),
  );
}
