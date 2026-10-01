import 'package:flutter/material.dart';
import '../models/questwell_boss.dart';
import 'questwell_boss_encounter.dart';
import 'questwell_pixel_art.dart';
import 'questwell_typography.dart';

const questwellBossNames = {
  'inbox_hydra': 'Inbox Hydra', 'meeting_mimic': 'Meeting Mimic',
  'spreadsheet_slime': 'Spreadsheet Slime', 'calendar_kraken': 'Calendar Kraken',
  'printer_poltergeist': 'Printer Poltergeist', 'notification_swarm': 'Notification Swarm',
  'ticket_troll': 'Ticket Troll', 'update_dragon': 'Update Dragon',
};
const _bossVersions = {'notification_swarm': 2, 'ticket_troll': 2};
const _strategies = {
  'inbox_hydra': 'One reply, one thread, one head at a time.',
  'meeting_mimic': 'Name the decision. Keep the next step small.',
  'spreadsheet_slime': 'Clean up one tab or formula at a time.',
  'calendar_kraken': 'Protect your next useful hour.',
  'printer_poltergeist': 'One check. One page. Peace restored.',
  'notification_swarm': 'Quiet the noise. Choose what matters.',
  'ticket_troll': 'Define done, then close one useful request.',
  'update_dragon': 'Small checkpoints. One safe upgrade.',
};
const _gold = Color(0xFFE4C586);
const _muted = Color(0xFFB7C4C9);

/// Shared page presentation. All data mutations belong to the supplied callbacks.
class QuestwellBossBoard extends StatefulWidget {
  const QuestwellBossBoard({super.key, required this.battles, required this.onHome,
    required this.onCreate, required this.onAttack, this.onRefresh, this.onRetry,
    this.loading = false, this.failed = false, this.busyStepId, this.campfire = false,
    this.archetype = 'wanderer', this.body = 'neutral', this.equipment = const {},
    this.practice = false, this.initialBattleId, this.footer});
  final List<QuestwellBossBattle> battles;
  final VoidCallback onHome, onCreate;
  final void Function(QuestwellBossBattle, QuestwellBossStep) onAttack;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onRetry;
  final bool loading, failed, campfire, practice;
  final String? busyStepId, initialBattleId;
  final String archetype, body;
  final Map<String, String> equipment;
  final Widget? footer;
  @override
  State<QuestwellBossBoard> createState() => _QuestwellBossBoardState();
}
class _QuestwellBossBoardState extends State<QuestwellBossBoard> {
  String? _selected;
  final _scroll = ScrollController();
  @override
  void initState() { super.initState(); _selected = widget.initialBattleId; }
  @override
  void dispose() { _scroll.dispose(); super.dispose(); }
  void _select(String id) {
    setState(() => _selected = id);
    if (_scroll.hasClients) {
      if (MediaQuery.disableAnimationsOf(context)) { _scroll.jumpTo(0); }
      else { _scroll.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut); }
    }
  }
  @override
  Widget build(BuildContext context) {
    final open = widget.battles.where((b) => !b.completed).toList();
    final won = widget.battles.where((b) => b.completed).toList();
    QuestwellBossBattle? featured;
    for (final b in widget.battles) { if (b.id == _selected) featured = b; }
    featured ??= open.isNotEmpty ? open.first : won.isNotEmpty ? won.first : null;
    _selected ??= featured?.id;
    final battle = featured;
    final remaining = battle?.steps.where((s) => !s.completed).toList() ?? <QuestwellBossStep>[];
    final shownSteps = battle == null ? <QuestwellBossStep>[] : widget.campfire && !battle.completed
      ? remaining.take(1).toList() : battle.steps;
    final content = ListView(controller: _scroll, physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 32), children: [
        Row(children: [
          IconButton(onPressed: widget.onHome, tooltip: 'Back to the Hearth',
            icon: const Icon(Icons.arrow_back_rounded, color: _gold)),
          const SizedBox(width: 6),
          Expanded(child: Text('BOSS BATTLES', style: QuestwellTypography.sectionHeading(size: 14))),
          const QuestwellNavPixelIcon(kind: 'boss', size: 28),
        ]),
        Row(children: [
          Expanded(child: Text('${open.length} active · ${won.length} defeated',
            style: QuestwellTypography.body(fontSize: 12, color: _muted))),
          TextButton.icon(onPressed: widget.onCreate, icon: const Icon(Icons.add, size: 18),
            style: TextButton.styleFrom(foregroundColor: _gold, minimumSize: const Size(48, 48)),
            label: const Text('Start a battle')),
        ]),
        const SizedBox(height: 8),
        if (widget.practice) ...[
          Text('PRACTICE PREVIEW · sample battles and rewards', style: QuestwellTypography.body(fontSize: 12, color: _muted)),
          const SizedBox(height: 8),
        ],
        if (widget.loading) const Padding(padding: EdgeInsets.all(36), child: Center(child: CircularProgressIndicator(color: _gold)))
        else if (widget.failed) _panel(Column(children: [
          const Icon(Icons.cloud_off_outlined, color: _gold, size: 32),
          const SizedBox(height: 12),
          Text('Your battles could not be loaded.', style: QuestwellTypography.control(color: _gold)),
          const SizedBox(height: 6),
          Text('Check your connection and try again.', style: QuestwellTypography.body(color: _muted)),
          TextButton(onPressed: widget.onRetry, child: const Text('Try again')),
        ]))
        else if (battle == null) _panel(Column(children: [
          const QuestwellNavPixelIcon(kind: 'boss', size: 48),
          const SizedBox(height: 16),
          Text('A clear field. A fresh start.', style: QuestwellTypography.body(fontSize: 20, color: _gold, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Choose one intimidating task and give it a small attack plan.', textAlign: TextAlign.center,
            style: QuestwellTypography.body(color: _muted)),
        ]))
        else ...[
          Text(battle.title, style: QuestwellTypography.body(fontSize: 21, height: 1.2,
            color: const Color(0xFFF2E8CE), fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(_strategies[battle.bossType] ?? 'One useful step at a time.', style: QuestwellTypography.body(color: _muted)),
          const SizedBox(height: 12),
          QuestwellBossEncounter(key: ValueKey('encounter-${battle.id}'), encounterId: battle.id,
            bossType: battle.bossType, progress: battle.progress, defeated: battle.completed,
            persistEntrance: !widget.practice, archetype: widget.archetype, body: widget.body, equipment: widget.equipment),
          const SizedBox(height: 16),
          if (battle.completed) ...[
            QuestwellBossVictoryPanel(bossName: questwellBossNames[battle.bossType] ?? 'Boss',
              xp: battle.rewardXp, coins: battle.rewardCoins, practice: widget.practice),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: open.isEmpty ? widget.onCreate : () => _select(open.first.id),
              style: OutlinedButton.styleFrom(foregroundColor: _gold, minimumSize: const Size.fromHeight(48)),
              child: Text(open.isEmpty ? 'Start a new battle' : 'Choose next battle')),
          ]
          else Wrap(spacing: 16, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            Text('ON VICTORY', style: QuestwellTypography.sectionHeading(size: 9)),
            Text('+${battle.rewardXp} XP', style: QuestwellTypography.control(color: _gold)),
            Text('+${battle.rewardCoins} coins', style: QuestwellTypography.control(color: _gold)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Text('ATTACK PLAN', style: QuestwellTypography.sectionHeading(size: 11))),
            Text('${battle.completedSteps}/${battle.totalSteps} done', style: QuestwellTypography.body(color: _muted)),
          ]),
          if (widget.campfire && !battle.completed) Padding(padding: const EdgeInsets.only(top: 8),
            child: Text('Campfire mode · just your next attack.', style: QuestwellTypography.body(color: _muted))),
          const SizedBox(height: 12),
          for (final step in shownSteps) Padding(padding: const EdgeInsets.only(bottom: 10),
            child: _attack(battle, step, remaining.isNotEmpty && step.id == remaining.first.id)),
          if (shownSteps.isEmpty && !battle.completed) Text('This battle has no remaining attacks.', style: QuestwellTypography.body(color: _muted)),
          const SizedBox(height: 20),
          if (!widget.campfire && open.any((b) => b.id != battle.id)) ...[
            Text('BATTLE QUEUE', style: QuestwellTypography.sectionHeading(size: 11)),
            const SizedBox(height: 6),
            Text('Choose the challenge you want to focus on.', style: QuestwellTypography.body(color: _muted)),
            const SizedBox(height: 12),
            for (final other in open.where((b) => b.id != battle.id)) _compact(other),
          ],
          if (won.any((b) => b.id != battle.id)) ExpansionTile(tilePadding: EdgeInsets.zero,
            iconColor: _gold, collapsedIconColor: _gold,
            title: Text('DEFEATED · ${won.where((b) => b.id != battle.id).length}', style: QuestwellTypography.sectionHeading(size: 10)),
            children: [for (final other in won.where((b) => b.id != battle.id)) _compact(other)]),
        ],
        if (widget.footer != null) ...[const SizedBox(height: 22), widget.footer!],
      ]);
    return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560),
      child: widget.onRefresh == null ? content : RefreshIndicator(onRefresh: widget.onRefresh!, child: content)));
  }
  Widget _attack(QuestwellBossBattle battle, QuestwellBossStep step, bool next) {
    final busy = widget.busyStepId == step.id;
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(
      color: step.completed ? const Color(0xFF1C2C2B) : const Color(0xFFF1E5C6),
      border: Border.all(color: next ? _gold : const Color(0xFF52645B), width: next ? 2 : 1)),
      child: Row(children: [
        Icon(step.completed ? Icons.check_circle_outline : Icons.radio_button_unchecked,
          color: step.completed ? const Color(0xFF95B79F) : const Color(0xFF786342), size: 22),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (next) Text('NEXT ATTACK', style: QuestwellTypography.body(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF70582E))),
          Text(step.title, style: QuestwellTypography.body(fontSize: 14,
            color: step.completed ? _muted : const Color(0xFF30261D), fontWeight: FontWeight.w600)),
        ])),
        const SizedBox(width: 10),
        if (step.completed) Text('Done', style: QuestwellTypography.body(fontSize: 12, color: _muted))
        else Semantics(label: 'Complete attack: ${step.title}', child: FilledButton(
          onPressed: widget.busyStepId != null || battle.completed ? null : () => widget.onAttack(battle, step),
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF274B43), foregroundColor: Colors.white,
            minimumSize: const Size(68, 44), padding: const EdgeInsets.symmetric(horizontal: 10),
            shape: const RoundedRectangleBorder()),
          child: busy ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Attack'))),
      ]));
  }
  Widget _compact(QuestwellBossBattle b) {
    final type = questwellBossNames.containsKey(b.bossType) ? b.bossType : 'inbox_hydra';
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Material(color: const Color(0xFF1A2730),
      child: InkWell(key: ValueKey('select-${b.id}'), onTap: () => _select(b.id),
        child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: const Color(0xFF53615B))),
          child: Row(children: [
            Image.asset('assets/images/questwell_${type}_v${_bossVersions[type] ?? 1}.webp', width: 64, height: 64, fit: BoxFit.contain, excludeFromSemantics: true),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(questwellBossNames[type]!, style: QuestwellTypography.body(fontSize: 12, color: _gold)),
              Text(b.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: QuestwellTypography.control(color: const Color(0xFFF1E5C6))),
              const SizedBox(height: 5),
              Text(b.completed ? 'Defeated' : '${b.completedSteps}/${b.totalSteps} attacks complete', style: QuestwellTypography.body(fontSize: 12, color: _muted)),
            ])),
            const Icon(Icons.chevron_right, color: _gold),
          ])))));
  }
  Widget _panel(Widget child) => Container(padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFF1B2A2D), border: Border.all(color: const Color(0xFF786744))), child: child);
}

class QuestwellBossVictoryPanel extends StatelessWidget {
  const QuestwellBossVictoryPanel({super.key, required this.bossName, required this.xp,
    required this.coins, this.practice = false});
  final String bossName;
  final int xp, coins;
  final bool practice;
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: const Color(0xFF20342E), border: Border.all(color: _gold, width: 2)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.workspace_premium_outlined, size: 36, color: _gold),
      const SizedBox(height: 10),
      Text('BOSS DEFEATED', textAlign: TextAlign.center, style: QuestwellTypography.sectionHeading(size: 12)),
      const SizedBox(height: 8),
      Text('$bossName is down. A little more room to breathe.', textAlign: TextAlign.center,
        style: QuestwellTypography.body(color: const Color(0xFFE4E6D8))),
      const SizedBox(height: 16),
      Wrap(alignment: WrapAlignment.center, spacing: 24, runSpacing: 8, children: [
        Text('+$xp XP', style: QuestwellTypography.body(fontSize: 21, fontWeight: FontWeight.w700, color: _gold)),
        Text('+$coins coins', style: QuestwellTypography.body(fontSize: 21, fontWeight: FontWeight.w700, color: _gold)),
      ]),
      if (practice) Padding(padding: const EdgeInsets.only(top: 12), child: Text('Sample rewards · your account is unchanged.',
        textAlign: TextAlign.center, style: QuestwellTypography.body(fontSize: 12, color: _muted))),
    ]));
}
