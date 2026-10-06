import 'package:flutter/material.dart';

import 'questwell_delete_account.dart';
import 'questwell_typography.dart';

/// Presentation only. The account page supplies the existing account actions.
class QuestwellAccountSettings extends StatefulWidget {
  const QuestwellAccountSettings({
    super.key,
    required this.onSignOut,
    required this.onDelete,
    required this.onDeleted,
  });

  final Future<void> Function() onSignOut, onDelete;
  final VoidCallback onDeleted;

  @override
  State<QuestwellAccountSettings> createState() =>
      _QuestwellAccountSettingsState();
}

class _QuestwellAccountSettingsState extends State<QuestwellAccountSettings> {
  bool _signingOut = false;

  Future<void> _signOut() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);
    try {
      // The existing owner callback handles authentication, errors and routing.
      await widget.onSignOut();
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF111827),
    appBar: AppBar(
      backgroundColor: const Color(0xFF111827),
      foregroundColor: const Color(0xFFF0E5CC),
      title: Text(
        'Account',
        style: QuestwellTypography.body(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'ACCOUNT SETTINGS',
                style: QuestwellTypography.sectionHeading(size: 12),
              ),
              const SizedBox(height: 12),
              Text(
                'Manage your session and account.',
                style: QuestwellTypography.body(
                  fontSize: 16,
                  color: const Color(0xFFB9C7D7),
                ),
              ),
              const SizedBox(height: 24),
              _AccountPanel(
                title: 'Sign out',
                description: 'Leave this session without deleting your account or progress.',
                child: OutlinedButton(
                  onPressed: _signingOut ? null : _signOut,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF2D9A0),
                    side: const BorderSide(color: Color(0xFF9E7546)),
                    minimumSize: const Size.fromHeight(48),
                    padding: const EdgeInsets.all(14),
                    textStyle: QuestwellTypography.control(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  child: Text(_signingOut ? 'Signing out…' : 'Sign out'),
                ),
              ),
              const SizedBox(height: 32),
              _AccountPanel(
                title: 'Permanent deletion',
                description: 'Deleting your account is permanent. Review what will be removed before confirming.',
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: QuestwellDeleteAccountButton(
                    enabled: !_signingOut,
                    onDelete: widget.onDelete,
                    onDeleted: widget.onDeleted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _AccountPanel extends StatelessWidget {
  const _AccountPanel({
    required this.title,
    required this.description,
    required this.child,
  });
  final String title, description;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF19232D),
      border: Border.all(color: const Color(0xFF65563D)),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: QuestwellTypography.body(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF0E5CC),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: QuestwellTypography.body(
            fontSize: 15,
            color: const Color(0xFFB9C7D7),
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}
