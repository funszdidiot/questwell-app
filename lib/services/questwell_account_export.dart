import 'dart:convert';

import '/backend/supabase/supabase.dart';
import '/config/questwell_environment.dart';
import 'questwell_export_client.dart';

class QuestwellAccountExport {
  static AccountExportClient? _client;

  static ExportSession? _session() {
    final session = SupaFlow.client.auth.currentSession;
    if (session == null || session.isExpired || session.user.isAnonymous) {
      return null;
    }
    try {
      final claims = jsonDecode(
        utf8.decode(
          base64Url.decode(
            base64Url.normalize(session.accessToken.split('.')[1]),
          ),
        ),
      );
      final id = claims['session_id'];
      if (id is! String || id.isEmpty) return null;
      return ExportSession(session.user.id, id, session.accessToken);
    } catch (_) {
      return null;
    }
  }

  static Future<PreparedAccountExport> prepare() {
    final environment = QuestwellEnvironment.current;
    // Production activation is a separate reviewed change after save acceptance.
    if (!environment.isStaging) {
      throw const AccountExportException('Downloads are not available yet.');
    }
    return (_client ??= AccountExportClient(
      endpoint: Uri.parse(
        '${environment.supabaseUrl}/functions/v1/export-account',
      ),
      publicKey: environment.publicKey,
      currentSession: _session,
    ))
        .prepare();
  }
}
