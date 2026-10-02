import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/services/questwell_purchase_recovery.dart';
import 'package:project_momentum/services/questwell_cosmetic_sync.dart';

void main() {
  test('Lost response confirms committed ownership without sending twice', () async {
    var coins = 100, writes = 0, reads = 0;
    var owned = false;
    final sync = QuestwellCosmeticSync();
    addTearDown(sync.dispose);
    var notifications = 0;
    sync.addListener(() => notifications++);
    final result = await sync.write(() => QuestwellPurchaseRecovery.run(
      attempt: () async {
        writes++; coins -= 30; owned = true;
        throw TimeoutException('response lost after commit');
      },
      confirmOwned: () async { reads++; return owned ? coins : null; },
    ));
    expect(result, 70);
    expect(writes, 1);
    expect(reads, 1);
    expect(notifications, 1);
  });

  test('Disconnect before commit leaves coins and inventory untouched', () async {
    var writes = 0;
    final failure = TimeoutException('request never reached server');
    await expectLater(QuestwellPurchaseRecovery.run(
      attempt: () async { writes++; throw failure; },
      confirmOwned: () async => null,
    ), throwsA(same(failure)));
    expect(writes, 1);
  });

  test('Offline confirmation preserves failure; explicit retry charges once', () async {
    var coins = 100, owned = false, writes = 0;
    final failure = TimeoutException('response lost');
    await expectLater(QuestwellPurchaseRecovery.run(
      attempt: () async { writes++; coins -= 30; owned = true; throw failure; },
      confirmOwned: () async => throw StateError('still offline'),
    ), throwsA(same(failure)));
    final result = await QuestwellPurchaseRecovery.run(
      attempt: () async {
        writes++;
        if (!owned) { coins -= 30; owned = true; }
        return coins;
      },
      confirmOwned: () async => fail('successful response needs no recovery'),
    );
    expect(result, 70);
    expect(writes, 2);
    expect(owned, isTrue);
  });

  test('Reads wait for reconciliation and see both coins and ownership', () async {
    final sync = QuestwellCosmeticSync();
    addTearDown(sync.dispose);
    final confirmation = Completer<int?>();
    final write = sync.write(() => QuestwellPurchaseRecovery.run(
      attempt: () async => throw TimeoutException('lost response'),
      confirmOwned: () => confirmation.future,
    ));
    var readStarted = false;
    final read = sync.read(() async { readStarted = true; return 'owned:70'; });
    await Future<void>.delayed(Duration.zero);
    expect(readStarted, isFalse);
    confirmation.complete(70);
    expect(await write, 70);
    expect(await read, 'owned:70');
  });

  test('Changed-account confirmation cannot claim a successful purchase', () async {
    final failure = StateError('Authentication changed.');
    await expectLater(QuestwellPurchaseRecovery.run(
      attempt: () async => throw failure,
      confirmOwned: () async => throw StateError('Authentication changed.'),
    ), throwsA(same(failure)));
  });
}
