import 'package:flutter/material.dart';
import 'package:project_momentum/add_task_page/add_task_page_widget.dart';
import '../widgets/questwell_quest_card.dart';
import '../widgets/questwell_app_navigation.dart';
import '../widgets/questwell_typography.dart';

class QuestBoardReviewApp extends StatefulWidget {
  const QuestBoardReviewApp({super.key, this.openNewQuest = false, this.initialQuests = const []});
  final bool openNewQuest;
  final List<({String title, String effort, int xp, int coins})> initialQuests;
  @override
  State<QuestBoardReviewApp> createState() => _QuestBoardReviewAppState();
}

class _QuestBoardReviewAppState extends State<QuestBoardReviewApp> {
  final _done = <int>{};
  final _pinned = <int>{0};
  String _filter = 'all';
  final _quests = [
    (title: 'Send the email you have been putting off', effort: 'Hard to Start', xp: 30, coins: 6),
    (title: 'Clear one small corner of your desk', effort: 'Low Energy', xp: 10, coins: 2),
    (title: 'Outline the first three steps of your project', effort: 'High Impact', xp: 40, coins: 8),
  ];
  @override
  void initState() {
    super.initState();
    _quests.insertAll(0, widget.initialQuests);
  }

  bool visible(int i) => !_done.contains(i) && switch (_filter) {
    'pinned' => _pinned.contains(i),
    'low' => const ['Easy', 'Annoying', 'Low Energy'].contains(_quests[i].effort),
    'high' => !const ['Easy', 'Annoying', 'Low Energy'].contains(_quests[i].effort),
    'boss' => false,
    _ => true,
  };

  void _add(BuildContext context) => Navigator.of(context).pushNamed('/new-quest');

  Future<void> _edit(BuildContext context, int i) async {
    final quest = _quests[i];
    final friction = switch (quest.effort) {
      'Easy' => 1, 'Low Energy' || 'Annoying' => 2, 'Hard to Start' => 3, _ => 4,
    };
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (editContext) => AddTaskPageWidget(
        editing: true, initialTitle: quest.title, initialFriction: friction,
        initialXp: quest.xp, initialCoins: quest.coins,
        onFinished: (saved) => Navigator.of(editContext).pop(saved),
        onCreate: (title, friction, xp, coins) async {
          setState(() {
            _quests[i] = (title: title, effort: switch (friction) {
              1 => 'Easy', 2 => 'Annoying', 3 => 'Hard to Start',
              _ => 'Brain Says Absolutely Not',
            }, xp: xp, coins: coins);
            _filter = 'all';
          });
        },
      ),
    ));
    if (saved == true && context.mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quest updated.')));
  }

  Future<void> _create(String title, int friction, int xp, int coins) async {
    setState(() {
      _quests.add((title: title, effort: switch (friction) {
        1 => 'Low Energy', 2 => 'Annoying', 3 => 'Hard to Start',
        _ => 'Brain Says Absolutely Not',
      }, xp: xp, coins: coins));
      _filter = 'all';
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true),
    initialRoute: widget.openNewQuest ? '/new-quest' : '/',
    routes: {
      '/new-quest': (context) => AddTaskPageWidget(
        onCreate: _create, onClose: () => Navigator.of(context).pop()),
    },
    home: Scaffold(
      bottomNavigationBar: const QuestwellAppNavigation(current: QuestwellDestination.quests),
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Builder(builder: (context) => ListView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 24), children: [
          QuestwellBoardHeading(completed: _done.length, onAdd: () => _add(context)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final item in const [
              ('all', 'All quests', Icons.calendar_today_outlined),
              ('low', 'Low Energy', Icons.bolt_outlined),
              ('high', 'Bigger quests', Icons.landscape_outlined),
              ('boss', 'Bosses', Icons.sports_mma_outlined),
              ('pinned', 'Pinned', Icons.star_border),
            ]) QuestwellBoardFilter(label: item.$2, icon: item.$3,
              selected: _filter == item.$1, onTap: () => setState(() => _filter = item.$1)),
          ]),
          const SizedBox(height: 22),
          Text(_filter == 'boss' ? 'BOSS QUESTS' : 'YOUR NEXT WIN',
            style: QuestwellTypography.sectionHeading(size: 10)),
          const SizedBox(height: 12),
          if (_filter == 'boss') OutlinedButton(
            onPressed: () => QuestwellNavigationScope.open(context, QuestwellDestination.bosses),
            child: const Text('Open Boss Battles'))
          else QuestwellNoticeboard(child: Column(children: [
            for (var i = 0; i < _quests.length; i++) if (visible(i))
              Padding(padding: const EdgeInsets.only(bottom: 14),
                child: QuestwellQuestCard(title: _quests[i].title,
                  effort: _quests[i].effort, xp: _quests[i].xp, coins: _quests[i].coins,
                  favorite: _pinned.contains(i),
                  onEdit: () => _edit(context, i),
                  onFavorite: () => setState(() {
                    if (!_pinned.add(i)) _pinned.remove(i);
                  }),
                  onComplete: () => setState(() => _done.add(i)),
                )),
            if (!_quests.asMap().keys.any(visible))
              Padding(padding: const EdgeInsets.all(20), child: Text(
                _filter == 'pinned' ? 'No pinned quests here. Pin a quest in All quests.'
                  : 'No quests in this lane right now.', textAlign: TextAlign.center,
                style: QuestwellTypography.body(color: const Color(0xFFF0E5CC)))),
          ])),
          const SizedBox(height: 12),
          TextButton(onPressed: () => setState(() { _done.clear(); _filter = 'all'; }),
            child: const Text('Reset sample quests')),
        ])),
      ))),
    ),
  );
}
