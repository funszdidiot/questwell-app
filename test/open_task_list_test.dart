import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:postgrest/postgrest.dart';
import 'package:project_momentum/services/questwell_open_task_list.dart';

String taskId(int n) =>
    '00000000-0000-4000-8000-${n.toString().padLeft(12, '0')}';

void main() {
  test(
    'all 135 open quests and an older pinned quest remain reachable',
    () async {
      final rows = List.generate(
        135,
        (i) => <String, dynamic>{
          'id': taskId(135 - i),
          'user_id': 'owner-a',
          'status': 'open',
          'created_at': DateTime.utc(
            2026,
            1,
            1,
          ).subtract(Duration(minutes: i)).toIso8601String(),
          'title': 'Quest $i',
          'pinned_at': i == 134 ? '2026-01-01T00:00:00Z' : null,
        },
      );
      final client = MockClient((request) async {
        expect(request.url.queryParameters['user_id'], 'eq.owner-a');
        expect(request.url.queryParameters['status'], 'eq.open');
        final limit = int.parse(request.url.queryParameters['limit']!);
        return http.Response(
          jsonEncode(rows.take(limit).toList()),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      addTearDown(client.close);
      final tasks = await QuestwellOpenTaskList(
        database: PostgrestClient(
          'https://fixture.invalid/rest/v1',
          httpClient: client,
        ),
        currentOwner: () => 'owner-a',
      ).load();
      expect(tasks, hasLength(135));
      expect(tasks.where((t) => t.pinnedAt != null).single.id, taskId(1));
    },
  );
}
