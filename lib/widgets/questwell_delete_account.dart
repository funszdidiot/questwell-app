import 'package:flutter/material.dart';
import 'questwell_typography.dart';

class QuestwellDeleteAccountButton extends StatefulWidget {
  const QuestwellDeleteAccountButton({super.key, required this.onDelete, required this.onDeleted,
    this.enabled = true, this.preview = false});
  final Future<void> Function() onDelete;
  final VoidCallback onDeleted;
  final bool enabled, preview;
  @override
  State<QuestwellDeleteAccountButton> createState() => _QuestwellDeleteAccountButtonState();
}

class _QuestwellDeleteAccountButtonState extends State<QuestwellDeleteAccountButton> {
  bool _open = false;
  Future<void> _confirm() async {
    if (_open) return;
    setState(() => _open = true);
    final deleted = await showDialog<bool>(
      context: context, barrierDismissible: false,
      builder: (_) => _DeleteAccountDialog(onDelete: widget.onDelete, preview: widget.preview));
    if (!mounted) return;
    setState(() => _open = false);
    if (deleted == true) widget.onDeleted();
  }
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: widget.enabled && !_open ? _confirm : null,
    style: TextButton.styleFrom(foregroundColor: const Color(0xFFFFB4AB),
      minimumSize: const Size(48, 48), textStyle: QuestwellTypography.control()),
    child: const Text('Delete account'));
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.onDelete, required this.preview});
  final Future<void> Function() onDelete;
  final bool preview;
  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}
class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _confirmation = TextEditingController();
  bool _busy = false;
  String? _error;
  @override
  void dispose() { _confirmation.dispose(); super.dispose(); }
  Future<void> _delete() async {
    if (_busy || _confirmation.text != 'DELETE') return;
    setState(() { _busy = true; _error = null; });
    try {
      await widget.onDelete();
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) setState(() {
        _error = 'Deletion was not confirmed. Check your connection and sign in again before retrying.';
        _busy = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      scrollable: true,
      backgroundColor: const Color(0xFF17232E),
      title: Text('Hang up your boots?', style: QuestwellTypography.body(fontSize: 22, fontWeight: FontWeight.w700)),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (widget.preview) ...[
          const Text('Preview only. No real account will be deleted.'),
          const SizedBox(height: 12),
        ],
        const Text('This permanently deletes your account, quests, boss battles, Chronicle history, XP, coins, and collected cosmetics. No reloads or resurrection spells here. This cannot be undone.'),
        const SizedBox(height: 16),
        TextField(controller: _confirmation, enabled: !_busy,
          autocorrect: false, enableSuggestions: false,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(labelText: 'Type DELETE to confirm',
            border: OutlineInputBorder()),
          style: QuestwellTypography.body(fontSize: 16)),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Semantics(liveRegion: true, child: Text(_error!, style: const TextStyle(color: Color(0xFFFFB4AB)))),
        ],
      ]),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text('Keep my account')),
        FilledButton(
          onPressed: !_busy && _confirmation.text == 'DELETE' ? _delete : null,
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF9E352E)),
          child: Text(_busy ? 'Deleting account…' : 'Permanently delete'),
        ),
      ],
    ),
  );
}
