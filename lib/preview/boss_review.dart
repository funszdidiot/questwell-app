import 'package:flutter/material.dart';
import '../widgets/questwell_app_navigation.dart';
import '../models/questwell_boss.dart';
import '../widgets/questwell_boss_board.dart';
import '../widgets/questwell_boss_picker.dart';
import '../models/questwell_boss_unlocks.dart';
import '../services/questwell_progression.dart';

class BossReviewApp extends StatefulWidget {
  const BossReviewApp({super.key});
  @override
  State<BossReviewApp> createState() => _BossReviewAppState();
}
class _BossReviewAppState extends State<BossReviewApp> {
  int _replay = 0;
  int _level = 1;
  String? _createdBattleId;
  bool _motion = true, _campfire = false;
  String _state = 'battles';
  final _done = <String>{};
  final _extra = <QuestwellBossBattle>[];
  static const _titles = {
    'inbox_hydra': 'Tame the inbox backlog', 'meeting_mimic': 'Make the planning meeting count',
    'spreadsheet_slime': 'Clean up the project tracker', 'calendar_kraken': 'Make room for focused work',
    'printer_poltergeist': 'Get the paperwork moving', 'notification_swarm': 'Clear the afternoon noise',
    'ticket_troll': 'Close the oldest useful request', 'update_dragon': 'Finish the overdue upgrade',
  };
  static const _steps = {
    'inbox_hydra': ['Sort the three threads that matter', 'Send one useful reply', 'Archive what no longer needs you'],
    'meeting_mimic': ['Name the decision this meeting needs', 'Write a three-point agenda', 'Send the decision and next steps'],
    'spreadsheet_slime': ['Choose the tab that needs attention', 'Fix one formula or messy column', 'Check the totals and save your work'],
    'calendar_kraken': ['Choose one priority for today', 'Protect a block of focus time', 'Move or decline one optional commitment'],
    'printer_poltergeist': ['Check the paper tray and connection', 'Clear the stalled print queue', 'Print one test page'],
    'notification_swarm': ['Silence one distracting channel', 'Clear alerts that need no action', 'Choose one message worth answering'],
    'ticket_troll': ['Choose the oldest useful request', 'Write down what done looks like', 'Finish the next action and close the loop'],
    'update_dragon': ['Save your work and check the update', 'Install one planned update', 'Restart and confirm everything works'],
  };
  List<QuestwellBossBattle> get _battles => [
    for (final type in questwellBossNames.keys)
      if (QuestwellBossUnlocks.available(type, _level)) QuestwellBossBattle(
      id: type, title: _titles[type]!, bossType: type, rewardXp: QuestwellBossRewards.victoryXp, rewardCoins: QuestwellBossRewards.victoryCoins,
      status: List.generate(3, (i) => '$type-$i').every(_done.contains) ? 'completed' : 'open',
      steps: [for (var i = 0; i < 3; i++) QuestwellBossStep(id: '$type-$i', title: _steps[type]![i],
        position: i, completed: _done.contains('$type-$i'))]),
    for (final b in _extra) QuestwellBossBattle(id: b.id, title: b.title, bossType: b.bossType,
      rewardXp: b.rewardXp, rewardCoins: b.rewardCoins,
      status: b.steps.every((s) => _done.contains(s.id)) ? 'completed' : 'open',
      steps: [for (final s in b.steps) QuestwellBossStep(id: s.id, title: s.title, position: s.position, completed: _done.contains(s.id))]),
  ];
  Future<void> _create(BuildContext context) async {
    final title = TextEditingController();
    final steps = List.generate(3, (_) => TextEditingController());
    var type = 'inbox_hydra';
    String? error;
    await showDialog<void>(context: context, builder: (dialogContext) => StatefulBuilder(builder: (context, change) => AlertDialog(
      title: const Text('Start a practice battle'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Your challenge')),
        QuestwellBossUnlockProgress(level: _level,
          totalXp: QuestwellProgression.totalAtLevel(_level)),
        const SizedBox(height: 12),
        QuestwellBossPicker(value: type, level: _level,
          onChanged: (value) => change(() => type = value)),
        for (var i = 0; i < steps.length; i++) TextField(controller: steps[i], decoration: InputDecoration(labelText: 'Attack ${i + 1}')),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => change(() => steps.add(TextEditingController())),
          icon: const Icon(Icons.add),
          label: const Text('Add step'),
        ),
        if (error != null) Text(error!, style: const TextStyle(color: Colors.amber)),
        const SizedBox(height: 8), const Text('Practice only. Your account is unchanged.'),
      ])), actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        FilledButton(onPressed: () {
          final entries = steps.map((s) => s.text.trim()).where((s) => s.isNotEmpty).toList();
          if (title.text.trim().isEmpty || entries.length < 2) { change(() => error = 'Add a title and at least two attacks.'); return; }
          if (!QuestwellBossUnlocks.available(type, _level)) return;
          final id = 'custom-${_extra.length}';
          setState(() {
            _createdBattleId = id;
            _state = 'battles';
            _extra.add(QuestwellBossBattle(id: id, title: title.text.trim(), bossType: type,
            status: 'open', rewardXp: QuestwellBossRewards.victoryXp, rewardCoins: QuestwellBossRewards.victoryCoins, steps: [for (var i = 0; i < entries.length; i++)
              QuestwellBossStep(id: '$id-$i', title: entries[i], position: i, completed: false)]));
          });
          Navigator.pop(dialogContext);
        }, child: const Text('Start battle')),
      ])));
    title.dispose(); for (final s in steps) { s.dispose(); }
  }
  @override
  Widget build(BuildContext context) => MaterialApp(debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true), home: Builder(builder: (context) =>
      MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: !_motion),
        child: Scaffold(backgroundColor: const Color(0xFF111827), body: SafeArea(
          child: QuestwellBossBoard(key: ValueKey(_replay), battles: _state == 'empty' ? [] : _battles,
            initialBattleId: _createdBattleId ?? Uri.base.queryParameters['boss'], failed: _state == 'error', practice: true,
            unlockProgress: QuestwellBossUnlockProgress(level: _level,
              totalXp: QuestwellProgression.totalAtLevel(_level)),
            campfire: _campfire, archetype: 'scholar', body: 'female',
            equipment: const {'neck': 'emerald-scholar-scarf', 'accessory': 'moonstone-brooch'},
            onHome: () => QuestwellNavigationScope.open(context, QuestwellDestination.hearth),
            onCreate: () => _create(context), onAttack: (b, s) => setState(() => _done.add(s.id)),
            onRetry: () => setState(() => _state = 'battles'),
            footer: ExpansionTile(title: const Text('Preview controls'), children: [
              OutlinedButton(onPressed: () => setState(() { _done.clear(); _replay++; }), child: const Text('Reset practice battles')),
              const Text('Simulated level · preview only; does not change your account'),
              DropdownButton<int>(value: _level,
                items: [for (final level in QuestwellBossUnlocks.levels.values)
                  DropdownMenuItem(value: level, child: Text('Level $level'))],
                onChanged: (level) { if (level != null) setState(() {
                  _level = level; _createdBattleId = null; _replay++;
                }); }),
              SwitchListTile(title: const Text('Animations'), value: _motion, onChanged: (v) => setState(() => _motion = v)),
              SwitchListTile(title: const Text('Campfire mode'), value: _campfire, onChanged: (v) => setState(() => _campfire = v)),
              Wrap(spacing: 8, children: [for (final state in ['battles', 'empty', 'error']) ChoiceChip(
                label: Text(state), selected: state == _state, onSelected: (_) => setState(() => _state = state))]),
            ]),
          ),
        )))));
}
