import 'package:flutter/material.dart';
import '../widgets/questwell_quest_card.dart';

class QuestBoardReviewApp extends StatefulWidget {
  const QuestBoardReviewApp({super.key});
  @override
  State<QuestBoardReviewApp> createState() => _QuestBoardReviewAppState();
}

class _QuestBoardReviewAppState extends State<QuestBoardReviewApp> {
  final _done = <int>{};
  final _pinned = <int>{0};
  bool _pinnedOnly = false;
  static const _titles = ['Send the email you have been putting off',
    'Clear one small corner of your desk', 'Outline the first three steps of your project'];
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true),
    home: Scaffold(backgroundColor: const Color(0xFF0E1724),
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Quest Board · design review', textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text('Sample quests only. Nothing changes your account.',
            textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB7C4D4))),
          const SizedBox(height: 18),
          QuestwellBoardHeading(completed: _done.length),
          const SizedBox(height: 16),
          Wrap(spacing: 8, children: [
            ChoiceChip(label: const Text('All quests'), selected: !_pinnedOnly,
              onSelected: (_) => setState(() => _pinnedOnly = false)),
            ChoiceChip(label: const Text('Pinned'), selected: _pinnedOnly,
              onSelected: (_) => setState(() => _pinnedOnly = true)),
          ]),
          const SizedBox(height: 12),
          QuestwellNoticeboard(child: Column(children: [
          for (var i = 0; i < _titles.length; i++)
            if (!_done.contains(i) && (!_pinnedOnly || _pinned.contains(i)))
              Padding(padding: const EdgeInsets.only(bottom: 14),
                child: QuestwellQuestCard(title: _titles[i],
                  effort: ['Hard to Start', 'Low Energy', 'High Impact'][i],
                  xp: [30, 10, 40][i], coins: [6, 2, 8][i],
                  favorite: _pinned.contains(i),
                  onFavorite: () => setState(() {
                    if (!_pinned.add(i)) _pinned.remove(i);
                  }),
                  onComplete: () => setState(() => _done.add(i)),
                )),
          if (!_titles.asMap().keys.any((i) => !_done.contains(i) && (!_pinnedOnly || _pinned.contains(i))))
            Padding(padding: const EdgeInsets.all(20), child: Text(
              _pinnedOnly ? 'No pinned quests here. Pin a quest in All quests.'
                : 'Board clear. Enjoy your small wins.', textAlign: TextAlign.center)),
          ])),
          TextButton(onPressed: () => setState(() { _done.clear(); _pinnedOnly = false; }),
            child: const Text('Reset sample quests')),
        ]),
      ))),
    ),
  );
}
