import 'package:flutter/material.dart';
import '../widgets/questwell_boss_encounter.dart';

/// Account-free visual fixture. Buttons never award rewards or write progress.
class HollowHarvestReview extends StatefulWidget {
  const HollowHarvestReview({super.key});
  @override
  State<HollowHarvestReview> createState() => _HollowHarvestReviewState();
}

class _HollowHarvestReviewState extends State<HollowHarvestReview> {
  int replay = 0;
  int steps = 0;
  bool reduced = false;
  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: Scaffold(
          appBar: AppBar(title: const Text('The Hollow Harvest')),
          body: Builder(
              builder: (context) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                      disableAnimations:
                          reduced || MediaQuery.disableAnimationsOf(context)),
                  child: ListView(padding: const EdgeInsets.all(16), children: [
                    const Text(
                        'Seasonal encounter preview · No account changes'),
                    const SizedBox(height: 12),
                    Center(
                        child: SizedBox(
                            width: 600,
                            child: QuestwellBossEncounter(
                                key: ValueKey(replay),
                                encounterId: 'harvest-preview-$replay',
                                bossType: 'hollow_harvest',
                                persistEntrance: false,
                                progress: steps / 3,
                                defeated: steps == 3))),
                    Wrap(spacing: 12, children: [
                      FilledButton(
                          onPressed:
                              steps < 3 ? () => setState(() => steps++) : null,
                          child: const Text('Preview task strike')),
                      OutlinedButton(
                          onPressed: () => setState(() {
                                replay++;
                                steps = 0;
                              }),
                          child: const Text('Replay entrance')),
                    ]),
                    SwitchListTile(
                        title: const Text('Reduced motion'),
                        value: reduced,
                        onChanged: (value) => setState(() => reduced = value)),
                  ]))),
        ),
      );
}
