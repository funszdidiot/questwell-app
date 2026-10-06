import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:postgrest/postgrest.dart';
import 'package:project_momentum/services/questwell_chronicle_service.dart';

String id(int n) => '00000000-0000-4000-8000-${n.toString().padLeft(12, '0')}';
final now = DateTime(2026, 10, 6, 12);
final stamp = now.toUtc().toIso8601String();
const scopes = ['quests', 'bosses', 'milestones', 'aside'];
Map<String, dynamic> row(String scope, int n) => {
      'id': id(n),
      'user_id': 'owner-a',
      'title': '$scope $n',
      'status': scope == 'aside' ? 'set_aside' : 'completed',
      'created_at': stamp,
      'completed_at': stamp,
      'occurred_at': stamp,
      'xp_value': 10,
      'coin_value': 5,
      'reward_xp': 25,
      'reward_coins': 50,
      'kind': 'level_up',
      'level': n,
      'source': 'level_progression',
    };
String scopeOf(http.Request r) {
  if (r.url.path.endsWith('boss_battles')) return 'bosses';
  if (r.url.path.endsWith('progression_events')) return 'milestones';
  return r.url.queryParameters['status'] == 'eq.set_aside' ? 'aside' : 'quests';
}

http.Response response(Object rows, {int status = 200}) => http.Response(
      jsonEncode(rows),
      status,
      headers: {'content-type': 'application/json'},
    );
PostgrestClient database(Future<http.Response> Function(http.Request) handle,
    {List<int> totals = const [35, 55, 2, 1]}) {
  final client = MockClient((request) async {
    final result = request.url.path.endsWith('/rpc/chronicle_totals')
        ? response({
            'owner_id': 'owner-a',
            'week_start': jsonDecode(request.body)['p_week_start'],
            'total_xp_earned': totals[0].toString(),
            'total_coins_earned': totals[1].toString(),
            'week_wins': totals[2].toString(),
            'bosses_defeated': totals[3].toString(),
          })
        : await handle(request);
    return http.Response.bytes(
      result.bodyBytes,
      result.statusCode,
      headers: result.headers,
      request: request,
    );
  });
  addTearDown(client.close);
  return PostgrestClient('https://fixture.invalid/rest/v1', httpClient: client);
}

Future<ChronicleSnapshot> load(
  Future<http.Response> Function(http.Request) handle, {
  String? Function()? owner,
  List<int> totals = const [35, 55, 2, 1],
}) =>
    QuestwellChronicleService.load(
      database: database(handle, totals: totals),
      currentOwner: owner ?? () => 'owner-a',
      now: now,
    );
List<Map<String, dynamic>> page(
  http.Request r,
  List<Map<String, dynamic>> rows, {
  int cap = 37,
}) {
  final q = r.url.queryParameters;
  expect(q['user_id'], 'eq.owner-a');
  expect(q['order'], 'id.asc.nullslast');
  expect(q.containsKey('offset'), isFalse);
  if (scopeOf(r) != 'milestones') {
    expect(
      q['status'],
      scopeOf(r) == 'aside' ? 'eq.set_aside' : 'eq.completed',
    );
  }
  final cursor = q['id'];
  if (cursor != null) expect(cursor.startsWith('gt.'), isTrue);
  final sorted = rows
      .where(
        (r) =>
            cursor == null ||
            (r['id'] as String).compareTo(cursor.substring(3)) > 0,
      )
      .toList()
    ..sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
  final limit = int.parse(q['limit']!);
  return sorted.take(limit < cap ? limit : cap).toList();
}

void main() {
  test(
    'historical single-page history undercounts XP, coins and victories',
    () async {
      final db = database(
        (r) async => response(
          List.generate(
            scopeOf(r) == 'quests' ? 135 : 127,
            (i) => row(scopeOf(r), i + 1),
          ).take(50).toList(),
        ),
      );
      final quests = await db
          .from('tasks')
          .select()
          .eq('user_id', 'owner-a')
          .eq('status', 'completed')
          .order('completed_at', ascending: false);
      final bosses = await db
          .from('boss_battles')
          .select()
          .eq('user_id', 'owner-a')
          .eq('status', 'completed')
          .order('completed_at', ascending: false);
      final xp = quests.fold<int>(0, (v, r) => v + (r['xp_value'] as int)) +
          bosses.fold<int>(0, (v, r) => v + (r['reward_xp'] as int));
      final coins =
          quests.fold<int>(0, (v, r) => v + (r['coin_value'] as int)) +
              bosses.fold<int>(0, (v, r) => v + (r['reward_coins'] as int));
      expect(xp, 1750);
      expect(xp, isNot(4525));
      expect(coins, 2750);
      expect(coins, isNot(7025));
      expect(bosses, hasLength(50));
    },
  );
  test(
    'all four collections and exact totals survive independent server caps',
    () async {
      const counts = {
        'quests': 135,
        'bosses': 127,
        'milestones': 111,
        'aside': 119,
      };
      const caps = {'quests': 37, 'bosses': 41, 'milestones': 23, 'aside': 17};
      final calls = <String, int>{};
      final data = await load((r) async {
        final scope = scopeOf(r);
        calls[scope] = (calls[scope] ?? 0) + 1;
        return response(
          page(
            r,
            List.generate(counts[scope]!, (i) => row(scope, i + 1)),
            cap: caps[scope]!,
          ),
        );
      }, totals: [4525, 7025, 262, 127]);
      expect(data.wins, hasLength(492));
      expect(data.totalXpEarned, 4525);
      expect(data.totalCoinsEarned, 7025);
      expect(data.weekWins, 262);
      expect(data.bossesDefeated, 127);
      expect(data.wins.any((w) => w.title == 'quests 135'), isTrue);
      expect(data.wins.any((w) => w.title == 'milestones 111'), isTrue);
      expect(data.wins.any((w) => w.title == 'aside 119'), isTrue);
      expect(calls, {'quests': 5, 'bosses': 5, 'milestones': 6, 'aside': 8});
    },
  );
  test(
    'older history counts toward lifetime totals but not this week',
    () async {
      final data = await load(
        (r) async => response(
          page(
            r,
            scopeOf(r) == 'quests'
                ? [
                    row('quests', 1)
                      ..['completed_at'] = now
                          .subtract(const Duration(days: 14))
                          .toUtc()
                          .toIso8601String(),
                    row('quests', 2),
                  ]
                : [],
          ),
        ),
        totals: [20, 10, 1, 0],
      );
      expect(data.totalXpEarned, 20);
      expect(data.totalCoinsEarned, 10);
      expect(data.weekWins, 1);
      expect(data.wins.first.taskId, id(2));
    },
  );
  test('empty history gives zero totals', () async {
    final data = await load((_) async => response([]), totals: [0, 0, 0, 0]);
    expect(data.wins, isEmpty);
    expect(data.totalXpEarned, 0);
    expect(data.totalCoinsEarned, 0);
    expect(data.weekWins, 0);
    expect(data.bossesDefeated, 0);
  });
  test('signed out makes no request', () async {
    await expectLater(
      load((_) async => throw StateError('unexpected'), owner: () => null),
      throwsStateError,
    );
  });
  test('deleting a prior page does not skip later history', () async {
    final rows = List.generate(80, (i) => row('quests', i + 1));
    var calls = 0;
    final data = await load((r) async {
      if (scopeOf(r) != 'quests') return response([]);
      if (++calls == 2) rows.removeAt(0);
      return response(page(r, rows));
    }, totals: [790, 395, 79, 0]);
    expect(data.wins, hasLength(80));
    expect(data.totalXpEarned, 790);
  });
  for (final scope in scopes) {
    test('account change during $scope discards whole snapshot', () async {
      var owner = 'owner-a';
      await expectLater(
        load((r) async {
          if (scopeOf(r) == scope) owner = 'owner-b';
          return response([]);
        }, owner: () => owner),
        throwsStateError,
      );
    });
    for (final bad in ['owner', 'id', 'duplicate', 'order', 'date']) {
      test('$scope rejects $bad instead of returning partial totals', () async {
        var calls = 0;
        await expectLater(
          load((r) async {
            if (scopeOf(r) != scope) return response([]);
            if (++calls == 1) return response([row(scope, 2)]);
            if (calls > 2) return response([]);
            final item = row(scope, 3);
            switch (bad) {
              case 'owner':
                item['user_id'] = 'owner-b';
                break;
              case 'id':
                item['id'] = 'invalid,cursor';
                break;
              case 'duplicate':
                item['id'] = id(2);
                break;
              case 'order':
                item['id'] = id(1);
                break;
              case 'date':
                item['created_at'] = null;
                item['completed_at'] = null;
                item['occurred_at'] = null;
                break;
            }
            return response([item]);
          }),
          throwsStateError,
        );
      });
    }
    test(
      '$scope later-page failure never returns partial totals; retry recovers',
      () async {
        var fail = true;
        final db = database((r) async {
          if (scopeOf(r) == scope &&
              r.url.queryParameters.containsKey('id') &&
              fail) {
            return response({
              'message': 'fixture failure',
              'code': 'fixture',
            }, status: 503);
          }
          return response(page(r, [row(scopeOf(r), 1)]));
        });
        Future<ChronicleSnapshot> request() => QuestwellChronicleService.load(
              database: db,
              currentOwner: () => 'owner-a',
              now: now,
            );
        await expectLater(request(), throwsA(isA<PostgrestException>()));
        fail = false;
        final data = await request();
        expect(data.wins, hasLength(4));
        expect(data.totalXpEarned, 35);
        expect(data.totalCoinsEarned, 55);
      },
    );
  }
}
