import '../services/questwell_progression.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'questwell_pixel_art.dart';
import 'questwell_typography.dart';
import 'questwell_wordmark_sparkles.dart';
import 'questwell_class_emblem.dart';

const _gold = Color(0xFFE4C586);
const _ink = Color(0xFFF0E5CC);
const _muted = Color(0xFFB9C7D7);
TextStyle _body(double size, {Color color = _ink, bool bold = false}) =>
    GoogleFonts.roboto(fontSize: size, height: 1.35, color: color,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400);

class QuestwellHomeHeader extends StatelessWidget {
  const QuestwellHomeHeader({super.key, required this.onOpen});
  final ValueChanged<String> onOpen;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(mainAxisSize: MainAxisSize.min, children: [
        Flexible(child: QuestwellBrandWordmark(showSubtitle: false)),
        SizedBox(width: 3),
        QuestwellWordmarkSparkles(),
      ]),
      const SizedBox(height: 4),
      Wrap(spacing: 8, runSpacing: 4, children: [
        for (final entry in const {'quest': 'Quests', 'chronicle': 'Chronicle',
          'adventurer': 'Adventurer'}.entries)
          TextButton.icon(onPressed: () => onOpen(entry.key),
            icon: QuestwellNavPixelIcon(kind: entry.key, size: 18),
            label: Text(entry.value), style: TextButton.styleFrom(
              foregroundColor: _ink, minimumSize: const Size(48, 48),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              textStyle: _body(14, bold: true))),
      ]),
    ],
  );
}

class HomeCollectionItem {
  const HomeCollectionItem({required this.name, required this.slug,
    required this.category, this.archetype, required this.owned, required this.equipped});
  final String name, slug, category;
  final String? archetype;
  final bool owned, equipped;
}

class QuestwellHomeCharacter extends StatelessWidget {
  const QuestwellHomeCharacter({super.key, required this.archetype,
    required this.className, required this.level, required this.xp,
    required this.coins, required this.mastered, required this.equippedNames, this.decorNames = const [],
    required this.collection, required this.onCustomize, required this.onMarket, this.nextReward});
  final String archetype, className;
  final int level, xp, coins;
  int get xpRequired => QuestwellProgression.xpToNextLevel(level);
  final bool mastered;
  final List<String> equippedNames, decorNames;
  final List<HomeCollectionItem> collection;
  final VoidCallback onCustomize, onMarket;
  final Widget? nextReward;

  @override
  Widget build(BuildContext context) => _HomePanel(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        QuestwellClassEmblem(archetype: archetype, size: 42),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(className, style: QuestwellTypography.sectionHeading(size: 13)),
          Text('Level $level${mastered ? ' · Mastered' : ''}', style: _body(14, color: _muted)),
        ])),
      ]),
      const SizedBox(height: 14),
      Wrap(spacing: 16, runSpacing: 6, children: [
        Text('$xp / $xpRequired XP', style: _body(14, bold: true)),
        Row(mainAxisSize: MainAxisSize.min, children: [
          const QuestwellCurrencyPixelIcon(kind: 'coin', size: 16),
          const SizedBox(width: 6), Text('$coins coins', style: _body(14, color: _gold, bold: true)),
        ]),
      ]),
      const SizedBox(height: 8),
      Semantics(label: 'Level progress', value: '$xp out of $xpRequired XP',
        child: QuestwellPixelMeter(value: xp / xpRequired, kind: 'xp', height: 16, segments: 12)),
      const SizedBox(height: 6),
      Text('${(xpRequired - xp).clamp(0, xpRequired)} XP to level ${level + 1}', style: _body(12, color: _muted)),
      if (nextReward != null) nextReward!,
      const SizedBox(height: 12),
      Text('${equippedNames.length} worn · ${decorNames.length} room item${decorNames.length == 1 ? '' : 's'}',
        style: _body(13, color: _muted)),
      const SizedBox(height: 10),
      SizedBox(width: double.infinity, child: OutlinedButton(
        onPressed: onCustomize, style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48), foregroundColor: _ink,
          side: const BorderSide(color: Color(0xFF766342)),
          textStyle: _body(15, bold: true),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
        child: const Text('Customize adventurer'))),
    ],
  ));
}

class QuestwellHomeMomentum extends StatelessWidget {
  const QuestwellHomeMomentum({super.key, required this.wins, required this.bosses, required this.onOpen});
  final int wins, bosses;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) => _HomePanel(child: Row(children: [
    QuestwellStatusPixelBadge(kind: 'momentum', size: 30, active: wins > 0),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(wins > 0 ? '$wins win${wins == 1 ? '' : 's'} this week' : 'A fresh start', style: QuestwellTypography.sectionHeading(size: 11, color: _ink)),
      Text(bosses > 0 ? '$bosses boss${bosses == 1 ? '' : 'es'} defeated'
        : wins > 0 ? 'Your small steps are adding up.' : 'One small step is enough.',
        style: _body(13, color: _muted)),
    ])),
    IconButton(tooltip: 'Open Chronicle', onPressed: onOpen,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      icon: const QuestwellNavPixelIcon(kind: 'chronicle', size: 22)),
  ]));
}

class QuestwellHomeCampfireControl extends StatelessWidget {
  const QuestwellHomeCampfireControl({super.key, required this.active, required this.onChanged});
  final bool active;
  final ValueChanged<bool>? onChanged;
  @override
  Widget build(BuildContext context) => _HomePanel(warm: active, child: Row(children: [
    const QuestwellNavPixelIcon(kind: 'expedition', size: 22),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Campfire Mode', style: QuestwellTypography.sectionHeading(size: 10, color: _ink)),
      Text(active ? 'One gentle quest. A little warmth.' : 'Lower the pace. Focus on one quest.',
        style: _body(13, color: _muted)),
    ])),
    const SizedBox(width: 6),
    Semantics(label: 'Campfire Mode', child: Switch(value: active, onChanged: onChanged,
      activeThumbColor: const Color(0xFFFFCC7A), activeTrackColor: const Color(0xFF936033))),
  ]));
}

class _HomePanel extends StatelessWidget {
  const _HomePanel({required this.child, this.warm = false});
  final Widget child;
  final bool warm;
  @override
  Widget build(BuildContext context) => Material(
    color: warm ? const Color(0xFF2B211D) : const Color(0xFF19232D),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3),
      side: BorderSide(color: warm ? const Color(0xFF94603D) : const Color(0xFF65563D))),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: const EdgeInsets.all(16), child: child));
}
