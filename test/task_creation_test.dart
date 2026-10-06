import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/services/questwell_task_creation.dart';

void main() {
  test('lost response retries the same request and captured account', () async {
    final sent = <Map<String, dynamic>>[];
    final creation = QuestwellTaskCreation(
      requestId: 'request-a',
      ownerId: 'owner-a',
      currentOwner: () => 'owner-a',
      send: (params) async {
        sent.add(params);
        if (sent.length == 1) throw TimeoutException('response lost');
        return 'task-a';
      },
    );
    await expectLater(
      creation.save('A small step', 2),
      throwsA(isA<TimeoutException>()),
    );
    expect(creation.started, isTrue);
    expect(await creation.save('A small step', 2), 'task-a');
    expect(sent[1], sent[0]);
    expect(sent[0]['p_expected_user_id'], 'owner-a');
    expect(sent[0]['p_request_id'], 'request-a');
    expect(await creation.save('A small step', 2), 'task-a');
    expect(sent.length, 2);
  });

  test('concurrent saves share one pending request', () async {
    var calls = 0;
    final response = Completer<String>();
    final creation = QuestwellTaskCreation(
      requestId: 'r',
      ownerId: 'a',
      currentOwner: () => 'a',
      send: (_) {
        calls++;
        return response.future;
      },
    );
    final first = creation.save('Quest', 1);
    final second = creation.save('Quest', 1);
    expect(calls, 1);
    response.complete('task');
    expect(await first, 'task');
    expect(await second, 'task');
  });

  test(
    'account switch prevents retry and rejects an old in-flight result',
    () async {
      var owner = 'a', calls = 0;
      final response = Completer<String>();
      final creation = QuestwellTaskCreation(
        requestId: 'r',
        ownerId: owner,
        currentOwner: () => owner,
        send: (_) {
          calls++;
          return response.future;
        },
      );
      final pending = creation.save('Quest', 1);
      owner = 'b';
      response.complete('task');
      await expectLater(
        pending,
        throwsA(isA<QuestwellCreationAccountChanged>()),
      );
      await expectLater(
        creation.save('Quest', 1),
        throwsA(isA<QuestwellCreationAccountChanged>()),
      );
      expect(calls, 1);
    },
  );

  test('uncertain request cannot be reused for edited content', () async {
    var calls = 0;
    final creation = QuestwellTaskCreation(
      requestId: 'r',
      ownerId: 'a',
      currentOwner: () => 'a',
      send: (_) async {
        calls++;
        throw TimeoutException('offline');
      },
    );
    await expectLater(
      creation.save('Quest', 1),
      throwsA(isA<TimeoutException>()),
    );
    await expectLater(creation.save('Edited', 1), throwsStateError);
    await expectLater(creation.save('Quest', 2), throwsStateError);
    expect(calls, 1);
  });
}
