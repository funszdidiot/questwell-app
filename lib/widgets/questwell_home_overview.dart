import '../services/questwell_progression.dart';
import 'package:flutter/material.dart';
import 'questwell_pixel_art.dart';
import 'questwell_typography.dart';
import 'questwell_wordmark_sparkles.dart';
import 'questwell_class_emblem.dart';
import 'questwell_hearth_material.dart';

const _gold = Color(0xFFE4C586);
const _ink = Color(0xFFF0E5CC);
const _muted = Color(0xFFB9C7D7);
TextStyle _body(double size, {Color color = _ink, bool bold = false}) =>
    QuestwellTypography.body(
        fontSize: size,
        color: color,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400);

class QuestwellHomeHeader extends StatelessWidget {
  const QuestwellHomeHeader({super.key});
  @override
  Widget build(BuildContext context) =>
      const Row(mainAxisSize: MainAxisSize.min, children: [
        // Fit the complete decorative logo; surrounding UI keeps its text scale.
        Flexible(
            child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: QuestwellBrandWordmark(showSubtitle: false))),
        SizedBox(width: 3),
        QuestwellWordmarkSparkles(),
      ]);
}

class HomeCollectionItem {
  const HomeCollectionItem(
      {required this.name,
      required this.slug,
      required this.category,
      this.archetype,
      required this.owned,
      required this.equipped});
  final String name, slug, category;
  final String? archetype;
  final bool owned, equipped;
}

class QuestwellHomeCharacter extends StatelessWidget {
  const QuestwellHomeCharacter(
      {super.key,
      required this.archetype,
      required this.className,
      required this.level,
      required this.xp,
      required this.coins,
      required this.mastered,
      required this.equippedNames,
      this.decorNames = const [],
      required this.collection,
      required this.onCustomize,
      required this.onMarket,
      this.nextReward,
      this.compact = false});
  final String archetype, className;
  final int level, xp, coins;
  int get xpRequired => QuestwellProgression.xpToNextLevel(level);
  final bool mastered;
  final List<String> equippedNames, decorNames;
  final List<HomeCollectionItem> collection;
  final VoidCallback onCustomize, onMarket;
  final Widget? nextReward;
  final bool compact;

  @override
  Widget build(BuildContext context) => compact
      ? _statusStrip(context)
      : QuestwellHomePanel(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              QuestwellClassEmblem(archetype: archetype, size: 42),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(className,
                        style: QuestwellTypography.sectionHeading(size: 13)),
                    Text('Level $level${mastered ? ' · Mastered' : ''}',
                        style: _body(14, color: _muted)),
                  ])),
            ]),
            const SizedBox(height: 14),
            Wrap(spacing: 16, runSpacing: 6, children: [
              Text('$xp / $xpRequired XP', style: _body(14, bold: true)),
              Row(mainAxisSize: MainAxisSize.min, children: [
                const QuestwellCurrencyPixelIcon(kind: 'coin', size: 16),
                const SizedBox(width: 6),
                Text('$coins coins',
                    style: _body(14, color: _gold, bold: true)),
              ]),
            ]),
            const SizedBox(height: 8),
            Semantics(
                label: 'Level progress',
                value: '$xp out of $xpRequired XP',
                child: QuestwellPixelMeter(
                    value: xp / xpRequired,
                    kind: 'xp',
                    height: 16,
                    segments: 12)),
            const SizedBox(height: 6),
            Text(
                '${(xpRequired - xp).clamp(0, xpRequired)} XP to level ${level + 1}',
                style: _body(12, color: _muted)),
            if (nextReward != null) nextReward!,
            const SizedBox(height: 12),
            Text(
                '${equippedNames.length} worn · ${decorNames.length} room item${decorNames.length == 1 ? '' : 's'}',
                style: _body(13, color: _muted)),
            const SizedBox(height: 10),
            SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                    onPressed: onCustomize,
                    style: QuestwellHearthMaterial.secondaryButton(),
                    child: const Text('Customize adventurer'))),
          ],
        ));
  Widget _statusStrip(BuildContext context) => Semantics(
        button: true,
        label: 'Customize adventurer',
        child: QuestwellHomePanel(
            padding: EdgeInsets.zero,
            child: InkWell(
                onTap: onCustomize,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: LayoutBuilder(builder: (context, bounds) {
                    final stacked = bounds.maxWidth < 300 ||
                        MediaQuery.textScalerOf(context).scale(14) > 20;
                    final identity = Row(children: [
                      QuestwellClassEmblem(archetype: archetype, size: 32),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(className,
                                style: QuestwellTypography.sectionHeading(
                                    size: 10)),
                            Text('Level $level${mastered ? ' · Mastered' : ''}',
                                style: _body(12, color: _muted)),
                          ])),
                    ]);
                    final coinsView =
                        Row(mainAxisSize: MainAxisSize.min, children: [
                      const QuestwellCurrencyPixelIcon(kind: 'coin', size: 20),
                      const SizedBox(width: 6),
                      Text('$coins coins', style: _body(13, color: _gold)),
                      const SizedBox(width: 3),
                      const Icon(Icons.chevron_right, size: 14, color: _muted),
                    ]);
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (stacked) ...[
                            identity,
                            const SizedBox(height: 8),
                            coinsView
                          ] else
                            Row(children: [
                              Expanded(child: identity),
                              const SizedBox(width: 12),
                              coinsView
                            ]),
                          const SizedBox(height: 7),
                          Semantics(
                              label: 'Level progress',
                              value: '$xp out of $xpRequired XP',
                              child: Row(children: [
                                Expanded(
                                    child: QuestwellPixelMeter(
                                        value: xp / xpRequired,
                                        kind: 'xp',
                                        height: 16,
                                        segments: 10)),
                                const SizedBox(width: 8),
                                Text('$xp / $xpRequired XP',
                                    style: _body(11, color: _muted))
                              ])),
                        ]);
                  }),
                ))),
      );
}

class QuestwellHomeMomentum extends StatelessWidget {
  const QuestwellHomeMomentum(
      {super.key,
      required this.wins,
      required this.bosses,
      required this.onOpen});
  final int wins, bosses;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) => QuestwellHomePanel(
          child: Row(children: [
        QuestwellStatusPixelBadge(kind: 'momentum', size: 30, active: wins > 0),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              wins > 0
                  ? '$wins win${wins == 1 ? '' : 's'} this week'
                  : 'A fresh start',
              style: QuestwellTypography.sectionHeading(size: 11, color: _ink)),
          Text(
              bosses > 0
                  ? '$bosses boss${bosses == 1 ? '' : 'es'} defeated'
                  : wins > 0
                      ? 'Your small steps are adding up.'
                      : 'One small step is enough.',
              style: _body(13, color: _muted)),
        ])),
        IconButton(
            tooltip: 'Open Chronicle',
            onPressed: onOpen,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: const QuestwellNavPixelIcon(kind: 'chronicle', size: 22)),
      ]));
}

class QuestwellHomeCampfireControl extends StatelessWidget {
  const QuestwellHomeCampfireControl(
      {super.key, required this.active, required this.onChanged});
  final bool active;
  final ValueChanged<bool>? onChanged;
  @override
  Widget build(BuildContext context) => QuestwellHomePanel(
      warm: active,
      child: Row(children: [
        const QuestwellNavPixelIcon(kind: 'campfire', size: 36),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Campfire Mode', style: QuestwellHearthMaterial.serif(17)),
          Text(
              active
                  ? 'One gentle quest. A little warmth.'
                  : 'Lower the pace. Focus on one quest.',
              style: _body(13, color: _muted)),
        ])),
        const SizedBox(width: 6),
        Semantics(
            label: 'Campfire Mode',
            child: Switch(
                value: active,
                onChanged: onChanged,
                activeThumbColor:
                    onChanged == null ? null : const Color(0xFFFFCC7A),
                activeTrackColor: onChanged == null
                    ? null
                    : QuestwellHearthMaterial.evergreen,
                inactiveThumbColor:
                    onChanged == null ? null : const Color(0xFFC4B79C),
                inactiveTrackColor:
                    onChanged == null ? null : const Color(0xFF26352F),
                trackOutlineColor: onChanged == null
                    ? null
                    : const WidgetStatePropertyAll(
                        QuestwellHearthMaterial.brass))),
      ]));
}

/// A quiet, shared material treatment around the Hearth's detailed pixel art.
class QuestwellHomePanel extends StatelessWidget {
  const QuestwellHomePanel(
      {super.key,
      required this.child,
      this.warm = false,
      this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final bool warm;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) =>
      QuestwellHearthFrame(warm: warm, padding: padding, child: child);
}
