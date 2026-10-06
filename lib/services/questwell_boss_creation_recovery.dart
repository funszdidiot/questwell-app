import '/backend/supabase/questwell_network.dart';

/// Retains an unconfirmed creation request across timeouts and page changes.
/// This is session-local protection; durable server idempotency is still needed.
class QuestwellBossCreationRecovery {
  final _requests = <String, Future<String>>{};
  final _confirmed = <String, String>{};

  void acknowledge(Iterable<String> visibleBattleIds) {
    final visible = visibleBattleIds.toSet();
    for (final key in _confirmed.keys.toList()) {
      if (visible.contains(_confirmed[key])) {
        _requests.remove(key);
        _confirmed.remove(key);
      }
    }
  }

  Future<String> create({
    required String key,
    required Future<String> Function() send,
    required bool Function(Object) rejected,
    Future<String> Function(Future<String>)? wait,
  }) async {
    final request = _requests.putIfAbsent(
      key,
      () => Future<String>.sync(send).then((result) {
        if (result.trim().isNotEmpty) _confirmed[key] = result;
        return result;
      }),
    );
    try {
      final result = await (wait != null
          ? wait(request)
          : QuestwellNetwork.write(() => request));
      if (result.trim().isEmpty) {
        throw const QuestwellNetworkException(
          'The server did not confirm your battle. Check your battles before trying again.',
        );
      }
      // Retain success until a list read observes this specific battle.
      return result;
    } catch (error) {
      // Only a definite server rejection permits another write. A lost response
      // stays attached to its original request, even after a successful list read.
      if (rejected(error) && identical(_requests[key], request)) {
        _requests.remove(key);
      }
      rethrow;
    }
  }
}
