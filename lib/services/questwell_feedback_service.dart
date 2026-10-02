import '/backend/supabase/supabase.dart';
import '/backend/supabase/questwell_network.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'questwell_feedback_draft.dart';

class QuestwellFeedbackException implements Exception {
  const QuestwellFeedbackException(this.message);
  final String message;
}

abstract final class QuestwellFeedbackService {
  static String? get userId => SupaFlow.client.auth.currentUser?.id;

  static Future<void> submit(QuestwellFeedbackDraft draft, String ownerId) async {
    if (userId != ownerId) {
      throw const QuestwellFeedbackException('Please sign in to the same account before sending this draft.');
    }
    final row = {...draft.toJson(), 'user_id': ownerId}..remove('attempted');
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
