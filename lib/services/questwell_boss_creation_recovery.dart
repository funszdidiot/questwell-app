import 'package:uuid/uuid.dart';

import '/backend/supabase/questwell_network.dart';

/// Keeps a stable identity for each unconfirmed draft in this app session.
/// The server receipt reconciles retries even when the response is lost.
class QuestwellBossCreationRecovery {
  final _identities = <String, String>{};
  final _requests = <String, Future<String>>{};
  final _confirmed = <String, String>{};

  void acknowledge(Iterable<String> visibleBattleIds) {
    final visible = visibleBattleIds.toSet();
    for (final key in _confirmed.keys.toList()) {
      if (visible.contains(_confirmed[key])) {
        _requests.remove(key);
        _confirmed.remove(key);
        _identities.remove(key);
      }
    }
  }

  Future<String> create({
    required String key,
    String? requestId,
    required Future<String> Function(String requestId) send,
    Future<String> Function(Future<String>)? wait,
  }) async {
    final saved = _confirmed[key];
    if (saved != null) return saved;
    final id = _identities.putIfAbsent(
      key,
      () => requestId ?? const Uuid().v4(),
    );
    final request = _requests.putIfAbsent(key, () async {
      final result = await Future<String>.sync(() => send(id));
      if (result.trim().isEmpty) {
        throw const QuestwellNetworkException(
          'Your battle was not confirmed. Retry this draft or check your battles.',
        );
      }
      // An older completion must not overwrite a newly acknowledged draft.
      if (_identities[key] == id) _confirmed[key] = result;
      return result;
    });
    try {
      return await (wait != null
          ? wait(request)
          : QuestwellNetwork.write(() => request));
    } finally {
      // A timed-out request may never settle. Permit another transport with the
      // same server identity; an older waiter must not remove a newer request.
      if (identical(_requests[key], request)) _requests.remove(key);
    }
  }
}
