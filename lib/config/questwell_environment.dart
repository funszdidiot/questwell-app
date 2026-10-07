/// Approved endpoint sets are selected explicitly at build time. A new hosted
/// environment needs its own reviewed profile; it never falls back to live beta.
class QuestwellEnvironment {
  const QuestwellEnvironment._({
    required this.name,
    required this.supabaseUrl,
    required this.publicKey,
    required this.authReturnUrl,
  });

  final String name;
  final String supabaseUrl;
  final String publicKey;
  final String authReturnUrl;

  // Const selection removes inactive endpoint sets from release bundles.
  static const _buildName = String.fromEnvironment('QUESTWELL_ENVIRONMENT');
  static const _compiledProfile = _buildName == 'live_beta'
      ? _liveBeta
      : _buildName == 'staging'
          ? _staging
          : _buildName == 'isolated_test'
              ? _isolatedTest
              : null;

  static QuestwellEnvironment get current =>
      _compiledProfile ?? (throw _unsupportedEnvironment());

  static const _liveBeta = QuestwellEnvironment._(
    name: 'live_beta',
    supabaseUrl: 'https://bdzcazkyypopbanbjnud.supabase.co',
    publicKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJkemNhemt5eXBvcGJhbmJqbnVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA0NTIwODcsImV4cCI6MjEwNjAyODA4N30.cxTSz21O_0ssNYZJj5i8APjdpRAEb_1c-5yDE9mfAIY',
    authReturnUrl: 'https://funszdidiot.github.io/questwell-app/',
  );

  static const _staging = QuestwellEnvironment._(
    name: 'staging',
    supabaseUrl: 'https://hpjzfytwivlpsdhiupyd.supabase.co',
    publicKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhwanpmeXR3aXZscHNkaGl1cHlkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTEzOTM5NDcsImV4cCI6MjEwNjk2OTk0N30.TD0j1jbSbgw2ui0EuOVqz0WZE9c05wgFN6liCaty-ZA',
    authReturnUrl: 'https://funszdidiot.github.io/questwell-app/staging/',
  );

  static const _isolatedTest = QuestwellEnvironment._(
    name: 'isolated_test',
    supabaseUrl: 'http://127.0.0.1:1',
    publicKey: 'isolated-test-public-key',
    authReturnUrl: 'http://127.0.0.1:1/',
  );

  static QuestwellEnvironment select(String name) {
    switch (name) {
      case 'live_beta':
        return _liveBeta;
      case 'staging':
        return _staging;
      case 'isolated_test':
        return _isolatedTest;
      default:
        throw _unsupportedEnvironment();
    }
  }

  static StateError _unsupportedEnvironment() =>
      StateError('Questwell build environment is missing or unsupported.');
}
