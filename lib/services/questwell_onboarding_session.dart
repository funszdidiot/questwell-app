class QuestwellOnboardingAccountChanged implements Exception {
  const QuestwellOnboardingAccountChanged();
}

class QuestwellOnboardingResult {
  const QuestwellOnboardingResult({required this.completed, this.taskId});
  final bool completed;
  final String? taskId;

  factory QuestwellOnboardingResult.fromResponse(dynamic response) {
    if (response is! Map ||
        !response.containsKey('task_id') ||
        !['completed', 'needs_confirmation'].contains(response['status']) ||
        (response['task_id'] != null &&
            (response['task_id'] is! String ||
                (response['task_id'] as String).isEmpty))) {
      throw const FormatException('Setup was not confirmed.');
    }
    return QuestwellOnboardingResult(
      completed: response['status'] == 'completed',
      taskId: response['task_id'] as String?,
    );
  }
}

/// The server persists one outcome per account. This boundary shares in-flight
/// taps and prevents applying a result after the signed-in account changes.
class QuestwellOnboardingSession {
  QuestwellOnboardingSession({
    required this.ownerId,
    required this.currentOwner,
    required this.send,
  });

  final String ownerId;
  final String Function() currentOwner;
  final Future<dynamic> Function(Map<String, dynamic>) send;
  Future<QuestwellOnboardingResult>? _pending;

  void _checkOwner() {
    if (ownerId.isEmpty || currentOwner() != ownerId) {
      throw const QuestwellOnboardingAccountChanged();
    }
  }

  Future<QuestwellOnboardingResult> finish(String? starterKey) async {
    _checkOwner();
    if (starterKey != null &&
        !['email', 'files', 'avoided'].contains(starterKey)) {
      throw ArgumentError.value(starterKey, 'starterKey');
    }
    if (_pending != null) return _pending!;
    final operation = _send(starterKey);
    _pending = operation;
    try {
      return await operation;
    } finally {
      _pending = null;
    }
  }

  Future<QuestwellOnboardingResult> _send(String? starterKey) async {
    final result = await send({
      'p_expected_user_id': ownerId,
      'p_starter_key': starterKey,
    });
    _checkOwner();
    return QuestwellOnboardingResult.fromResponse(result);
  }
}
