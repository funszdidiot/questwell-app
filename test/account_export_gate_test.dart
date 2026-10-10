import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/services/questwell_account_export.dart';
import 'package:project_momentum/services/questwell_export_client.dart';

void main() {
  test('isolated build cannot construct a live export client', () {
    expect(
        QuestwellAccountExport.prepare, throwsA(isA<AccountExportException>()));
  });
}
