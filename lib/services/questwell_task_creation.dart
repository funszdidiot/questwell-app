import 'questwell_content_policy.dart';

class QuestwellCreationAccountChanged implements Exception {
  const QuestwellCreationAccountChanged();
}

/// One form submission, including retries after an unconfirmed response.
/// The request identity and original payload live until this form is discarded.
class QuestwellTaskCreation {
  QuestwellTaskCreation({
    required this.requestId,
    required this.ownerId,
    required this.currentOwner,
    required this.send,
  });

  final String requestId;
  final String ownerId;
  final String Function() currentOwner;
  final Future<String> Function(Map<String, dynamic>) send;
  Map<String, dynamic>? _params;
  Future<String>? _pending;
  String? _savedId;

  bool get started => _params != null;

  void _checkOwner() {
    if (ownerId.isEmpty || currentOwner() != ownerId) {
      throw const QuestwellCreationAccountChanged();
    }
  }

  Future<String> save(String title, int friction) async {
    _checkOwner();
    final normalizedTitle = title.trim();
    if (QuestwellContentPolicy.titleError(normalizedTitle) != null ||
        friction < 1 ||
        friction > 4) {
      throw ArgumentError('A quest needs a title and difficulty.');
    }
    final existing = _params;
    if (existing != null &&
        (existing['p_title'] != normalizedTitle ||
            existing['p_friction'] != friction)) {
      throw StateError('Resolve the original submission before editing it.');
    }
    _params ??= Map.unmodifiable({
      'p_request_id': requestId,
      'p_expected_user_id': ownerId,
      'p_title': normalizedTitle,
      'p_friction': friction,
    });
    if (_savedId != null) return _savedId!;
    if (_pending != null) return _pending!;
    final operation = _send();
    _pending = operation;
    try {
      return await operation;
    } finally {
      _pending = null;
    }
  }

  Future<String> _send() async {
    final id = await send(_params!);
    _checkOwner();
    if (id.isEmpty) throw StateError('Quest creation was not confirmed.');
    _savedId = id;
    return id;
  }
}
