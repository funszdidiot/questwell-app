import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/services/questwell_monitoring.dart';
import 'package:sentry/sentry.dart';

class RecordingTransport implements Transport {
  final List<SentryEnvelope> envelopes = [];
  bool fail = false;
  @override
  Future<SentryId?> send(SentryEnvelope envelope) async {
    envelopes.add(envelope);
    if (fail) throw StateError('private transport failure');
    return envelope.header.eventId;
  }
}

const validDsn =
    'https://0123456789abcdef0123456789abcdef@o123.ingest.us.sentry.io/456';

void main() {
  late RecordingTransport transport;
  late SentryOptions options;
  late QuestwellMonitoring monitoring;
  setUp(() {
    transport = RecordingTransport();
    options = SentryOptions()..transport = transport;
    monitoring = QuestwellMonitoring(
      dsn: validDsn,
      build: 'f20fc118',
      environment: 'staging',
      platform: MonitoringPlatform.web,
      options: options,
    );
  });
  tearDown(() async => monitoring.close());

  test(
    'actual SDK envelope contains only the permitted event fields',
    () async {
      expect(
        await monitoring.report(MonitoringCode.backendStartup),
        MonitoringResult.accepted,
      );
      final envelope = transport.envelopes.single;
      expect(envelope.items, hasLength(1));
      final event = envelope.items.single.originalObject! as SentryEvent;
      expect(event.toJson().keys.toSet(), {
        'event_id',
        'timestamp',
        'message',
        'level',
        'platform',
        'release',
        'environment',
        'tags',
        'fingerprint',
      });
      expect(event.message!.formatted, 'backendStartup');
      expect(event.tags, {'platform': 'web'});
      expect(options.sendDefaultPii, isFalse);
      expect(options.attachStacktrace, isFalse);
      expect(options.sendClientReports, isFalse);
      expect(options.enableLogs, isFalse);
      expect(options.enableMetrics, isFalse);
      expect(options.integrations, isEmpty);
    },
  );

  test('reconstruction removes sensitive fields added before send', () async {
    const secret = 'private-token-email-user-text-screenshot';
    options.addEventProcessor((event, hint) {
      event.user = SentryUser(id: secret, email: secret);
      event.request = SentryRequest(url: secret);
      event.breadcrumbs = [Breadcrumb(message: secret)];
      event.tags = {'private': secret};
      event.serverName = secret;
      event.transaction = secret;
      event.message = SentryMessage('backendStartup', params: [secret]);
      final attachment = SentryAttachment.fromIntList(
        utf8.encode(secret),
        'private.png',
      );
      hint.attachments.add(attachment);
      hint.screenshot = attachment;
      hint.viewHierarchy = attachment;
      return event;
    });
    await monitoring.report(MonitoringCode.backendStartup);
    final event =
        transport.envelopes.single.items.single.originalObject! as SentryEvent;
    expect(jsonEncode(event.toJson()), isNot(contains(secret)));
    expect(event.request, isNull);
    expect(event.user, isNull);
    expect(event.breadcrumbs, isNull);
    expect(transport.envelopes.single.items, hasLength(1));
  });

  test('unknown diagnostic is dropped at the outbound boundary', () async {
    options.addEventProcessor((event, hint) {
      event.message = SentryMessage('private arbitrary text');
      return event;
    });
    expect(
      await monitoring.report(MonitoringCode.probe),
      MonitoringResult.unavailable,
    );
    expect(transport.envelopes, isEmpty);
  });

  test('concurrent duplicate reports make only one attempt', () async {
    final results = await Future.wait(
      List.generate(
        20,
        (_) => monitoring.report(MonitoringCode.flutterFailure),
      ),
    );
    expect(results.where((r) => r == MonitoringResult.accepted), hasLength(1));
    expect(transport.envelopes, hasLength(1));
  });

  test('failed transport is typed and never recursively retried', () async {
    transport.fail = true;
    expect(
      await monitoring.report(MonitoringCode.probe),
      MonitoringResult.unavailable,
    );
    expect(
      await monitoring.report(MonitoringCode.probe),
      MonitoringResult.suppressed,
    );
    expect(transport.envelopes, hasLength(1));
  });

  test('closed reporter sends nothing', () async {
    await monitoring.close();
    expect(
      await monitoring.report(MonitoringCode.probe),
      MonitoringResult.disabled,
    );
    expect(transport.envelopes, isEmpty);
  });

  for (final dsn in [
    '',
    'http://0123456789abcdef0123456789abcdef@o123.ingest.us.sentry.io/456',
    'https://key@attacker.example/456',
    '$validDsn?token=secret',
    '$validDsn#secret',
  ]) {
    test(
      'invalid or unapproved destination disables reporting: $dsn',
      () async {
        final disabled = QuestwellMonitoring(
          dsn: dsn,
          build: 'f20fc118',
          environment: 'staging',
          platform: MonitoringPlatform.web,
          options: options,
        );
        expect(
          await disabled.report(MonitoringCode.probe),
          MonitoringResult.disabled,
        );
        expect(transport.envelopes, isEmpty);
        await disabled.close();
      },
    );
  }

  for (final environment in ['isolated_test', '', 'private-account']) {
    test('unsupported environment cannot send: $environment', () async {
      final disabled = QuestwellMonitoring(
        dsn: validDsn,
        build: 'f20fc118',
        environment: environment,
        platform: MonitoringPlatform.web,
        options: options,
      );
      expect(
        await disabled.report(MonitoringCode.probe),
        MonitoringResult.disabled,
      );
      expect(transport.envelopes, isEmpty);
      await disabled.close();
    });
  }
  test('arbitrary build text cannot enter telemetry', () async {
    final disabled = QuestwellMonitoring(
      dsn: validDsn,
      build: 'user@example.com',
      environment: 'staging',
      platform: MonitoringPlatform.web,
      options: options,
    );
    expect(
      await disabled.report(MonitoringCode.probe),
      MonitoringResult.disabled,
    );
    expect(transport.envelopes, isEmpty);
    await disabled.close();
  });
}
