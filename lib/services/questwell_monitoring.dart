import 'dart:async';

import 'package:sentry/sentry.dart';

/// Only closed-vocabulary diagnostics may cross the monitoring boundary.
enum MonitoringCode {
  flutterFailure,
  platformFailure,
  backendStartup,
  preferencesStartup,
  probe,
}

enum MonitoringPlatform { web, android, ios, desktop }

enum MonitoringResult { disabled, suppressed, accepted, unavailable }

class QuestwellMonitoring {
  QuestwellMonitoring({
    required String dsn,
    required String build,
    required String environment,
    required MonitoringPlatform platform,
    SentryOptions? options,
  }) {
    // No implicit live destination, no test traffic, no arbitrary metadata.
    if (!_validDsn(dsn) ||
        !RegExp(r'^[0-9a-f]{7,40}$').hasMatch(build) ||
        !{'live_beta', 'staging'}.contains(environment)) return;
    final settings = options ?? SentryOptions();
    settings
      ..dsn = dsn
      ..sendDefaultPii = false
      ..attachStacktrace = false
      ..sendClientReports = false
      ..enableLogs = false
      ..enableMetrics = false
      ..debug = false
      ..beforeSend = (event, hint) {
        hint.attachments.clear();
        hint.screenshot = null;
        hint.viewHierarchy = null;
        final code = event.message?.formatted;
        if (!MonitoringCode.values.any((value) => value.name == code))
          return null;
        // Reconstruct; never pass SDK-enriched context, user, request, exception,
        // breadcrumb, stack, hostname or arbitrary tags through to transport.
        return SentryEvent(
          eventId: event.eventId,
          timestamp: event.timestamp,
          message: SentryMessage(code!),
          level: SentryLevel.error,
          platform: 'dart',
          release: build,
          environment: environment,
          tags: {'platform': platform.name},
          fingerprint: ['questwell', code],
        );
      };
    // Deliberately no global Hub, integrations, scope, native crash capture,
    // replay, screenshots, logs, tracing, user sessions, or disk queue.
    _client = SentryClient(settings);
  }

  SentryClient? _client;
  final Set<MonitoringCode> _attempted = {};

  static bool _validDsn(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.scheme == 'https' &&
        RegExp(
          r'^o[0-9]+\.ingest(\.[a-z]+)?\.sentry\.io$',
        ).hasMatch(uri.host) &&
        RegExp(r'^[0-9a-f]{32}$').hasMatch(uri.userInfo) &&
        RegExp(r'^/[0-9]+$').hasMatch(uri.path) &&
        !uri.hasQuery &&
        !uri.hasFragment &&
        !uri.hasPort;
  }

  /// At most one attempt per code per process. Never delays or retries a user
  /// action; a failed diagnostic is represented without recursively reporting it.
  Future<MonitoringResult> report(MonitoringCode code) async {
    final client = _client;
    if (client == null) return MonitoringResult.disabled;
    if (!_attempted.add(code)) return MonitoringResult.suppressed;
    try {
      final id = await client
          .captureEvent(SentryEvent(message: SentryMessage(code.name)))
          .timeout(const Duration(seconds: 5));
      return id == SentryId.empty()
          ? MonitoringResult.unavailable
          : MonitoringResult.accepted;
    } catch (_) {
      return MonitoringResult.unavailable;
    }
  }

  Future<void> close() async {
    final client = _client;
    _client = null;
    await client?.close();
  }
}
