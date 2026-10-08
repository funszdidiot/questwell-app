import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:postgrest/postgrest.dart';
import 'package:project_momentum/services/questwell_chronicle_service.dart';
import 'package:project_momentum/services/questwell_content_policy.dart';
import 'package:project_momentum/services/questwell_task_creation.dart';

void main() {
  test(
    'set-aside legacy titles render fallback without rewriting records',
    () async {
      final client = MockClient((request) async {
        expect(
          request.method,
          request.url.path.contains('/rpc/') ? 'POST' : 'GET',
        );
        final Object payload;
        if (request.url.path.endsWith('/rpc/chronicle_totals')) {
          payload = {
            'owner_id': 'owner-a',
            'week_start': jsonDecode(request.body)['p_week_start'],
            'total_xp_earned': '0',
            'total_coins_earned': '0',
            'week_wins': '0',
            'bosses_defeated': '0',
          };
        } else if (request.url.path.endsWith('/tasks') &&
            request.url.queryParameters['status'] == 'eq.set_aside' &&
            !request.url.queryParameters.containsKey('id')) {
          payload = [
            {
              'id': '00000000-0000-4000-8000-000000000001',
              'user_id': 'owner-a',
              'status': 'set_aside',
              'title': ' \u00a0\ufeff',
              'created_at': '2026-10-07T00:00:00Z',
            },
          ];
        } else {
          payload = [];
        }
        return http.Response(
          jsonEncode(payload),
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      });
      addTearDown(client.close);
      final result = await QuestwellChronicleService.load(
        database: PostgrestClient(
          'https://fixture.invalid/rest/v1',
          httpClient: client,
        ),
        currentOwner: () => 'owner-a',
        now: DateTime.utc(2026, 10, 7),
      );
      expect(result.wins.single.kind, 'set_aside');
      expect(result.wins.single.title, 'Untitled quest');
    },
  );
  test(
    'title limits count Unicode scalars after trimming, without truncation',
    () {
      final boundary = List.filled(120, '🧭').join();
      expect(QuestwellContentPolicy.titleError(' \u00a0$boundary\n'), isNull);
      expect(QuestwellContentPolicy.titleError('$boundary🧭'), isNotNull);
      expect(QuestwellContentPolicy.titleError('\u00a0\n\ufeff'), isNotNull);
      // Combining characters are two scalars; this is not a grapheme limit.
      expect(
        QuestwellContentPolicy.titleError(List.filled(61, 'e\u0301').join()),
        isNotNull,
      );
      expect(
        QuestwellContentPolicy.displayTitle(boundary, 'Untitled'),
        boundary,
      );
      expect(QuestwellContentPolicy.displayTitle('  ', 'Untitled'), 'Untitled');
    },
  );
  test('description and boss boundaries reject oversized payloads', () {
    expect(
      QuestwellContentPolicy.descriptionError(List.filled(4000, '🧭').join()),
      isNull,
    );
    expect(
      QuestwellContentPolicy.descriptionError(List.filled(4001, '🧭').join()),
      isNotNull,
    );
    expect(
      QuestwellContentPolicy.bossError('Boss', List.filled(50, 'Step')),
      isNull,
    );
    expect(
      QuestwellContentPolicy.bossError('Boss', List.filled(51, 'Step')),
      isNotNull,
    );
    expect(QuestwellContentPolicy.bossError('Boss', ['One', ' ']), isNotNull);
  });
  test('invalid quest never sends or freezes an idempotent draft', () async {
    var calls = 0;
    final creation = QuestwellTaskCreation(
      requestId: 'request',
      ownerId: 'owner',
      currentOwner: () => 'owner',
      send: (params) async {
        calls++;
        return 'saved';
      },
    );
    await expectLater(creation.save('x' * 121, 1), throwsArgumentError);
    expect(calls, 0);
    expect(creation.started, isFalse);
    expect(await creation.save('Corrected title', 1), 'saved');
    expect(calls, 1);
  });
}
