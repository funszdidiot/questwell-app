import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/config/questwell_environment.dart';

void main() {
  test('test runner explicitly uses the isolated non-live target', () {
    final config = QuestwellEnvironment.current;
    expect(config.name, 'isolated_test');
    expect(Uri.parse(config.supabaseUrl).host, '127.0.0.1');
    expect(Uri.parse(config.supabaseUrl).port, 1);
    expect(config.authReturnUrl, 'http://127.0.0.1:1/');
  });

  test('missing and unapproved environment names fail closed', () {
    for (final name in [
      '',
      'production',
      'staging',
      'live-beta',
      ' live_beta',
    ]) {
      expect(() => QuestwellEnvironment.select(name), throwsStateError);
    }
  });

  test(
    'live beta preserves its existing project and callback as one profile',
    () {
      final config = QuestwellEnvironment.select('live_beta');
      expect(config.supabaseUrl, 'https://bdzcazkyypopbanbjnud.supabase.co');
      expect(
        config.authReturnUrl,
        'https://funszdidiot.github.io/questwell-app/',
      );
      final claims = jsonDecode(
        utf8.decode(
          base64Url.decode(base64Url.normalize(config.publicKey.split('.')[1])),
        ),
      ) as Map<String, dynamic>;
      expect(claims['role'], 'anon');
      expect(claims['ref'], 'bdzcazkyypopbanbjnud');
    },
  );

  test('isolated profile cannot inherit any live beta endpoint or key', () {
    final isolated = QuestwellEnvironment.select('isolated_test');
    final live = QuestwellEnvironment.select('live_beta');
    expect(isolated.supabaseUrl, isNot(live.supabaseUrl));
    expect(isolated.publicKey, isNot(live.publicKey));
    expect(isolated.authReturnUrl, isNot(live.authReturnUrl));
  });
}
