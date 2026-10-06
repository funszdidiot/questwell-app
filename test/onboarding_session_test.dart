import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/services/questwell_onboarding_session.dart';

void main() {
  test('starter and skip share one in-flight submission', () async {
    final pending = Completer<dynamic>();
    final sent = <Map<String, dynamic>>[];
    final session = QuestwellOnboardingSession(
      ownerId: 'a',
      currentOwner: () => 'a',
      send: (params) {
        sent.add(params);
        return pending.future;
      },
    );
    final first = session.finish('email');
    final second = session.finish(null);
    expect(sent.length, 1);
    expect(sent.single, {'p_expected_user_id': 'a', 'p_starter_key': 'email'});
    pending.complete({'status': 'completed', 'task_id': 'task-a'});
    expect((await first).completed, isTrue);
    expect((await second).taskId, 'task-a');
  });

  test(
    'an unconfirmed write can safely retry the account-scoped operation',
    () async {
      var calls = 0;
      final session = QuestwellOnboardingSession(
        ownerId: 'a',
        currentOwner: () => 'a',
        send: (_) async {
          if (++calls == 1) throw TimeoutException('lost response');
          return {'status': 'completed', 'task_id': 'original-task'};
        },
      );
      await expectLater(
        session.finish('email'),
        throwsA(isA<TimeoutException>()),
      );
      expect((await session.finish('email')).taskId, 'original-task');
      expect(calls, 2);
    },
  );

  test('account changes reject both late results and later retries', () async {
    var owner = 'a', calls = 0;
    final pending = Completer<dynamic>();
    final session = QuestwellOnboardingSession(
      ownerId: owner,
      currentOwner: () => owner,
      send: (_) {
        calls++;
        return pending.future;
      },
    );
    final request = session.finish('files');
    owner = 'b';
    pending.complete({'status': 'completed', 'task_id': 'task-a'});
    await expectLater(
      request,
      throwsA(isA<QuestwellOnboardingAccountChanged>()),
    );
    await expectLater(
      session.finish('files'),
      throwsA(isA<QuestwellOnboardingAccountChanged>()),
    );
    expect(calls, 1);
  });

  test(
    'legacy ambiguity remains incomplete until explicit skip confirmation',
    () async {
      final session = QuestwellOnboardingSession(
        ownerId: 'a',
        currentOwner: () => 'a',
        send: (params) async => params['p_starter_key'] == null
            ? {'status': 'completed', 'task_id': null}
            : {'status': 'needs_confirmation', 'task_id': null},
      );
      expect((await session.finish('avoided')).completed, isFalse);
      expect((await session.finish(null)).completed, isTrue);
    },
  );

  test('malformed responses cannot report completed setup', () async {
    for (final response in [
      null,
      [],
      {},
      {'status': 'other'},
      {'status': 'completed', 'task_id': 42},
    ]) {
      final session = QuestwellOnboardingSession(
        ownerId: 'a',
        currentOwner: () => 'a',
        send: (_) async => response,
      );
      await expectLater(session.finish('email'), throwsFormatException);
    }
  });
}
