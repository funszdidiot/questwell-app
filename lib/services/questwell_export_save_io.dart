import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'questwell_export_client.dart';

Future<bool> saveAccountExport(PreparedAccountExport export) async {
  final suffix = List.generate(
    12,
    (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  final name = 'questwell-account-export-$suffix.json';
  // file_picker 8.1.7 stages iOS exports in Documents. Remove only this
  // operation's randomly named source after success, cancellation or failure.
  final source = Platform.isIOS
      ? File('${(await getApplicationDocumentsDirectory()).path}/$name')
      : null;
  String? destination;
  try {
    destination = await FilePicker.platform.saveFile(
      dialogTitle: 'Save your Questwell data',
      fileName: name,
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: export.bytes,
    );
    if (destination == null) return false;
    // In this pinned version desktop dialogs return a path without writing.
    if (!Platform.isIOS && !Platform.isAndroid) {
      await File(destination).writeAsBytes(export.bytes, flush: true);
    }
    return true;
  } finally {
    if (source != null && source.path != destination && await source.exists()) {
      await source.delete();
    }
  }
}
