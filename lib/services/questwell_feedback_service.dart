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
  static const allowedAttachmentTypes = {
    'image/png',
    'image/jpeg',
    'image/webp',
  };

  static String? get userId => SupaFlow.client.auth.currentUser?.id;

  static void _requireOwner(String? ownerId) {
    if (ownerId == null || ownerId.isEmpty || userId != ownerId) {
      throw const QuestwellFeedbackException(
        'Your account changed. Close this note and reopen feedback.',
      );
    }
  }

  static Future<String> uploadScreenshot({
    required String ownerId,
    required String feedbackId,
    required Uint8List bytes,
    required String mimeType,
    int index = 0,
  }) async {
    _requireOwner(ownerId);
    if (bytes.isEmpty || bytes.length > maxAttachmentBytes) {
      throw const QuestwellFeedbackException(
        'Screenshots must be 5 MB or smaller.',
      );
    }
    if (!allowedAttachmentTypes.contains(mimeType)) {
      throw const QuestwellFeedbackException(
        'Use a PNG, JPEG, or WebP screenshot.',
      );
    }
    final extension = mimeType == 'image/png'
        ? 'png'
        : mimeType == 'image/webp'
            ? 'webp'
            : 'jpg';
    final path = '$ownerId/$feedbackId-$index.$extension';
    await QuestwellNetwork.write(() {
      _requireOwner(ownerId);
      return SupaFlow.client.storage.from(_bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: mimeType, upsert: false),
          );
    });
    _requireOwner(ownerId);
    return path;
  }

  static Future<void> removeScreenshots(List<String> paths) async {
    if (paths.isEmpty) return;
    final ownerId = userId;
    _requireOwner(ownerId);
    if (paths.any((path) => !path.startsWith('$ownerId/'))) {
      throw const QuestwellFeedbackException(
        'Screenshots belong to a different account.',
      );
    }
    await QuestwellNetwork.write(() {
      _requireOwner(ownerId);
      return SupaFlow.client.storage.from(_bucket).remove(paths);
    });
    _requireOwner(ownerId);
  }

  static Future<void> submit(
    QuestwellFeedbackDraft draft,
    String ownerId, {
    List<String> attachmentPaths = const [],
  }) async {
    _requireOwner(ownerId);
    final row = {
      ...draft.toJson(),
      'user_id': ownerId,
      'attachment_path': attachmentPaths.firstOrNull,
      'attachment_paths': attachmentPaths,
    }..remove('attempted');
    for (final field in [
      'goal',
      'message',
      'expected',
      'steps',
      'reply_email',
      'device',
    ]) {
      row[field] = (row[field] as String).trim();
    }
    try {
      await QuestwellNetwork.write(() async {
        _requireOwner(ownerId);
        try {
          await SupaFlow.client.from('beta_feedback').insert(row);
        } on PostgrestException catch (error) {
          _requireOwner(ownerId);
          if (error.code != '23505') rethrow;
          // A previous timed-out request may have succeeded. Confirm ownership
          // before treating this exact request ID as already received.
          final existing = await SupaFlow.client
              .from('beta_feedback')
              .select('id')
              .eq('id', draft.id)
              .eq('user_id', ownerId)
              .maybeSingle();
          _requireOwner(ownerId);
          if (existing == null) rethrow;
        }
      });
      _requireOwner(ownerId);
    } on PostgrestException catch (error) {
      if (error.message.contains('feedback_rate_limit')) {
        throw const QuestwellFeedbackException(
          'You have sent several notes recently. Your note is still here; please try again in an hour.',
        );
      }
      rethrow;
    }
  }
}
