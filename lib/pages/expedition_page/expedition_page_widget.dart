import '/flutter_flow/flutter_flow_theme.dart';
import '/widgets/questwell_pixel_art.dart';
import '/widgets/questwell_expedition_scene.dart';
import '/widgets/questwell_typography.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class ExpeditionPageWidget extends StatefulWidget {
  const ExpeditionPageWidget({
    super.key,
    this.initialDuration = const Duration(minutes: 25),
    this.clock,
  });

  /// Also supports a short local-only session in the development review.
  final Duration initialDuration;
  @visibleForTesting
  final DateTime Function()? clock;

  static String routeName = 'ExpeditionPage';
  static String routePath = '/expedition';

  @override
  State<ExpeditionPageWidget> createState() => _ExpeditionPageWidgetState();
}

class _ExpeditionPageWidgetState extends State<ExpeditionPageWidget> {
  Timer? _timer;
  int _selectedMinutes = 25;
  late final ValueNotifier<int> _secondsRemaining;
  late int _sessionSeconds;
  bool _campfirePreloaded = false;
  bool _running = false;
  bool _finished = false;
  bool _started = false;
  bool _sceneMotion = true;
  DateTime? _deadline;

  DateTime _now() => widget.clock?.call() ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _sessionSeconds = widget.initialDuration.inSeconds;
    if (_sessionSeconds < 1) _sessionSeconds = 1;
    _selectedMinutes = _sessionSeconds % 60 == 0 ? _sessionSeconds ~/ 60 : 0;
    _secondsRemaining = ValueNotifier<int>(_sessionSeconds);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_campfirePreloaded) {
      _campfirePreloaded = true;
      precacheImage(const AssetImage('assets/images/questwell_campfire_rest_v1.webp'), context);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _secondsRemaining.dispose();
    super.dispose();
  }

  void _choosePreset(int minutes) {
    if (_running) return;
    setState(() {
      _started = false;
      _selectedMinutes = minutes;
      _sessionSeconds = minutes * 60;
      _secondsRemaining.value = _sessionSeconds;
      _finished = false;
    });
  }

  void _start() {
    if (_running || _secondsRemaining.value <= 0) return;

    _timer?.cancel();
    _deadline = _now().add(Duration(seconds: _secondsRemaining.value));

    setState(() {
      _started = true;
      _running = true;
      _finished = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final remaining = _deadline!.difference(_now()).inMilliseconds;
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
    final remaining = _deadline?.difference(_now()).inMilliseconds ?? 0;
    _deadline = null;
    setState(() {
      _secondsRemaining.value =
          (remaining / 1000).ceil().clamp(0, _sessionSeconds).toInt();
      _running = false;
      _finished = _secondsRemaining.value == 0;
    });
  }

  void _reset() {
    _timer?.cancel();
    _deadline = null;
    setState(() {
      _started = false;
      _running = false;
      _finished = false;
      _secondsRemaining.value = _sessionSeconds;
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
        actions: [IconButton(
          tooltip: _sceneMotion ? 'Pause scenery' : 'Animate scenery',
          onPressed: () => setState(() => _sceneMotion = !_sceneMotion),
          icon: Icon(_sceneMotion ? Icons.motion_photos_pause_outlined : Icons.motion_photos_on_outlined),
        )],
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
        child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600), child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            Text(
              _finished ? 'REST BY THE FIRE.' : 'SET OUT. DO ONE THING.',
              style: theme.headlineSmall.override(
                font: GoogleFonts.pressStart2p(
                  fontWeight: FontWeight.w700,
                ),
                fontSize: 14,
                letterSpacing: .3,
              ),
            ),
            const SizedBox(height: 18),
            AnimatedSwitcher(
              key: const ValueKey('expedition-scene-transition'),
              duration: MediaQuery.disableAnimationsOf(context) || !_sceneMotion
                  ? Duration.zero : const Duration(milliseconds: 2200),
              switchInCurve: Curves.easeInOutSine,
              switchOutCurve: Curves.easeInOutSine,
              // Keep the outgoing scene opaque behind the incoming fade.
              // This avoids the dark dip of fading both layers at once.
              transitionBuilder: (child, animation) => AnimatedBuilder(
                animation: animation,
                child: child,
                builder: (context, scene) => Opacity(
                  opacity: animation.status == AnimationStatus.reverse
                      ? 1.0 : animation.value,
                  child: scene,
                ),
              ),
              child: QuestwellExpeditionScene(
                key: ValueKey(_finished),
                campfire: _finished,
                motion: _sceneMotion,
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF171F1B),
                border: Border.all(color: const Color(0xFF8E7548), width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
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
                            final progress = _sessionSeconds == 0
                                ? 0.0
                                : 1 -
                                    (secondsRemaining /
                                        (_sessionSeconds));
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
                                  : _started
                                      ? 'REST. THE PATH CAN WAIT.'
                                      : 'READY WHEN YOU ARE',
                          textAlign: TextAlign.center,
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
                          labelStyle: QuestwellTypography.control(
                            color: _selectedMinutes == minutes
                                ? const Color(0xFFFFE8B4)
                                : const Color(0xFFDBE3DA)),
                          selectedColor: const Color(0xFF2A4C3B),
                          backgroundColor: const Color(0xFF202E26),
                          disabledColor: const Color(0xFF24332B),
                          checkmarkColor: const Color(0xFFE4C586),
                          side: BorderSide(
                            color: _selectedMinutes == minutes
                                ? const Color(0xFFBFA168)
                                : const Color(0xFF52604F)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                                ? 'Return to trail'
                                : _running
                                    ? 'Pause'
                                    : _started
                                        ? 'Resume Expedition'
                                        : 'Begin Expedition',
                          ),
                          style: FilledButton.styleFrom(
                            textStyle: QuestwellTypography.control(),
                            backgroundColor: const Color(0xFF244C3E),
                            foregroundColor: const Color(0xFFFFF0C9),
                            side: const BorderSide(color: Color(0xFFBFA168), width: 1.5),
                            elevation: 0,
                            minimumSize: const Size.fromHeight(52),
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
                      style: TextButton.styleFrom(
                        textStyle: QuestwellTypography.control(),
                        foregroundColor: const Color(0xFFE4C586),
                        disabledForegroundColor: const Color(0xFF8C978D)),
                      onPressed: _started ? _reset : null,
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
                      _finished
                          ? 'A quest well traveled. Rest by the fire, adventurer. Every small victory is worth celebrating.'
                          : _running
                              ? 'Steady onward, adventurer. One task, one stretch of trail. Every small step is a little victory.'
                              : _started
                                  ? 'Take a breath, adventurer. Your progress is safe, and the path will be here when you’re ready.'
                                  : 'You don’t need to see the whole path to take the first step. Choose one small task, adventurer. Your journey begins here.',
                      style: theme.bodyMedium.override(
                        font: GoogleFonts.roboto(),
                        color: const Color(0xFFF2E7CE),
                        fontSize: 15,
                        lineHeight: 1.5,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ))),
      ),
    );
  }
}
