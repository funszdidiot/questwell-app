import 'dart:async';

import 'package:flutter/foundation.dart';

enum QuestwellSoundscape {
  hearth('Hearthlight', 'hearth_v1.mp3', 'embers_v1.mp3'),
  market('Little Wonders Market', 'marketplace_v1.mp3', null),
  expedition('Quiet Trail', 'expedition_v1.mp3', 'woodland_v1.mp3'),
  boss('A Little Courage', 'boss_v1.mp3', null),
  hearthMusic('Hearthlight', 'hearth_v1.mp3', null),
  expeditionMusic('Quiet Trail', 'expedition_v1.mp3', null);

  const QuestwellSoundscape(this.title, this.music, this.ambience);
  final String title, music;
  final String? ambience;

  static QuestwellSoundscape? forPath(String path) => switch (path) {
        '/homePage' || '/account' => hearth,
        '/adventurer' || '/chronicle' => hearthMusic,
        '/quest-board' => expeditionMusic,
        '/market' => market,
        '/expedition' => expedition,
        '/boss-battles' => boss,
        _ => null,
      };
}

enum QuestwellAudioIssue { preferences, playback, cleanup }

@immutable
class QuestwellAudioPreferences {
  const QuestwellAudioPreferences({
    this.musicEnabled = false,
    this.ambienceEnabled = false,
    this.musicVolume = .35,
    this.ambienceVolume = .25,
  });
  final bool musicEnabled, ambienceEnabled;
  final double musicVolume, ambienceVolume;

  QuestwellAudioPreferences copyWith({
    bool? musicEnabled,
    bool? ambienceEnabled,
    double? musicVolume,
    double? ambienceVolume,
  }) =>
      QuestwellAudioPreferences(
        musicEnabled: musicEnabled ?? this.musicEnabled,
        ambienceEnabled: ambienceEnabled ?? this.ambienceEnabled,
        musicVolume: (musicVolume ?? this.musicVolume).clamp(0, 1),
        ambienceVolume: (ambienceVolume ?? this.ambienceVolume).clamp(0, 1),
      );
}

abstract interface class QuestwellAudioStore {
  Future<QuestwellAudioPreferences> read();
  Future<void> write(QuestwellAudioPreferences preferences);
}

abstract interface class QuestwellAudioChannel {
  Future<void> prepare(String asset);
  Future<void> resume();
  Future<void> pause();
  Future<void> volume(double value);
  Future<void> close();
}

/// Browser channels must unlock synchronously, before asset loading awaits.
abstract interface class QuestwellGestureAudioChannel {
  void unlock();
}

/// One owner for the app. Commands are serialized and checked after every load;
/// old routes cannot start music after navigation, mute or backgrounding.
class QuestwellAudio extends ChangeNotifier {
  QuestwellAudio({
    required this.store,
    required this.music,
    required this.ambience,
    this.fadeStep = const Duration(milliseconds: 40),
  });
  final QuestwellAudioStore store;
  final QuestwellAudioChannel music, ambience;
  final Duration fadeStep;
  QuestwellAudioPreferences preferences = const QuestwellAudioPreferences();
  QuestwellSoundscape? scene;
  QuestwellAudioIssue? issue;
  bool ready = false;
  bool activated = false;
  bool foreground = true;
  bool _closed = false;
  bool _musicPlaying = false, _ambiencePlaying = false;
  int _revision = 0;
  String? _musicAsset, _ambienceAsset;
  double _musicLevel = 0, _ambienceLevel = 0;
  Future<void> _queue = Future<void>.value();
  Future<void> _saveQueue = Future<void>.value();
  Future<void> get settled async {
    await Future.wait([_queue, _saveQueue]);
  }

  Future<void> initialize() async {
    try {
      preferences = await store.read();
    } catch (_) {
      issue = QuestwellAudioIssue.preferences;
    }
    if (_closed) return;
    ready = true;
    notifyListeners();
  }

  void setScene(QuestwellSoundscape? value) {
    if (_closed || scene == value) return;
    scene = value;
    _request();
  }

  void setForeground(bool value) {
    if (_closed || foreground == value) return;
    foreground = value;
    _request();
    if (!value) unawaited(_silence());
  }

  /// A normal app interaction resumes only sound the listener already enabled.
  void activateOnInteraction() {
    if (!ready || !foreground || activated || _closed) return;
    if (!preferences.musicEnabled && !preferences.ambienceEnabled) return;
    activate();
  }

  void _unlockEnabledChannels() {
    if (preferences.musicEnabled && music is QuestwellGestureAudioChannel) {
      (music as QuestwellGestureAudioChannel).unlock();
    }
    if (preferences.ambienceEnabled &&
        ambience is QuestwellGestureAudioChannel) {
      (ambience as QuestwellGestureAudioChannel).unlock();
    }
  }

  /// Called directly by the interaction, before entering the async queue.
  void activate() {
    if (!ready || _closed) return;
    _unlockEnabledChannels();
    activated = true;
    issue = null;
    _request();
  }

  void update(QuestwellAudioPreferences value) {
    if (!ready || _closed) return;
    preferences = value;
    _unlockEnabledChannels();
    activated = true;
    issue = null;
    _saveQueue = _saveQueue.then((_) async {
      try {
        await store.write(value);
      } catch (_) {
        if (!_closed) {
          issue = QuestwellAudioIssue.preferences;
          notifyListeners();
        }
      }
    });
    _request();
  }

  void _request() {
    final revision = ++_revision;
    notifyListeners();
    _queue = _queue.then((_) async {
      if (_closed || revision != _revision) return;
      try {
        final audible = ready && activated && foreground;
        await _channel(
          music,
          audible && preferences.musicEnabled ? scene?.music : null,
          preferences.musicVolume,
          true,
          revision,
        );
        if (_closed || revision != _revision) return;
        await _channel(
          ambience,
          audible && preferences.ambienceEnabled ? scene?.ambience : null,
          preferences.ambienceVolume,
          false,
          revision,
        );
      } catch (_) {
        if (_closed) return;
        activated = false;
        issue = QuestwellAudioIssue.playback;
        await _silence();
        notifyListeners();
      }
    });
  }

  Future<void> _channel(
    QuestwellAudioChannel channel,
    String? asset,
    double level,
    bool isMusic,
    int revision,
  ) async {
    final previous = isMusic ? _musicAsset : _ambienceAsset;
    final previousLevel = isMusic ? _musicLevel : _ambienceLevel;
    if (asset != previous || asset == null) {
      // Mute/background requests pause immediately; scene changes fade out.
      if (asset != null && previous != null) {
        await _fade(channel, previousLevel, 0, revision);
      }
      await channel.pause();
      if (isMusic) {
        _musicPlaying = false;
        _musicLevel = 0;
      } else {
        _ambiencePlaying = false;
        _ambienceLevel = 0;
      }
      if (asset == null || _closed || revision != _revision) return;
      await channel.volume(0);
      await channel.prepare('audios/$asset');
      if (isMusic) {
        _musicAsset = asset;
      } else {
        _ambienceAsset = asset;
      }
    }
    if (_closed || revision != _revision) return;
    if (!(isMusic ? _musicPlaying : _ambiencePlaying)) {
      await channel.resume();
      if (isMusic) {
        _musicPlaying = true;
      } else {
        _ambiencePlaying = true;
      }
      if (_closed || revision != _revision) {
        await channel.pause();
        if (isMusic) {
          _musicPlaying = false;
        } else {
          _ambiencePlaying = false;
        }
        return;
      }
    }
    await _fade(
      channel,
      isMusic ? _musicLevel : _ambienceLevel,
      level,
      revision,
    );
    if (isMusic) {
      _musicLevel = level;
    } else {
      _ambienceLevel = level;
    }
  }

  Future<void> _fade(
    QuestwellAudioChannel channel,
    double from,
    double to,
    int revision,
  ) async {
    for (var step = 1; step <= 6; step++) {
      if (_closed || revision != _revision) return;
      await channel.volume(from + (to - from) * step / 6);
      if (fadeStep != Duration.zero) await Future<void>.delayed(fadeStep);
    }
  }

  Future<void> _silence() async {
    for (final channel in [music, ambience]) {
      try {
        await channel.pause();
      } catch (_) {
        issue = QuestwellAudioIssue.cleanup;
      }
    }
    _musicPlaying = false;
    _ambiencePlaying = false;
    _musicLevel = 0;
    _ambienceLevel = 0;
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    ++_revision;
    await settled;
    for (final channel in [music, ambience]) {
      try {
        await channel.close();
      } catch (_) {
        issue = QuestwellAudioIssue.cleanup;
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: StateError('Questwell audio cleanup failed'),
            library: 'questwell_audio',
          ),
        );
      }
    }
    super.dispose();
  }
}
