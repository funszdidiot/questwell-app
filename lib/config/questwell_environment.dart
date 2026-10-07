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

  static final current = select(
    const String.fromEnvironment('QUESTWELL_ENVIRONMENT'),
  );

  static QuestwellEnvironment select(String name) {
    switch (name) {
      case 'live_beta':
        return const QuestwellEnvironment._(
          name: 'live_beta',
          supabaseUrl: 'https://bdzcazkyypopbanbjnud.supabase.co',
          publicKey:
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJkemNhemt5eXBvcGJhbmJqbnVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA0NTIwODcsImV4cCI6MjEwNjAyODA4N30.cxTSz21O_0ssNYZJj5i8APjdpRAEb_1c-5yDE9mfAIY',
          authReturnUrl: 'https://funszdidiot.github.io/questwell-app/',
        );
      case 'staging':
        // Fixed synthetic-only hosted target. Never inherit beta endpoints.
        // Public anon key, not a service-role key or account credential.
        return const QuestwellEnvironment._(
          name: 'staging',
          supabaseUrl: 'https://hpjzfytwivlpsdhiupyd.supabase.co',
          publicKey:
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhwanpmeXR3aXZscHNkaGl1cHlkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTEzOTM5NDcsImV4cCI6MjEwNjk2OTk0N30.TD0j1jbSbgw2ui0EuOVqz0WZE9c05wgFN6liCaty-ZA',
          authReturnUrl: 'https://funszdidiot.github.io/questwell-app/staging/',
        );
      case 'isolated_test':
        // Deliberately unusable for Auth/Data API operations. Widget/unit tests
        // inject their services; accidental network calls cannot reach beta.
        return const QuestwellEnvironment._(
          name: 'isolated_test',
          supabaseUrl: 'http://127.0.0.1:1',
          publicKey: 'isolated-test-public-key',
          authReturnUrl: 'http://127.0.0.1:1/',
        );
      default:
        throw StateError(
          'Questwell build environment is missing or unsupported.',
        );
    }
  }
}
