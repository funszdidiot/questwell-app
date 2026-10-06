import '/backend/supabase/questwell_network.dart';

/// Retains an unconfirmed creation request across timeouts and page changes.
/// This is session-local protection; durable server idempotency is still needed.
class QuestwellBossCreationRecovery {
  final _requests = <String, Future<String>>{};

  Future<String> create({
    required String key,
    required Future<String> Function() send,
    required bool Function(Object) rejected,
    Future<String> Function(Future<String>)? wait,
  }) async {
    final request = _requests.putIfAbsent(key, () => Future<String>.sync(send));
    try {
      final result = await (wait != null
          ? wait(request)
          : QuestwellNetwork.write(() => request));
      if (result.trim().isEmpty) {
        throw const QuestwellNetworkException(
          'The server did not confirm your battle. Check your battles before trying again.',
        );
      }
      if (identical(_requests[key], request)) _requests.remove(key);
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
