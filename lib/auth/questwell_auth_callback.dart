/// Captured before Supabase consumes the callback fragment during startup.
/// Stores flags only; never retains tokens or server-provided error text.
class QuestwellAuthCallback {
  static bool recovering = false;
  static bool linkFailed = false;

  static bool get needsAuthScreen => recovering || linkFailed;

  static const appUrl = String.fromEnvironment('QUESTWELL_AUTH_RETURN_URL',
      defaultValue: 'https://funszdidiot.github.io/questwell-app/');
  static String get recoveryUrl => Uri.parse(appUrl)
      .replace(queryParameters: {'recovery': 'true'}, fragment: '').toString();

  static void capture(Uri uri) {
    Map<String, String> fragment;
    try {
      fragment = Uri.splitQueryString(uri.fragment);
    } on FormatException {
      fragment = const {};
    }
    recovering = uri.queryParameters['recovery'] == 'true' ||
        fragment['type'] == 'recovery';
    linkFailed = fragment.containsKey('error') ||
        fragment.containsKey('error_code') ||
        uri.queryParameters.containsKey('error') ||
        uri.queryParameters.containsKey('error_code');
  }

  static void clear() {
    recovering = false;
    linkFailed = false;
  }
}
