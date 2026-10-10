import 'package:flutter/services.dart';
import 'questwell_export_client.dart';

Future<bool> saveAccountExportIOS(PreparedAccountExport export) async {
  // Check session/expiry before transferring any bytes to the native adapter.
  final bytes = export.bytes;
  try {
    return await const MethodChannel('questwell/account_export')
            .invokeMethod<bool>('save', bytes) ??
        false;
  } on PlatformException {
    throw const AccountExportException(
      'Could not save your data. Please try again.',
    );
  } on MissingPluginException {
    throw const AccountExportException('Saving is unavailable on this device.');
  }
}
