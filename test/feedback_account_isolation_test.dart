import 'dart:async' show Completer;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_momentum/backend/supabase/supabase.dart';
import 'package:project_momentum/services/questwell_feedback_draft.dart';
import 'package:project_momentum/services/questwell_feedback_service.dart';
import 'package:project_momentum/widgets/questwell_feedback.dart';

class ScreenshotPicker extends FilePicker {
  ScreenshotPicker({this.pending});
  final Future<FilePickerResult?>? pending;
  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async =>
      pending != null
          ? await pending!
          : FilePickerResult([
              PlatformFile(
                name: 'synthetic.png',
                size: 3,
                bytes: Uint8List.fromList([1, 2, 3]),
              ),
            ]);
}

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
    await SupaFlow.client.auth.recoverSession(
      jsonEncode({
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
          'created_at': '2026-01-01T00:00:00Z',
        },
      }),
    );
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
        return http.Response.bytes(
          response.bodyBytes,
          response.statusCode,
          headers: response.headers,
          request: request,
        );
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

  final draft = QuestwellFeedbackDraft(
    id: '33333333-3333-4333-8333-333333333333',
    screen: 'Quests',
    build: 'test',
    platform: 'web',
    goal: 'Synthetic goal',
    message: 'Synthetic message',
  );
  final stale = throwsA(isA<QuestwellFeedbackException>());
  Future<String> upload() => QuestwellFeedbackService.uploadScreenshot(
        ownerId: owner,
        feedbackId: draft.id,
        bytes: Uint8List.fromList([1, 2, 3]),
        mimeType: 'image/png',
      );

  test('same-owner report writes once with its stable request ID', () async {
    respond = (request) async {
      expect(body(request)['user_id'], owner);
      expect(body(request)['id'], draft.id);
      return http.Response('', 201);
    };
    await QuestwellFeedbackService.submit(draft, owner);
    expect(requests, hasLength(1));
  });
  test(
    'wrong-owner report and upload are rejected before any request',
    () async {
      await session(other);
      await expectLater(QuestwellFeedbackService.submit(draft, owner), stale);
      await expectLater(upload(), stale);
      expect(requests, isEmpty);
    },
  );
  for (final logout in [false, true]) {
    test(
      'report rejects stale success after ${logout ? 'logout' : 'switch'}',
      () async {
        respond = (_) async {
          if (logout) {
            await signOut();
          } else {
            await session(other);
          }
          return http.Response('', 201);
        };
        await expectLater(QuestwellFeedbackService.submit(draft, owner), stale);
      },
    );
    test(
      'upload rejects stale success after ${logout ? 'logout' : 'switch'}',
      () async {
        respond = (_) async {
          if (logout) {
            await signOut();
          } else {
            await session(other);
          }
          return json({'Key': 'beta-feedback/$owner/${draft.id}-0.png'});
        };
        await expectLater(upload(), stale);
      },
    );
  }
  test(
    'account switch after duplicate does not launch reconciliation read',
    () async {
      respond = (_) async {
        await session(other);
        return json({'code': '23505', 'message': 'duplicate'}, status: 409);
      };
      await expectLater(QuestwellFeedbackService.submit(draft, owner), stale);
      expect(requests, hasLength(1));
    },
  );
  test(
    'account switch during duplicate lookup rejects stale confirmation',
    () async {
      respond = (request) async {
        if (request.method == 'POST')
          return json({'code': '23505', 'message': 'duplicate'}, status: 409);
        await session(other);
        return json({'id': draft.id});
      };
      await expectLater(QuestwellFeedbackService.submit(draft, owner), stale);
      expect(requests, hasLength(2));
    },
  );
  test('same-owner duplicate reconciles exact report and owner', () async {
    respond = (request) async {
      if (request.method == 'POST')
        return json({'code': '23505', 'message': 'duplicate'}, status: 409);
      expect(request.url.queryParameters['id'], 'eq.${draft.id}');
      expect(request.url.queryParameters['user_id'], 'eq.$owner');
      return json({'id': draft.id});
    };
    await QuestwellFeedbackService.submit(draft, owner);
    expect(requests, hasLength(2));
  });
  test('uncertain write is not retried', () async {
    respond = (_) async => throw http.ClientException('synthetic offline');
    await expectLater(
      QuestwellFeedbackService.submit(draft, owner),
      throwsException,
    );
    expect(requests, hasLength(1));
  });

  test('same-owner upload returns the owner-scoped path', () async {
    respond =
        (_) async => json({'Key': 'beta-feedback/$owner/${draft.id}-0.png'});
    expect(await upload(), '$owner/${draft.id}-0.png');
    expect(requests, hasLength(1));
  });
  test('screenshot cleanup cannot cross account boundaries', () async {
    await session(other);
    respond = (_) async => json([]);
    await expectLater(
      QuestwellFeedbackService.removeScreenshots(['$owner/${draft.id}-0.png']),
      stale,
    );
    expect(requests, isEmpty);
  });
  test('same-owner screenshot cleanup succeeds once', () async {
    respond = (_) async => json([]);
    await QuestwellFeedbackService.removeScreenshots([
      '$owner/${draft.id}-0.png',
    ]);
    expect(requests, hasLength(1));
  });

  testWidgets(
    'open feedback with screenshots cannot send an old draft under the new account',
    (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      FilePicker.platform = ScreenshotPicker();
      await tester.binding.setSurfaceSize(const Size(390, 850));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await QuestwellFeedbackDraftStore(owner).save(draft);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () =>
                    QuestwellFeedback.open(context, screen: 'Quests'),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final attach = find.text('Attach screenshots');
      await tester.ensureVisible(attach);
      await tester.pumpAndSettle();
      await tester.tap(attach);
      await tester.pumpAndSettle();
      expect(find.text('synthetic.png'), findsOneWidget);
      await session(other);
      await tester.pumpAndSettle();
      respond = (request) async => request.url.path.contains('/storage/')
          ? json({'Key': 'beta-feedback/$other/${draft.id}-0.png'})
          : http.Response('', 201);
      final send = find.widgetWithText(FilledButton, 'Send feedback');
      if (send.evaluate().isNotEmpty) {
        await tester.ensureVisible(send);
        await tester.pumpAndSettle();
        await tester.tap(send);
        await tester.pumpAndSettle();
      }
      expect(requests, isEmpty);
      expect(find.text('NOTE RECEIVED'), findsNothing);
      expect(find.text('Synthetic message'), findsNothing);
      expect((await QuestwellFeedbackDraftStore(owner).load())?.id, draft.id);
      expect(await QuestwellFeedbackDraftStore(other).load(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
    timeout: const Timeout(Duration(seconds: 45)),
  );
  test('cleanup rejects stale completion after a switch', () async {
    respond = (_) async {
      await session(other);
      return json([]);
    };
    await expectLater(
      QuestwellFeedbackService.removeScreenshots(['$owner/${draft.id}-0.png']),
      stale,
    );
    expect(requests, hasLength(1));
  });

  for (final phase in ['save', 'submit', 'clear']) {
    testWidgets(
      'account switch during $phase prevents subsequent work and stale success',
      (tester) async {
        GoogleFonts.config.allowRuntimeFetching = false;
        await tester.binding.setSurfaceSize(const Size(390, 850));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final pending = Completer<void>();
        var sends = 0, clears = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: QuestwellFeedbackForm(
                initialDraft: draft,
                ownerId: owner,
                onSave: (_) =>
                    phase == 'save' ? pending.future : Future.value(),
                onSubmit: (_) {
                  sends++;
                  return phase == 'submit' ? pending.future : Future.value();
                },
                onClear: () {
                  clears++;
                  return phase == 'clear' ? pending.future : Future.value();
                },
                onClose: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final send = find.widgetWithText(FilledButton, 'Send feedback');
        await tester.ensureVisible(send);
        await tester.pumpAndSettle();
        await tester.tap(send);
        await tester.pumpAndSettle();
        await session(other);
        await tester.pumpAndSettle();
        pending.complete();
        await tester.pumpAndSettle();
        expect(sends, phase == 'save' ? 0 : 1);
        expect(clears, phase == 'clear' ? 1 : 0);
        expect(find.text('NOTE RECEIVED'), findsNothing);
        expect(find.text('Synthetic message'), findsNothing);
        expect(
          find.text(
            'Your account changed. Close this note and reopen feedback.',
          ),
          findsOneWidget,
        );
        // A return to the original account does not revive this invalidated screen.
        await session(owner);
        await tester.pumpAndSettle();
        expect(find.text('Synthetic message'), findsNothing);
        expect(find.text('Send feedback'), findsNothing);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
      timeout: const Timeout(Duration(seconds: 45)),
    );
  }

  for (final disposed in [false, true]) {
    testWidgets(
      'pending file picker cannot publish after ${disposed ? 'disposal' : 'account switch'}',
      (tester) async {
        GoogleFonts.config.allowRuntimeFetching = false;
        await tester.binding.setSurfaceSize(const Size(390, 850));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final pending = Completer<FilePickerResult?>();
        FilePicker.platform = ScreenshotPicker(pending: pending.future);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: QuestwellFeedbackForm(
                initialDraft: draft,
                ownerId: owner,
                onSave: (_) async {},
                onSubmit: (_) async {},
                onClear: () async {},
                onClose: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final attach = find.text('Attach screenshots');
        await tester.ensureVisible(attach);
        await tester.pumpAndSettle();
        await tester.tap(attach);
        await tester.pumpAndSettle();
        if (disposed) {
          await tester.pumpWidget(const SizedBox());
        } else {
          await session(other);
        }
        await tester.pumpAndSettle();
        pending.complete(
          FilePickerResult([
            PlatformFile(
              name: 'late.png',
              size: 1,
              bytes: Uint8List.fromList([1]),
            ),
          ]),
        );
        await tester.pumpAndSettle();
        expect(find.text('late.png'), findsNothing);
        expect(requests, isEmpty);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
      timeout: const Timeout(Duration(seconds: 45)),
    );
  }
  testWidgets(
    'failed close keeps account-change protection active',
    (
      tester,
    ) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      await tester.binding.setSurfaceSize(const Size(390, 850));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var closes = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestwellFeedbackForm(
              initialDraft: draft,
              ownerId: owner,
              onSave: (_) async =>
                  throw StateError('synthetic storage failure'),
              onSubmit: (_) async {},
              onClear: () async {},
              onClose: () => closes++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Close feedback'));
      await tester.pumpAndSettle();
      expect(closes, 0);
      await session(other);
      await tester.pumpAndSettle();
      expect(find.text('Synthetic message'), findsNothing);
      expect(
        find.text('Your account changed. Close this note and reopen feedback.'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(TextButton, 'Close feedback'));
      await tester.pumpAndSettle();
      expect(closes, 1);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(seconds: 45)),
  );

  testWidgets(
    'disposing during successful screenshot report does not delete its attachments',
    (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      FilePicker.platform = ScreenshotPicker();
      await tester.binding.setSurfaceSize(const Size(390, 850));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await QuestwellFeedbackDraftStore(owner).save(draft);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () =>
                    QuestwellFeedback.open(context, screen: 'Quests'),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final attach = find.text('Attach screenshots');
      await tester.ensureVisible(attach);
      await tester.pumpAndSettle();
      await tester.tap(attach);
      await tester.pumpAndSettle();
      final pending = Completer<http.Response>();
      respond = (request) async {
        if (request.method == 'DELETE') return json([]);
        if (request.url.path.contains('/storage/'))
          return json({'Key': 'beta-feedback/$owner/${draft.id}-0.png'});
        return pending.future;
      };
      final send = find.widgetWithText(FilledButton, 'Send feedback');
      await tester.ensureVisible(send);
      await tester.pumpAndSettle();
      await tester.tap(send);
      await tester.pumpAndSettle();
      expect(
        requests.where((r) => r.url.path.contains('/rest/v1/beta_feedback')),
        hasLength(1),
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      pending.complete(http.Response('', 201));
      await tester.pumpAndSettle();
      expect(requests.where((r) => r.method == 'DELETE'), isEmpty);
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(seconds: 45)),
  );
}
