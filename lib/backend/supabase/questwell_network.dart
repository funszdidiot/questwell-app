import 'dart:async';
import 'dart:io';

/// Stable failure type for backend connectivity problems.
///
/// UI code can catch [QuestwellNetworkException] and show a retry/offline state
/// instead of exposing low-level socket/timeout errors to the widget tree.
class QuestwellNetworkException implements Exception {
  const QuestwellNetworkException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class QuestwellNetwork {
  const QuestwellNetwork._();

  static const Duration timeout = Duration(seconds: 12);

  /// Runs a backend read with one short retry for transient connectivity.
  ///
  /// Reads are safe to retry. Mutations must use [write] so a late server
  /// response cannot be applied twice after the client retries.
  static Future<T> read<T>(Future<T> Function() operation) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        return await operation().timeout(timeout);
      } on TimeoutException catch (error) {
        if (attempt == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 350));
          continue;
        }
        throw QuestwellNetworkException(
          'Questwell could not reach the server. Check your connection and try again.',
          cause: error,
        );
      } on SocketException catch (error) {
        if (attempt == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 350));
          continue;
        }
        throw QuestwellNetworkException(
          'Questwell appears to be offline. Check your connection and try again.',
          cause: error,
        );
      } on HttpException catch (error) {
        throw QuestwellNetworkException(
          'Questwell could not contact the server. Please try again.',
          cause: error,
        );
      }
    }
    throw const QuestwellNetworkException('Questwell could not reach the server.');
  }

  /// Runs a mutation once with a bounded wait.
  ///
  /// Never automatically retry writes: after a timeout the server may still
  /// have committed the request, so retrying could duplicate an action.
  static Future<T> write<T>(Future<T> Function() operation) async {
    try {
      return await operation().timeout(timeout);
    } on TimeoutException catch (error) {
      throw QuestwellNetworkException(
        'The server took too long to respond. Your change may have been received; refresh before trying again.',
        cause: error,
      );
    } on SocketException catch (error) {
      throw QuestwellNetworkException(
        'Questwell appears to be offline. Your change was not confirmed.',
        cause: error,
      );
    } on HttpException catch (error) {
      throw QuestwellNetworkException(
        'Questwell could not contact the server. Your change was not confirmed.',
        cause: error,
      );
    }
  }
}
