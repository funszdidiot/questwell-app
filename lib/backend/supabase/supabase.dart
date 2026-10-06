import 'package:project_momentum/config/questwell_environment.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

export 'database/database.dart';

class SupaFlow {
  SupaFlow._();

  static SupaFlow? _instance;
  static SupaFlow get instance => _instance ??= SupaFlow._();

  final _supabase = Supabase.instance.client;
  static SupabaseClient get client => instance._supabase;

  static Future initialize() => Supabase.initialize(
        url: QuestwellEnvironment.current.supabaseUrl,
        headers: {
          'X-Client-Info': 'flutterflow',
        },
        anonKey: QuestwellEnvironment.current.publicKey,
        debug: false,
        authOptions:
            FlutterAuthClientOptions(authFlowType: AuthFlowType.implicit),
      );
}
