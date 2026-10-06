import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/services/questwell_boss_creation_recovery.dart';

void main() {
  test(
    'retry reuses a timed-out write even when a list read precedes its commit',
    () async {
      final recovery = QuestwellBossCreationRecovery();
      final pending = Completer<String>();
      var writes = 0;
      Future<String> send() {
        writes++;
        return pending.future;
      }

      await expectLater(
        recovery.create(
          key: 'account A/draft',
          send: send,
          rejected: (_) => false,
          wait: (request) => request.timeout(Duration.zero),
        ),
        throwsA(isA<TimeoutException>()),
      );
      // A successful list read is not evidence that the original write failed.
      await Future<void>.value();
      final retry = recovery.create(
        key: 'account A/draft',
        send: send,
        rejected: (_) => false,
      );
      pending.complete('original-battle');
      expect(await retry, 'original-battle');
      expect(writes, 1);
    },
  );
  test(
    'lost responses stay blocked; definite rejection permits retry',
    () async {
      final recovery = QuestwellBossCreationRecovery();
      var writes = 0;
      Future<String> lost() async {
        writes++;
        throw StateError('response lost');
      }

      for (var i = 0; i < 2; i++) {
        await expectLater(
          recovery.create(key: 'A/lost', send: lost, rejected: (_) => false),
          throwsStateError,
        );
      }
      expect(writes, 1);
      for (var i = 0; i < 2; i++) {
        await expectLater(
          recovery.create(key: 'A/rejected', send: lost, rejected: (_) => true),
          throwsStateError,
        );
      }
      expect(writes, 3);
    },
  );
  test('accounts do not share a pending request', () async {
    final recovery = QuestwellBossCreationRecovery();
    final pending = Completer<String>();
    final first = recovery.create(
      key: 'A/draft',
      send: () => pending.future,
      rejected: (_) => false,
    );
    expect(
      await recovery.create(
        key: 'B/draft',
        send: () async => 'B-battle',
        rejected: (_) => false,
      ),
      'B-battle',
    );
    pending.complete('A-battle');
    expect(await first, 'A-battle');
  });
}
