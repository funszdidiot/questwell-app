import '/flutter_flow/flutter_flow_theme.dart';
import '/widgets/questwell_pixel_art.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class ExpeditionPageWidget extends StatefulWidget {
  const ExpeditionPageWidget({super.key});

  static String routeName = 'ExpeditionPage';
  static String routePath = '/expedition';

  @override
  State<ExpeditionPageWidget> createState() => _ExpeditionPageWidgetState();
}

class _ExpeditionPageWidgetState extends State<ExpeditionPageWidget> {
  Timer? _timer;
  int _selectedMinutes = 25;
  int _secondsRemaining = 25 * 60;
  bool _running = false;
  bool _finished = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _choosePreset(int minutes) {
    if (_running) return;
    setState(() {
      _selectedMinutes = minutes;
      _secondsRemaining = minutes * 60;
      _finished = false;
    });
  }

  void _start() {
    if (_running || _secondsRemaining <= 0) return;

    setState(() {
      _running = true;
      _finished = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
          _running = false;
          _finished = true;
        });
        return;
      }

      setState(() => _secondsRemaining -= 1);
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _finished = false;
      _secondsRemaining = _selectedMinutes * 60;
    });
  }

  String get _timeLabel {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final progress = _selectedMinutes == 0
        ? 0.0
        : 1 - (_secondsRemaining / (_selectedMinutes * 60));

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        foregroundColor: theme.primaryText,
        title: Text(
          'Expedition',
          style: theme.titleLarge.override(
            font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
            letterSpacing: 0,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            Text(
              'Set out. Do one thing.',
              style: theme.headlineSmall.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                letterSpacing: -0.25,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'A quiet focus session with no streaks, rankings, or guilt.',
              style: theme.bodyMedium.override(
                font: GoogleFonts.inter(),
                color: theme.secondaryText,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 18),
            QuestwellExpeditionPixelScene(
              height: 155,
              campfire: _finished,
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.alternate),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 210,
                        height: 210,
                        child: CircularProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          strokeWidth: 10,
                          backgroundColor: theme.primaryBackground,
                        ),
                      ),
                      Column(
                        children: [
                          _finished
                              ? const QuestwellStatusPixelBadge(
                                  kind: 'campfire',
                                  size: 34,
                                  active: true,
                                )
                              : const QuestwellNavPixelIcon(
                                  kind: 'expedition',
                                  size: 34,
                                ),
                          const SizedBox(height: 8),
                          Text(
                            _timeLabel,
                            style: theme.displaySmall.override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.w700,
                              ),
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _finished
                                ? 'Expedition complete'
                                : _running
                                    ? 'Stay with the quest'
                                    : 'Ready when you are',
                            style: theme.bodySmall.override(
                              font: GoogleFonts.inter(),
                              color: theme.secondaryText,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final minutes in const [15, 25, 45])
                        ChoiceChip(
                          selected: _selectedMinutes == minutes,
                          onSelected: _running
                              ? null
                              : (_) => _choosePreset(minutes),
                          label: Text('$minutes min'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _finished
                              ? _reset
                              : _running
                                  ? _pause
                                  : _start,
                          icon: Icon(
                            _finished
                                ? Icons.replay
                                : _running
                                    ? Icons.pause
                                    : Icons.play_arrow,
                          ),
                          label: Text(
                            _finished
                                ? 'Reset'
                                : _running
                                    ? 'Pause'
                                    : 'Begin Expedition',
                          ),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!_running && !_finished) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _secondsRemaining ==
                              _selectedMinutes * 60
                          ? null
                          : _reset,
                      child: const Text('Reset timer'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.alternate),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const QuestwellStatusPixelBadge(
                    kind: 'campfire',
                    size: 34,
                    active: false,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'If 15 minutes feels like too much, leave. The point is to help you begin, not trap you in a timer.',
                      style: theme.bodyMedium.override(
                        font: GoogleFonts.inter(),
                        color: theme.secondaryText,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
