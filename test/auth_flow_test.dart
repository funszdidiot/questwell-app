import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/auth/questwell_auth_callback.dart';
import 'package:project_momentum/auth_page/auth_page_widget.dart';
import 'package:project_momentum/backend/supabase/supabase.dart';
import 'package:project_momentum/services/questwell_auth_service.dart';

class FakeAuth extends QuestwellAuthService {
  bool session = false;
  bool signupSession = false;
  int signups = 0, resets = 0, saves = 0;
  Object? failure;
  Completer<bool>? pending;
  @override
  bool get hasSession => session;
  @override
  Future<bool> signUp(String email, String password) async {
    signups++;
    if (failure != null) throw failure!;
    if (pending != null) return await pending!.future;
    return signupSession;
  }
  @override
  Future<bool> signIn(String email, String password) async => true;
  @override
  Future<void> sendReset(String email) async {
    resets++;
    if (failure != null) throw failure!;
  }
  @override
  Future<void> savePassword(String password) async {
    saves++;
    if (failure != null) throw failure!;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(QuestwellAuthCallback.clear);
  tearDown(QuestwellAuthCallback.clear);

  Future<void> mount(WidgetTester tester, FakeAuth auth,
      {String initial = '/authPage', double width = 390, double scale = 1}) async {
    await tester.binding.setSurfaceSize(Size(width, 1000));
    final router = GoRouter(initialLocation: initial, routes: [
      GoRoute(path: '/', builder: (_, __) => AuthPageWidget(authService: auth)),
      GoRoute(path: '/authPage', name: 'AuthPage',
          builder: (_, __) => AuthPageWidget(authService: auth)),
      GoRoute(path: '/homePage', name: 'HomePage',
          builder: (_, __) => const Scaffold(body: Text('Signed-in Hearth'))),
    ]);
    addTearDown(() { router.dispose(); tester.binding.setSurfaceSize(null); });
    await tester.pumpWidget(MaterialApp.router(routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!)));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Future<void> signup(WidgetTester tester) async {
    await tap(tester, 'New here? Create an account');
    await tester.enterText(find.byType(TextFormField).at(0), 'adventurer@example.invalid');
    await tester.enterText(find.byType(TextFormField).at(1), 'Test-only-12345');
    await tap(tester, 'Create account');
  }

  test('recovery markers survive SDK fragment consumption; errors are flags only', () {
    QuestwellAuthCallback.capture(Uri.parse(
        'https://example.invalid/?recovery=true#type=recovery'));
    expect(QuestwellAuthCallback.recovering, isTrue);
    expect(QuestwellAuthCallback.linkFailed, isFalse);
    QuestwellAuthCallback.capture(Uri.parse(
        'https://example.invalid/#error=access_denied&error_code=otp_expired'));
    expect(QuestwellAuthCallback.linkFailed, isTrue);
    expect(QuestwellAuthCallback.needsAuthScreen, isTrue);
    expect(Uri.parse(QuestwellAuthCallback.recoveryUrl).queryParameters['recovery'], 'true');
    expect(QuestwellAuthCallback.recoveryUrl,
        'https://funszdidiot.github.io/questwell-app/?recovery=true');
  });

  testWidgets('confirmation-required signup stays out of Hearth and clears password', (tester) async {
    final auth = FakeAuth();
    await mount(tester, auth);
    await signup(tester);
    expect(auth.signups, 1);
    expect(find.text('Check your email to confirm your account, then return to sign in.'), findsOneWidget);
    expect(find.text('Signed-in Hearth'), findsNothing);
    expect(tester.widget<TextFormField>(find.byType(TextFormField).at(1)).controller!.text, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('signup server failure never claims confirmation email was sent', (tester) async {
    final auth = FakeAuth()..failure = const AuthException('Email service unavailable');
    await mount(tester, auth);
    await signup(tester);
    expect(find.text('Email service unavailable'), findsOneWidget);
    expect(find.text('Check your email to confirm your account, then return to sign in.'), findsNothing);
  });

  testWidgets('signup with a session enters Hearth without a client profile insert', (tester) async {
    final auth = FakeAuth()..signupSession = true;
    await mount(tester, auth);
    await signup(tester);
    // No Supabase singleton is initialized: a duplicate table insert would fail.
    expect(find.text('Signed-in Hearth'), findsOneWidget);
    expect(auth.signups, 1);
  });

  testWidgets('busy signup cannot submit twice', (tester) async {
    final auth = FakeAuth()..pending = Completer<bool>();
    await mount(tester, auth);
    await signup(tester);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    expect(auth.signups, 1);
    auth.pending!.complete(false);
    await tester.pumpAndSettle();
  });

  testWidgets('reset request failure stays distinct from successful request', (tester) async {
    final auth = FakeAuth()..failure = const AuthException('Please wait before retrying');
    await mount(tester, auth);
    await tap(tester, 'Forgot password?');
    await tester.enterText(find.byType(TextFormField), 'adventurer@example.invalid');
    await tap(tester, 'Send reset link');
    expect(find.text('Please wait before retrying'), findsOneWidget);
    auth.failure = null;
    await tap(tester, 'Send reset link');
    expect(auth.resets, 2);
    expect(find.text('If an account matches that email, you’ll receive a password reset link.'), findsOneWidget);
  });

  testWidgets('expired recovery blocks password update even with a stale session', (tester) async {
    QuestwellAuthCallback.capture(Uri.parse(
        'https://example.invalid/?recovery=true#error_code=otp_expired'));
    final auth = FakeAuth()..session = true;
    await mount(tester, auth, initial: '/?recovery=true', width: 320, scale: 1.6);
    expect(find.text('New password'), findsNothing);
    await tap(tester, 'Request a new reset link');
    expect(find.text('Send reset link'), findsOneWidget);
    expect(auth.saves, 0);
    await tap(tester, 'Back to sign in');
    expect(find.text('Enter the Hearth'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recovery without a session offers another link', (tester) async {
    await mount(tester, FakeAuth(), initial: '/authPage?recovery=true');
    expect(find.text('Request a new reset link'), findsOneWidget);
    expect(find.text('Save new password'), findsNothing);
  });

  testWidgets('password update failure retains recovery; success clears it', (tester) async {
    QuestwellAuthCallback.recovering = true;
    final auth = FakeAuth()..session = true
      ..failure = const AuthException('Password update failed');
    await mount(tester, auth, initial: '/authPage?recovery=true');
    await tester.enterText(find.byType(TextFormField), 'Test-only-new-12345');
    await tap(tester, 'Save new password');
    expect(find.text('Password update failed'), findsOneWidget);
    expect(QuestwellAuthCallback.recovering, isTrue);
    auth.failure = null;
    await tap(tester, 'Save new password');
    expect(find.text('Signed-in Hearth'), findsOneWidget);
    expect(QuestwellAuthCallback.needsAuthScreen, isFalse);
  });
}
