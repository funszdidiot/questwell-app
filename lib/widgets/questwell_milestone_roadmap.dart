import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/questwell_cosmetic_service.dart';
import '../services/questwell_progression.dart';
import 'questwell_pixel_art.dart';
import 'questwell_typography.dart';

class QuestwellMilestoneRoadmap extends StatelessWidget {
  const QuestwellMilestoneRoadmap({super.key, required this.profile,
    required this.cosmetics, required this.onOpenCollection});
  final QuestwellProfile profile;
  final List<QuestwellCosmetic> cosmetics;
  final VoidCallback onOpenCollection;
  static const _gold = Color(0xFFE4C586), _muted = Color(0xFFB9C7D7);
  TextStyle _text(double size, {Color color = const Color(0xFFF0E5CC), bool bold = false}) =>
    GoogleFonts.roboto(fontSize: size, color: color, height: 1.4,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400);

  static int xpRemaining(QuestwellProfile profile, int level) =>
    (QuestwellProgression.totalAtLevel(level) - profile.totalXp - profile.levelXpOffset)
      .clamp(0, QuestwellProgression.totalAtLevel(level)).toInt();

  @override
  Widget build(BuildContext context) {
    final milestones = cosmetics.where((c) => c.unlockMethod == 'level_milestone' && c.milestoneLevel != null).toList()
      ..sort((a,b) => a.milestoneLevel!.compareTo(b.milestoneLevel!));
    if (milestones.isEmpty) return const SizedBox.shrink();
    final next = milestones.where((c) => c.milestoneLevel! > profile.level).firstOrNull;
    final collected = milestones.where((c) => c.owned).toList();
    final earned = collected.where((c) => profile.level >= c.milestoneLevel!).length;
    return Material(color: const Color(0xFF19232D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3),
        side: const BorderSide(color: Color(0xFF65563D))),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('YOUR JOURNEY', style: QuestwellTypography.sectionHeading(size: 10)),
          const SizedBox(height: 14),
          if (next != null) ...[
            Text('NEXT MILESTONE · LEVEL ${next.milestoneLevel}', style: _text(12, color: _gold, bold: true)),
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              QuestwellItemPixelArt(slug: next.slug, category: next.category, size: 76),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(next.name, style: _text(18, bold: true)),
                const SizedBox(height: 4),
                Text(next.owned ? 'Already in your collection' : 'A free trophy for your Hearth', style: _text(13, color: _muted)),
              ])),
            ]),
            const SizedBox(height: 10),
            Semantics(label: 'Milestone progress',
              value: '${xpRemaining(profile, next.milestoneLevel!)} XP to level ${next.milestoneLevel}',
              child: QuestwellPixelMeter(value: (1 - xpRemaining(profile, next.milestoneLevel!) /
                QuestwellProgression.totalAtLevel(next.milestoneLevel!)).clamp(0.0, 1.0).toDouble(), kind: 'xp', height: 12, segments: 12)),
            const SizedBox(height: 6),
            Text('${xpRemaining(profile, next.milestoneLevel!)} XP to level ${next.milestoneLevel}', style: _text(13, color: _muted)),
          ] else ...[
            Text('You’ve reached every released milestone.', style: _text(16, bold: true)),
            const SizedBox(height: 4),
            Text('More rewards will appear here as your journey grows.', style: _text(13, color: _muted)),
          ],
          const SizedBox(height: 14),
          Theme(data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(tilePadding: EdgeInsets.zero, childrenPadding: EdgeInsets.zero,
              iconColor: _gold, collapsedIconColor: _gold,
              title: Text('Trophy collection · ${collected.length}', style: _text(15, color: _gold, bold: true)),
              subtitle: Text('$earned earned through milestones', style: _text(12, color: _muted)),
              children: [
                if (collected.isEmpty) Align(alignment: Alignment.centerLeft,
                  child: Padding(padding: const EdgeInsets.only(bottom: 12),
                    child: Text('Your first trophy is ahead. Every quest brings it closer.', style: _text(13, color: _muted)))),
                for (final item in collected) Padding(padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    QuestwellItemPixelArt(slug: item.slug, category: item.category, size: 54),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.name, style: _text(15, bold: true)),
                      Text(profile.level >= item.milestoneLevel! ? 'Level ${item.milestoneLevel} reward' : 'Preview copy', style: _text(12, color: _muted)),
                      if (item.unlockedAt != null) Text('${item.source == 'level_milestone' ? 'Earned' : 'Added'} ${DateFormat('MMM d, yyyy').format(item.unlockedAt!.toLocal())}', style: _text(12, color: _muted)),
                      Text(item.equipped ? 'Displayed in your Hearth' : 'In your inventory', style: _text(12, color: _gold)),
                    ])),
                  ])),
                if (collected.isNotEmpty) Align(alignment: Alignment.centerLeft,
                  child: TextButton(onPressed: onOpenCollection, child: const Text('Manage in Adventurer'))),
              ])),
        ])));
  }
}
