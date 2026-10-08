import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/flutter_flow/nav/nav.dart';
import 'package:project_momentum/auth/supabase_auth/supabase_user_provider.dart';
import 'package:project_momentum/auth_page/auth_page_widget.dart';
import 'package:project_momentum/pages/account_settings_page/account_settings_page_widget.dart';
import 'package:project_momentum/widgets/questwell_account_settings.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  Future<void> mount(
    WidgetTester tester, {
    required Future<void> Function() signOut,
    required Future<void> Function() delete,
    VoidCallback? deleted,
  }) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => QuestwellAccountSettings(
                    onSignOut: signOut,
                    onDelete: delete,
                    onDeleted: deleted ?? () {},
                  ),
                ),
              ),
              child: const Text('Account settings'),
            ),
          ),
        ),
      ),
    );
    // Opening settings itself must not perform either account operation.
    await tester.tap(find.text('Account settings'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'settings separates account actions, supports large text and returns safely',
    (tester) async {
      var signOuts = 0;
      var deletions = 0;
      await mount(
        tester,
        signOut: () async {
          signOuts++;
        },
        delete: () async {
          deletions++;
        },
      );
      expect(find.byType(QuestwellAccountSettings), findsOneWidget);
      final signOut = find.widgetWithText(OutlinedButton, 'Sign out');
      await tester.scrollUntilVisible(signOut, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(signOut.hitTestable(), findsOneWidget);
      expect(tester.getSize(signOut).height, greaterThanOrEqualTo(48));
      await tester.scrollUntilVisible(
        find.text('Delete account'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Permanent deletion'), findsOneWidget);
      expect(signOuts, 0);
      expect(deletions, 0);
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Account settings'), findsOneWidget);
      expect(find.text('Delete account'), findsNothing);
      expect(signOuts, 0);
      expect(deletions, 0);
    },
  );

  testWidgets('pending sign-out prevents repeated sign-out and deletion', (
    tester,
  ) async {
    final pending = Completer<void>();
    var signOuts = 0;
    var deletions = 0;
    await mount(
      tester,
      signOut: () {
        signOuts++;
        return pending.future;
      },
      delete: () async {
        deletions++;
      },
    );
    final signOut = find.widgetWithText(OutlinedButton, 'Sign out');
    await tester.scrollUntilVisible(signOut, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(signOut.hitTestable(), findsOneWidget);
    await tester.tap(signOut);
    await tester.pump();
    final busy = find.widgetWithText(OutlinedButton, 'Signing out…');
    expect(tester.widget<OutlinedButton>(busy).onPressed, isNull);
    await tester.scrollUntilVisible(
      find.text('Delete account'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    final deletion = find.widgetWithText(TextButton, 'Delete account');
    expect(tester.widget<TextButton>(deletion).onPressed, isNull);
    expect(signOuts, 1);
    expect(deletions, 0);
    pending.complete();
    await tester.pumpAndSettle();
    expect(tester.widget<TextButton>(deletion).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opening and cancelling deletion preserves the account', (
    tester,
  ) async {
    var deletions = 0;
    await mount(
      tester,
      signOut: () async {},
      delete: () async {
        deletions++;
      },
    );
    await tester.scrollUntilVisible(
      find.text('Delete account'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    expect(find.text('Hang up your boots?'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Delete forever'),
          )
          .onPressed,
      isNull,
    );
    await tester.ensureVisible(find.text('Keep my account'));
    await tester.tap(find.text('Keep my account'));
    await tester.pumpAndSettle();
    expect(deletions, 0);
    expect(find.text('Hang up your boots?'), findsNothing);
    expect(find.byType(QuestwellAccountSettings), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  test('production router registers the account settings URL', () {
    final router = createRouter(AppStateNotifier.instance);
    addTearDown(router.dispose);
    final match =
        router.configuration.findMatch(AccountSettingsPageWidget.routePath);
    expect(match.isError, isFalse);
    expect((match.last.route as GoRoute).name,
        AccountSettingsPageWidget.routeName);
  });

  testWidgets('production router rejects signed-out account history',
      (tester) async {
    final appState = AppStateNotifier.instance;
    final previousUser = appState.user;
    final previousSplash = appState.showSplashImage;
    appState.user = ProjectMomentumSupabaseUser(null);
    appState.showSplashImage = false;
    appState.clearRedirectLocation();
    addTearDown(() {
      appState.user = previousUser;
      appState.showSplashImage = previousSplash;
      appState.clearRedirectLocation();
    });
    final router = createRouter(appState);
    addTearDown(router.dispose);
    await tester.pumpWidget(
        MaterialApp.router(theme: ThemeData.dark(), routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.byType(AuthPageWidget), findsOneWidget);
    for (final path in [AccountSettingsPageWidget.routePath, '/adventurer']) {
      await router.routeInformationProvider.didPushRouteInformation(
        RouteInformation(uri: Uri.parse(path)),
      );
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/authPage');
      expect(find.byType(AuthPageWidget), findsOneWidget);
      expect(find.byType(AccountSettingsPageWidget), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  GoRouter settingsRouter({String initialLocation = '/adventurer'}) => GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(
            path: '/adventurer',
            name: 'AdventurerPage',
            builder: (context, state) => Scaffold(
                body: TextButton(
              onPressed: () =>
                  context.pushNamed(AccountSettingsPageWidget.routeName),
              child: const Text('Account settings'),
            )),
          ),
          GoRoute(
            path: AccountSettingsPageWidget.routePath,
            name: AccountSettingsPageWidget.routeName,
            builder: (context, state) => QuestwellAccountSettings(
              onSignOut: () async {},
              onDelete: () async {},
              onDeleted: () {},
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed('AdventurerPage');
                }
              },
            ),
          ),
        ],
      );

  testWidgets(
      'settings URL participates in browser back and forward restoration',
      (tester) async {
    final previousOption = GoRouter.optionURLReflectsImperativeAPIs;
    GoRouter.optionURLReflectsImperativeAPIs = true;
    addTearDown(
        () => GoRouter.optionURLReflectsImperativeAPIs = previousOption);
    final router = settingsRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
        MaterialApp.router(theme: ThemeData.dark(), routerConfig: router));
    await tester.pumpAndSettle();
    final adventurerLocation =
        router.routeInformationParser.restoreRouteInformation(
      router.routerDelegate.currentConfiguration,
    )!;
    await tester.tap(find.text('Account settings'));
    await tester.pumpAndSettle();
    final settingsLocation =
        router.routeInformationParser.restoreRouteInformation(
      router.routerDelegate.currentConfiguration,
    )!;
    expect(settingsLocation.uri.path, AccountSettingsPageWidget.routePath);
    expect(find.byType(QuestwellAccountSettings), findsOneWidget);

    // Feed the same serialized route information returned by browser history.
    await router.routeInformationProvider
        .didPushRouteInformation(adventurerLocation);
    await tester.pumpAndSettle();
    expect(find.byType(QuestwellAccountSettings), findsNothing);
    expect(router.routeInformationProvider.value.uri.path, '/adventurer');
    await router.routeInformationProvider
        .didPushRouteInformation(settingsLocation);
    await tester.pumpAndSettle();
    expect(find.byType(QuestwellAccountSettings), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Account settings'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'direct settings URL restores after refresh and provides a way back',
      (tester) async {
    final router =
        settingsRouter(initialLocation: AccountSettingsPageWidget.routePath);
    addTearDown(router.dispose);
    await tester.pumpWidget(
        MaterialApp.router(theme: ThemeData.dark(), routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.byType(QuestwellAccountSettings), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path,
        AccountSettingsPageWidget.routePath);
    expect(router.canPop(), isFalse);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Account settings'), findsOneWidget);
    expect(find.byType(QuestwellAccountSettings), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final pendingStage in [
    'sign-out',
    'deletion',
    'cleanup',
    'cleanup failure'
  ]) {
    for (final leaveSettings
        in pendingStage == 'cleanup failure' ? [false, true] : [true]) {
      testWidgets(
          'account exit completes during $pendingStage with Back=$leaveSettings',
          (tester) async {
        final pending = Completer<void>();
        var signOuts = 0;
        var deletions = 0;
        var cleanups = 0;
        final router = GoRouter(initialLocation: '/adventurer', routes: [
          GoRoute(
              path: '/adventurer',
              builder: (context, state) => Scaffold(
                    body: TextButton(
                      onPressed: () => context
                          .pushNamed(AccountSettingsPageWidget.routeName),
                      child: const Text('Account settings'),
                    ),
                  )),
          GoRoute(
            path: AccountSettingsPageWidget.routePath,
            name: AccountSettingsPageWidget.routeName,
            builder: (_, state) => AccountSettingsPageWidget(
              signOut: () async {
                signOuts++;
                await pending.future;
              },
              deleteAccount: () async {
                deletions++;
                if (pendingStage == 'deletion') await pending.future;
              },
              clearLocalAccount: () async {
                cleanups++;
                if (pendingStage.startsWith('cleanup')) await pending.future;
                if (pendingStage == 'cleanup failure')
                  throw StateError('Preferences removal failed');
              },
            ),
          ),
          GoRoute(
              path: '/authPage',
              name: 'AuthPage',
              builder: (_, state) =>
                  const Scaffold(body: Text('Signed out destination'))),
        ]);
        addTearDown(router.dispose);
        await tester.pumpWidget(
            MaterialApp.router(theme: ThemeData.dark(), routerConfig: router));
        await tester.pumpAndSettle();
        final previousLocation =
            router.routeInformationParser.restoreRouteInformation(
          router.routerDelegate.currentConfiguration,
        )!;
        await tester.tap(find.text('Account settings'));
        await tester.pumpAndSettle();
        if (pendingStage == 'sign-out') {
          await tester.tap(find.widgetWithText(OutlinedButton, 'Sign out'));
        } else {
          await tester.scrollUntilVisible(find.text('Delete account'), 200,
              scrollable: find.byType(Scrollable).first);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Delete account'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byType(TextField), 'DELETE');
          await tester.pump();
          await tester.tap(find.text('Delete forever'));
        }
        await tester.pumpAndSettle();
        expect(pendingStage == 'sign-out' ? signOuts : deletions, 1);
        if (leaveSettings) {
          await router.routeInformationProvider
              .didPushRouteInformation(previousLocation);
          await tester.pumpAndSettle();
          expect(find.byType(AccountSettingsPageWidget), findsNothing);
          expect(find.text('Account settings'), findsOneWidget);
        }
        pending.complete();
        await tester.pumpAndSettle();
        expect(find.text('Signed out destination'), findsOneWidget);
        expect(cleanups, pendingStage == 'sign-out' ? 0 : 1);
        expect(router.routeInformationProvider.value.uri.path, '/authPage');
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final delete in [false, true]) {
    testWidgets(
      'account navigation removes settings after ${delete ? 'deletion' : 'sign-out'}',
      (tester) async {
        var operations = 0;
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                body: TextButton(
                  child: const Text('Account settings'),
                  onPressed: () =>
                      context.pushNamed(AccountSettingsPageWidget.routeName),
                ),
              ),
            ),
            GoRoute(
              path: AccountSettingsPageWidget.routePath,
              name: AccountSettingsPageWidget.routeName,
              builder: (context, state) => QuestwellAccountSettings(
                onSignOut: () async {
                  operations++;
                  context.goNamed('signed-out');
                },
                onDelete: () async {
                  operations++;
                },
                onDeleted: () => context.goNamed('signed-out'),
              ),
            ),
            GoRoute(
              path: '/signed-out',
              name: 'signed-out',
              builder: (_, state) =>
                  const Scaffold(body: Text('Signed out destination')),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          MaterialApp.router(theme: ThemeData.dark(), routerConfig: router),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Account settings'));
        await tester.pumpAndSettle();
        if (delete) {
          await tester.scrollUntilVisible(
            find.text('Delete account'),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.tap(find.text('Delete account'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byType(TextField), 'DELETE');
          await tester.pump();
          await tester.tap(find.text('Delete forever'));
        } else {
          await tester.tap(find.widgetWithText(OutlinedButton, 'Sign out'));
        }
        await tester.pumpAndSettle();
        expect(operations, 1);
        expect(find.text('Signed out destination'), findsOneWidget);
        expect(find.byType(QuestwellAccountSettings), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
