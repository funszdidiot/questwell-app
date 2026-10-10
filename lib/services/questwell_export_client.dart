import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class AccountExportException implements Exception {
  const AccountExportException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ExportSession {
  const ExportSession(this.ownerId, this.sessionId, this.accessToken);
  final String ownerId, sessionId, accessToken;
  bool sameSession(ExportSession? other) =>
      other != null && ownerId == other.ownerId && sessionId == other.sessionId;
}

/// Private bytes live only for this screen's short prepare/save interaction.
class PreparedAccountExport {
  PreparedAccountExport(this._bytes, this._isCurrent);
  Uint8List? _bytes;
  final bool Function() _isCurrent;
  final _expires = DateTime.now().add(const Duration(minutes: 2));
  bool get isCurrent =>
      _bytes != null && DateTime.now().isBefore(_expires) && _isCurrent();
  Uint8List get bytes {
    if (!isCurrent) {
      dispose();
      throw const AccountExportException('Please prepare a new download.');
    }
    return _bytes!;
  }

  void dispose() {
    _bytes?.fillRange(0, _bytes!.length, 0);
    _bytes = null;
  }
}

class AccountExportClient {
  AccountExportClient({
    required this.endpoint,
    required this.publicKey,
    required this.currentSession,
    http.Client Function()? createClient,
    this.maxBytes = 40 * 1024 * 1024,
    this.timeout = const Duration(seconds: 60),
  }) : _createClient = createClient ?? http.Client.new;

  final Uri endpoint;
  final String publicKey;
  final ExportSession? Function() currentSession;
  final http.Client Function() _createClient;
  final int maxBytes;
  final Duration timeout;
  bool _busy = false;

  Future<PreparedAccountExport> prepare() async {
    final session = currentSession();
    if (session == null) {
      throw const AccountExportException(
        'Sign in again to download your data.',
      );
    }
    if (_busy) {
      throw const AccountExportException(
        'A download is already being prepared.',
      );
    }
    _busy = true;
    final client = _createClient();
    var active = true;
    try {
      return await _prepare(client, session, () => active).timeout(timeout,
          onTimeout: () {
        active = false;
        throw TimeoutException('Export timed out');
      });
    } on AccountExportException {
      rethrow;
    } catch (_) {
      // Never propagate HTTP bodies, tokens, file paths or account records.
      throw const AccountExportException(
        'Could not prepare your data. Please try again.',
      );
    } finally {
      active = false;
      client.close();
      _busy = false;
    }
  }

  Future<PreparedAccountExport> _prepare(
    http.Client client,
    ExportSession session,
    bool Function() active,
  ) async {
    final request = http.Request('POST', endpoint)
      ..followRedirects = false
      ..headers.addAll({
        'Authorization': 'Bearer ${session.accessToken}',
        'apikey': publicKey,
        'Accept': 'application/json',
      });
    // One empty POST; no owner argument, durable URL, telemetry or retry.
    final response = await client.send(request);
    if (response.statusCode != 200) {
      await response.stream.listen((_) {}).cancel();
      throw AccountExportException(switch (response.statusCode) {
        401 || 403 => 'Sign in again to download your data.',
        429 => 'Please wait a minute before preparing another download.',
        503 => 'Downloads are unavailable right now. Please try again later.',
        _ => 'Could not prepare your data. Please try again.',
      });
    }
    if (!(response.headers['content-type'] ?? '').toLowerCase().startsWith(
              'application/json',
            ) ||
        !(response.headers['cache-control'] ?? '').contains('no-store') ||
        (response.contentLength ?? 0) > maxBytes) {
      throw const AccountExportException('The download could not be verified.');
    }
    final builder = BytesBuilder(copy: false);
    await for (final chunk in response.stream) {
      if (!active()) throw const FormatException('Export cancelled');
      if (builder.length + chunk.length > maxBytes) {
        throw const AccountExportException(
          'The download is too large to save.',
        );
      }
      builder.add(chunk);
    }
    final bytes = builder.takeBytes();
    try {
      _validate(bytes, session.ownerId);
      if (!active() || !session.sameSession(currentSession())) {
        throw const AccountExportException(
          'Your session changed. Please prepare a new download.',
        );
      }
      return PreparedAccountExport(
        bytes,
        () => session.sameSession(currentSession()),
      );
    } catch (_) {
      bytes.fillRange(0, bytes.length, 0);
      rethrow;
    }
  }

  static const _tables = {
    'users',
    'tasks',
    'boss_battles',
    'boss_steps',
    'user_cosmetics',
    'progression_events',
    'reward_events',
    'beta_feedback',
  };

  static void _validate(Uint8List bytes, String owner) {
    final data = jsonDecode(utf8.decode(bytes));
    if (data is! Map ||
        data['format'] != 'questwell-account-export' ||
        data['version'] != 1 ||
        data['tables'] is! Map ||
        data['attachments'] is! List) {
      throw const FormatException('Invalid export');
    }
    final tables = data['tables'] as Map;
    if (tables.length != _tables.length || !_tables.every(tables.containsKey))
      throw const FormatException('Missing tables');
    for (final table in _tables) {
      final rows = tables[table];
      if (rows is! List ||
          (table == 'users' && rows.length != 1) ||
          rows.any(
            (row) =>
                row is! Map ||
                row[table == 'users' ? 'id' : 'user_id'] != owner,
          )) {
        throw const FormatException('Invalid owner');
      }
    }
    final paths = <String>{};
    for (final row in tables['beta_feedback'] as List) {
      final path = row['attachment_path'];
      final more = row['attachment_paths'];
      if (path != null) paths.add(path as String);
      if (more != null) paths.addAll((more as List).cast<String>());
    }
    final seen = <String>{};
    var total = 0;
    for (final item in data['attachments'] as List) {
      if (item is! Map ||
          item['path'] is! String ||
          !paths.contains(item['path']) ||
          !seen.add(item['path'] as String) ||
          !(item['path'] as String).startsWith('$owner/') ||
          item['encoding'] != 'base64' ||
          item['data'] is! String) {
        throw const FormatException('Invalid attachment');
      }
      final raw = base64Decode(item['data'] as String);
      total += raw.length;
      if (raw.length > 5 * 1024 * 1024 ||
          total > 25 * 1024 * 1024 ||
          raw.length != item['size'] ||
          sha256.convert(raw).toString() != item['sha256']) {
        throw const FormatException('Invalid attachment checksum');
      }
    }
    if (seen.length != paths.length || seen.length > 100) {
      throw const FormatException('Missing attachment');
    }
  }
}
