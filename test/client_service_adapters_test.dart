import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:project_momentum/backend/supabase/questwell_network.dart';
import 'package:project_momentum/backend/supabase/supabase.dart';
import 'package:project_momentum/services/questwell_account_service.dart';
import 'package:project_momentum/services/questwell_boss_service.dart';
import 'package:project_momentum/services/questwell_cosmetic_service.dart';
import 'package:project_momentum/services/questwell_task_creation.dart';
import 'package:project_momentum/services/questwell_task_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Real service adapters and pinned SDK; only the HTTP boundary is substituted.
// No live endpoint, credentials, users, or deletion requests are used.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const owner = '11111111-1111-4111-8111-111111111111';
  const other = '22222222-2222-4222-8222-222222222222';
  final requests = <http.Request>[];
  late Future<http.Response> Function(http.Request) respond;

  http.Response json(Object? data, {int status = 200}) => http.Response(
        jsonEncode(data),
        status,
        headers: {'content-type': 'application/json'},
      );
  Map<String, dynamic> body(http.Request request) =>
      jsonDecode(request.body) as Map<String, dynamic>;
  Future<void> session(String uid) async {
    final expiry =
        DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
            1000;
    final payload = base64Url
        .encode(utf8.encode(jsonEncode({'sub': uid, 'exp': expiry})))
        .replaceAll('=', '');
    await SupaFlow.client.auth.recoverSession(jsonEncode({
      'access_token': 'eyJhbGciOiJub25lIn0.$payload.synthetic',
      'refresh_token': 'synthetic-refresh',
      'token_type': 'bearer',
      'expires_in': 3600,
      'expires_at': expiry,
      'user': {
        'id': uid,
        'aud': 'authenticated',
        'role': 'authenticated',
        'email': 'adapter@example.invalid',
        'app_metadata': {},
        'user_metadata': {},
        'created_at': '2026-01-01T00:00:00Z'
      },
    }));
  }

  Future<void> signOut() async {
    respond = (_) async => json({});
    await SupaFlow.client.auth.signOut(scope: SignOutScope.local);
    requests.clear();
    respond = (request) async =>
        throw StateError('Unexpected request: ${request.url}');
  }

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://adapter.example.invalid',
      anonKey: 'synthetic-public-key',
      debug: false,
      httpClient: MockClient((request) async {
        expect(request.url.host, 'adapter.example.invalid');
        requests.add(request);
        final response = await respond(request);
        return http.Response.bytes(response.bodyBytes, response.statusCode,
            headers: response.headers, request: request);
      }),
      authOptions: FlutterAuthClientOptions(
        autoRefreshToken: false,
        detectSessionInUri: false,
        localStorage: EmptyLocalStorage(),
      ),
    );
  });
  tearDownAll(() => Supabase.instance.dispose());
  setUp(() async {
    requests.clear();
    respond = (request) async =>
        throw StateError('Unexpected request: ${request.url}');
    await session(owner);
  });

  group('account deletion adapter', () {
    test('signed out deletion never sends a request', () async {
      await signOut();
      await expectLater(
          QuestwellAccountService.deleteAccount(), throwsStateError);
      expect(requests, isEmpty);
    });
    test('requires explicit server confirmation and leaves cleanup to caller',
        () async {
      respond = (_) async => json({'deleted': true});
      await QuestwellAccountService.deleteAccount();
      expect(requests.single.url.path, '/functions/v1/delete-account');
      expect(requests.single.method.toUpperCase(), 'POST');
      expect(body(requests.single), {'confirmation': 'DELETE'});
      expect(requests.single.headers['authorization'],
          contains(SupaFlow.client.auth.currentSession!.accessToken));
      expect(SupaFlow.client.auth.currentUser!.id, owner);
    });
    for (final data in <Object?>[
      null,
      [],
      {},
      {'deleted': false},
      {'deleted': 'true'}
    ]) {
      test('unconfirmed response $data keeps the session', () async {
        respond = (_) async => json(data);
        await expectLater(
            QuestwellAccountService.deleteAccount(), throwsStateError);
        expect(requests, hasLength(1));
        expect(SupaFlow.client.auth.currentUser!.id, owner);
      });
    }
    test('non-200 success status is not deletion confirmation', () async {
      respond = (_) async => json({'deleted': true}, status: 202);
      await expectLater(
          QuestwellAccountService.deleteAccount(), throwsStateError);
      expect(requests, hasLength(1));
    });
    test(
        'partial cleanup failure propagates without automatic retry or signout',
        () async {
      respond =
          (_) async => json({'error': 'storage_cleanup_failed'}, status: 500);
      await expectLater(QuestwellAccountService.deleteAccount(),
          throwsA(isA<FunctionException>()));
      expect(requests, hasLength(1));
      expect(SupaFlow.client.auth.currentUser!.id, owner);
    });
    test('lost response is unconfirmed and never resends deletion', () async {
      respond =
          (_) async => throw const SocketException('synthetic disconnect');
      await expectLater(QuestwellAccountService.deleteAccount(),
          throwsA(isA<QuestwellNetworkException>()));
      expect(requests, hasLength(1));
      expect(SupaFlow.client.auth.currentUser!.id, owner);
    });
    test(
        'local cleanup signs out locally and removes only this owner drafts and favorites',
        () async {
      SharedPreferences.setMockInitialValues({
        'questwell_favorite_quests_$owner': ['quest'],
        'questwell_feedback_draft_$owner': 'private draft',
        'questwell_favorite_quests_$other': ['other quest'],
        'questwell_feedback_draft_$other': 'other draft',
        'theme': 'dark',
      });
      respond = (_) async => json({});
      await QuestwellAccountService.clearLocalAccount();
      expect(SupaFlow.client.auth.currentSession, isNull);
      expect(requests.single.url.path, '/auth/v1/logout');
      expect(requests.single.url.queryParameters['scope'], 'local');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('questwell_favorite_quests_$owner'), isFalse);
      expect(prefs.containsKey('questwell_feedback_draft_$owner'), isFalse);
      expect(prefs.getStringList('questwell_favorite_quests_$other'),
          ['other quest']);
      expect(prefs.getString('questwell_feedback_draft_$other'), 'other draft');
      expect(prefs.getString('theme'), 'dark');
    });
    test('cleanup without a session preserves unrelated local data', () async {
      await signOut();
      SharedPreferences.setMockInitialValues({'theme': 'dark'});
      await QuestwellAccountService.clearLocalAccount();
      expect(requests, isEmpty);
      expect(
          (await SharedPreferences.getInstance()).getString('theme'), 'dark');
    });
  });

  group('reward completion adapters', () {
    for (final boss in [false, true]) {
      final label = boss ? 'boss step' : 'quest';
      Future<dynamic> complete() => boss
          ? QuestwellBossService.completeStep('step-id')
          : QuestwellTaskService.completeTask('quest-id');
      test('$label uses server reward totals and sends only the entity id',
          () async {
        respond = (_) async => json([
              {
                'task_id': 'quest-id',
                'boss_completed': true,
                'xp_awarded': 13,
                'coins_awarded': 7,
                'total_xp': 213,
                'coin_balance': 87
              }
            ]);
        final result = await complete();
        expect(result.xpAwarded, 13);
        expect(result.coinsAwarded, 7);
        expect(result.totalXp, 213);
        expect(result.coinBalance, 87);
        if (boss) {
          expect(result.bossCompleted, isTrue);
        } else {
          expect(result.taskId, 'quest-id');
        }
        expect(requests.single.url.path,
            '/rest/v1/rpc/${boss ? 'complete_boss_step' : 'complete_task'}');
        expect(requests.single.method.toUpperCase(), 'POST');
        expect(body(requests.single),
            boss ? {'p_step_id': 'step-id'} : {'p_task_id': 'quest-id'});
      });
      test('$label repeated completion respects zero server award', () async {
        respond = (_) async => json([
              {
                'task_id': 'quest-id',
                'boss_completed': false,
                'xp_awarded': 0,
                'coins_awarded': 0,
                'total_xp': 213,
                'coin_balance': 87
              }
            ]);
        final result = await complete();
        expect(result.xpAwarded, 0);
        expect(result.coinsAwarded, 0);
        expect(result.coinBalance, 87);
        if (boss) expect(result.bossCompleted, isFalse);
        expect(requests, hasLength(1));
      });
      for (final response in <Object?>[[], {}]) {
        test('$label rejects missing result $response', () async {
          respond = (_) async => json(response);
          await expectLater(complete(), throwsStateError);
          expect(requests, hasLength(1));
        });
      }
      test('$label propagates authorization failure without retry', () async {
        respond = (_) async =>
            json({'code': '42501', 'message': 'Not owner'}, status: 403);
        await expectLater(complete(), throwsA(isA<PostgrestException>()));
        expect(requests, hasLength(1));
      });
      test('$label lost response is not automatically repeated', () async {
        respond =
            (_) async => throw const SocketException('synthetic disconnect');
        await expectLater(
            complete(), throwsA(isA<QuestwellNetworkException>()));
        expect(requests, hasLength(1));
      });
    }
    test('quest creation explicit retry preserves receipt and original owner',
        () async {
      respond = (_) async => throw const SocketException('lost response');
      final draft = QuestwellTaskService.newCreation();
      await expectLater(
          draft.save('  Read  ', 2), throwsA(isA<QuestwellNetworkException>()));
      final first = body(requests.single);
      respond = (_) async => json('created-quest');
      expect(await draft.save('Read', 2), 'created-quest');
      expect(requests, hasLength(2));
      expect(body(requests.last), first);
      expect(first, {
        'p_request_id': draft.requestId,
        'p_expected_user_id': owner,
        'p_title': 'Read',
        'p_friction': 2
      });
      expect(requests.last.url.path, '/rest/v1/rpc/create_task_once');
      expect(await draft.save('Read', 2), 'created-quest');
      expect(requests, hasLength(2));
      await session(other);
      await expectLater(draft.save('Read', 2),
          throwsA(isA<QuestwellCreationAccountChanged>()));
      expect(requests, hasLength(2));
    });
    test('quest creation rejects malformed server acknowledgement', () async {
      for (final value in <Object>['', {}]) {
        respond = (_) async => json(value);
        await expectLater(QuestwellTaskService.newCreation().save('Read', 2),
            throwsStateError);
      }
      expect(requests, hasLength(2));
    });
    test('boss creation explicit retry uses the same receipt and payload',
        () async {
      Future<String> create() => QuestwellBossService.createBattle(
          title: 'Adapter retry',
          steps: ['First', 'Second'],
          expectedOwnerId: owner,
          requestId: 'boss-retry');
      respond = (_) async => throw const SocketException('lost response');
      await expectLater(create(), throwsA(isA<QuestwellNetworkException>()));
      final first = body(requests.single);
      respond = (_) async => json('created-boss');
      expect(await create(), 'created-boss');
      expect(body(requests.last), first);
      expect(first, {
        'p_request_id': 'boss-retry',
        'p_expected_user_id': owner,
        'p_title': 'Adapter retry',
        'p_steps': ['First', 'Second'],
        'p_boss_type': 'inbox_hydra'
      });
      expect(requests.last.url.path, '/rest/v1/rpc/create_boss_once');
      expect(await create(), 'created-boss');
      expect(requests, hasLength(2));
    });
    test('boss creation rejects signed-out or mismatched owner before sending',
        () async {
      await expectLater(
          QuestwellBossService.createBattle(
              title: 'Wrong owner', steps: ['Step'], expectedOwnerId: other),
          throwsStateError);
      await signOut();
      await expectLater(
          QuestwellBossService.createBattle(
              title: 'Signed out', steps: ['Step']),
          throwsStateError);
      expect(requests, isEmpty);
    });
    test('boss acknowledgement arriving after account switch is discarded',
        () async {
      respond = (_) async {
        await session(other);
        return json('old-owner-boss');
      };
      await expectLater(
          QuestwellBossService.createBattle(
              title: 'Switch pending',
              steps: ['Step'],
              requestId: 'boss-switch'),
          throwsStateError);
      expect(requests, hasLength(1));
    });
    test('boss creation rejects malformed acknowledgement', () async {
      respond = (_) async => json({});
      await expectLater(
          QuestwellBossService.createBattle(
              title: 'Malformed', steps: ['Step'], requestId: 'boss-malformed'),
          throwsA(isA<QuestwellNetworkException>()));
      expect(requests, hasLength(1));
    });
  });

  group('purchase adapter', () {
    test('uses server balance, sends one purchase and notifies after success',
        () async {
      var notifications = 0;
      void listener() => notifications++;
      QuestwellCosmeticService.changes.addListener(listener);
      addTearDown(
          () => QuestwellCosmeticService.changes.removeListener(listener));
      respond = (_) async => json([
            {'remaining_coins': 35}
          ]);
      expect(await QuestwellCosmeticService.purchase('cosmetic-id'), 35);
      expect(requests.single.url.path, '/rest/v1/rpc/purchase_cosmetic');
      expect(body(requests.single), {'p_cosmetic_id': 'cosmetic-id'});
      expect(notifications, 1);
    });
    test('signed out purchase never sends or reconciles', () async {
      await signOut();
      await expectLater(
          QuestwellCosmeticService.purchase('item'), throwsStateError);
      expect(requests, isEmpty);
    });
    test(
        'lost response confirms owner-scoped ownership then current balance without resending',
        () async {
      respond = (request) async {
        switch (request.url.path) {
          case '/rest/v1/rpc/purchase_cosmetic':
            throw const SocketException('lost response');
          case '/rest/v1/user_cosmetics':
            expect(request.url.queryParameters['user_id'], 'eq.$owner');
            expect(request.url.queryParameters['cosmetic_id'], 'eq.item');
            return json([
              {'cosmetic_id': 'item'}
            ]);
          case '/rest/v1/users':
            expect(requests.last.url.path, '/rest/v1/users');
            expect(requests[requests.length - 2].url.path,
                '/rest/v1/user_cosmetics');
            expect(request.url.queryParameters['id'], 'eq.$owner');
            return json({'coin_balance': 35});
          default:
            throw StateError('Unexpected request');
        }
      };
      expect(await QuestwellCosmeticService.purchase('item'), 35);
      expect(requests.map((r) => r.method), ['POST', 'GET', 'GET']);
    });
    test('unowned after failure retains error and never reads balance',
        () async {
      var notifications = 0;
      void listener() => notifications++;
      QuestwellCosmeticService.changes.addListener(listener);
      addTearDown(
          () => QuestwellCosmeticService.changes.removeListener(listener));
      respond = (request) async => request.method == 'POST'
          ? json({'code': 'P0001', 'message': 'Insufficient coins'},
              status: 400)
          : json([]);
      await expectLater(
          QuestwellCosmeticService.purchase('item'),
          throwsA(isA<PostgrestException>()
              .having((e) => e.message, 'message', 'Insufficient coins')));
      expect(requests.map((r) => r.url.path),
          ['/rest/v1/rpc/purchase_cosmetic', '/rest/v1/user_cosmetics']);
      expect(notifications, 0);
      // A failed transaction must not poison the local write queue.
      respond = (_) async => json([
            {'remaining_coins': 30}
          ]);
      expect(await QuestwellCosmeticService.purchase('next-item'), 30);
      expect(notifications, 1);
    });
    for (final data in <Object?>[
      [],
      {},
      [
        {'remaining_coins': '35'}
      ]
    ]) {
      test(
          'malformed purchase $data requires reconciliation and cannot fabricate balance',
          () async {
        respond = (r) async => json(r.method == 'POST' ? data : []);
        await expectLater(
            QuestwellCosmeticService.purchase('item'), throwsStateError);
        expect(requests.where((r) => r.method == 'POST'), hasLength(1));
        expect(requests, hasLength(2));
      });
    }
    test(
        'failed reconciliation retains original error and does not retry write',
        () async {
      respond = (r) async {
        if (r.method == 'POST')
          return json({'code': 'P0001', 'message': 'Original failure'},
              status: 400);
        throw const SocketException('offline reconciliation');
      };
      await expectLater(
          QuestwellCosmeticService.purchase('item'),
          throwsA(isA<PostgrestException>()
              .having((e) => e.message, 'original error', 'Original failure')));
      expect(requests.where((r) => r.method == 'POST'), hasLength(1));
      expect(requests.where((r) => r.method == 'GET'), hasLength(2));
    });
    test('account switch while response pending cannot claim purchase',
        () async {
      respond = (_) async {
        await session(other);
        return json([
          {'remaining_coins': 35}
        ]);
      };
      await expectLater(
          QuestwellCosmeticService.purchase('item'), throwsStateError);
      expect(requests, hasLength(1));
    });
    test('account switch during ownership confirmation prevents balance read',
        () async {
      respond = (r) async {
        if (r.method == 'POST') throw const SocketException('lost response');
        await session(other);
        return json([
          {'cosmetic_id': 'item'}
        ]);
      };
      await expectLater(QuestwellCosmeticService.purchase('item'),
          throwsA(isA<QuestwellNetworkException>()));
      expect(requests, hasLength(2));
    });
    test('account switch during balance read discards old-owner balance',
        () async {
      respond = (r) async {
        if (r.method == 'POST') throw const SocketException('lost response');
        if (r.url.path.endsWith('/user_cosmetics'))
          return json([
            {'cosmetic_id': 'item'}
          ]);
        await session(other);
        return json({'coin_balance': 35});
      };
      await expectLater(QuestwellCosmeticService.purchase('item'),
          throwsA(isA<QuestwellNetworkException>()));
      expect(requests, hasLength(3));
    });
    test('queued purchase cannot send after account changes', () async {
      final entered = Completer<void>();
      final reply = Completer<http.Response>();
      respond = (_) {
        entered.complete();
        return reply.future;
      };
      final first = QuestwellCosmeticService.purchase('first');
      final firstCheck = expectLater(first, throwsStateError);
      await entered.future;
      final second = QuestwellCosmeticService.purchase('second');
      final secondCheck = expectLater(second, throwsStateError);
      await session(other);
      reply.complete(json([
        {'remaining_coins': 35}
      ]));
      await Future.wait([firstCheck, secondCheck]);
      expect(requests, hasLength(1));
    });
  });
}
