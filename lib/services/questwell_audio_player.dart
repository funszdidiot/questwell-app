import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'questwell_audio.dart';

QuestwellAudioChannel createQuestwellAudioChannel() =>
    QuestwellAssetAudioChannel();

class QuestwellLocalAudioStore implements QuestwellAudioStore {
  static const _prefix = 'questwell.audio.v1.';

  @override
  Future<QuestwellAudioPreferences> read() async {
    final prefs = await SharedPreferences.getInstance();
    double level(String key, double fallback) {
      final value = prefs.getDouble('$_prefix$key');
      return value != null && value.isFinite ? value.clamp(0, 1) : fallback;
    }

    return QuestwellAudioPreferences(
      musicEnabled: prefs.getBool('${_prefix}music') ?? false,
      ambienceEnabled: prefs.getBool('${_prefix}ambience') ?? false,
      musicVolume: level('musicVolume', .35),
      ambienceVolume: level('ambienceVolume', .25),
    );
  }

  @override
  Future<void> write(QuestwellAudioPreferences value) async {
    final prefs = await SharedPreferences.getInstance();
    final results = [
      await prefs.setBool('${_prefix}music', value.musicEnabled),
      await prefs.setBool('${_prefix}ambience', value.ambienceEnabled),
      await prefs.setDouble('${_prefix}musicVolume', value.musicVolume),
      await prefs.setDouble('${_prefix}ambienceVolume', value.ambienceVolume),
    ];
    if (results.any((saved) => !saved)) {
      throw StateError('Audio preferences could not be saved');
    }
  }
}

/// Pinned audioplayers 6.5.1 adapter; disabled sound creates no player.
class QuestwellAssetAudioChannel implements QuestwellAudioChannel {
  AudioPlayer? _player;

  Future<AudioPlayer> _getPlayer() async {
    if (_player case final player?) return player;
    final player = AudioPlayer();
    try {
      await player
          .setAudioContext(
            AudioContext(
              android: const AudioContextAndroid(
                audioFocus: AndroidAudioFocus.none,
              ),
              iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
            ),
          )
          .timeout(const Duration(seconds: 3));
      await player
          .setReleaseMode(ReleaseMode.loop)
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      await player.dispose().timeout(const Duration(seconds: 3));
      rethrow;
    }
    _player = player;
    return player;
  }

  @override
  Future<void> prepare(String asset) async {
    final player = await _getPlayer();
    await player
        .setSource(AssetSource(asset))
        .timeout(const Duration(seconds: 8));
  }

  @override
  Future<void> resume() async =>
      (await _getPlayer()).resume().timeout(const Duration(seconds: 8));

  @override
  Future<void> pause() async {
    await _player?.pause().timeout(const Duration(seconds: 3));
  }

  @override
  Future<void> volume(double value) async {
    await (await _getPlayer())
        .setVolume(value)
        .timeout(const Duration(seconds: 3));
  }

  @override
  Future<void> close() async {
    await _player?.dispose().timeout(const Duration(seconds: 3));
  }
}
