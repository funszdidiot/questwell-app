import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/services/questwell_boss_creation_recovery.dart';

void main() {
  test('concurrent calls share one pending transport', () async {
    final recovery = QuestwellBossCreationRecovery();
    final pending = Completer<String>();
    var writes = 0;
    Future<String> send(String id) {
      writes++;
      return pending.future;
    }

    final first = recovery.create(key: 'A/draft', send: send);
    final second = recovery.create(key: 'A/draft', send: send);
    expect(writes, 1);
    pending.complete('saved');
    expect(await first, 'saved');
    expect(await second, 'saved');
  });
  test(
    'a never-settling transport can retry the same server identity',
    () async {
      final recovery = QuestwellBossCreationRecovery();
      final pending = Completer<String>();
      final ids = <String>[];
      Future<String> send(String id) {
        ids.add(id);
        return ids.length == 1
            ? pending.future
            : Future.value('original-battle');
      }

      await expectLater(
        recovery.create(
          key: 'A/draft',
          send: send,
          wait: (request) => request.timeout(Duration.zero),
        ),
        throwsA(isA<TimeoutException>()),
      );
      expect(
        await recovery.create(key: 'A/draft', send: send),
        'original-battle',
      );
      expect(ids.length, 2);
      expect(ids[0], ids[1]);
      pending.complete('original-battle');
      await Future<void>.value();
      expect(
        await recovery.create(key: 'A/draft', send: send),
        'original-battle',
      );
      expect(ids.length, 2);
    },
  );
  test(
    'failed transport retries with the same identity and reconciles success',
    () async {
      final recovery = QuestwellBossCreationRecovery();
      final ids = <String>[];
      Future<String> send(String requestId) async {
        ids.add(requestId);
        if (ids.length == 1) throw StateError('accepted but response lost');
        return 'original-battle';
      }

      await expectLater(
        recovery.create(key: 'A/draft', send: send),
        throwsStateError,
      );
      recovery.acknowledge(['unrelated']);
      expect(
        await recovery.create(key: 'A/draft', send: send),
        'original-battle',
      );
      expect(ids.length, 2);
      expect(ids[0], ids[1]);
      expect(ids[0], matches(RegExp(r'^[0-9a-f-]{36}$')));
    },
  );
  test(
    'blank success is unconfirmed and can retry the same identity',
    () async {
      final recovery = QuestwellBossCreationRecovery();
      final ids = <String>[];
      Future<String> send(String id) async {
        ids.add(id);
        return ids.length == 1 ? '' : 'saved';
      }

      await expectLater(
        recovery.create(key: 'A/draft', send: send),
        throwsException,
      );
      expect(await recovery.create(key: 'A/draft', send: send), 'saved');
      expect(ids[0], ids[1]);
    },
  );
  test('accounts do not share request identities', () async {
    final recovery = QuestwellBossCreationRecovery();
    final ids = <String>[];
    Future<String> send(String id) async {
      ids.add(id);
      return id;
    }

    await recovery.create(key: 'A/draft', send: send);
    await recovery.create(key: 'B/draft', send: send);
    expect(ids.toSet().length, 2);
  });
  test(
    'confirmation is retained until that specific battle is observed',
    () async {
      final recovery = QuestwellBossCreationRecovery();
      final ids = <String>[];
      Future<String> send(String id) async {
        ids.add(id);
        return 'battle-${ids.length}';
      }

      Future<String> create() => recovery.create(key: 'A/draft', send: send);
      expect(await create(), 'battle-1');
      recovery.acknowledge(['unrelated']);
      expect(await create(), 'battle-1');
      expect(ids.length, 1);
      recovery.acknowledge(['battle-1']);
      expect(await create(), 'battle-2');
      expect(ids.toSet().length, 2);
    },
  );
}
