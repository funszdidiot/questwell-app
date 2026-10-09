import 'package:flutter/foundation.dart';
import 'questwell_cosmetic_models.dart';

/// A room draft never writes equipment. Save submits one complete arrangement.
class QuestwellHearthDraft {
  QuestwellHearthDraft(Map<String, String> initial,
      {Map<String, Map<String, String>> rooms = const {}})
      : saved = Map.unmodifiable(initial),
        _layout = Map.of(initial),
        _rooms = {for (final e in rooms.entries) e.key: Map.of(e.value)};

  static const wallSlots = {'wall_left', 'wall_center', 'wall_right'};

  final Map<String, String> saved;
  Map<String, Map<String, String>> _rooms;
  Map<String, String> _layout;
  final List<(Map<String, String>, Map<String, Map<String, String>>)> _history =
      [];
  Map<String, String> get layout => Map.unmodifiable(_layout);
  bool get dirty => !mapEquals(saved, _layout);
  bool get canUndo => _history.isNotEmpty;
  String get room => _layout['setting'] ?? 'original';

  void _change(Map<String, String> next,
      {Map<String, Map<String, String>>? rooms}) {
    if (mapEquals(next, _layout)) return;
    _history.add((
      Map.of(_layout),
      {for (final e in _rooms.entries) e.key: Map.of(e.value)}
    ));
    _layout = next;
    if (rooms != null) _rooms = rooms;
  }

  void place(String id, String slot) {
    if (slot == 'setting') {
      switchRoom(id);
      return;
    }
    _change(Map.of(_layout)
      ..removeWhere((key, value) => value == id)
      ..[slot] = id);
  }

  void remove(String slot) {
    if (slot == 'setting') {
      switchRoom(null);
    } else {
      _change(Map.of(_layout)..remove(slot));
    }
  }

  void switchRoom(String? id) {
    // Preserve in-session drafts when trying more than one background.
    final rooms = {
      for (final e in _rooms.entries) e.key: Map<String, String>.of(e.value),
      room: Map<String, String>.of(_layout)
    };
    final next = Map<String, String>.of(rooms[id ?? 'original'] ?? _layout)
      ..remove('setting')
      // Wall hangings follow the adventurer, including intentionally empty spots.
      // Never restore an old painting from a room's historical arrangement.
      ..removeWhere((slot, _) => wallSlots.contains(slot))
      ..addEntries(_layout.entries.where((e) => wallSlots.contains(e.key)));
    if (id != null) next['setting'] = id;
    _change(next, rooms: rooms);
  }

  void undo() {
    if (_history.isNotEmpty) {
      final previous = _history.removeLast();
      _layout = previous.$1;
      _rooms = previous.$2;
    }
  }

  List<String> problems(List<QuestwellCosmetic> catalog) {
    final byId = {for (final item in catalog) item.id: item};
    final problems = <String>[];
    final shelfPlaced = _layout.entries.any((e) =>
        e.key != 'bookshelf_top' && byId[e.value]?.slug == 'walnut-bookshelf');
    if (_layout.containsKey('bookshelf_top') && !shelfPlaced) {
      problems.add('Place a bookcase or remove the item on its top.');
    }
    if (byId[_layout['left']]?.hearthProfileKey == 'large_furniture' &&
        byId[_layout['front']]?.hearthProfileKey == 'seating') {
      problems.add(
          'The bookcase or cabinet crowds the left chair. Move one to the right or return it to inventory.');
    }
    return problems;
  }
}

class QuestwellHearthLayouts {
  const QuestwellHearthLayouts(this.current, this.rooms, this.revision,
      {this.ownerId});
  final String? ownerId;
  final Map<String, String> current;
  final Map<String, Map<String, String>> rooms;
  final int revision;
  factory QuestwellHearthLayouts.fromJson(Map<String, dynamic> json,
          {String? ownerId}) =>
      QuestwellHearthLayouts(
          Map<String, String>.from(json['current'] as Map),
          {
            for (final entry in (json['rooms'] as Map).entries)
              entry.key.toString(): Map<String, String>.from(entry.value as Map)
          },
          (json['revision'] as num).toInt(),
          ownerId: ownerId);
}
