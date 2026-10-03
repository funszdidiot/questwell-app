import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/backend/supabase/database/tables/tasks.dart';

void main() {
  test('task row exposes persistent pinned state', () {
    final pinned = TasksRow({
      'id': 'pinned',
      'status': 'open',
      'pinned_at': '2026-10-03T18:00:00.000Z',
    });
    final normal = TasksRow({'id': 'normal', 'status': 'open'});
    expect(pinned.pinnedAt, isNotNull);
    expect(normal.pinnedAt, isNull);
  });
}
