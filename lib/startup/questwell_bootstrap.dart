import 'dart:async';

/// A safe recovery decision, never the underlying exception or callback URL.
class StartupFailure implements Exception {
  const StartupFailure({required this.restartRequired});
  final bool restartRequired;
}

/// Keeps successful startup stages intact across a safe preference retry.
/// Supabase Flutter 2.9.0 may leave a partially initialized singleton on error;
/// neither a second initialize nor dispose is safe at every failure boundary.
class QuestwellBootstrap {
  QuestwellBootstrap({
    required this.captureCallback,
    required this.initializeBackend,
    required this.initializePreferences,
  });

  final void Function() captureCallback;
  final Future<void> Function() initializeBackend;
  final Future<void> Function() initializePreferences;
  Future<void>? _backendAttempt;
  Future<void>? _active;
  bool _ready = false;

  Future<void> run() {
    if (_ready) return Future<void>.value();
    return _active ??= _run().whenComplete(() => _active = null);
  }

  Future<void> _run() async {
    try {
      await (_backendAttempt ??= Future<void>.sync(() {
        // Capture only once, before the SDK can consume the auth fragment.
        captureCallback();
        return initializeBackend();
      }));
    } catch (_) {
      throw const StartupFailure(restartRequired: true);
    }
    try {
      await initializePreferences();
    } catch (_) {
      throw const StartupFailure(restartRequired: false);
    }
    _ready = true;
  }
}
