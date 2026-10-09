import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:postgrest/postgrest.dart';
import 'package:project_momentum/services/questwell_boss_list.dart';

String id(int n) => '00000000-0000-4000-8000-${n.toString().padLeft(12, '0')}';
Map<String, dynamic> battle(int n) => {
      'id': id(n),
      'user_id': 'owner-a',
      'title': 'Boss $n',
      'status': 'open',
      'created_at': '2026-01-01T00:00:00.000001+00:00',
      'reward_xp': 25,
      'reward_coins': 50,
      'boss_type': 'inbox_hydra',
    };
Map<String, dynamic> step(int n, int boss, int position) => {
      'id': id(n),
      'user_id': 'owner-a',
      'boss_id': id(boss),
      'title': 'Step $n',
      'position': position,
      'completed': position == 1,
    };
http.Response response(Object rows, {int status = 200}) => http.Response(
      jsonEncode(rows),
      status,
      headers: {'content-type': 'application/json'},
    );
PostgrestClient database(Future<http.Response> Function(http.Request) handle) {
  final client = MockClient((request) async {
    final result = await handle(request);
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

QuestwellBossList loader(
  Future<http.Response> Function(http.Request) handle, {
  String? Function()? owner,
}) =>
    QuestwellBossList(
      database: database(handle),
      currentOwner: owner ?? () => 'owner-a',
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
  final cursor = q['id'];
  if (cursor != null) expect(cursor.startsWith('gt.'), isTrue);
  final sorted = rows
      .where(
        (row) =>
            cursor == null ||
            (row['id'] as String).compareTo(cursor.substring(3)) > 0,
      )
      .toList()
    ..sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
  final limit = int.parse(q['limit']!);
  return sorted.take(limit < cap ? limit : cap).toList();
}

void main() {
  test('both collections start together and publish only when complete',
      () async {
    final started = <String>{};
    final bothStarted = Completer<void>();
    final battlesReady = Completer<http.Response>();
    final stepsReady = Completer<http.Response>();
    final battlesFinished = Completer<void>();
    var completed = false;
    final result = loader((r) async {
      final table = r.url.path.split('/').last;
      if (r.url.queryParameters.containsKey('id')) {
        if (table == 'boss_battles') battlesFinished.complete();
        return response([]);
      }
      started.add(table);
      if (started.length == 2) bothStarted.complete();
      return table == 'boss_battles' ? battlesReady.future : stepsReady.future;
    }).load().then((value) {
      completed = true;
      return value;
    });

    await bothStarted.future.timeout(const Duration(seconds: 2));
    expect(started, {'boss_battles', 'boss_steps'});
    battlesReady.complete(response([battle(1)]));
    await battlesFinished.future;
    expect(completed, isFalse);
    stepsReady.complete(response([step(1, 1, 0)]));
    final bosses = await result;
    expect(bosses.single.id, id(1));
    expect(bosses.single.steps.single.id, id(1));
  });

  for (final failedTable in ['boss_battles', 'boss_steps']) {
    test('$failedTable failure surfaces while the other collection is pending',
        () async {
      final bothStarted = Completer<void>();
      final pending = Completer<http.Response>();
      var started = 0;
      final service = loader((r) async {
        if (++started == 2) bothStarted.complete();
        await bothStarted.future;
        if (r.url.path.endsWith(failedTable)) {
          return response({'message': 'fixture failure', 'code': 'fixture'},
              status: 503);
        }
        return pending.future;
      });
      await expectLater(
        service.load().timeout(const Duration(seconds: 2)),
        throwsA(isA<PostgrestException>()),
      );
      expect(pending.isCompleted, isFalse);
      // A late failure is still observed by the combined future, never emitted
      // as an unhandled error after the first failure reached the caller.
      pending.complete(response(
          {'message': 'late fixture failure', 'code': 'fixture'},
          status: 503));
      await Future<void>.delayed(Duration.zero);
    });
  }

  test('historical queries truncate battles and steps independently', () async {
    final db = database(
      (r) async => response(
        r.url.path.endsWith('boss_battles')
            ? List.generate(135, (i) => battle(i + 1)).take(100).toList()
            : List.generate(
                2700,
                (i) => step(i + 1, i ~/ 20 + 1, i % 20),
              ).take(1000).toList(),
      ),
    );
    final bosses = await db
        .from('boss_battles')
        .select()
        .eq('user_id', 'owner-a')
        .order('created_at', ascending: true);
    final steps = await db
        .from('boss_steps')
        .select()
        .eq('user_id', 'owner-a')
        .order('position', ascending: true);
    expect(bosses, hasLength(100));
    expect(steps, hasLength(1000));
    expect(bosses.any((b) => b['id'] == id(135)), isFalse);
    expect(steps.any((s) => s['boss_id'] == id(135)), isFalse);
  });
  test(
    'loads 135 bosses and 2700 steps through independent server caps',
    () async {
      final bosses = List.generate(135, (i) => battle(i + 1));
      final steps = List.generate(
        2700,
        (i) => step(i + 1, i ~/ 20 + 1, 19 - i % 20),
      );
      final calls = <String, int>{};
      final result = await loader((r) async {
        final table = r.url.path.split('/').last;
        calls[table] = (calls[table] ?? 0) + 1;
        return response(
          page(
            r,
            table == 'boss_battles' ? bosses : steps,
            cap: table == 'boss_battles' ? 37 : 61,
          ),
        );
      }).load();
      expect(result, hasLength(135));
      expect(result.map((b) => b.id).toSet(), hasLength(135));
      expect(result.last.id, id(135));
      for (final boss in result) {
        expect(boss.steps, hasLength(20));
        expect(boss.steps.map((s) => s.position), List.generate(20, (i) => i));
        expect(boss.completedSteps, 1);
      }
      expect(calls, {'boss_battles': 5, 'boss_steps': 46});
    },
  );
  test(
    'presentation keeps chronological microseconds, then UUID ties',
    () async {
      final bosses = [
        battle(1)..['created_at'] = '2026-01-01T00:00:00.000002Z',
        battle(2),
        battle(3),
      ];
      final result = await loader(
        (r) async => response(
          page(r, r.url.path.endsWith('boss_battles') ? bosses : [], cap: 1),
        ),
      ).load();
      expect(result.map((b) => b.id), [id(2), id(3), id(1)]);
    },
  );
  test(
    'deleting rows behind the cursor does not skip remaining bosses',
    () async {
      final bosses = List.generate(80, (i) => battle(i + 1));
      var calls = 0;
      final result = await loader((r) async {
        if (!r.url.path.endsWith('boss_battles')) return response([]);
        if (++calls == 2) bosses.removeAt(0);
        return response(page(r, bosses));
      }).load();
      expect(result.map((b) => b.id), List.generate(80, (i) => id(i + 1)));
    },
  );
  test('signed out fails without requests', () async {
    await expectLater(
      loader(
        (_) async => throw StateError('unexpected'),
        owner: () => null,
      ).load(),
      throwsStateError,
    );
  });
  test('empty account returns no bosses', () async {
    expect(await loader((_) async => response([])).load(), isEmpty);
  });
  for (final table in ['boss_battles', 'boss_steps']) {
    test('account switch during $table discards whole result', () async {
      var owner = 'owner-a';
      await expectLater(
        loader((r) async {
          if (r.url.path.endsWith(table)) owner = 'owner-b';
          return response(
            page(r, r.url.path.endsWith('boss_battles') ? [battle(1)] : []),
          );
        }, owner: () => owner).load(),
        throwsStateError,
      );
    });
    for (final bad in ['owner', 'id', 'duplicate', 'order']) {
      test('$table rejects $bad instead of returning partial data', () async {
        var calls = 0;
        await expectLater(
          loader((r) async {
            if (!r.url.path.endsWith(table)) return response([]);
            final row = table == 'boss_battles' ? battle(2) : step(2, 1, 0);
            if (++calls == 1) return response([row]);
            switch (bad) {
              case 'owner':
                row['user_id'] = 'owner-b';
                break;
              case 'id':
                row['id'] = 'invalid,cursor';
                break;
              case 'duplicate':
                return response([row]);
              case 'order':
                row['id'] = id(1);
                break;
            }
            return response([row]);
          }).load(),
          throwsStateError,
        );
      });
    }
    test('$table later-page error fails load; retry starts fresh', () async {
      var fail = true;
      final service = loader((r) async {
        if (r.url.path.endsWith(table) &&
            r.url.queryParameters.containsKey('id') &&
            fail) {
          return response({
            'message': 'fixture failure',
            'code': 'fixture',
          }, status: 503);
        }
        return response(
          page(
            r,
            r.url.path.endsWith('boss_battles') ? [battle(1)] : [step(1, 1, 0)],
          ),
        );
      });
      await expectLater(service.load(), throwsA(isA<PostgrestException>()));
      fail = false;
      expect((await service.load()).single.steps, hasLength(1));
    });
  }
}
