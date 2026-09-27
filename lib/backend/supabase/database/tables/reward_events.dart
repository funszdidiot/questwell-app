import '../database.dart';

class RewardEventsTable extends SupabaseTable<RewardEventsRow> {
  @override
  String get tableName => 'reward_events';

  @override
  RewardEventsRow createRow(Map<String, dynamic> data) => RewardEventsRow(data);
}

class RewardEventsRow extends SupabaseDataRow {
  RewardEventsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => RewardEventsTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get taskId => getField<String>('task_id');
  set taskId(String? value) => setField<String>('task_id', value);

  String? get eventType => getField<String>('event_type');
  set eventType(String? value) => setField<String>('event_type', value);

  int? get xpAmount => getField<int>('xp_amount');
  set xpAmount(int? value) => setField<int>('xp_amount', value);

  int? get coinAmount => getField<int>('coin_amount');
  set coinAmount(int? value) => setField<int>('coin_amount', value);
}
