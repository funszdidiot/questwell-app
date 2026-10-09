import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_momentum/services/questwell_audio.dart';
import 'package:project_momentum/services/questwell_audio_player.dart';
import 'package:project_momentum/widgets/questwell_audio_controls.dart';

class MemoryStore implements QuestwellAudioStore {
  QuestwellAudioPreferences value = const QuestwellAudioPreferences();
  bool failRead = false, failWrite = false;
  @override
  Future<QuestwellAudioPreferences> read() async {
    if (failRead) throw StateError('read');
    return value;
  }

  @override
  Future<void> write(QuestwellAudioPreferences next) async {
    if (failWrite) throw StateError('write');
    value = next;
  }
}

class RecordingChannel implements QuestwellAudioChannel {
  final loads = <String>[];
  bool playing = false, closed = false, failLoad = false;
  int starts = 0;
  double level = 0;
  Completer<void>? loading;
  @override
  Future<void> prepare(String asset) async {
    loads.add(asset);
    if (failLoad) throw StateError('load');
    await loading?.future;
  }

  @override
  Future<void> resume() async {
    playing = true;
    starts++;
  }

  @override
  Future<void> pause() async {
    playing = false;
  }

  @override
  Future<void> volume(double value) async {
    level = value;
  }

  @override
  Future<void> close() async {
    playing = false;
    closed = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MemoryStore store;
  late RecordingChannel music, ambience;
  late QuestwellAudio audio;
  setUp(() {
    store = MemoryStore();
    music = RecordingChannel();
    ambience = RecordingChannel();
    audio = QuestwellAudio(
      store: store,
      music: music,
      ambience: ambience,
      fadeStep: Duration.zero,
    );
  });
  tearDown(() async => audio.close());

  test('settings toggles and both volumes survive controller recreation',
      () async {
    SharedPreferences.setMockInitialValues({});
    final local = QuestwellLocalAudioStore();
    await local.write(const QuestwellAudioPreferences(
      musicEnabled: true,
      ambienceEnabled: false,
      musicVolume: .65,
      ambienceVolume: .15,
    ));
    final restored = await QuestwellLocalAudioStore().read();
    expect(restored.musicEnabled, isTrue);
    expect(restored.ambienceEnabled, isFalse);
    expect(restored.musicVolume, .65);
    expect(restored.ambienceVolume, .15);
    await local
        .write(restored.copyWith(musicEnabled: false, ambienceEnabled: true));
    final toggled = await QuestwellLocalAudioStore().read();
    expect(toggled.musicEnabled, isFalse);
    expect(toggled.ambienceEnabled, isTrue);
    expect(toggled.musicVolume, .65);
  });

  test('first visit is silent and does not load audio assets', () async {
    await audio.initialize();
    audio.setScene(QuestwellSoundscape.hearth);
    await audio.settled;
    expect(audio.preferences.musicEnabled, isFalse);
    expect(audio.preferences.ambienceEnabled, isFalse);
    expect(music.loads, isEmpty);
    expect(ambience.loads, isEmpty);
  });

  test('saved preference needs an explicit gesture each session', () async {
    store.value = const QuestwellAudioPreferences(
      musicEnabled: true,
      musicVolume: .2,
    );
    await audio.initialize();
    audio.setScene(QuestwellSoundscape.hearth);
    await audio.settled;
    expect(music.playing, isFalse);
    audio.activate();
    await audio.settled;
    expect(music.playing, isTrue);
    expect(music.level, closeTo(.2, .001));
  });

  test(
    'all four routes map correctly; auth and unknown routes stay silent',
    () {
      expect(
        QuestwellSoundscape.forPath('/homePage'),
        QuestwellSoundscape.hearth,
      );
      expect(
        QuestwellSoundscape.forPath('/market'),
        QuestwellSoundscape.market,
      );
      expect(
        QuestwellSoundscape.forPath('/expedition'),
        QuestwellSoundscape.expedition,
      );
      expect(
        QuestwellSoundscape.forPath('/boss-battles'),
        QuestwellSoundscape.boss,
      );
      expect(QuestwellSoundscape.forPath('/authPage'), isNull);
      expect(QuestwellSoundscape.forPath('/unknown'), isNull);
    },
  );

  test('same scene rebuild cannot reload or restart the track', () async {
    await audio.initialize();
    audio.setScene(QuestwellSoundscape.boss);
    audio.update(audio.preferences.copyWith(musicEnabled: true));
    await audio.settled;
    for (var i = 0; i < 20; i++) {
      audio.setScene(QuestwellSoundscape.boss);
    }
    await audio.settled;
    expect(music.loads, ['audios/boss_v1.mp3']);
    expect(music.starts, 1);
  });

  test('navigation during a load never starts the stale scene', () async {
    await audio.initialize();
    music.loading = Completer<void>();
    audio.setScene(QuestwellSoundscape.hearth);
    audio.update(audio.preferences.copyWith(musicEnabled: true));
    await Future<void>.delayed(Duration.zero);
    expect(music.loads, ['audios/hearth_v1.mp3']);
    audio.setScene(QuestwellSoundscape.expedition);
    audio.setScene(QuestwellSoundscape.market);
    music.loading!.complete();
    await audio.settled;
    expect(music.loads.last, 'audios/marketplace_v1.mp3');
    expect(music.loads, isNot(contains('audios/expedition_v1.mp3')));
    expect(music.starts, 1);
  });

  test('mute while loading cannot subsequently start music', () async {
    await audio.initialize();
    music.loading = Completer<void>();
    audio.setScene(QuestwellSoundscape.hearth);
    audio.update(audio.preferences.copyWith(musicEnabled: true));
    await Future<void>.delayed(Duration.zero);
    audio.update(audio.preferences.copyWith(musicEnabled: false));
    music.loading!.complete();
    await audio.settled;
    expect(music.starts, 0);
    expect(store.value.musicEnabled, isFalse);
  });

  test('music and ambience levels and switches remain independent', () async {
    await audio.initialize();
    audio.setScene(QuestwellSoundscape.expedition);
    audio.update(
      const QuestwellAudioPreferences(
        musicEnabled: true,
        ambienceEnabled: true,
        musicVolume: .2,
        ambienceVolume: .6,
      ),
    );
    await audio.settled;
    audio.update(audio.preferences.copyWith(musicEnabled: false));
    await audio.settled;
    expect(music.playing, isFalse);
    expect(ambience.playing, isTrue);
    expect(ambience.level, closeTo(.6, .001));
    expect(store.value.ambienceEnabled, isTrue);
  });

  test(
    'background pauses both channels; foreground restores chosen sound',
    () async {
      await audio.initialize();
      audio.setScene(QuestwellSoundscape.hearth);
      audio.update(
        const QuestwellAudioPreferences(
          musicEnabled: true,
          ambienceEnabled: true,
        ),
      );
      await audio.settled;
      audio.setForeground(false);
      await audio.settled;
      expect(music.playing || ambience.playing, isFalse);
      audio.setForeground(true);
      await audio.settled;
      expect(music.playing && ambience.playing, isTrue);
      expect(music.loads.length, 1);
    },
  );

  test(
    'load failure stops audio and is surfaced; explicit retry recovers',
    () async {
      await audio.initialize();
      music.failLoad = true;
      audio.setScene(QuestwellSoundscape.hearth);
      audio.update(audio.preferences.copyWith(musicEnabled: true));
      await audio.settled;
      expect(audio.issue, QuestwellAudioIssue.playback);
      expect(music.playing || ambience.playing, isFalse);
      music.failLoad = false;
      audio.activate();
      await audio.settled;
      expect(audio.issue, isNull);
      expect(music.playing, isTrue);
    },
  );

  test(
    'read and write failure remain visible without blocking navigation',
    () async {
      store.failRead = true;
      await audio.initialize();
      expect(audio.ready, isTrue);
      expect(audio.issue, QuestwellAudioIssue.preferences);
      store.failWrite = true;
      audio.update(audio.preferences.copyWith(musicVolume: .5));
      await audio.settled;
      expect(audio.issue, QuestwellAudioIssue.preferences);
      audio.setScene(QuestwellSoundscape.market);
      await audio.settled;
      expect(audio.scene, QuestwellSoundscape.market);
    },
  );

  test(
    'closing during a load disposes both players without starting',
    () async {
      await audio.initialize();
      music.loading = Completer<void>();
      audio.setScene(QuestwellSoundscape.hearth);
      audio.update(audio.preferences.copyWith(musicEnabled: true));
      await Future<void>.delayed(Duration.zero);
      final closing = audio.close();
      music.loading!.complete();
      await closing;
      expect(music.starts, 0);
      expect(music.closed && ambience.closed, isTrue);
    },
  );

  testWidgets('controls remain usable at 320px with large text', (
    tester,
  ) async {
    await audio.initialize();
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: QuestwellAudioControls(audio: audio),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Sound & music'), findsOneWidget);
    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pump();
    expect(audio.preferences.musicEnabled, isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
