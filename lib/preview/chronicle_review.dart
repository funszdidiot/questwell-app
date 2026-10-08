import '../widgets/questwell_app_style.dart';
import 'quest_board_review.dart';
import 'package:flutter/material.dart';
import '../pages/chronicle_page/chronicle_page_widget.dart';
import '../services/questwell_chronicle_service.dart';

/// Real Chronicle screen with synthetic history and no authenticated requests.
class ChronicleReviewApp extends StatefulWidget {
  const ChronicleReviewApp({super.key});
  @override
  State<ChronicleReviewApp> createState() => _ChronicleReviewAppState();
}

class _ChronicleReviewAppState extends State<ChronicleReviewApp> {
  double width = 390;
  bool empty = false;
  final _copies = <({String title, String effort, int xp, int coins})>[];
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day, 18);
    final entries = [
      ChronicleWin(
          kind: 'set_aside',
          title: 'Reorganize the reference folder',
          completedAt: day.subtract(const Duration(days: 3)),
          xp: 20,
          coins: 10),
      ChronicleWin(
          kind: 'milestone_reward',
          title: 'Starlit Orrery',
          completedAt: day,
          xp: 0,
          coins: 0,
          cosmeticSlug: 'starlit-orrery',
          source: 'level_milestone',
          level: 10),
      ChronicleWin(
          kind: 'level_up',
          title: 'Level 10 reached',
          completedAt: day.subtract(const Duration(minutes: 1)),
          xp: 0,
          coins: 0,
          level: 10),
      ChronicleWin(
          kind: 'boss',
          title: 'The Inbox Hydra',
          completedAt: day.subtract(const Duration(minutes: 2)),
          xp: 100,
          coins: 50),
      ChronicleWin(
          kind: 'quest',
          title: 'Send the follow-up email',
          completedAt: day.subtract(const Duration(hours: 2)),
          xp: 20,
          coins: 10),
      ChronicleWin(
          kind: 'quest',
          title: 'Make space for one small win',
          completedAt: day.subtract(const Duration(days: 1)),
          xp: 10,
          coins: 5),
      ChronicleWin(
          kind: 'milestone_reward',
          title: 'First Journey',
          completedAt: day.subtract(const Duration(days: 2)),
          xp: 0,
          coins: 0,
          cosmeticSlug: 'first-journey-trophy',
          source: 'founder_testing_grant',
          level: 5),
    ];
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: QuestwellAppStyle.theme(),
        home: QuestwellScaffold(
            backgroundColor: const Color(0xFF0B1117),
            body: SafeArea(
                child: Column(children: [
              Wrap(
                  spacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('Chronicle · sample history'),
                    TextButton(
                        onPressed: () =>
                            setState(() => width = width == 390 ? 320 : 390),
                        child: Text('${width.toInt()} px')),
                    TextButton(
                        onPressed: () => setState(() => empty = !empty),
                        child: Text(empty
                            ? 'Show sample history'
                            : 'Show empty journal')),
                  ]),
              Expanded(
                  child: Center(
                      child: SizedBox(
                          width: width,
                          child: Builder(
                              builder: (context) => ChroniclePageWidget(
                                    key: ValueKey(empty),
                                    previewData: ChronicleSnapshot.fromWins(
                                        empty ? [] : entries,
                                        now: today),
                                    onRepeat: (win) async {
                                      _copies.add((
                                        title: win.title,
                                        effort:
                                            win.xp <= 10 ? 'Easy' : 'Annoying',
                                        xp: win.xp,
                                        coins: win.coins
                                      ));
                                    },
                                    onOpenBoard: () => Navigator.of(context)
                                        .push(MaterialPageRoute<void>(
                                            builder: (_) => QuestBoardReviewApp(
                                                initialQuests:
                                                    List.of(_copies)))),
                                  ))))),
            ]))));
  }
}
