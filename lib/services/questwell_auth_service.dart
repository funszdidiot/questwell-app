import '/auth/questwell_auth_callback.dart';
import '/auth/supabase_auth/supabase_user_provider.dart';
import '/backend/supabase/supabase.dart';
import '/backend/supabase/questwell_network.dart';
import '/flutter_flow/nav/nav.dart';

/// Shared by the real account form and its regression tests.
class QuestwellAuthService {
  bool get hasSession => SupaFlow.client.auth.currentSession != null;

  bool _acceptSession(AuthResponse response) {
    if (response.session == null || response.user == null) return false;
    currentUser = ProjectMomentumSupabaseUser(response.user);
    AppStateNotifier.instance.update(currentUser!);
    return true;
  }

  Future<bool> signIn(String email, String password) async => _acceptSession(
      await QuestwellNetwork.write(() => SupaFlow.client.auth
          .signInWithPassword(email: email, password: password)));

  /// A successful signup can require email confirmation and have no session.
  Future<bool> signUp(String email, String password) async => _acceptSession(
      await QuestwellNetwork.write(() => SupaFlow.client.auth.signUp(
          email: email, password: password,
          emailRedirectTo: QuestwellAuthCallback.appUrl)));

  Future<void> sendReset(String email) => QuestwellNetwork.write(() =>
      SupaFlow.client.auth.resetPasswordForEmail(email,
          redirectTo: QuestwellAuthCallback.recoveryUrl));

  Future<void> savePassword(String password) async {
    if (!hasSession || QuestwellAuthCallback.linkFailed) {
      throw const AuthException('This reset link has expired. Request a new link.');
    }
    await QuestwellNetwork.write(() => SupaFlow.client.auth
        .updateUser(UserAttributes(password: password)));
  }
}
