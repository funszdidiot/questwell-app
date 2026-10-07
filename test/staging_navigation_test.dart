import 'package:flutter/material.dart';
import 'package:project_momentum/flutter_flow/nav/nav.dart';
import 'package:project_momentum/startup/questwell_startup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:project_momentum/config/questwell_staging_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeLocation extends BrowserPlatformLocation {
  FakeLocation(this.current);
  Uri current;
  final writes = <String>[];
  @override
  String get hash => current.hasFragment ? '#${current.fragment}' : '';
  @override
  String get pathname => current.path;
  @override
  String get search => current.hasQuery ? '?${current.query}' : '';
  @override
  void replaceState(Object? state, String title, String url) {
    writes.add(url);
    current = current.resolve(url);
  }

  @override
  void pushState(Object? state, String title, String url) {
    writes.add(url);
    current = current.resolve(url);
  }
}

void main() {
  for (final fragment in [
    'access_token=private&refresh_token=private&type=recovery',
    'error_description=private&error_code=expired',
    'malformed-private-fragment',
  ]) {
    test('callback is hidden until consumed: ${fragment.split('=').first}', () {
      final location = FakeLocation(Uri.parse(
        'https://funszdidiot.github.io/questwell-app/staging/'
        '?recovery=true&error_description=private#$fragment',
      ));
      final navigation = QuestwellStagingNavigation(location);
      expect(navigation.getPath(), '/');
      navigation.replaceState(null, '', '/');
      navigation.pushState(null, '', '/authPage');
      expect(location.writes, isEmpty);
      expect(location.current.fragment, fragment);
      navigation.finishCallback();
      expect(location.current.toString(),
          'https://funszdidiot.github.io/questwell-app/staging/?recovery=true#/');
      expect(navigation.getPath(), '/');
      expect(location.writes.single, isNot(contains('private')));
    });
  }

  test('ordinary hash routes survive startup and reload', () {
    final location = FakeLocation(Uri.parse(
      'https://funszdidiot.github.io/questwell-app/staging/#/questBoard',
    ));
    final navigation = QuestwellStagingNavigation(location);
    expect(navigation.getPath(), '/');
    navigation.finishCallback();
    expect(navigation.getPath(), '/questBoard');
    expect(location.writes, isEmpty);
  });

  testWidgets('startup hands sanitized hash route to the actual app router',
      (tester) async {
    final location = FakeLocation(Uri.parse(
      'https://funszdidiot.github.io/questwell-app/staging/#/questBoard',
    ));
    final navigation = QuestwellStagingNavigation(location);
    GoRouter? router;
    addTearDown(() => router?.dispose());
    await tester.pumpWidget(QuestwellStartup(
      initialize: () async {
        navigation.finishCallback();
      },
      appBuilder: (_) {
        router = createRouter(AppStateNotifier.instance,
            initialLocation: navigation.getPath());
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Text(router!.routeInformationProvider.value.uri.path),
        );
      },
    ));
    await tester.pumpAndSettle();
    expect(find.text('/questBoard'), findsOneWidget);
    expect(location.writes, isEmpty);
  });

  test('staging prefix isolates identical account keys from live preferences',
      () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({
      'flutter.questwell_feedback_draft_same-uid': 'live draft',
      'flutter.questwell.staging.questwell_feedback_draft_same-uid':
          'test draft',
      'flutter.__theme_mode__': true,
    });
    SharedPreferences.setPrefix('flutter.questwell.staging.');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('questwell_feedback_draft_same-uid'), 'test draft');
    expect(prefs.getBool('__theme_mode__'), isNull);
    await prefs.remove('questwell_feedback_draft_same-uid');
    expect(prefs.getString('questwell_feedback_draft_same-uid'), isNull);
    SharedPreferences.resetStatic();
  });
}
