import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/services/questwell_cosmetic_sync.dart';

void main() {
  test('Hearth read waits for an appearance save already in flight', () async {
    final sync = QuestwellCosmeticSync();
    addTearDown(sync.dispose);
    final saved = Completer<void>();
    var body = 'female', reads = 0, notifications = 0;
    sync.addListener(() => notifications++);
    final write = sync.write(() async { await saved.future; body = 'male'; });
    final home = sync.read(() async { reads++; return body; });
    await Future<void>.delayed(Duration.zero);
    expect(reads, 0);
    saved.complete();
    await write;
    expect(await home, 'male');
    expect(notifications, 1);
  });

  test('A stale read cannot overwrite a newer class selection', () async {
    final sync = QuestwellCosmeticSync();
    addTearDown(sync.dispose);
    final old = Completer<String>();
    var reads = 0;
    final home = sync.read(() { reads++; return reads == 1 ? old.future : Future.value('guardian'); });
    await Future<void>.delayed(Duration.zero);
    await sync.write(() async {});
    old.complete('scholar');
    expect(await home, 'guardian');
    expect(reads, 2);
  });

  test('Failed save releases reads and later writes remain usable', () async {
    final sync = QuestwellCosmeticSync();
    addTearDown(sync.dispose);
    var changes = 0;
    sync.addListener(() => changes++);
    await expectLater(sync.write(() async { throw StateError('offline'); }), throwsStateError);
    expect(await sync.read(() async => 'previous selection'), 'previous selection');
    expect(changes, 0);
    await sync.write(() async {});
    expect(changes, 1);
  });

  test('Rapid changes commit in selection order', () async {
    final sync = QuestwellCosmeticSync();
    addTearDown(sync.dispose);
    final first = Completer<void>();
    final order = <String>[];
    final a = sync.write(() async { await first.future; order.add('body'); });
    final b = sync.write(() async { order.add('class'); });
    final read = sync.read(() async => order.toList());
    await Future<void>.delayed(Duration.zero);
    expect(order, isEmpty);
    first.complete();
    await Future.wait([a,b]);
    expect(await read, ['body','class']);
  });
}
