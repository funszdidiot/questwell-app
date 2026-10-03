import '../backend/supabase/supabase.dart';
import '../backend/supabase/questwell_network.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'questwell_feedback_draft.dart';
import 'dart:typed_data';

class QuestwellFeedbackException implements Exception {
  const QuestwellFeedbackException(this.message);
  final String message;
}

abstract final class QuestwellFeedbackService {
  static const _bucket = 'beta-feedback';
  static const maxAttachmentBytes = 5 * 1024 * 1024;
  static const maxAttachments = 5;
  static const allowedAttachmentTypes = {'image/png', 'image/jpeg', 'image/webp'};

  static String? get userId => SupaFlow.client.auth.currentUser?.id;

  static Future<String> uploadScreenshot({
    required String ownerId,
    required String feedbackId,
    required Uint8List bytes,
    required String mimeType,
    int index = 0,
  }) async {
    if (userId != ownerId) {
      throw const QuestwellFeedbackException('Please sign in to the same account before uploading.');
    }
    if (bytes.isEmpty || bytes.length > maxAttachmentBytes) {
      throw const QuestwellFeedbackException('Screenshots must be 5 MB or smaller.');
    }
    if (!allowedAttachmentTypes.contains(mimeType)) {
      throw const QuestwellFeedbackException('Use a PNG, JPEG, or WebP screenshot.');
    }
    final extension = mimeType == 'image/png' ? 'png' : mimeType == 'image/webp' ? 'webp' : 'jpg';
    final path = '$ownerId/$feedbackId-$index.$extension';
    await QuestwellNetwork.write(() => SupaFlow.client.storage.from(_bucket)
      .uploadBinary(path, bytes, fileOptions: FileOptions(contentType: mimeType, upsert: false)));
    return path;
  }

  static Future<void> removeScreenshots(List<String> paths) async {
    if (paths.isEmpty) return;
    await QuestwellNetwork.write(() => SupaFlow.client.storage.from(_bucket).remove(paths));
  }

  static Future<void> submit(QuestwellFeedbackDraft draft, String ownerId, {List<String> attachmentPaths = const []}) async {
    if (userId != ownerId) {
      throw const QuestwellFeedbackException('Please sign in to the same account before sending this draft.');
    }
    final row = {...draft.toJson(), 'user_id': ownerId, 'attachment_path': attachmentPaths.firstOrNull, 'attachment_paths': attachmentPaths}..remove('attempted');
    for (final field in ['goal', 'message', 'expected', 'steps', 'reply_email', 'device']) {
      row[field] = (row[field] as String).trim();
    }
    try {
      await QuestwellNetwork.write(() async {
        try {
          await SupaFlow.client.from('beta_feedback').insert(row);
        } on PostgrestException catch (error) {
          if (error.code != '23505') rethrow;
          // A previous timed-out request may have succeeded. Confirm ownership
          // before treating this exact request ID as already received.
          final existing = await SupaFlow.client.from('beta_feedback').select('id')
            .eq('id', draft.id).eq('user_id', ownerId).maybeSingle();
          if (existing == null) rethrow;
        }
      });
    } on PostgrestException catch (error) {
      if (error.message.contains('feedback_rate_limit')) {
        throw const QuestwellFeedbackException('You have sent several notes recently. Your note is still here; please try again in an hour.');
      }
      rethrow;
    }
  }
}
