import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'services/questwell_monitoring.dart';
import 'config/questwell_environment.dart';
import 'config/questwell_staging_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'startup/questwell_bootstrap.dart';
import 'startup/questwell_startup.dart';
import 'auth/questwell_auth_callback.dart';

import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'auth/supabase_auth/supabase_user_provider.dart';
import 'auth/supabase_auth/auth_util.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';

void main() => runQuestwell();

/// The preview-only check uses the real startup failure path before any backend
/// initialization. The standard/native entry point never enables it.
void runQuestwell({
  bool monitoringCheck = false,
  QuestwellMonitoring? monitoringOverride,
}) {
  WidgetsFlutterBinding.ensureInitialized();
  final monitoring = monitoringOverride ??
      QuestwellMonitoring(
        dsn: const String.fromEnvironment('QUESTWELL_SENTRY_DSN'),
        build: const String.fromEnvironment('QUESTWELL_BUILD'),
        environment: const String.fromEnvironment('QUESTWELL_ENVIRONMENT'),
        platform: kIsWeb
            ? MonitoringPlatform.web
            : defaultTargetPlatform == TargetPlatform.android
                ? MonitoringPlatform.android
                : defaultTargetPlatform == TargetPlatform.iOS
                    ? MonitoringPlatform.ios
                    : MonitoringPlatform.desktop,
      );
  final previousFlutterError = FlutterError.onError;
  FlutterError.onError = (details) {
    unawaited(monitoring.report(MonitoringCode.flutterFailure));
    previousFlutterError?.call(details);
  };
  final previousPlatformError = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(monitoring.report(MonitoringCode.platformFailure));
    return previousPlatformError?.call(error, stack) ?? false;
  };
  GoRouter.optionURLReflectsImperativeAPIs = true;
  final environment = QuestwellEnvironment.current;
  final stagingNavigation =
      environment.isStaging ? QuestwellStagingNavigation() : null;
  if (stagingNavigation != null) {
    SharedPreferences.setPrefix('flutter.questwell.staging.');
    setUrlStrategy(stagingNavigation);
  } else {
    usePathUrlStrategy();
  }

  final bootstrap = QuestwellBootstrap(
    captureCallback: () {
      if (kIsWeb) environment.verifyWebLocation(Uri.base);
      QuestwellAuthCallback.capture(Uri.base);
    },
    initializeBackend: () async {
      try {
        if (monitoringCheck) {
          await monitoring.report(MonitoringCode.probe);
          throw StateError('Questwell diagnostic startup check');
        }
        await SupaFlow.initialize();
      } catch (_) {
        unawaited(monitoring.report(MonitoringCode.backendStartup));
        rethrow;
      } finally {
        stagingNavigation?.finishCallback();
      }
    },
    initializePreferences: () async {
      try {
        await FlutterFlowTheme.initialize();
      } catch (_) {
        unawaited(monitoring.report(MonitoringCode.preferencesStartup));
        rethrow;
      }
    },
  );
  final startup = QuestwellStartup(
    initialize: bootstrap.run,
    appBuilder: (_) => MyApp(initialLocation: stagingNavigation?.getPath()),
  );
  runApp(environment.isStaging
      ? Directionality(
          textDirection: TextDirection.ltr,
          child: Banner(
            message: 'STAGING',
            location: BannerLocation.topEnd,
            child: startup,
          ),
        )
      : startup);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.initialLocation});
  final String? initialLocation;

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.path;
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();

  late Stream<BaseAuthUser> userStream;
  StreamSubscription<AuthState>? _recoverySubscription;

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier,
        initialLocation: widget.initialLocation);
    userStream = projectMomentumSupabaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
      }, onError: _handleAuthStreamError);
    jwtTokenStream.listen((_) {}, onError: _handleAuthStreamError);
    _recoverySubscription = SupaFlow.client.auth.onAuthStateChange.listen((
      state,
    ) {
      if (state.event == AuthChangeEvent.passwordRecovery && mounted) {
        QuestwellAuthCallback.recovering = true;
        QuestwellAuthCallback.linkFailed = false;
        _router.go('/authPage?recovery=true');
      }
    }, onError: _handleAuthStreamError);
    Future.delayed(
      const Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  @override
  void dispose() {
    _recoverySubscription?.cancel();
    super.dispose();
  }

  void _handleAuthStreamError(Object error, StackTrace stack) {
    // Consume callback errors on every auth subscription. Never log link tokens.
    if (QuestwellAuthCallback.needsAuthScreen) {
      QuestwellAuthCallback.linkFailed = true;
      if (mounted) _router.go('/authPage');
    }
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Questwell',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(brightness: Brightness.light, useMaterial3: false),
      darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: false),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
