import 'questwell_destination_entrance.dart';
import 'questwell_hearth_icon.dart';
import 'questwell_hearth_material.dart';
import 'questwell_app_style.dart';
import 'package:flutter/material.dart';
import '../models/questwell_boss.dart';
import 'questwell_boss_encounter.dart';
import 'questwell_typography.dart';

const questwellBossNames = {
  'inbox_hydra': 'Inbox Hydra',
  'meeting_mimic': 'Meeting Mimic',
  'spreadsheet_slime': 'Spreadsheet Slime',
  'calendar_kraken': 'Calendar Kraken',
  'printer_poltergeist': 'Printer Poltergeist',
  'notification_swarm': 'Notification Swarm',
  'ticket_troll': 'Ticket Troll',
  'update_dragon': 'Update Dragon',
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
  const QuestwellBossBoard(
      {super.key,
      required this.battles,
      required this.onHome,
      required this.onCreate,
      required this.onAttack,
      this.onRefresh,
      this.onRetry,
      this.loading = false,
      this.failed = false,
      this.busyStepId,
      this.campfire = false,
      this.archetype = 'wanderer',
      this.body = 'neutral',
      this.equipment = const {},
      this.practice = false,
      this.initialBattleId,
      this.footer,
      this.unlockProgress});
  final List<QuestwellBossBattle> battles;
  final VoidCallback onHome, onCreate;
  final void Function(QuestwellBossBattle, QuestwellBossStep) onAttack;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onRetry;
  final bool loading, failed, campfire, practice;
  final String? busyStepId, initialBattleId;
  final String archetype, body;
  final Map<String, String> equipment;
  final Widget? footer, unlockProgress;
  @override
  State<QuestwellBossBoard> createState() => _QuestwellBossBoardState();
}

class _QuestwellBossBoardState extends State<QuestwellBossBoard> {
  String? _selected;
  final _scroll = ScrollController();
  final _encounterAnchor = GlobalKey();
  bool _revealingAttack = false;
  @override
  void initState() {
    super.initState();
    _selected = widget.initialBattleId;
  }

  @override
  void didUpdateWidget(covariant QuestwellBossBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A creation result can arrive before the refreshed battle list.
    // Keep that requested ID until its battle arrives.
    final requested = widget.initialBattleId;
    final requestedArrived = requested != null &&
        _selected == requested &&
        !oldWidget.battles.any((battle) => battle.id == requested) &&
        widget.battles.any((battle) => battle.id == requested);
    if (requested != null &&
        (requested != oldWidget.initialBattleId || requestedArrived)) {
      _selected = requested;
      _revealSelected(requested);
    }
  }

  void _revealSelected(String id) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _showEncounter(id);
    });
  }

  Future<bool> _showEncounter(String id) async {
    if (!mounted || _selected != id || !_scroll.hasClients) return false;
    // A tall arrival at enlarged text can keep the encounter outside the lazy
    // list's cache. Walk toward it until its real anchor has been laid out.
    _scroll.jumpTo(0);
    await WidgetsBinding.instance.endOfFrame;
    while (mounted &&
        _selected == id &&
        _scroll.hasClients &&
        _encounterAnchor.currentContext == null) {
      final position = _scroll.position;
      final next = (position.pixels + position.viewportDimension)
          .clamp(0.0, position.maxScrollExtent)
          .toDouble();
      if (next <= position.pixels) return false;
      _scroll.jumpTo(next);
      await WidgetsBinding.instance.endOfFrame;
    }
    if (!mounted || _selected != id) return false;
    final anchor = _encounterAnchor.currentContext;
    if (anchor == null) return false;
    await Scrollable.ensureVisible(anchor,
        alignment: 0,
        duration: Duration(
            milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 300),
        curve: Curves.easeOut);
    await WidgetsBinding.instance.endOfFrame;
    return mounted && _selected == id;
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _select(String id) {
    setState(() => _selected = id);
    _revealSelected(id);
  }

  Future<void> _attackAfterReveal(
      QuestwellBossBattle battle, QuestwellBossStep step) async {
    if (_revealingAttack ||
        widget.loading ||
        widget.failed ||
        widget.busyStepId != null) return;
    setState(() {
      _revealingAttack = true;
      _selected = battle.id;
    });
    try {
      if (!await _showEncounter(battle.id)) {
        if (!mounted || _selected != battle.id) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Bring the battle into view, then try your attack again.')));
        return;
      }
      if (!mounted ||
          _selected != battle.id ||
          widget.loading ||
          widget.failed ||
          widget.busyStepId != null) return;
      // Re-check the current snapshot after asynchronous scrolling.
      for (final current in widget.battles) {
        if (current.id != battle.id || current.completed) continue;
        for (final currentStep in current.steps) {
          if (currentStep.id == step.id && !currentStep.completed) {
            widget.onAttack(current, currentStep);
            return;
          }
        }
      }
    } finally {
      if (mounted) setState(() => _revealingAttack = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final open = widget.battles.where((b) => !b.completed).toList();
    final won = widget.battles.where((b) => b.completed).toList()
      ..sort((a, b) {
        // Creation order is not victory order: older battles can finish later.
        final aTime = a.completedAt ?? a.createdAt;
        final bTime = b.completedAt ?? b.createdAt;
        if (aTime == null) return bTime == null ? a.id.compareTo(b.id) : 1;
        if (bTime == null) return -1;
        final order = bTime.compareTo(aTime);
        return order == 0 ? a.id.compareTo(b.id) : order;
      });
    QuestwellBossBattle? featured;
    for (final b in widget.battles) {
      if (b.id == _selected) featured = b;
    }
    featured ??= open.isNotEmpty
        ? open.first
        : won.isNotEmpty
            ? won.first
            : null;
    final battle = featured;
    final remaining = battle?.steps.where((s) => !s.completed).toList() ??
        <QuestwellBossStep>[];
    final completedSteps = battle?.steps.where((s) => s.completed).toList() ??
        <QuestwellBossStep>[];
    final content = ListView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          QuestwellDestinationEntrance(
              destination: 'bosses',
              title: 'BOSS BATTLES',
              subtitle: 'Big challenges. One brave step at a time.',
              onHome: widget.onHome),
          Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 4,
              children: [
                Text('${open.length} active · ${won.length} defeated',
                    style:
                        QuestwellTypography.body(fontSize: 12, color: _muted)),
                TextButton.icon(
                    onPressed: widget.onCreate,
                    icon: const Icon(Icons.add, size: 18),
                    style: TextButton.styleFrom(
                        foregroundColor: _gold,
                        minimumSize: const Size(48, 48),
                        textStyle: QuestwellTypography.control()),
                    label: const Text('Start a battle')),
              ]),
          const SizedBox(height: 8),
          if (widget.unlockProgress != null) ...[
            widget.unlockProgress!,
            const SizedBox(height: 12),
          ],
          if (widget.practice) ...[
            Text('PRACTICE PREVIEW · sample battles and rewards',
                style: QuestwellTypography.body(fontSize: 12, color: _muted)),
            const SizedBox(height: 8),
          ],
          if (widget.loading && battle == null)
            const Padding(
                padding: EdgeInsets.all(36),
                child: Center(child: CircularProgressIndicator(color: _gold)))
          else if (widget.failed)
            _panel(Column(children: [
              const Icon(Icons.cloud_off_outlined, color: _gold, size: 32),
              const SizedBox(height: 12),
              Text('Your battles could not be loaded.',
                  style: QuestwellTypography.control(color: _gold)),
              const SizedBox(height: 6),
              Text('Check your connection and try again.',
                  style: QuestwellTypography.body(color: _muted)),
              TextButton(
                  onPressed: widget.onRetry,
                  style: TextButton.styleFrom(
                      textStyle: QuestwellTypography.control()),
                  child: const Text('Try again')),
            ]))
          else if (battle == null)
            _panel(Column(children: [
              const QuestwellHearthIcon(kind: 'boss', size: 48),
              const SizedBox(height: 16),
              Text('A clear field. A fresh start.',
                  style: QuestwellTypography.body(
                      fontSize: 20, color: _gold, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                  'Choose one intimidating task and give it a small attack plan.',
                  textAlign: TextAlign.center,
                  style: QuestwellTypography.body(color: _muted)),
            ]))
          else ...[
            if (widget.loading)
              Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('Updating battle…',
                      style: QuestwellTypography.body(color: _muted))),
            Text(battle.title,
                style: QuestwellTypography.body(
                    fontSize: 21,
                    height: 1.2,
                    color: const Color(0xFFF2E8CE),
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(_strategies[battle.bossType] ?? 'One useful step at a time.',
                style: QuestwellTypography.body(color: _muted)),
            const SizedBox(height: 12),
            SizedBox(
                key: _encounterAnchor,
                child: QuestwellBossEncounter(
                    key: ValueKey('encounter-${battle.id}'),
                    encounterId: battle.id,
                    bossType: battle.bossType,
                    progress: battle.progress,
                    defeated: battle.completed,
                    persistEntrance: !widget.practice,
                    archetype: widget.archetype,
                    body: widget.body,
                    equipment: widget.equipment)),
            const SizedBox(height: 16),
            if (battle.completed) ...[
              QuestwellBossVictoryPanel(
                  bossName: questwellBossNames[battle.bossType] ?? 'Boss',
                  xp: battle.rewardXp,
                  coins: battle.rewardCoins,
                  practice: widget.practice),
              const SizedBox(height: 8),
              OutlinedButton(
                  onPressed: open.isEmpty
                      ? widget.onCreate
                      : () => _select(open.first.id),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: _gold,
                      minimumSize: const Size.fromHeight(48),
                      textStyle: QuestwellTypography.control()),
                  child: Text(open.isEmpty
                      ? 'Start a new battle'
                      : 'Choose next battle')),
            ] else
              Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('ON VICTORY',
                        style: QuestwellTypography.sectionHeading(size: 10)),
                    Text('+${battle.rewardXp} XP',
                        style: QuestwellTypography.control(color: _gold)),
                    Text('+${battle.rewardCoins} coins',
                        style: QuestwellTypography.control(color: _gold)),
                  ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: Text('ATTACK PLAN',
                      style: QuestwellTypography.sectionHeading(size: 11))),
              Text('${battle.completedSteps}/${battle.totalSteps} done',
                  style: QuestwellTypography.body(color: _muted)),
            ]),
            if (widget.campfire && !battle.completed)
              Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Campfire mode · just your next attack.',
                      style: QuestwellTypography.body(color: _muted))),
            const SizedBox(height: 12),
            if (remaining.isNotEmpty && !battle.completed)
              _attack(battle, remaining.first, true),
            if (!widget.campfire && remaining.length > 1 && !battle.completed)
              _stepGroup(battle, remaining.skip(1).toList(), 'Later attacks',
                  'later-attacks'),
            if (!widget.campfire && completedSteps.isNotEmpty)
              _stepGroup(battle, completedSteps, 'Completed attacks',
                  'completed-attacks'),
            if (remaining.isEmpty && !battle.completed)
              Text('This battle has no remaining attacks.',
                  style: QuestwellTypography.body(color: _muted)),
            const SizedBox(height: 20),
            if (!widget.campfire && open.any((b) => b.id != battle.id)) ...[
              Text('BATTLE QUEUE',
                  style: QuestwellTypography.sectionHeading(size: 11)),
              const SizedBox(height: 6),
              Text('Choose the challenge you want to focus on.',
                  style: QuestwellTypography.body(color: _muted)),
              const SizedBox(height: 12),
              for (final other in open.where((b) => b.id != battle.id))
                _compact(other),
            ],
            if (won.any((b) => b.id != battle.id))
              ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  iconColor: _gold,
                  collapsedIconColor: _gold,
                  title: Text(
                      'DEFEATED · ${won.where((b) => b.id != battle.id).length}',
                      style: QuestwellTypography.sectionHeading(size: 10)),
                  children: [
                    for (final other in won.where((b) => b.id != battle.id))
                      _compact(other)
                  ]),
          ],
          if (widget.footer != null) ...[
            const SizedBox(height: 22),
            widget.footer!
          ],
        ]);
    return Center(
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: widget.onRefresh == null
                ? content
                : RefreshIndicator(
                    onRefresh: widget.onRefresh!, child: content)));
  }

  Widget _attack(
      QuestwellBossBattle battle, QuestwellBossStep step, bool next) {
    final busy = widget.busyStepId == step.id;
    final foreground = next ? const Color(0xFF30261D) : const Color(0xFFE4E6D8);
    final action = step.completed
        ? null
        : Semantics(
            label: 'Complete attack: ${step.title}',
            child: FilledButton(
                onPressed: _revealingAttack ||
                        widget.loading ||
                        widget.failed ||
                        widget.busyStepId != null ||
                        battle.completed
                    ? null
                    : () => _attackAfterReveal(battle, step),
                style: QuestwellAppStyle.primaryButton(),
                child: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Attack')));
    return QuestwellHearthFrame(
        key: ValueKey('attack-${step.id}'),
        parchment: next,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Icon(
                step.completed
                    ? Icons.check_circle_outline
                    : Icons.radio_button_unchecked,
                color: next ? const Color(0xFF786342) : const Color(0xFF95B79F),
                size: 22),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  if (next)
                    Text('NEXT ATTACK',
                        style: QuestwellTypography.body(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF70582E))),
                  Text(step.title,
                      style: QuestwellTypography.body(
                          fontSize: next ? 16 : 14,
                          color: step.completed ? _muted : foreground,
                          fontWeight: FontWeight.w600)),
                ])),
          ]),
          if (action != null) ...[const SizedBox(height: 12), action],
        ]));
  }

  Widget _stepGroup(QuestwellBossBattle battle, List<QuestwellBossStep> steps,
          String title, String group) =>
      ExpansionTile(
          key: ValueKey('$group-${battle.id}'),
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 4),
          iconColor: _muted,
          collapsedIconColor: _muted,
          shape: const Border(),
          collapsedShape: const Border(),
          title: Text('$title · ${steps.length}',
              style: QuestwellTypography.body(fontSize: 14, color: _muted)),
          children: [
            for (final step in steps)
              Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _attack(battle, step, false))
          ]);
  Widget _compact(QuestwellBossBattle b) {
    final type =
        questwellBossNames.containsKey(b.bossType) ? b.bossType : 'inbox_hydra';
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
            color: const Color(0xFF1A2730),
            child: InkWell(
                key: ValueKey('select-${b.id}'),
                onTap: () => _select(b.id),
                child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF53615B))),
                    child: Row(children: [
                      Image.asset(
                          'assets/images/questwell_${type}_v${_bossVersions[type] ?? 1}.webp',
                          width: 64,
                          height: 64,
                          fit: BoxFit.contain,
                          excludeFromSemantics: true),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(questwellBossNames[type]!,
                                style: QuestwellTypography.body(
                                    fontSize: 12, color: _gold)),
                            Text(b.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: QuestwellTypography.control(
                                    color: const Color(0xFFF1E5C6))),
                            const SizedBox(height: 5),
                            Text(
                                b.completed
                                    ? 'Defeated'
                                    : '${b.completedSteps}/${b.totalSteps} attacks complete',
                                style: QuestwellTypography.body(
                                    fontSize: 12, color: _muted)),
                          ])),
                      const Icon(Icons.chevron_right, color: _gold),
                    ])))));
  }

  Widget _panel(Widget child) => QuestwellHearthFrame(child: child);
}

class QuestwellBossVictoryPanel extends StatelessWidget {
  const QuestwellBossVictoryPanel(
      {super.key,
      required this.bossName,
      required this.xp,
      required this.coins,
      this.practice = false});
  final String bossName;
  final int xp, coins;
  final bool practice;
  @override
  Widget build(BuildContext context) => QuestwellHearthFrame(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.workspace_premium_outlined, size: 36, color: _gold),
        const SizedBox(height: 10),
        Text('BOSS DEFEATED',
            textAlign: TextAlign.center,
            style: QuestwellTypography.sectionHeading(size: 12)),
        const SizedBox(height: 8),
        Text('$bossName is down. A little more room to breathe.',
            textAlign: TextAlign.center,
            style: QuestwellTypography.body(color: const Color(0xFFE4E6D8))),
        const SizedBox(height: 16),
        Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 8,
            children: [
              Text('+$xp XP',
                  style: QuestwellTypography.body(
                      fontSize: 21, fontWeight: FontWeight.w700, color: _gold)),
              Text('+$coins coins',
                  style: QuestwellTypography.body(
                      fontSize: 21, fontWeight: FontWeight.w700, color: _gold)),
            ]),
        if (practice)
          Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('Sample rewards · your account is unchanged.',
                  textAlign: TextAlign.center,
                  style:
                      QuestwellTypography.body(fontSize: 12, color: _muted))),
      ]));
}
