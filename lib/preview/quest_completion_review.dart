import 'package:flutter/material.dart';
import '../widgets/questwell_app_style.dart';
import '../widgets/questwell_quest_completion.dart';

/// Local-only visual fixture; no account, task, or reward writes.
class QuestCompletionReviewApp extends StatelessWidget {
  const QuestCompletionReviewApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: QuestwellAppStyle.theme(),
        home: Scaffold(
            body: Builder(
                builder: (context) => Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text('LOCAL PREVIEW · sample quest and rewards'),
                        const SizedBox(height: 16),
                        FilledButton(
                            onPressed: () => showDialog<String>(
                                context: context,
                                builder: (_) =>
                                    const QuestwellQuestCompletionDialog(
                                        questTitle:
                                            'Make room for what matters',
                                        xpAwarded: 20,
                                        coinsAwarded: 10,
                                        totalXp: 115,
                                        coinBalance: 59,
                                        level: 3)),
                            child: const Text('Preview quest completion')),
                      ]),
                    ))),
      );
}
