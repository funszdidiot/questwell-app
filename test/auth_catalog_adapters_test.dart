import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/pages/market_page/market_page_widget.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:project_momentum/backend/supabase/supabase.dart';
import 'package:project_momentum/services/questwell_auth_service.dart';
import 'package:project_momentum/auth/questwell_auth_callback.dart';
import 'package:project_momentum/auth/supabase_auth/supabase_user_provider.dart';
import 'package:project_momentum/flutter_flow/nav/nav.dart';
import 'package:project_momentum/services/questwell_onboarding_session.dart';
import 'package:project_momentum/services/questwell_boss_service.dart';
import 'package:project_momentum/services/questwell_cosmetic_service.dart';
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
    QuestwellAuthCallback.clear();
    currentUser = null;
    AppStateNotifier.instance.user = null;
    AppStateNotifier.instance.initialUser = null;
  });

  group('real auth adapter', () {
    final auth = QuestwellAuthService();
    const email = 'adapter@example.invalid';
    const password = 'Synthetic-password-123';
    for (final signup in [false, true]) {
      test(
          '${signup ? 'signup' : 'signin'} accepts SDK session and updates routing identity',
          () async {
        final data = SupaFlow.client.auth.currentSession!.toJson();
        await signOut();
        expect(auth.hasSession, isFalse);
        respond = (_) async => json(data);
        expect(
            await (signup
                ? auth.signUp(email, password)
                : auth.signIn(email, password)),
            isTrue);
        expect(auth.hasSession, isTrue);
        expect(currentUser!.uid, owner);
        expect(AppStateNotifier.instance.user!.uid, owner);
        final request = requests.single;
        expect(request.url.path, signup ? '/auth/v1/signup' : '/auth/v1/token');
        expect(body(request)['email'], email);
        expect(body(request)['password'], password);
        if (signup) {
          expect(request.url.queryParameters['redirect_to'],
              QuestwellAuthCallback.appUrl);
        } else {
          expect(request.url.queryParameters['grant_type'], 'password');
        }
      });
      test(
          '${signup ? 'signup' : 'signin'} server rejection neither authenticates nor retries',
          () async {
        await signOut();
        respond = (_) async => json({'msg': 'Synthetic denial'}, status: 400);
        await expectLater(
            signup
                ? auth.signUp(email, password)
                : auth.signIn(email, password),
            throwsA(isA<AuthException>()));
        expect(auth.hasSession, isFalse);
        expect(currentUser, isNull);
        expect(AppStateNotifier.instance.loggedIn, isFalse);
        expect(requests, hasLength(1));
      });
    }
    test(
        'confirmation-required signup stays signed out without client profile write',
        () async {
      final user = SupaFlow.client.auth.currentUser!.toJson();
      await signOut();
      respond = (_) async => json(user);
      expect(await auth.signUp(email, password), isFalse);
      expect(auth.hasSession, isFalse);
      expect(currentUser, isNull);
      expect(AppStateNotifier.instance.loggedIn, isFalse);
      expect(requests.single.url.path, '/auth/v1/signup');
    });
    test('reset request uses the recovery callback and does not sign in',
        () async {
      await signOut();
      respond = (_) async => json({});
      await auth.sendReset(email);
      expect(requests.single.url.path, '/auth/v1/recover');
      expect(body(requests.single)['email'], email);
      expect(requests.single.url.queryParameters['redirect_to'],
          QuestwellAuthCallback.recoveryUrl);
      expect(auth.hasSession, isFalse);
    });
    test('reset throttling propagates without a second email request',
        () async {
      respond = (_) async => json({'msg': 'Try later'}, status: 429);
      await expectLater(auth.sendReset(email), throwsA(isA<AuthException>()));
      expect(requests, hasLength(1));
    });
    test('password update sends only password through the current session',
        () async {
      respond = (_) async => json(SupaFlow.client.auth.currentUser!.toJson());
      await auth.savePassword(password);
      expect(requests.single.url.path, '/auth/v1/user');
      expect(requests.single.method.toUpperCase(), 'PUT');
      expect(body(requests.single), {'password': password});
      expect(SupaFlow.client.auth.currentUser!.id, owner);
    });
    test('expired callback blocks password update despite a session', () async {
      QuestwellAuthCallback.linkFailed = true;
      await expectLater(
          auth.savePassword(password), throwsA(isA<AuthException>()));
      expect(requests, isEmpty);
    });
    test('signed-out password update is rejected before transport', () async {
      await signOut();
      await expectLater(
          auth.savePassword(password), throwsA(isA<AuthException>()));
      expect(requests, isEmpty);
    });
    test('password update rejection is not success or an automatic retry',
        () async {
      respond = (_) async => json({'msg': 'Password rejected'}, status: 422);
      await expectLater(
          auth.savePassword(password), throwsA(isA<AuthException>()));
      expect(requests, hasLength(1));
    });
    test(
        'browser auth transport failure preserves SDK retryable error without replay',
        () async {
      await signOut();
      respond = (_) async => throw http.ClientException('Failed to fetch');
      await expectLater(auth.signIn(email, password),
          throwsA(isA<AuthRetryableFetchException>()));
      expect(requests, hasLength(1));
      expect(auth.hasSession, isFalse);
    });
  });

  Map<String, Object?> catalogRow(String id, String slug) => {
        'id': id,
        'slug': slug,
        'name': 'Synthetic item',
        'category': 'decor',
        'price': 25,
        'hearth_profile_key': 'wall',
      };
  Future<http.Response> catalog(http.Request request) async {
    switch (request.url.path) {
      case '/rest/v1/users':
        return json({
          'level': 7,
          'total_xp': 240,
          'coin_balance': 120,
          'current_energy_mode': 'campfire',
          'onboarding_completed': true,
          'adventurer_archetype': 'scout',
          'avatar_body_type': 'neutral'
        });
      case '/rest/v1/cosmetics':
        return json([
          catalogRow('owned', 'fern-study'),
          catalogRow('unowned', 'celestial-study'),
          catalogRow('retired', 'pathfinder-boots'),
        ]);
      case '/rest/v1/user_cosmetics':
        return json([
          {
            'cosmetic_id': 'owned',
            'equipped': true,
            'room_slot': 'wall-left',
            'unlocked_at': '2026-01-01T00:00:00Z',
            'source': 'purchase'
          },
          {'cosmetic_id': 'retired', 'equipped': false},
          {
            'cosmetic_id': 'inactive-rug',
            'equipped': true,
            'room_slot': 'floor'
          },
          {
            'cosmetic_id': 'unequipped-old',
            'equipped': false,
            'room_slot': 'left'
          },
          {'cosmetic_id': 'non-room', 'equipped': true, 'room_slot': null},
        ]);
      case '/rest/v1/hearth_profile_slots':
        return json([
          {
            'profile_key': 'wall',
            'slot_key': 'right',
            'placement_label': 'Right',
            'sort_order': 2
          },
          {
            'profile_key': 'wall',
            'slot_key': 'left',
            'placement_label': 'Left',
            'sort_order': 1
          },
          {'profile_key': ''},
          {},
        ]);
      case '/rest/v1/hearth_render_registry':
        return json([
          {
            'cosmetic_id': 'owned',
            'render_kind': 'static_sprite',
            'asset_source': 'bundle',
            'asset_path': 'synthetic.png',
            'canvas_width': 32,
            'canvas_height': 64,
            'visible_base': 0.8
          },
          {'cosmetic_id': ''},
          {},
        ]);
      default:
        throw StateError('Unexpected request: ${request.url}');
    }
  }

  QuestwellCosmetic item({bool owned = true, String slug = 'fern-study'}) =>
      QuestwellCosmetic.fromJson(catalogRow('owned', slug),
          owned: owned, equipped: false);

  testWidgets('Market replaces a hidden saved rug only after confirmation',
      (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var placed = false;
    respond = (request) async {
      switch (request.url.path) {
        case '/rest/v1/cosmetics':
          return json([
            {
              ...catalogRow('moonweb', 'moonweb-rug'),
              'name': 'Moonweb Rug',
              'category': 'room',
              'hearth_profile_key': 'floor_rug',
              'price': 60,
            }
          ]);
        case '/rest/v1/user_cosmetics':
          return json([
            {
              'cosmetic_id': 'moonweb',
              'equipped': placed,
              'room_slot': placed ? 'floor' : null
            },
            {
              'cosmetic_id': 'hidden-emerald',
              'equipped': !placed,
              'room_slot': placed ? null : 'floor'
            },
          ]);
        case '/rest/v1/hearth_profile_slots':
          return json([
            {
              'profile_key': 'floor_rug',
              'slot_key': 'floor',
              'placement_label': 'Beneath the adventurer',
              'sort_order': 10
            }
          ]);
        case '/rest/v1/hearth_render_registry':
          return json([]);
        case '/rest/v1/rpc/place_hearth_cosmetic':
          expect(body(request), {
            'p_cosmetic_id': 'moonweb',
            'p_slot': 'floor',
            'p_expected_occupant': 'hidden-emerald',
          });
          placed = true;
          return http.Response('', 204);
        default:
          return catalog(request);
      }
    };
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: const MarketPageWidget(),
    ));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Place in Hearth'));
    await tester.tap(find.text('Place in Hearth'));
    await tester.pumpAndSettle();
    expect(find.text('Replaces Stored Hearth item'), findsOneWidget);
    await tester.tap(find.text('Save placement'));
    await tester.pumpAndSettle();
    expect(find.text('Replace Stored Hearth item?'), findsOneWidget);
    await tester.tap(find.text('Keep current item'));
    await tester.pumpAndSettle();
    expect(placed, isFalse);
    expect(requests.where((r) => r.url.path.endsWith('place_hearth_cosmetic')),
        isEmpty);
    await tester.tap(find.text('Save placement'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Replace item'));
    await tester.pumpAndSettle();
    expect(placed, isTrue);
    expect(requests.where((r) => r.url.path.endsWith('place_hearth_cosmetic')),
        hasLength(1));
    expect(find.text('Moonweb Rug placed in your Hearth.'), findsOneWidget);
    expect(find.text('Could not save your equipment. Refresh and try again.'),
        findsNothing);
    // A reload reconstructs the newly saved floor slot from persisted ownership.
    final saved = await QuestwellCosmeticService.load();
    expect(saved.hearthOccupants['floor']!.id, 'moonweb');
    expect(saved.cosmetics.single.equipped, isTrue);
    expect(saved.cosmetics.single.roomSlot, 'floor');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  group('catalog adapter', () {
    test(
        'joins ownership, placements and renderer metadata while filtering retired items',
        () async {
      respond = catalog;
      final snapshot = await QuestwellCosmeticService.load();
      expect(snapshot.profile.coinBalance, 120);
      expect(snapshot.profile.campfireMode, isTrue);
      expect(snapshot.profile.avatarBodyType, 'neutral');
      expect(snapshot.cosmetics.map((x) => x.id), ['owned', 'unowned']);
      final owned = snapshot.cosmetics.first;
      expect(owned.owned, isTrue);
      expect(owned.equipped, isTrue);
      expect(owned.roomSlot, 'wall-left');
      expect(owned.unlockedAt, DateTime.utc(2026));
      expect(owned.source, 'purchase');
      expect(owned.hearthPlacements.map((x) => x.slot), ['left', 'right']);
      expect(owned.hearthRenderSpec!.assetPath, 'synthetic.png');
      expect(owned.hearthRenderSpec!.aspectRatio, 0.5);
      // Hidden catalog entries still occupy saved room slots. They must not
      // reappear as purchasable/equippable items just to allow replacement.
      expect(snapshot.hearthOccupants.keys,
          unorderedEquals(['wall-left', 'floor']));
      expect(snapshot.hearthOccupants['floor']!.id, 'inactive-rug');
      expect(snapshot.hearthOccupants['floor']!.name, 'Stored Hearth item');
      expect(snapshot.hearthOccupants['wall-left']!.name, owned.name);
      expect(
          snapshot.cosmetics.any((item) => item.id == 'inactive-rug'), isFalse);
      expect(snapshot.cosmetics.last.owned, isFalse);
      expect(snapshot.cosmetics.last.hearthRenderSpec, isNull);
      expect(requests, hasLength(5));
      expect(
          requests
              .singleWhere((r) => r.url.path.endsWith('/users'))
              .url
              .queryParameters['id'],
          'eq.$owner');
      expect(
          requests
              .singleWhere((r) => r.url.path.endsWith('/user_cosmetics'))
              .url
              .queryParameters['user_id'],
          'eq.$owner');
      expect(
          requests
              .singleWhere((r) => r.url.path.endsWith('/cosmetics'))
              .url
              .queryParameters['active'],
          'eq.true');
    });
    test('signed-out catalog never makes a request', () async {
      await signOut();
      await expectLater(QuestwellCosmeticService.load(), throwsStateError);
      expect(requests, isEmpty);
    });
    test('one failed catalog component rejects the whole snapshot', () async {
      respond = (r) async => r.url.path.endsWith('/hearth_render_registry')
          ? json({'code': '42501', 'message': 'Denied'}, status: 403)
          : await catalog(r);
      await expectLater(
          QuestwellCosmeticService.load(), throwsA(isA<PostgrestException>()));
      expect(requests, hasLength(5));
    });
    test('catalog transport retry is bounded and returns the full snapshot',
        () async {
      var profiles = 0;
      respond = (r) async {
        if (r.url.path.endsWith('/users') && ++profiles == 1)
          throw http.ClientException('offline');
        return catalog(r);
      };
      final snapshot = await QuestwellCosmeticService.load();
      expect(snapshot.profile.coinBalance, 120);
      expect(profiles, 2);
      expect(requests, hasLength(10));
    });
    test(
        'account switch during catalog response discards every old-owner field',
        () async {
      final entered = Completer<void>();
      final reply = Completer<http.Response>();
      respond = (r) {
        if (r.url.path.endsWith('/users')) {
          entered.complete();
          return reply.future;
        }
        return catalog(r);
      };
      final result = QuestwellCosmeticService.load();
      final check = expectLater(result, throwsStateError);
      await entered.future;
      await session(other);
      reply.complete(json({'coin_balance': 999}));
      await check;
    });
    test('account switch before catalog retry blocks new requests', () async {
      respond = (r) async {
        if (r.url.path.endsWith('/users')) {
          await session(other);
          throw http.ClientException('offline');
        }
        return catalog(r);
      };
      await expectLater(QuestwellCosmeticService.load(), throwsStateError);
      expect(requests, hasLength(5));
    });
    test('catalog waits for queued equipment changes before reading', () async {
      final entered = Completer<void>();
      final reply = Completer<http.Response>();
      respond = (r) {
        if (r.method == 'POST') {
          entered.complete();
          return reply.future;
        }
        return catalog(r);
      };
      final save = QuestwellCosmeticService.unequip('owned');
      await entered.future;
      final load = QuestwellCosmeticService.load();
      await Future<void>.delayed(Duration.zero);
      expect(requests, hasLength(1));
      reply.complete(json(null));
      await save;
      expect((await load).cosmetics.first.owned, isTrue);
      expect(requests, hasLength(6));
    });
  });

  group('equipment and preference adapters', () {
    final operations = <String, Future<dynamic> Function()>{
      'equip': () =>
          QuestwellCosmeticService.equip(item(), expectedConflict: 'old-item'),
      'place': () =>
          QuestwellCosmeticService.place('owned', 'wall-left', 'old-item'),
      'unequip': () => QuestwellCosmeticService.unequip('owned'),
      'energy': () => QuestwellCosmeticService.setEnergyMode('campfire'),
      'body': () => QuestwellCosmeticService.setAvatarBodyType('neutral'),
      'archetype': () =>
          QuestwellCosmeticService.setAdventurerArchetype('scout'),
      'mastery': QuestwellCosmeticService.claimClassMasteryReward,
    };
    final paths = <String, String>{
      'equip': 'rpc/equip_cosmetic_loadout',
      'place': 'rpc/place_hearth_cosmetic',
      'unequip': 'rpc/unequip_cosmetic',
      'energy': 'users',
      'body': 'rpc/set_avatar_body_type',
      'archetype': 'rpc/set_adventurer_archetype',
      'mastery': 'rpc/claim_class_mastery_reward'
    };
    final payloads = <String, Map<String, Object?>>{
      'equip': {'p_cosmetic_id': 'owned', 'p_expected_conflict': 'old-item'},
      'place': {
        'p_cosmetic_id': 'owned',
        'p_slot': 'wall-left',
        'p_expected_occupant': 'old-item'
      },
      'unequip': {'p_cosmetic_id': 'owned'},
      'energy': {'current_energy_mode': 'campfire'},
      'body': {'p_body_type': 'neutral'},
      'archetype': {'p_archetype': 'scout'},
      'mastery': {},
    };
    for (final entry in operations.entries) {
      test(
          '${entry.key} sends authoritative contract and notifies only confirmed success',
          () async {
        var notifications = 0;
        void listener() => notifications++;
        QuestwellCosmeticService.changes.addListener(listener);
        addTearDown(
            () => QuestwellCosmeticService.changes.removeListener(listener));
        respond =
            (_) async => json(entry.key == 'mastery' ? 'reward-id' : null);
        final result = await entry.value();
        expect(requests.single.url.path, '/rest/v1/${paths[entry.key]}');
        if (entry.key == 'mastery') {
          expect(jsonDecode(requests.single.body), isNull);
        } else {
          expect(body(requests.single), payloads[entry.key]);
        }
        if (entry.key == 'energy')
          expect(requests.single.url.queryParameters['id'], 'eq.$owner');
        if (entry.key == 'mastery') expect(result, 'reward-id');
        expect(notifications, 1);
      });
      test('${entry.key} rejects signed-out calls without transport', () async {
        await signOut();
        await expectLater(entry.value(), throwsStateError);
        expect(requests, isEmpty);
      });
      test(
          '${entry.key} discards completion after account switch without notification',
          () async {
        var notifications = 0;
        void listener() => notifications++;
        QuestwellCosmeticService.changes.addListener(listener);
        addTearDown(
            () => QuestwellCosmeticService.changes.removeListener(listener));
        respond = (_) async {
          await session(other);
          return json(entry.key == 'mastery' ? 'reward-id' : null);
        };
        await expectLater(entry.value(), throwsStateError);
        expect(requests, hasLength(1));
        expect(notifications, 0);
      });
    }
    test('invalid body class or mode cannot mutate profile', () async {
      await expectLater(QuestwellCosmeticService.setEnergyMode('invalid'),
          throwsArgumentError);
      await expectLater(QuestwellCosmeticService.setAvatarBodyType('invalid'),
          throwsArgumentError);
      await expectLater(
          QuestwellCosmeticService.setAdventurerArchetype('invalid'),
          throwsArgumentError);
      expect(requests, isEmpty);
    });
    test('unowned unknown and retired equipment cannot be sent', () async {
      for (final cosmetic in [
        item(owned: false),
        item(slug: 'unknown'),
        item(slug: 'pathfinder-boots')
      ]) {
        await expectLater(
            QuestwellCosmeticService.equip(cosmetic), throwsStateError);
      }
      expect(requests, isEmpty);
    });
    test('conflict failure does not notify or poison later equipment saves',
        () async {
      var notifications = 0;
      void listener() => notifications++;
      QuestwellCosmeticService.changes.addListener(listener);
      addTearDown(
          () => QuestwellCosmeticService.changes.removeListener(listener));
      respond = (_) async =>
          json({'code': 'P0001', 'message': 'Conflict changed'}, status: 409);
      await expectLater(
          QuestwellCosmeticService.place('owned', 'wall-left', 'old'),
          throwsA(isA<PostgrestException>()));
      expect(notifications, 0);
      respond = (_) async => json(null);
      await QuestwellCosmeticService.unequip('owned');
      expect(notifications, 1);
      expect(requests, hasLength(2));
    });
    test('queued preference save stops before sending after account switch',
        () async {
      final entered = Completer<void>();
      final reply = Completer<http.Response>();
      respond = (_) {
        entered.complete();
        return reply.future;
      };
      final first = QuestwellCosmeticService.unequip('owned');
      final firstCheck = expectLater(first, throwsStateError);
      await entered.future;
      final queued = QuestwellCosmeticService.setEnergyMode('normal');
      final queuedCheck = expectLater(queued, throwsStateError);
      await session(other);
      reply.complete(json(null));
      await Future.wait([firstCheck, queuedCheck]);
      expect(requests, hasLength(1));
    });
    test('onboarding forwards receipt owner and starter choice', () async {
      respond =
          (_) async => json({'status': 'completed', 'task_id': 'starter'});
      final result =
          await QuestwellCosmeticService.newOnboardingSession().finish('email');
      expect(result.completed, isTrue);
      expect(result.taskId, 'starter');
      expect(requests.single.url.path, '/rest/v1/rpc/finish_onboarding_once');
      expect(body(requests.single),
          {'p_expected_user_id': owner, 'p_starter_key': 'email'});
    });
    test('onboarding cannot move a draft between accounts', () async {
      final draft = QuestwellCosmeticService.newOnboardingSession();
      await session(other);
      await expectLater(draft.finish(null),
          throwsA(isA<QuestwellOnboardingAccountChanged>()));
      expect(requests, isEmpty);
    });
  });

  group('remaining reward adapters', () {
    for (final restore in [false, true]) {
      Future<void> change() => restore
          ? QuestwellTaskService.restore('quest')
          : QuestwellTaskService.setAside('quest');
      test(
          '${restore ? 'restore' : 'set aside'} checks owner original status and affected count',
          () async {
        respond = (_) async => json([
              {'id': 'quest'}
            ]);
        await change();
        expect(requests.single.method, 'PATCH');
        expect(requests.single.url.queryParameters['id'], 'eq.quest');
        expect(requests.single.url.queryParameters['user_id'], 'eq.$owner');
        expect(requests.single.url.queryParameters['status'],
            restore ? 'eq.set_aside' : 'eq.open');
        expect(
            body(requests.single), {'status': restore ? 'open' : 'set_aside'});
        respond = (_) async => json([]);
        await expectLater(change(), throwsStateError);
        expect(requests, hasLength(2));
      });
      test('${restore ? 'restore' : 'set aside'} needs authentication',
          () async {
        await signOut();
        await expectLater(change(), throwsStateError);
        expect(requests, isEmpty);
      });
    }
    test(
        'boss service loads owner-bound collections through the paging adapter',
        () async {
      respond = (r) async {
        expect(r.url.queryParameters['user_id'], 'eq.$owner');
        return json([]);
      };
      expect(await QuestwellBossService.loadBattles(), isEmpty);
      expect(requests.map((r) => r.url.path),
          ['/rest/v1/boss_battles', '/rest/v1/boss_steps']);
    });
  });
}
