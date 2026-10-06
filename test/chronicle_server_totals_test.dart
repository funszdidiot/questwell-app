import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:postgrest/postgrest.dart';
import 'package:project_momentum/services/questwell_chronicle_service.dart';

void main() {
  final now = DateTime(2026, 10, 6, 12);
  Map<String, Object?> valid(http.Request r) => {
        'owner_id': 'owner-a',
        'week_start': jsonDecode(r.body)['p_week_start'],
        'total_xp_earned': '9000',
        'total_coins_earned': '5000',
        'week_wins': '45',
        'bosses_defeated': '12',
      };
  Future<ChronicleSnapshot> load(
    Future<http.Response> Function(http.Request) rpc, {
    String? Function()? owner,
  }) async {
    final client = MockClient((r) async {
      final result = r.url.path.endsWith('/rpc/chronicle_totals')
          ? await rpc(r)
          : http.Response(
              jsonEncode(r.url.path.endsWith('/tasks') &&
                      r.url.queryParameters['status'] == 'eq.completed' &&
                      !r.url.queryParameters.containsKey('id')
                  ? [
                      {
                        'id': '00000000-0000-4000-8000-000000000001',
                        'user_id': 'owner-a',
                        'status': 'completed',
                        'title': 'One quest',
                        'completed_at': now.toUtc().toIso8601String(),
                        'xp_value': 10,
                        'coin_value': 5
                      }
                    ]
                  : []),
              200);
      return http.Response(result.body, result.statusCode,
          headers: {'content-type': 'application/json'}, request: r);
    });
    addTearDown(client.close);
    return QuestwellChronicleService.load(
        database: PostgrestClient('https://fixture.invalid/rest/v1',
            httpClient: client),
        currentOwner: owner ?? () => 'owner-a',
        now: now);
  }

  http.Response response(Object? data, [int status = 200]) =>
      http.Response(jsonEncode(data), status);
  test('server totals replace client folds while preserving history', () async {
    var calls = 0;
    final result = await load((r) async {
      calls++;
      expect(r.method, 'POST');
      final body = jsonDecode(r.body) as Map;
      expect(body.keys, ['p_week_start']);
      final monday = DateTime(2026, 10, 5).toUtc();
      expect(DateTime.parse(body['p_week_start']), monday);
      return response(valid(r));
    });
    expect(calls, 1);
    expect(result.wins, hasLength(1));
    expect(result.wins.single.xp, 10);
    expect([
      result.totalXpEarned,
      result.totalCoinsEarned,
      result.weekWins,
      result.bossesDefeated
    ], [
      9000,
      5000,
      45,
      12
    ]);
  });
  for (final value in [
    null,
    [],
    'bad',
    {'owner_id': 'owner-b'}
  ]) {
    test('reject malformed envelope $value', () async {
      await expectLater(load((r) async => response(value)), throwsStateError);
    });
  }
  for (final field in [
    'total_xp_earned',
    'total_coins_earned',
    'week_wins',
    'bosses_defeated'
  ]) {
    for (final bad in [
      null,
      1,
      1.5,
      '1.5',
      '01',
      '+1',
      '1e3',
      '9007199254740992',
      '-9007199254740992'
    ]) {
      test('reject $field value $bad (${bad.runtimeType})', () async {
        await expectLater(load((r) async => response(valid(r)..[field] = bad)),
            throwsStateError);
      });
    }
    test('reject missing $field', () async {
      await expectLater(load((r) async => response(valid(r)..remove(field))),
          throwsStateError);
    });
  }
  for (final field in ['week_wins', 'bosses_defeated']) {
    test('reject negative count $field', () async {
      await expectLater(load((r) async => response(valid(r)..[field] = '-1')),
          throwsStateError);
    });
  }
  for (final bad in [
    null,
    'garbage',
    '2026-10-05T00:00:00',
    '2026-09-28T00:00:00Z'
  ]) {
    test('reject unverifiable week $bad', () async {
      await expectLater(
          load((r) async => response(valid(r)..['week_start'] = bad)),
          throwsStateError);
    });
  }
  test('accept zero and exact safe-limit totals without rounding', () async {
    final result = await load((r) async => response(valid(r)
      ..['total_xp_earned'] = '9007199254740991'
      ..['total_coins_earned'] = '-9007199254740991'
      ..['week_wins'] = '0'
      ..['bosses_defeated'] = '0'));
    expect(result.totalXpEarned, 9007199254740991);
    expect(result.totalCoinsEarned, -9007199254740991);
    expect(result.weekWins, 0);
    expect(result.bossesDefeated, 0);
  });
  test('account change while aggregate is pending discards snapshot', () async {
    var owner = 'owner-a';
    await expectLater(
        load((r) async {
          owner = 'owner-b';
          return response(valid(r));
        }, owner: () => owner),
        throwsStateError);
  });
  test('account change before retry prevents another aggregate request',
      () async {
    var owner = 'owner-a', calls = 0;
    await expectLater(
        load((r) async {
          calls++;
          owner = 'owner-b';
          throw TimeoutException('fixture timeout');
        }, owner: () => owner),
        throwsStateError);
    expect(calls, 1);
  });
  test('transient read retries and returns validated aggregate', () async {
    var calls = 0;
    final result = await load((r) async {
      if (++calls == 1) throw TimeoutException('fixture timeout');
      return response(valid(r));
    });
    expect(calls, 2);
    expect(result.totalXpEarned, 9000);
  });
  for (final status in [401, 403, 404, 503]) {
    test('RPC failure $status cannot fall back to client totals', () async {
      await expectLater(
          load((r) async => response(
              {'message': 'fixture failure', 'code': 'fixture'}, status)),
          throwsA(isA<PostgrestException>()));
    });
  }
}
