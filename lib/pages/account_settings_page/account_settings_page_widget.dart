import 'package:flutter/material.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/auth_page/auth_page_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/questwell_account_service.dart';
import '/widgets/questwell_account_settings.dart';
import '/widgets/questwell_app_navigation.dart';

Future<void> _signOutCurrentSession() async => authManager.signOut();

/// Route owner for account actions; injectable callbacks keep QA account-free.
class AccountSettingsPageWidget extends StatefulWidget {
  const AccountSettingsPageWidget({
    super.key,
    this.signOut = _signOutCurrentSession,
    this.deleteAccount = QuestwellAccountService.deleteAccount,
    this.clearLocalAccount = QuestwellAccountService.clearLocalAccount,
  });

  static const routeName = 'AccountSettingsPage';
  static const routePath = '/account';

  final Future<void> Function() signOut, deleteAccount, clearLocalAccount;

  @override
  State<AccountSettingsPageWidget> createState() =>
      _AccountSettingsPageWidgetState();
}

class _AccountSettingsPageWidgetState extends State<AccountSettingsPageWidget> {
  bool _signingOut = false;

  void _finishAccountExit(GoRouter router) {
    // The app router outlives this page, including browser Back during a request.
    router.clearRedirectLocation();
    router.goNamed(AuthPageWidget.routeName);
  }

  Future<void> _signOut() async {
    if (_signingOut) return;
    final router = GoRouter.of(context);
    setState(() => _signingOut = true);
    try {
      await widget.signOut();
      _finishAccountExit(router);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not sign out. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  Future<void> _deleteAccount() async {
    final router = GoRouter.of(context);
    final clearLocalAccount = widget.clearLocalAccount;
    await widget.deleteAccount();
    // Cleanup belongs to the operation, not the dialog's mounted callback.
    try {
      await clearLocalAccount();
    } finally {
      // Remote deletion succeeded: a local cleanup failure must not strand the
      // deleted account in the app or invite a second deletion attempt.
      _finishAccountExit(router);
    }
  }

  @override
  Widget build(BuildContext context) => QuestwellAccountSettings(
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.goNamed(QuestwellDestination.adventurer.routeName);
          }
        },
        onSignOut: _signOut,
        onDelete: _deleteAccount,
        // The confirmed operation above already owns cleanup and navigation.
        onDeleted: () {},
      );
}
