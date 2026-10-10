import 'questwell_hearth_material.dart';
import 'questwell_app_style.dart';
import 'package:flutter/material.dart';

import 'questwell_delete_account.dart';
import 'questwell_typography.dart';
import 'questwell_audio_controls.dart';
import 'questwell_export_panel.dart';
import '/services/questwell_export_client.dart';

/// Presentation only. The account page supplies the existing account actions.
class QuestwellAccountSettings extends StatefulWidget {
  const QuestwellAccountSettings({
    super.key,
    required this.onSignOut,
    required this.onDelete,
    required this.onDeleted,
    this.onBack,
    this.onPrepareExport,
  });

  final Future<void> Function() onSignOut, onDelete;
  final VoidCallback onDeleted;
  final VoidCallback? onBack;
  final Future<PreparedAccountExport> Function()? onPrepareExport;

  @override
  State<QuestwellAccountSettings> createState() =>
      _QuestwellAccountSettingsState();
}

class _QuestwellAccountSettingsState extends State<QuestwellAccountSettings> {
  bool _signingOut = false;
  bool _exportBusy = false;

  Future<void> _signOut() async {
    if (_signingOut || _exportBusy) return;
    setState(() => _signingOut = true);
    try {
      // The existing owner callback handles authentication, errors and routing.
      await widget.onSignOut();
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) => QuestwellScaffold(
        backgroundColor: const Color(0xFF111827),
        appBar: AppBar(
          leading: widget.onBack == null
              ? null
              : BackButton(onPressed: widget.onBack),
          backgroundColor: QuestwellAppStyle.background,
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
                  if (QuestwellAudioScope.maybeOf(context)
                      case final audio?) ...[
                    QuestwellHearthFrame(
                      child: QuestwellAudioControls(audio: audio),
                    ),
                    const SizedBox(height: 24),
                  ],
                  _AccountPanel(
                    title: 'Sign out',
                    description:
                        'Leave this session without deleting your account or progress.',
                    child: OutlinedButton(
                      onPressed: _signingOut || _exportBusy ? null : _signOut,
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
                  if (widget.onPrepareExport != null) ...[
                    const SizedBox(height: 24),
                    QuestwellExportPanel(
                      prepare: widget.onPrepareExport!,
                      enabled: !_signingOut,
                      onBusyChanged: (busy) =>
                          setState(() => _exportBusy = busy),
                    ),
                  ],
                  const SizedBox(height: 32),
                  _AccountPanel(
                    title: 'Permanent deletion',
                    description:
                        'Deleting your account is permanent. Review what will be removed before confirming.',
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: QuestwellDeleteAccountButton(
                        enabled: !_signingOut && !_exportBusy,
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
  Widget build(BuildContext context) => QuestwellHearthFrame(
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
