/// Resolves a lost purchase response using an ownership read, never a second write.
abstract final class QuestwellPurchaseRecovery {
  static Future<int> run({
    required Future<int> Function() attempt,
    required Future<int?> Function() confirmOwned,
  }) async {
    try {
      return await attempt();
    } catch (error, stack) {
      try {
        final balance = await confirmOwned();
        if (balance != null) return balance;
      } catch (_) {
        // Offline or changed account: keep the original unconfirmed outcome.
      }
      Error.throwWithStackTrace(error, stack);
    }
  }
}
