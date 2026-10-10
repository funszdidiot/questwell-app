import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_momentum/services/questwell_export_client.dart';
import 'package:project_momentum/widgets/questwell_export_panel.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  Future<void> mount(
    WidgetTester tester,
    Future<PreparedAccountExport> Function() prepare,
    Future<bool> Function(PreparedAccountExport) save,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: QuestwellExportPanel(prepare: prepare, save: save),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('download needs a second tap to save and clears after handoff', (
    tester,
  ) async {
    var requests = 0;
    var saves = 0;
    final bytes = Uint8List.fromList([1, 2, 3]);
    await mount(
      tester,
      () async {
        requests++;
        return PreparedAccountExport(bytes, () => true);
      },
      (export) async {
        saves++;
        expect(export.bytes, [1, 2, 3]);
        return true;
      },
    );
    expect(requests, 0);
    await tester.ensureVisible(find.text('Download my data'));
    await tester.tap(find.text('Download my data'));
    await tester.pumpAndSettle();
    expect(requests, 1);
    expect(saves, 0);
    await tester.ensureVisible(find.text('Save data file'));
    await tester.tap(find.text('Save data file'));
    await tester.pumpAndSettle();
    expect(saves, 1);
    expect(bytes, [0, 0, 0]);
    expect(find.textContaining('Save request sent'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('duplicate tap is disabled and leaving discards late response', (
    tester,
  ) async {
    final pending = Completer<PreparedAccountExport>();
    final bytes = Uint8List.fromList([7]);
    var requests = 0;
    await mount(tester, () {
      requests++;
      return pending.future;
    }, (_) async => false);
    await tester.ensureVisible(find.text('Download my data'));
    await tester.tap(find.text('Download my data'));
    await tester.pump();
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNull,
    );
    expect(requests, 1);
    await tester.pumpWidget(const SizedBox());
    pending.complete(PreparedAccountExport(bytes, () => true));
    await tester.pump();
    expect(bytes, [0]);
    expect(tester.takeException(), isNull);
  });

  for (final scenario in [
    'cancel',
    'discard',
    'session',
    'expiry',
    'failure',
  ]) {
    testWidgets('$scenario clears private bytes without a false saved claim', (
      tester,
    ) async {
      final bytes = Uint8List.fromList([9]);
      var valid = true;
      var saves = 0;
      await mount(
        tester,
        () async => PreparedAccountExport(bytes, () => valid),
        (_) async {
          saves++;
          if (scenario == 'failure') throw StateError('PRIVATE_MARKER');
          return false;
        },
      );
      await tester.ensureVisible(find.text('Download my data'));
      await tester.tap(find.text('Download my data'));
      await tester.pumpAndSettle();
      if (scenario == 'expiry') {
        await tester.pump(const Duration(minutes: 2));
      } else {
        if (scenario == 'session') valid = false;
        final label =
            scenario == 'discard' ? 'Discard download' : 'Save data file';
        await tester.ensureVisible(find.text(label));
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
      }
      expect(bytes, [0]);
      expect(saves, ['cancel', 'failure'].contains(scenario) ? 1 : 0);
      expect(find.textContaining('Save request sent'), findsNothing);
      expect(find.textContaining('PRIVATE_MARKER'), findsNothing);
      expect(find.text('Download my data'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
