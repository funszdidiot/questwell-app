import 'package:flutter_web_plugins/url_strategy.dart';

/// Keep implicit-auth fragments out of the router until Supabase has consumed
/// them. Startup widgets must not replace the URL while that is in progress.
class QuestwellStagingNavigation extends HashUrlStrategy {
  QuestwellStagingNavigation([PlatformLocation? location])
      : location = location ?? BrowserPlatformLocation(),
        super(location ?? BrowserPlatformLocation());

  final PlatformLocation location;
  bool _ready = false;
  String _orEmpty(String? value) => value ?? '';

  @override
  String getPath() {
    final hash = _orEmpty(location.hash);
    return _ready && hash.startsWith('#/') ? hash.substring(1) : '/';
  }

  @override
  void pushState(Object? state, String title, String url) {
    if (_ready) super.pushState(state, title, url);
  }

  @override
  void replaceState(Object? state, String title, String url) {
    if (_ready) super.replaceState(state, title, url);
  }

  void finishCallback() {
    final hash = _orEmpty(location.hash);
    if (hash.isNotEmpty && !hash.startsWith('#/')) {
      // Only the safe recovery flag survives an Auth callback. Never preserve
      // token/error parameters or let them appear as a router diagnostic.
      Map<String, String> query;
      try {
        query = Uri.splitQueryString(
          location.search.startsWith('?')
              ? location.search.substring(1)
              : location.search,
        );
      } on FormatException {
        query = const {};
      }
      final recovery = query['recovery'] == 'true' ? '?recovery=true' : '';
      location.replaceState(null, '', '${location.pathname}$recovery#/');
    }
    _ready = true;
  }
}
