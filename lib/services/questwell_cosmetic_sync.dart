import 'package:flutter/foundation.dart';

/// Coordinates local saves and reads without caching any account data.
class QuestwellCosmeticSync extends ChangeNotifier {
  Future<void> _writes = Future<void>.value();
  int _generation = 0;

  Future<T> write<T>(Future<T> Function() operation) {
    _generation++;
    final result = _writes.then((_) => operation());
    // Keep the queue usable after a failure; the caller still receives it.
    _writes = result.then<void>((_) {
      notifyListeners();
    }, onError: (Object error, StackTrace stack) {});
    return result;
  }

  Future<T> read<T>(Future<T> Function() operation) async {
    while (true) {
      final generation = _generation;
      await _writes;
      if (generation != _generation) continue;
      final result = await operation();
      // Discard a response started before a newer save, including failed saves.
      if (generation == _generation) return result;
    }
  }
}
