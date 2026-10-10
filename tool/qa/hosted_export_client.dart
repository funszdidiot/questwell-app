import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:project_momentum/config/questwell_environment.dart';
import 'package:project_momentum/services/questwell_export_client.dart';

Future<void> main() async {
  final email = Platform.environment['STAGING_EXPORT_TEST_EMAIL'];
  final password = Platform.environment['STAGING_EXPORT_TEST_PASSWORD'];
  if (email == null || password == null) {
    stderr.writeln('BLOCKED: existing synthetic staging credentials required.');
    exitCode = 2;
    return;
  }
  final environment = QuestwellEnvironment.select('staging');
  final transport = http.Client();
  String? token;
  PreparedAccountExport? prepared;
  var step = 'sign-in';
  try {
    final auth = await transport
        .post(
          Uri.parse(
              '${environment.supabaseUrl}/auth/v1/token?grant_type=password'),
          headers: {
            'apikey': environment.publicKey,
            'Content-Type': 'application/json'
          },
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 30));
    if (auth.statusCode != 200) throw StateError('Sign-in failed');
    final data = jsonDecode(auth.body) as Map;
    token = data['access_token'] as String;
    final owner = (data['user'] as Map)['id'] as String;
    if (owner != '2e0c217b-950b-4122-8fc5-9e37fced985e') {
      throw StateError('Unexpected synthetic account');
    }
    final claims = jsonDecode(utf8.decode(
        base64Url.decode(base64Url.normalize(token.split('.')[1])))) as Map;
    ExportSession? session =
        ExportSession(owner, claims['session_id'] as String, token);
    final original = session;
    final client = AccountExportClient(
      endpoint:
          Uri.parse('${environment.supabaseUrl}/functions/v1/export-account'),
      publicKey: environment.publicKey,
      currentSession: () => session,
    );
    step = 'prepare-and-verify';
    prepared = await client.prepare();
    final export = jsonDecode(utf8.decode(prepared.bytes)) as Map;
    if ((export['attachments'] as List).isEmpty)
      throw StateError('Missing fixture');
    step = 'repeat-denial';
    try {
      final unexpected = await client.prepare();
      unexpected.dispose();
      throw StateError('Repeat accepted');
    } on AccountExportException catch (error) {
      if (!error.message.contains('wait a minute')) rethrow;
    }
    step = 'logout';
    final logout = await transport.post(
      Uri.parse('${environment.supabaseUrl}/auth/v1/logout?scope=local'),
      headers: {
        'apikey': environment.publicKey,
        'Authorization': 'Bearer $token'
      },
    ).timeout(const Duration(seconds: 30));
    if (![200, 204].contains(logout.statusCode))
      throw StateError('Logout failed');
    session = null;
    if (prepared.isCurrent) throw StateError('Prepared export survived logout');
    prepared.dispose();
    step = 'revoked-token-denial';
    session = original;
    try {
      final unexpected = await client.prepare();
      unexpected.dispose();
      throw StateError('Revoked token accepted');
    } on AccountExportException catch (error) {
      if (!error.message.contains('Sign in again')) rethrow;
    }
    token = null;
    stdout.writeln(
        'PASS: Dart client verified owner-scoped staging export and attachment integrity; repeat throttled; prepared data invalidated on logout; revoked token denied. No private content logged or saved.');
  } catch (_) {
    stderr.writeln('FAIL: stage=$step. No private content logged or saved.');
    exitCode = 1;
  } finally {
    prepared?.dispose();
    if (token != null) {
      try {
        await transport.post(
          Uri.parse('${environment.supabaseUrl}/auth/v1/logout?scope=local'),
          headers: {
            'apikey': environment.publicKey,
            'Authorization': 'Bearer $token'
          },
        ).timeout(const Duration(seconds: 15));
      } catch (_) {}
    }
    transport.close();
  }
}
