import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'questwell_export_client.dart';
import 'questwell_export_save_ios.dart';

Future<bool> saveAccountExport(PreparedAccountExport export) async {
  if (Platform.isIOS) return saveAccountExportIOS(export);
  final suffix = List.generate(
    12,
    (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  final name = 'questwell-account-export-$suffix.json';
  final destination = await FilePicker.platform.saveFile(
    dialogTitle: 'Save your Questwell data',
    fileName: name,
    type: FileType.custom,
    allowedExtensions: ['json'],
    bytes: export.bytes,
  );
  if (destination == null) return false;
  // In this pinned version desktop dialogs return a path without writing.
  if (!Platform.isAndroid) {
    await File(destination).writeAsBytes(export.bytes, flush: true);
  }
  return true;
}
