import 'package:flutter/material.dart';
import '../services/questwell_audio.dart';
import '../widgets/questwell_audio_controls.dart';
import '../widgets/questwell_app_style.dart';

/// Account-free beta listening room, using the production playback controller.
class QuestwellAudioReview extends StatelessWidget {
  const QuestwellAudioReview({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Questwell Sound Room',
        theme: QuestwellAppStyle.theme(),
        home: QuestwellAudioHost(
          child: Builder(
            builder: (context) {
              final audio = QuestwellAudioScope.maybeOf(context)!;
              return Scaffold(
                appBar: AppBar(title: const Text('Questwell · Sound Room')),
                body: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          const Text(
                            'Four little adventures for your ears. Choose a place, then turn on Music.',
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final scene in QuestwellSoundscape.values)
                                ChoiceChip(
                                  label: Text(switch (scene) {
                                    QuestwellSoundscape.hearth => 'Hearth',
                                    QuestwellSoundscape.market => 'Marketplace',
                                    QuestwellSoundscape.expedition =>
                                      'Expedition',
                                    QuestwellSoundscape.boss => 'Boss Battles',
                                  }),
                                  selected: audio.scene == scene,
                                  onSelected: (_) {
                                    audio.setScene(scene);
                                    audio.activate();
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          QuestwellAudioControls(audio: audio),
                          const Divider(height: 40),
                          const Text('Beta listening notes'),
                          const SizedBox(height: 8),
                          const Text(
                            'Does each theme fit the space? Is it calming or distracting? Does repetition become noticeable? What volume feels right? Include your phone/browser when reporting sound problems.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
}
