import 'dart:async';
import 'package:flutter/material.dart';
import '/services/questwell_export_client.dart';
import '/services/questwell_export_save.dart';
import 'questwell_hearth_material.dart';
import 'questwell_typography.dart';

class QuestwellExportPanel extends StatefulWidget {
  const QuestwellExportPanel({
    super.key,
    required this.prepare,
    this.save = saveAccountExport,
    this.enabled = true,
    this.onBusyChanged,
  });
  final Future<PreparedAccountExport> Function() prepare;
  final Future<bool> Function(PreparedAccountExport) save;
  final bool enabled;
  final ValueChanged<bool>? onBusyChanged;
  @override
  State<QuestwellExportPanel> createState() => _QuestwellExportPanelState();
}

class _QuestwellExportPanelState extends State<QuestwellExportPanel> {
  PreparedAccountExport? _prepared;
  Timer? _expiry;
  bool _busy = false;
  String? _message;

  void _clear() {
    _expiry?.cancel();
    _expiry = null;
    _prepared?.dispose();
    _prepared = null;
  }

  void _setBusy(bool value) {
    setState(() => _busy = value);
    widget.onBusyChanged?.call(value);
  }

  Future<void> _act() async {
    if (_busy || !widget.enabled) return;
    final saving = _prepared != null;
    _setBusy(true);
    setState(() => _message = null);
    try {
      if (saving) {
        // Check session and expiry immediately before handing bytes to the OS.
        if (!_prepared!.isCurrent) {
          throw const AccountExportException('Please prepare a new download.');
        }
        final started = await widget.save(_prepared!);
        if (mounted) {
          _message = started
              ? 'Save request sent. Check your downloads or chosen folder.'
              : 'Save cancelled.';
        }
        _clear();
      } else {
        final prepared = await widget.prepare();
        if (!mounted) {
          prepared.dispose();
          return;
        }
        _prepared = prepared;
        _message = 'Your data is ready. Save it within two minutes.';
        _expiry = Timer(const Duration(minutes: 2), () {
          if (!mounted || _busy) return;
          setState(() {
            _clear();
            _message = 'Download expired. Please prepare it again.';
          });
        });
      }
    } catch (error) {
      _clear();
      if (mounted) {
        _message = error is AccountExportException
            ? error.message
            : 'Could not complete your download. Please try again.';
      }
    } finally {
      if (mounted) _setBusy(false);
    }
  }

  @override
  void dispose() {
    _clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => QuestwellHearthFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Your data',
              style: QuestwellTypography.body(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Download your account records and feedback attachments as a JSON file. '
              'It may contain personal information. Save it somewhere private.',
              style: QuestwellTypography.body(fontSize: 15),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _busy || !widget.enabled ? null : _act,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                padding: const EdgeInsets.all(14),
                textStyle: QuestwellTypography.control(),
              ),
              child: Text(
                _busy
                    ? (_prepared == null ? 'Preparing…' : 'Saving…')
                    : (_prepared == null
                        ? 'Download my data'
                        : 'Save data file'),
              ),
            ),
            if (_prepared != null && !_busy)
              TextButton(
                onPressed: () => setState(() {
                  _clear();
                  _message = 'Prepared download discarded.';
                }),
                child: const Text('Discard download'),
              ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Text(
                  _message!,
                  style: QuestwellTypography.body(fontSize: 15),
                ),
              ),
            ],
          ],
        ),
      );
}
