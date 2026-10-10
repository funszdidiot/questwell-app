import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:project_momentum/services/questwell_export_client.dart';

const owner = '2e0c217b-950b-4122-8fc5-9e37fced985e';
const session = ExportSession(owner, 'session-a', 'synthetic-token');

Map<String, Object> fixture() => {
      'format': 'questwell-account-export',
      'version': 1,
      'tables': {
        'users': [
          {'id': owner},
        ],
        'tasks': [],
        'boss_battles': [],
        'boss_steps': [],
        'user_cosmetics': [],
        'progression_events': [],
        'reward_events': [],
        'beta_feedback': [],
      },
      'attachments': [],
    };

http.Response response(Object data, {int status = 200}) => http.Response(
      jsonEncode(data),
      status,
      headers: {
        'content-type': 'application/json',
        'cache-control': 'no-store, private',
      },
    );

void main() {
  AccountExportClient client(
    Future<http.Response> Function(http.Request) send, {
    ExportSession? Function()? current,
    int maxBytes = 1024 * 1024,
    Duration timeout = const Duration(seconds: 10),
  }) =>
      AccountExportClient(
        endpoint:
            Uri.parse('https://example.invalid/functions/v1/export-account'),
        publicKey: 'public-test-key',
        currentSession: current ?? () => session,
        createClient: () => MockClient(send),
        maxBytes: maxBytes,
        timeout: timeout,
      );

  test(
    'one empty authenticated POST and explicit private-byte disposal',
    () async {
      var calls = 0;
      final result = await client((request) async {
        calls++;
        expect(request.method, 'POST');
        expect(request.body, isEmpty);
        expect(request.url.query, isEmpty);
        expect(request.followRedirects, isFalse);
        expect(request.headers['Authorization'], 'Bearer synthetic-token');
        return response(fixture());
      }).prepare();
      final bytes = result.bytes;
      expect(jsonDecode(utf8.decode(bytes)), fixture());
      result.dispose();
      expect(bytes.every((byte) => byte == 0), isTrue);
      expect(result.isCurrent, isFalse);
      expect(() => result.bytes, throwsA(isA<AccountExportException>()));
      expect(calls, 1);
    },
  );

  test('signed-out request never reaches the network', () async {
    await expectLater(
      client(
        (_) async => throw StateError('network called'),
        current: () => null,
      ).prepare(),
      throwsA(isA<AccountExportException>()),
    );
  });

  test('changed session rejects response and prepared download', () async {
    ExportSession? current = session;
    final result = await client(
      (_) async => response(fixture()),
      current: () => current,
    ).prepare();
    current = const ExportSession(owner, 'session-b', 'new-token');
    expect(result.isCurrent, isFalse);
    expect(() => result.bytes, throwsA(isA<AccountExportException>()));
    current = session;
    await expectLater(
      client((_) async {
        current = null;
        return response(fixture());
      }, current: () => current).prepare(),
      throwsA(isA<AccountExportException>()),
    );
  });

  test('token refresh within the same session preserves eligibility', () async {
    var current = session;
    final result = await client((_) async {
      current = const ExportSession(owner, 'session-a', 'refreshed-token');
      return response(fixture());
    }, current: () => current).prepare();
    expect(result.isCurrent, isTrue);
    result.dispose();
  });

  for (final status in [401, 403, 429, 503, 500, 302]) {
    test('HTTP $status is never saved, leaked or retried', () async {
      var calls = 0;
      await expectLater(
        client((_) async {
          calls++;
          return response({'private': 'PRIVATE_MARKER'}, status: status);
        }).prepare(),
        throwsA(
          isA<AccountExportException>().having(
            (error) => error.message,
            'safe message',
            isNot(contains('PRIVATE_MARKER')),
          ),
        ),
      );
      expect(calls, 1);
    });
  }

  test(
    'malformed, incomplete, wrong-owner and corrupt exports are rejected',
    () async {
      final missing = fixture();
      (missing['tables'] as Map).remove('tasks');
      final wrongOwner = fixture();
      (wrongOwner['tables'] as Map)['tasks'] = [
        {'user_id': 'another-user'},
      ];
      final missingFile = fixture();
      (missingFile['tables'] as Map)['beta_feedback'] = [
        {
          'user_id': owner,
          'attachment_path': '$owner/probe.png',
          'attachment_paths': [],
        },
      ];
      final corrupt = fixture();
      (corrupt['tables'] as Map)['beta_feedback'] = [
        {
          'user_id': owner,
          'attachment_path': '$owner/probe.png',
          'attachment_paths': [],
        },
      ];
      corrupt['attachments'] = [
        {
          'path': '$owner/probe.png',
          'encoding': 'base64',
          'data': 'AQ==',
          'size': 1,
          'sha256': 'wrong',
        },
      ];
      for (final data in [{}, missing, wrongOwner, missingFile, corrupt]) {
        await expectLater(
          client((_) async => response(data)).prepare(),
          throwsA(isA<AccountExportException>()),
        );
      }
    },
  );

  test('oversized response is rejected', () async {
    await expectLater(
      client((_) async => response(fixture()), maxBytes: 8).prepare(),
      throwsA(isA<AccountExportException>()),
    );
  });

  test('parallel prepare is rejected and timeout does not retry', () async {
    final pending = Completer<http.Response>();
    var calls = 0;
    final api = client((_) {
      calls++;
      return pending.future;
    }, timeout: const Duration(milliseconds: 10));
    final first = api.prepare();
    await expectLater(api.prepare(), throwsA(isA<AccountExportException>()));
    await expectLater(first, throwsA(isA<AccountExportException>()));
    pending.complete(response({}, status: 503));
    expect(calls, 1);
  });
}
