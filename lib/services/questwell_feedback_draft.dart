import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Local recovery metadata only. Screenshot bytes are never saved in preferences.
class QuestwellFeedbackAttachment {
  const QuestwellFeedbackAttachment(
      {required this.name,
      required this.mimeType,
      required this.length,
      required this.digest});
  factory QuestwellFeedbackAttachment.fromBytes(
          String name, String mimeType, Uint8List bytes) =>
      QuestwellFeedbackAttachment(
          name: name,
          mimeType: mimeType,
          length: bytes.length,
          digest: sha256.convert(bytes).toString());
  final String name, mimeType, digest;
  final int length;
  bool matches(Uint8List bytes) =>
      bytes.length == length && sha256.convert(bytes).toString() == digest;
  Map<String, dynamic> toJson() =>
      {'name': name, 'mime': mimeType, 'length': length, 'digest': digest};
  factory QuestwellFeedbackAttachment.fromJson(Map<String, dynamic> data) =>
      QuestwellFeedbackAttachment(
          name: data['name'] as String,
          mimeType: data['mime'] as String,
          length: data['length'] as int,
          digest: data['digest'] as String);
}

class QuestwellFeedbackDraft {
  QuestwellFeedbackDraft(
      {String? id,
      this.category = 'confusing',
      this.goal = '',
      this.message = '',
      this.expected = '',
      this.steps = '',
      this.replyEmail = '',
      this.device = '',
      required this.screen,
      required this.build,
      required this.platform,
      this.attempted = false,
      List<QuestwellFeedbackAttachment> attachments = const [],
      this.attachmentsKnown = true})
      : id = id ?? const Uuid().v4(),
        attachments = List.unmodifiable(attachments);

  final String id, category, goal, message, expected, steps, replyEmail, device;
  final String screen, build, platform;
  final bool attempted;
  final List<QuestwellFeedbackAttachment> attachments;
  final bool attachmentsKnown;
  static const categories = <String, String>{
    'bug': 'Something broke',
    'confusing': 'Hard to understand',
    'idea': 'An idea',
    'positive': 'Worked well',
  };

  QuestwellFeedbackDraft copyWith(
          {String? category,
          String? goal,
          String? message,
          String? expected,
          String? steps,
          String? replyEmail,
          String? device,
          bool? attempted,
          bool edited = false,
          List<QuestwellFeedbackAttachment>? attachments}) =>
      QuestwellFeedbackDraft(
          // An unchanged retry keeps its ID, even after closing/reopening the form.
          // Edited feedback is a new report if a previous send may have committed.
          id: edited && this.attempted ? null : id,
          category: category ?? this.category,
          goal: goal ?? this.goal,
          message: message ?? this.message,
          expected: expected ?? this.expected,
          steps: steps ?? this.steps,
          replyEmail: replyEmail ?? this.replyEmail,
          device: device ?? this.device,
          screen: screen,
          build: build,
          platform: platform,
          attempted: edited ? false : attempted ?? this.attempted,
          attachments: attachments ?? this.attachments,
          attachmentsKnown: edited ? true : attachmentsKnown);

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'goal': goal,
        'message': message,
        'expected': expected,
        'steps': steps,
        'reply_email': replyEmail,
        'device': device,
        'screen': screen,
        'build': build,
        'platform': platform,
        'attempted': attempted,
        'attachments_known': attachmentsKnown,
        'attachment_manifest': attachments.map((a) => a.toJson()).toList()
      };

  factory QuestwellFeedbackDraft.fromJson(Map<String, dynamic> data) =>
      QuestwellFeedbackDraft(
          id: data['id'] as String,
          category: data['category'] as String,
          goal: data['goal'] as String,
          message: data['message'] as String,
          expected: data['expected'] as String,
          steps: data['steps'] as String,
          replyEmail: data['reply_email'] as String,
          device: data['device'] as String,
          screen: data['screen'] as String,
          build: data['build'] as String,
          platform: data['platform'] as String,
          attempted: data['attempted'] == true,
          attachmentsKnown:
              data['attachments_known'] as bool? ?? data['attempted'] != true,
          attachments: (data['attachment_manifest'] as List? ?? [])
              .map((a) => QuestwellFeedbackAttachment.fromJson(
                  Map<String, dynamic>.from(a as Map)))
              .toList());
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
          return QuestwellFeedbackDraft.fromJson(
              jsonDecode(raw) as Map<String, dynamic>);
        } catch (_) {
          return null;
        }
      });
  Future<void> save(QuestwellFeedbackDraft draft) => _queue(() async {
        final saved = await (await SharedPreferences.getInstance())
            .setString(key, jsonEncode(draft.toJson()));
        if (!saved) throw StateError('Draft could not be saved.');
      });
  Future<void> clear() => _queue(() async {
        final cleared =
            await (await SharedPreferences.getInstance()).remove(key);
        if (!cleared) throw StateError('Draft could not be cleared.');
      });
}
