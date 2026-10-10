import 'questwell_export_client.dart';

Future<bool> saveAccountExport(PreparedAccountExport export) =>
    throw const AccountExportException('Saving is unavailable on this device.');
