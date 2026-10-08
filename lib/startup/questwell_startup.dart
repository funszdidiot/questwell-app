import '../widgets/questwell_app_style.dart';
import '../widgets/questwell_hearth_material.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import 'questwell_bootstrap.dart';
export 'questwell_bootstrap.dart' show StartupFailure;

/// Draws before async initialization and never creates application routes until
/// startup succeeds. Slow work is not cancelled or retried concurrently.
class QuestwellStartup extends StatefulWidget {
  const QuestwellStartup({
    super.key,
    required this.initialize,
    required this.appBuilder,
  });

  final Future<void> Function() initialize;
  final WidgetBuilder appBuilder;

  @override
  State<QuestwellStartup> createState() => _QuestwellStartupState();
}

class _QuestwellStartupState extends State<QuestwellStartup> {
  Timer? _slowTimer;
  bool _running = false;
  bool _ready = false;
  bool _slow = false;
  StartupFailure? _failure;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    if (_running) return;
    setState(() {
      _running = true;
      _slow = false;
      _failure = null;
    });
    _slowTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) setState(() => _slow = true);
    });
    try {
      await widget.initialize();
      if (mounted) setState(() => _ready = true);
    } catch (error) {
      // Raw SDK/storage exceptions can contain sensitive callback information.
      if (mounted) {
        setState(
          () => _failure = error is StartupFailure
              ? error
              : const StartupFailure(restartRequired: true),
        );
      }
    } finally {
      _slowTimer?.cancel();
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return widget.appBuilder(context);
    final failed = _failure != null;
    final canRetry = failed && !_failure!.restartRequired;
    final title = failed
        ? 'Questwell couldn’t open'
        : _slow
            ? 'Taking longer than expected'
            : 'Opening Questwell…';
    final message = canRetry
        ? 'Your local settings couldn’t load. Try again to continue.'
        : failed
            ? 'Close and reopen Questwell. In a browser, reload this page. If you opened a sign-in link, you may need to open it again.'
            : _slow
                ? 'You can keep waiting, or close and reopen Questwell. In a browser, reload this page.'
                : 'Getting your adventure ready.';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Questwell',
      theme: QuestwellAppStyle.fallbackTheme(),
      home: QuestwellScaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: QuestwellHearthFrame(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!failed && !_slow) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 24),
                    ],
                    Semantics(
                      liveRegion: true,
                      header: true,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(message, textAlign: TextAlign.center),
                    if (canRetry) ...[
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _start,
                        child: const Text('Try again'),
                      ),
                    ],
                  ],
                )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
