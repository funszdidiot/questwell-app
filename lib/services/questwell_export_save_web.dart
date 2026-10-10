import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'questwell_export_client.dart';

Future<bool> saveAccountExport(PreparedAccountExport export) async {
  // Run synchronously from the Save tap; no network await loses user activation.
  final blob = web.Blob(
    [export.bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/json'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = 'questwell-account-export.json';
  try {
    web.document.body!.append(anchor);
    anchor.click();
  } finally {
    anchor.remove();
    // Browsers may consume the blob after the click returns.
    Timer(const Duration(seconds: 30), () => web.URL.revokeObjectURL(url));
  }
  // The browser does not expose whether the user completed the download.
  return true;
}
