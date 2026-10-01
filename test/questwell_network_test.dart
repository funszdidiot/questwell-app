import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/backend/supabase/questwell_network.dart';

void main() {
  test('read retries one transient socket failure', () async {
    var calls = 0;
    final result = await QuestwellNetwork.read(() async {
      calls++;
      if (calls == 1) {
        throw const SocketException('offline');
      }
      return 'ok';
    });

    expect(result, 'ok');
    expect(calls, 2);
  });

  test('read converts repeated socket failures to app exception', () async {
    expect(
      () => QuestwellNetwork.read<String>(
        () async => throw const SocketException('offline'),
      ),
      throwsA(isA<QuestwellNetworkException>()),
    );
  });

  test('write never retries an ambiguous failed mutation', () async {
    var calls = 0;
    expect(
      () => QuestwellNetwork.write<void>(() async {
        calls++;
        throw const SocketException('offline');
      }),
      throwsA(isA<QuestwellNetworkException>()),
    );
    await Future<void>.delayed(Duration.zero);
    expect(calls, 1);
  });
}
