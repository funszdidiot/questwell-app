# Recoverable startup — C05

The prior `main.dart` awaited backend and theme initialization before `runApp`.
A rejected or stalled initialization therefore had no Flutter recovery surface.
This is a source-confirmed failure path; no live failure was injected.

The startup boundary now renders immediately, mounts the unchanged application
only after initialization succeeds, and replaces its spinner with recovery
guidance after 15 seconds. A late success still opens the app. It does not cancel
or duplicate a pending SDK initialization. Exceptions are consumed without
printing raw values, URLs, tokens or user content. Disposal cancels the timer
and prevents late completions from changing the widget tree.

The bootstrap captures auth callback flags before backend initialization and
retains that attempt across retries. Only preference initialization is retried
in-process after a failure. Successful backend initialization is not repeated.
Backend errors require closing/reopening the app (reloading in a browser).
Recovery links may need reopening. This is an explicit recovery limitation,
not an assertion that every SDK failure can be repaired in-process.

Pinned SDK inspection: `supabase_flutter` 2.9.0 calls `_init` (setting
`_initialized`) before awaited `SupabaseAuth.initialize`. `dispose` first uses a
late restoration operation assigned only after that await. Consequently, neither
blindly reinitializing nor blindly disposing a failed singleton is safe at every
boundary. No SDK upgrade or session/reset behavior is included here.
Source: https://github.com/supabase/supabase-flutter/blob/supabase_flutter-v2.9.0/packages/supabase_flutter/lib/src/supabase.dart

Tests authored before implementation replace the assertion-free widget test:
loading/success, safe retry, redacted failure, slow/late success, disposal with
late error/success, and narrow enlarged-text recovery. Bootstrap tests cover
callback ordering, preference-only retry, cached backend failure and overlapping
attempts. They inject only local futures; no live session or backend is used.
CI now runs `flutter test` with no widget-test exclusion. Flutter 3.44.6 and the
existing dependency lock remain unchanged. Local Node checks pass; full Flutter
and build results are pending CI. Existing analyzer findings are not waived.

Current Flutter State.mounted and Dart Future.sync docs were checked on
October 6, 2026. UI recovery is bounded; timeout is not cancellation.
https://api.flutter.dev/flutter/widgets/State/mounted.html
https://api.dart.dev/dart-async/Future/Future.sync.html

Rollback: revert this boundary if it causes an application regression, retaining
the recorded startup limitation and release NO-GO. No hosted migration, production
promotion, account write, artwork or gameplay change is part of C05. Signed-in
callback and physical-device acceptance remain separate release evidence.
