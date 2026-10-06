import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/auth/questwell_auth_callback.dart';
import 'package:project_momentum/startup/questwell_bootstrap.dart';

void main() {
  tearDown(QuestwellAuthCallback.clear);

  test('captures recovery callback before backend consumes it', () async {
    var uri = Uri.parse(
      'https://example.test/#type=recovery&access_token=secret',
    );
    final bootstrap = QuestwellBootstrap(
      captureCallback: () => QuestwellAuthCallback.capture(uri),
      initializeBackend: () async {
        expect(QuestwellAuthCallback.recovering, isTrue);
        uri = Uri.parse('https://example.test/');
      },
      initializePreferences: () async {},
    );
    await bootstrap.run();
    expect(QuestwellAuthCallback.recovering, isTrue);
  });

  test(
    'preference retry preserves successful backend and callback flags',
    () async {
      var captures = 0;
      var backends = 0;
      var preferences = 0;
      final bootstrap = QuestwellBootstrap(
        captureCallback: () => captures++,
        initializeBackend: () async {
          backends++;
        },
        initializePreferences: () async {
          if (++preferences == 1) throw StateError('local storage');
        },
      );
      await expectLater(
        bootstrap.run(),
        throwsA(
          isA<StartupFailure>().having(
            (e) => e.restartRequired,
            'safe preference retry',
            false,
          ),
        ),
      );
      await bootstrap.run();
      expect([captures, backends, preferences], [1, 1, 2]);
    },
  );

  test(
    'partially initialized backend cannot be retried in the same process',
    () async {
      var attempts = 0;
      var preferences = 0;
      final bootstrap = QuestwellBootstrap(
        captureCallback: () {},
        initializeBackend: () async {
          attempts++;
          throw StateError('partial SDK');
        },
        initializePreferences: () async {
          preferences++;
        },
      );
      for (var n = 0; n < 2; n++) {
        await expectLater(
          bootstrap.run(),
          throwsA(
            isA<StartupFailure>().having(
              (e) => e.restartRequired,
              'fresh process required',
              true,
            ),
          ),
        );
      }
      expect(attempts, 1);
      expect(preferences, 0);
    },
  );

  test('overlapping startup calls share the whole active attempt', () async {
    final backend = Completer<void>();
    var attempts = 0;
    var preferences = 0;
    final bootstrap = QuestwellBootstrap(
      captureCallback: () {},
      initializeBackend: () {
        attempts++;
        return backend.future;
      },
      initializePreferences: () async {
        preferences++;
      },
    );
    final a = bootstrap.run();
    final b = bootstrap.run();
    backend.complete();
    await Future.wait([a, b]);
    expect(attempts, 1);
    expect(preferences, 1);
  });
}
