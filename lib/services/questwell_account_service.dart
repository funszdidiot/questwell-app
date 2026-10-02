import '/backend/supabase/supabase.dart';
import '/backend/supabase/questwell_network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'questwell_feedback_draft.dart';

class QuestwellAccountService {
  const QuestwellAccountService._();
  static Future<void> deleteAccount() async {
    if (SupaFlow.client.auth.currentUser == null) throw StateError('Sign in required.');
    final response = await QuestwellNetwork.write(() => SupaFlow.client.functions.invoke(
      'delete-account', body: {'confirmation': 'DELETE'}));
    if (response.status != 200 || response.data is! Map || response.data['deleted'] != true) {
      throw StateError('Deletion was not confirmed.');
    }
  }

  static Future<void> clearLocalAccount() async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    // The Auth SDK clears its persisted session and emits SIGNED_OUT.
    await SupaFlow.client.auth.signOut(scope: SignOutScope.local);
    if (uid != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('questwell_favorite_quests_$uid');
      await QuestwellFeedbackDraftStore(uid).clear();
    }
  }
}
