import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class QuestwellFeedbackDraft {
  QuestwellFeedbackDraft({String? id, this.category = 'confusing', this.goal = '',
    this.message = '', this.expected = '', this.steps = '', this.replyEmail = '',
    this.device = '', required this.screen, required this.build,
    required this.platform, this.attempted = false}) : id = id ?? const Uuid().v4();

  final String id, category, goal, message, expected, steps, replyEmail, device;
  final String screen, build, platform;
  final bool attempted;
  static const categories = <String, String>{
    'bug': 'Something broke', 'confusing': 'Hard to understand',
    'idea': 'An idea', 'positive': 'Worked well',
  };

  QuestwellFeedbackDraft copyWith({String? category, String? goal, String? message,
    String? expected, String? steps, String? replyEmail, String? device,
    bool? attempted, bool edited = false}) => QuestwellFeedbackDraft(
      // An unchanged retry keeps its ID, even after closing/reopening the form.
      // Edited feedback is a new report if a previous send may have committed.
      id: edited && this.attempted ? null : id,
      category: category ?? this.category, goal: goal ?? this.goal,
      message: message ?? this.message, expected: expected ?? this.expected,
      steps: steps ?? this.steps, replyEmail: replyEmail ?? this.replyEmail,
      device: device ?? this.device, screen: screen, build: build, platform: platform,
      attempted: edited ? false : attempted ?? this.attempted);

  Map<String, dynamic> toJson() => {'id': id, 'category': category, 'goal': goal,
    'message': message, 'expected': expected, 'steps': steps, 'reply_email': replyEmail,
    'device': device, 'screen': screen, 'build': build, 'platform': platform,
    'attempted': attempted};

  factory QuestwellFeedbackDraft.fromJson(Map<String, dynamic> data) => QuestwellFeedbackDraft(
    id: data['id'] as String, category: data['category'] as String,
    goal: data['goal'] as String, message: data['message'] as String,
    expected: data['expected'] as String, steps: data['steps'] as String,
    replyEmail: data['reply_email'] as String, device: data['device'] as String,
    screen: data['screen'] as String, build: data['build'] as String,
    platform: data['platform'] as String, attempted: data['attempted'] == true);
}

/// Serialize local writes so a delayed keystroke save cannot resurrect a sent draft.
/// The key is account-specific; never restore another account's feedback.
class QuestwellFeedbackDraftStore {
  QuestwellFeedbackDraftStore(this.ownerId);
  final String ownerId;
  static Future<void> _pending = Future<void>.value();
  String get key => 'questwell_feedback_draft_$ownerId';
  Future<T> _queue<T>(Future<T> Function() operation) {
    final result = _pending.then((_) => operation());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }
  Future<QuestwellFeedbackDraft?> load() => _queue(() async {
    final raw = (await SharedPreferences.getInstance()).getString(key);
    if (raw == null) return null;
    try {
      return QuestwellFeedbackDraft.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) { return null; }
  });
  Future<void> save(QuestwellFeedbackDraft draft) => _queue(() async {
    final saved = await (await SharedPreferences.getInstance()).setString(key, jsonEncode(draft.toJson()));
    if (!saved) throw StateError('Draft could not be saved.');
  });
  Future<void> clear() => _queue(() async {
    final cleared = await (await SharedPreferences.getInstance()).remove(key);
    if (!cleared) throw StateError('Draft could not be cleared.');
  });
}
