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
  late final ValueNotifier<int> _secondsRemaining.value = ValueNotifier<int>(25 * 60);
  bool _running = false;
  bool _finished = false;
  DateTime? _deadline;

  @override
  void dispose() {
    _timer?.cancel();
    _secondsRemaining.value.dispose();
    super.dispose();
  }

  void _choosePreset(int minutes) {
    if (_running) return;
    setState(() {
      _selectedMinutes = minutes;
      _secondsRemaining.value = minutes * 60;
      _finished = false;
    });
  }

  void _start() {
    if (_running || _secondsRemaining.value <= 0) return;

    _timer?.cancel();
    _deadline = DateTime.now().add(Duration(seconds: _secondsRemaining.value));

    setState(() {
      _running = true;
      _finished = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final remaining = _deadline!.difference(DateTime.now()).inMilliseconds;
      if (remaining <= 0) {
        timer.cancel();
        _deadline = null;
        setState(() {
          _secondsRemaining.value = 0;
          _running = false;
          _finished = true;
        });
        return;
      }

      _secondsRemaining.value = (remaining / 1000).ceil();
    });
  }

  void _pause() {
    _timer?.cancel();
    final remaining = _deadline?.difference(DateTime.now()).inMilliseconds ?? 0;
    _deadline = null;
    setState(() {
      _secondsRemaining.value =
          (remaining / 1000).ceil().clamp(0, _selectedMinutes * 60).toInt();
      _running = false;
      _finished = _secondsRemaining.value == 0;
    });
  }

  void _reset() {
    _timer?.cancel();
    _deadline = null;
    setState(() {
      _running = false;
      _finished = false;
      _secondsRemaining.value = _selectedMinutes * 60;
    });
  }

  String _timeLabel(int secondsRemaining) {
    final minutes = secondsRemaining ~/ 60;
    final seconds = secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        foregroundColor: theme.primaryText,
        title: Text(
          'EXPEDITION',
          style: theme.titleLarge.override(
            font: GoogleFonts.pressStart2p(
              fontWeight: FontWeight.w700,
            ),
            fontSize: 14,
            letterSpacing: .4,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            Text(
              'SET OUT. DO ONE THING.',
              style: theme.headlineSmall.override(
                font: GoogleFonts.pressStart2p(
                  fontWeight: FontWeight.w700,
                ),
                fontSize: 14,
                letterSpacing: .3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'A quiet focus session with no streaks, rankings, or guilt.',
              style: theme.bodyMedium.override(
                font: GoogleFonts.roboto(),
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
            QuestwellRetroPanel(
              padding: const EdgeInsets.all(18),
              accent: const Color(0xFF8E6B35),
              background: const Color(0xFF15141B),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF17151A),
                      border: Border.all(
                        color: const Color(0xFF8E6B35),
                        width: 3,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x55322018),
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _finished
                            ? const QuestwellStatusPixelBadge(
                                kind: 'campfire',
                                size: 38,
                                active: true,
                              )
                            : const QuestwellNavPixelIcon(
                                kind: 'expedition',
                                size: 38,
                              ),
                        const SizedBox(height: 10),
                        ValueListenableBuilder<int>(
                          valueListenable: _secondsRemaining,
                          builder: (context, secondsRemaining, child) {
                            final progress = _selectedMinutes == 0
                                ? 0.0
                                : 1 -
                                    (secondsRemaining /
                                        (_selectedMinutes * 60));
                            return Column(
                              children: [
                                Text(
                                  _timeLabel(secondsRemaining),
                                  style: theme.displaySmall.override(
                                    font: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w800,
                                    ),
                                    color: const Color(0xFFF2E7CE),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                QuestwellPixelMeter(
                                  value: progress,
                                  kind: 'xp',
                                  height: 20,
                                  segments: 16,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 9),
                        Text(
                          _finished
                              ? 'EXPEDITION COMPLETE'
                              : _running
                                  ? 'STAY WITH THE QUEST'
                                  : 'READY WHEN YOU ARE',
                          style: theme.labelSmall.override(
                            font: GoogleFonts.roboto(
                              fontWeight: FontWeight.w800,
                            ),
                            color: const Color(0xFFD8C7A3),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
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
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!_running && !_finished) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _secondsRemaining.value ==
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
            QuestwellRetroPanel(
              padding: const EdgeInsets.all(14),
              accent: const Color(0xFF8E6B35),
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
                        font: GoogleFonts.roboto(),
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
