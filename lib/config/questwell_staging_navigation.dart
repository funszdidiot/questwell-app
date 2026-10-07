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
    final isRoute = hash.startsWith('#/');
    if (location.search.isNotEmpty || (hash.isNotEmpty && !isRoute)) {
      // Recovery intent was captured before SDK initialization. Remove the
      // outer query as well, so subsequent hash navigation/reloads cannot
      // revive a completed recovery flow or expose callback parameters.
      location.replaceState(
          null, '', '${location.pathname}${isRoute ? hash : '#/'}');
    }
    _ready = true;
  }
}
