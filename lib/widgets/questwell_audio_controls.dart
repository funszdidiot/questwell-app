import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/questwell_audio.dart';
import '../services/questwell_audio_player.dart';
import 'questwell_hearth_material.dart';

class QuestwellAudioScope extends InheritedNotifier<QuestwellAudio> {
  const QuestwellAudioScope({
    super.key,
    required QuestwellAudio audio,
    required super.child,
  }) : super(notifier: audio);
  static QuestwellAudio? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<QuestwellAudioScope>()
      ?.notifier;
}

/// Lives above the Navigator, never inside a rebuilding destination.
class QuestwellAudioHost extends StatefulWidget {
  const QuestwellAudioHost({
    super.key,
    required this.child,
    this.router,
    this.audio,
    this.isHomeRoot,
  });
  final Widget child;
  final GoRouter? router;
  final QuestwellAudio? audio;
  final bool Function()? isHomeRoot;
  @override
  State<QuestwellAudioHost> createState() => _QuestwellAudioHostState();
}

class _QuestwellAudioHostState extends State<QuestwellAudioHost>
    with WidgetsBindingObserver {
  late final QuestwellAudio audio;
  @override
  void initState() {
    super.initState();
    audio = widget.audio ??
        QuestwellAudio(
          store: QuestwellLocalAudioStore(),
          music: QuestwellAssetAudioChannel(),
          ambience: QuestwellAssetAudioChannel(),
        );
    WidgetsBinding.instance.addObserver(this);
    audio.setForeground(
      WidgetsBinding.instance.lifecycleState == null ||
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed,
    );
    widget.router?.routerDelegate.addListener(_routeChanged);
    _routeChanged();
    unawaited(audio.initialize());
  }

  void _routeChanged() {
    final config = widget.router?.routerDelegate.currentConfiguration;
    if (config == null || config.isEmpty) return;
    final last = config.last;
    final path =
        last is ImperativeRouteMatch ? last.matches.uri.path : config.uri.path;
    audio.setScene(
      path == '/' && (widget.isHomeRoot?.call() ?? false)
          ? QuestwellSoundscape.hearth
          : QuestwellSoundscape.forPath(path),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      audio.setForeground(state == AppLifecycleState.resumed);
  @override
  void dispose() {
    widget.router?.routerDelegate.removeListener(_routeChanged);
    WidgetsBinding.instance.removeObserver(this);
    unawaited(audio.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      QuestwellAudioScope(audio: audio, child: widget.child);
}

class QuestwellAudioControls extends StatelessWidget {
  const QuestwellAudioControls({super.key, required this.audio});
  final QuestwellAudio audio;
  static Future<void> open(BuildContext context, QuestwellAudio audio) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: const Color(0xFF251C18),
        builder: (context) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: QuestwellAudioControls(audio: audio),
          ),
        ),
      );
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: audio,
        builder: (context, _) {
          final prefs = audio.preferences;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sound & music', style: QuestwellHearthMaterial.serif(22)),
              const SizedBox(height: 8),
              Text(
                audio.scene == null
                    ? 'A quiet corner. Music follows you through Questwell.'
                    : 'Here: ${audio.scene!.title}',
              ),
              const SizedBox(height: 8),
              const Text(
                'Make yourself at home. Your sound choices stay on this device.',
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Music'),
                value: prefs.musicEnabled,
                onChanged: audio.ready
                    ? (value) =>
                        audio.update(prefs.copyWith(musicEnabled: value))
                    : null,
              ),
              _volume(
                'Music volume',
                prefs.musicVolume,
                audio.ready && prefs.musicEnabled,
                (value) => audio.update(prefs.copyWith(musicVolume: value)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Nature & fireplace'),
                subtitle: const Text('Hearth and Expedition ambience'),
                value: prefs.ambienceEnabled,
                onChanged: audio.ready
                    ? (value) =>
                        audio.update(prefs.copyWith(ambienceEnabled: value))
                    : null,
              ),
              _volume(
                'Ambience volume',
                prefs.ambienceVolume,
                audio.ready && prefs.ambienceEnabled,
                (value) => audio.update(prefs.copyWith(ambienceVolume: value)),
              ),
              if (!audio.activated &&
                  audio.ready &&
                  (prefs.musicEnabled || prefs.ambienceEnabled))
                FilledButton(
                  onPressed: audio.activate,
                  child: const Text('Start sound'),
                ),
              if (audio.issue != null) ...[
                const SizedBox(height: 8),
                Text(
                  audio.issue == QuestwellAudioIssue.preferences
                      ? 'Your sound choices could not be saved. Try changing them again.'
                      : 'Sound could not start. Tap Start sound to try again, or keep enjoying the quiet.',
                ),
              ],
              const SizedBox(height: 8),
              const Text(
                'Sound pauses when you leave the app. Listening to your own music? Turn both options off.',
              ),
            ],
          );
        },
      );

  Widget _volume(
    String label,
    double value,
    bool enabled,
    ValueChanged<double> onChanged,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label · ${(value * 100).round()}%'),
          Slider(
            value: value,
            divisions: 20,
            label: '${(value * 100).round()}%',
            semanticFormatterCallback: (value) =>
                '$label ${(value * 100).round()} percent',
            onChanged: enabled ? onChanged : null,
          ),
        ],
      );
}
