import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/services/questwell_export_client.dart';
import 'package:project_momentum/services/questwell_export_save_ios.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('questwell/account_export');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late PreparedAccountExport export;

  setUp(() {
    export = PreparedAccountExport(Uint8List.fromList([123, 125]), () => true);
  });
  tearDown(() {
    export.dispose();
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('iOS receives only validated bytes and reports save completion',
      () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'save');
      expect(call.arguments, [123, 125]);
      return true;
    });
    expect(await saveAccountExportIOS(export), isTrue);
  });

  test('iOS cancellation reports false without another request', () async {
    var calls = 0;
    messenger.setMockMethodCallHandler(channel, (_) async {
      calls++;
      return false;
    });
    expect(await saveAccountExportIOS(export), isFalse);
    expect(calls, 1);
  });

  test('native errors never expose a path or private content', () async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(
          code: 'failure', message: 'private path and data');
    });
    await expectLater(
      saveAccountExportIOS(export),
      throwsA(isA<AccountExportException>().having(
        (error) => error.message,
        'message',
        'Could not save your data. Please try again.',
      )),
    );
  });

  test('missing native adapter fails safely', () async {
    await expectLater(
      saveAccountExportIOS(export),
      throwsA(isA<AccountExportException>().having(
        (error) => error.message,
        'message',
        'Saving is unavailable on this device.',
      )),
    );
  });

  test('discarded or changed sessions never reach native storage', () async {
    var calls = 0;
    messenger.setMockMethodCallHandler(channel, (_) async {
      calls++;
      return true;
    });
    export.dispose();
    await expectLater(
        saveAccountExportIOS(export), throwsA(isA<AccountExportException>()));
    final stale = PreparedAccountExport(Uint8List.fromList([1]), () => false);
    await expectLater(
        saveAccountExportIOS(stale), throwsA(isA<AccountExportException>()));
    expect(calls, 0);
  });
}
