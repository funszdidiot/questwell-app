/// Validation shared by the existing completion RPC contracts.
/// A rejected reply does not establish whether the server committed the write.
class QuestwellRewardResponse {
  const QuestwellRewardResponse._();

  static Never invalid() => throw StateError(
        'Completion was not confirmed. Refresh before trying again.',
      );

  static Map<String, dynamic> singleRow(Object? response) {
    if (response is! List || response.length != 1) invalid();
    final row = response.single;
    if (row is! Map<String, dynamic>) invalid();
    return row;
  }

  static int integer(Map<String, dynamic> row, String field) {
    final value = row[field];
    // PostgreSQL integer results are bounded, nonnegative reward quantities.
    // Accept whole JSON numbers on both VM and web, never truncate fractions.
    if (value is! num ||
        !value.isFinite ||
        value < 0 ||
        value > 2147483647 ||
        value != value.truncateToDouble()) {
      invalid();
    }
    return value.toInt();
  }
}
