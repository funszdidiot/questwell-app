import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/backend/supabase/database/tables/tasks.dart';
import 'package:project_momentum/services/questwell_task_service.dart';

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

  test('normal Hearth shows all open quests with pinned quest first', () {
    final tasks = [
      TasksRow({
        'id': 'old',
        'status': 'open',
        'created_at': '2026-10-01T12:00:00.000Z',
        'friction_level': 2,
      }),
      TasksRow({
        'id': 'new',
        'status': 'open',
        'created_at': '2026-10-03T12:00:00.000Z',
        'friction_level': 1,
      }),
      TasksRow({
        'id': 'pinned',
        'status': 'open',
        'created_at': '2026-10-02T12:00:00.000Z',
        'pinned_at': '2026-10-03T18:00:00.000Z',
        'friction_level': 4,
      }),
      TasksRow({
        'id': 'fourth',
        'status': 'open',
        'created_at': '2026-09-30T12:00:00.000Z',
        'friction_level': 3,
      }),
    ];

    final visible = QuestwellTaskService.visibleHomeTasks(
      tasks,
      campfireMode: false,
    );

    expect(visible.map((task) => task.id).toList(), [
      'pinned',
      'new',
      'old',
      'fourth',
    ]);
  });

  test('Campfire Mode still shows exactly one gentle quest', () {
    final tasks = [
      TasksRow({
        'id': 'hard',
        'status': 'open',
        'created_at': '2026-10-03T12:00:00.000Z',
        'friction_level': 4,
      }),
      TasksRow({
        'id': 'easy',
        'status': 'open',
        'created_at': '2026-10-02T12:00:00.000Z',
        'friction_level': 1,
      }),
    ];

    final visible = QuestwellTaskService.visibleHomeTasks(
      tasks,
      campfireMode: true,
    );

    expect(visible, hasLength(1));
    expect(visible.single.id, 'easy');
  });
}
