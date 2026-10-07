import '../backend/supabase/supabase.dart';
import '../backend/supabase/questwell_network.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'questwell_feedback_draft.dart';
import 'dart:typed_data';
import 'package:collection/collection.dart';

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

  static String screenshotPath(
      String ownerId, String feedbackId, String mimeType, int index) {
    final extension = mimeType == 'image/png'
        ? 'png'
        : mimeType == 'image/webp'
            ? 'webp'
            : 'jpg';
    return '$ownerId/$feedbackId-$index.$extension';
  }

  static List<String> attachmentPaths(
          QuestwellFeedbackDraft draft, String ownerId) =>
      [
        for (var i = 0; i < draft.attachments.length; i++)
          screenshotPath(ownerId, draft.id, draft.attachments[i].mimeType, i)
      ];

  static Future<Uint8List> _download(String ownerId, String path) async {
    _requireOwner(ownerId);
    final bytes = await QuestwellNetwork.read(() {
      _requireOwner(ownerId);
      return SupaFlow.client.storage.from(_bucket).download(path);
    });
    _requireOwner(ownerId);
    return bytes;
  }

  /// Reopened drafts may reuse an object only after verifying its saved intent.
  static Future<String> restoreScreenshot(
      {required String ownerId,
      required String feedbackId,
      required QuestwellFeedbackAttachment attachment,
      required int index}) async {
    final path =
        screenshotPath(ownerId, feedbackId, attachment.mimeType, index);
    final bytes = await _download(ownerId, path);
    if (!attachment.matches(bytes)) {
      throw const QuestwellFeedbackException(
          'A saved screenshot could not be verified. Remove it and choose it again.');
    }
    return path;
  }

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
    final path = screenshotPath(ownerId, feedbackId, mimeType, index);
    try {
      await QuestwellNetwork.write(() {
        _requireOwner(ownerId);
        return SupaFlow.client.storage.from(_bucket).uploadBinary(
              path,
              bytes,
              fileOptions: FileOptions(contentType: mimeType, upsert: false),
            );
      });
    } catch (error, stack) {
      _requireOwner(ownerId);
      // A conflict or a lost upload response is not proof of success. Read the
      // immutable private object and compare bytes; never overwrite or replay.
      Uint8List existing;
      try {
        existing = await _download(ownerId, path);
      } catch (_) {
        _requireOwner(ownerId);
        Error.throwWithStackTrace(error, stack);
      }
      if (!const ListEquality<int>().equals(existing, bytes)) {
        throw const QuestwellFeedbackException(
            'A screenshot at this request ID is different. Remove it and choose it again.');
      }
    }
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
    final row = _row(draft, ownerId, attachmentPaths);
    try {
      await QuestwellNetwork.write(() async {
        _requireOwner(ownerId);
        try {
          await SupaFlow.client.from('beta_feedback').insert(row);
        } on PostgrestException catch (error) {
          _requireOwner(ownerId);
          if (error.code != '23505') rethrow;
          if (!await isReceived(draft, ownerId,
              attachmentPaths: attachmentPaths)) rethrow;
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

  static Map<String, dynamic> _row(QuestwellFeedbackDraft draft, String ownerId,
      List<String> attachmentPaths) {
    // Local manifest/recovery fields must never become database columns.
    final local = draft.toJson();
    final row = <String, dynamic>{
      for (final key in [
        'id',
        'category',
        'goal',
        'message',
        'expected',
        'steps',
        'reply_email',
        'device',
        'screen',
        'build',
        'platform'
      ])
        key: local[key],
      'user_id': ownerId,
      'attachment_path': attachmentPaths.firstOrNull,
      'attachment_paths': attachmentPaths,
    };
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
    return row;
  }

  /// A receipt is valid only for the complete immutable request, not just its ID.
  static Future<bool> isReceived(QuestwellFeedbackDraft draft, String ownerId,
      {required List<String> attachmentPaths}) async {
    _requireOwner(ownerId);
    final row = _row(draft, ownerId, attachmentPaths);
    final existing = await QuestwellNetwork.read(() {
      _requireOwner(ownerId);
      return SupaFlow.client
          .from('beta_feedback')
          .select(row.keys.join(','))
          .eq('id', draft.id)
          .eq('user_id', ownerId)
          .maybeSingle();
    });
    _requireOwner(ownerId);
    if (existing == null) return false;
    // Older attempted drafts did not retain attachment intent. A receipt can
    // recover the original report, but its absence must never permit a new send.
    if (!draft.attachmentsKnown) {
      row.remove('attachment_path');
      row.remove('attachment_paths');
    }
    if (row.entries.any((entry) => !const DeepCollectionEquality()
        .equals(entry.value, existing[entry.key]))) {
      throw const QuestwellFeedbackException(
          'This report ID belongs to different feedback. Edit your note before sending it again.');
    }
    return true;
  }
}
