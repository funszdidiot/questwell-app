import 'package:flutter/material.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/auth_page/auth_page_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/questwell_account_service.dart';
import '/widgets/questwell_account_settings.dart';
import '/widgets/questwell_app_navigation.dart';

/// Route owner for the existing account actions; the settings view stays reusable.
class AccountSettingsPageWidget extends StatefulWidget {
  const AccountSettingsPageWidget({super.key});

  static const routeName = 'AccountSettingsPage';
  static const routePath = '/account';

  @override
  State<AccountSettingsPageWidget> createState() =>
      _AccountSettingsPageWidgetState();
}

class _AccountSettingsPageWidgetState extends State<AccountSettingsPageWidget> {
  bool _signingOut = false;

  Future<void> _signOut() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);
    try {
      await authManager.signOut();
      if (!mounted) return;
      GoRouter.of(context).clearRedirectLocation();
      context.goNamed(AuthPageWidget.routeName);
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not sign out. Please try again.')),
        );
    } finally {
      if (mounted) setState(() => _signingOut = false);
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
        onDelete: QuestwellAccountService.deleteAccount,
        onDeleted: () async {
          await QuestwellAccountService.clearLocalAccount();
          if (!mounted) return;
          GoRouter.of(context).clearRedirectLocation();
          context.goNamed(AuthPageWidget.routeName);
        },
      );
}
