import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../flutter_flow/flutter_flow_theme.dart';
import '../services/questwell_onboarding_session.dart';
import 'questwell_pixel_art.dart';

/// The existing welcome panel with one shared submission state for all choices.
class QuestwellOnboardingPanel extends StatefulWidget {
  const QuestwellOnboardingPanel({
    super.key,
    required this.finish,
    required this.onCompleted,
  });
  final Future<QuestwellOnboardingResult> Function(String?) finish;
  final VoidCallback onCompleted;

  @override
  State<QuestwellOnboardingPanel> createState() =>
      _QuestwellOnboardingPanelState();
}

class _QuestwellOnboardingPanelState extends State<QuestwellOnboardingPanel> {
  bool _busy = false;
  bool _finished = false;
  bool _needsConfirmation = false;
  String? _error;

  Future<void> _finish(String? key) async {
    if (_busy || _finished) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await widget.finish(key);
      if (!mounted) return;
      if (result.completed) {
        _finished = true;
        widget.onCompleted();
      } else {
        setState(() => _needsConfirmation = true);
      }
    } on QuestwellOnboardingAccountChanged {
      if (mounted)
        setState(
          () => _error = 'Your account changed. Return to the home page before finishing setup.',
        );
    } catch (_) {
      if (mounted)
        setState(
          () => _error = 'Setup was not confirmed. You can retry safely.',
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return QuestwellRetroPanel(
      padding: const EdgeInsets.all(16),
      accent: const Color(0xFFF1C75B),
      background: const Color(0xFF1A1714),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: theme.primary),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Welcome to Questwell',
                  style: theme.titleLarge.override(
                    font: GoogleFonts.pressStart2p(fontWeight: FontWeight.w700),
                    fontSize: 11,
                    lineHeight: 1.5,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            'Pick one tiny real-life win. Completing it earns your first XP and coins.',
            style: theme.bodyMedium.override(
              font: GoogleFonts.roboto(),
              color: theme.secondaryText,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final choice in const [
                ('email', 'Reply to one email'),
                ('files', 'Clear five files'),
                ('avoided', 'Do the avoided thing'),
              ])
                OutlinedButton(
                  onPressed: _busy || _finished || _needsConfirmation
                      ? null
                      : () => _finish(choice.$1),
                  child: Text(choice.$2),
                ),
            ],
          ),
          if (_needsConfirmation) ...[
            const SizedBox(height: 8),
            const Text(
              'Your account already has quest progress. Finish setup without adding another starter.',
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: theme.error)),
          ],
          const SizedBox(height: 8),
          TextButton(
            onPressed: _busy || _finished ? null : () => _finish(null),
            child: Text(
              _needsConfirmation
                  ? 'Finish setup with my current progress'
                  : 'I already know what I want to do',
            ),
          ),
          if (_busy) const Text('Finishing setup…'),
        ],
      ),
    );
  }
}
