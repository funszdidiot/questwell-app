import 'dart:async';
import 'package:flutter/material.dart';

/// Keeps a requested scene identifiable while its artwork is downloading.
/// The child shares the provider's cache entry; no second download is started.
class QuestwellSceneLoad extends StatefulWidget {
  const QuestwellSceneLoad({
    super.key,
    required this.image,
    required this.label,
    required this.child,
    this.timeout = const Duration(seconds: 12),
  });

  final ImageProvider image;
  final String label;
  final Widget child;
  final Duration timeout;

  @override
  State<QuestwellSceneLoad> createState() => _QuestwellSceneLoadState();
}

class _QuestwellSceneLoadState extends State<QuestwellSceneLoad> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  ImageConfiguration? _configuration;
  Timer? _timer;
  int _request = 0;
  bool _ready = false;
  bool _failed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final configuration = createLocalImageConfiguration(context);
    if (configuration != _configuration) {
      _configuration = configuration;
      _resolve();
    }
  }

  @override
  void didUpdateWidget(covariant QuestwellSceneLoad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) _resolve();
  }

  void _detach() {
    _timer?.cancel();
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    _stream = null;
    _listener = null;
  }

  void _resolve() {
    _detach();
    final request = ++_request;
    _ready = false;
    _failed = false;
    _timer = Timer(widget.timeout, () {
      if (mounted && request == _request && !_ready) {
        setState(() => _failed = true);
      }
    });
    _stream = widget.image.resolve(_configuration!);
    _listener = ImageStreamListener((info, synchronous) {
      info.dispose();
      if (!mounted || request != _request) return;
      _timer?.cancel();
      setState(() {
        _ready = true;
        _failed = false;
      });
    }, onError: (Object error, StackTrace? stack) {
      if (!mounted || request != _request) return;
      _timer?.cancel();
      setState(() => _failed = true);
    });
    _stream!.addListener(_listener!);
  }

  Future<void> _retry() async {
    final request = ++_request;
    _detach();
    setState(() => _failed = false);
    try {
      await widget.image.evict(configuration: _configuration!);
      if (!mounted || request != _request) return;
      setState(_resolve);
    } catch (_) {
      if (mounted && request == _request) {
        setState(() => _failed = true);
      }
    }
  }

  @override
  void dispose() {
    ++_request;
    _detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        // Recreate the image child after Retry so it subscribes to the fresh
        // cache entry, rather than keeping a failed image stream.
        ExcludeSemantics(
            excluding: !_ready,
            child: IgnorePointer(
                ignoring: !_ready,
                child: KeyedSubtree(
                    key: ValueKey(_request), child: widget.child))),
        if (!_ready)
          Positioned.fill(
              child: ColoredBox(
                  color: const Color(0xFF192F2C),
                  child: Center(
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Semantics(
                              liveRegion: true,
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                        child: Text(
                                            _failed
                                                ? '${widget.label} could not load.'
                                                : 'Loading ${widget.label}…',
                                            textAlign: TextAlign.center)),
                                    if (_failed)
                                      TextButton.icon(
                                          onPressed: _retry,
                                          icon: const Icon(Icons.refresh),
                                          label: const Text('Retry artwork'))
                                    else ...[
                                      const SizedBox(height: 12),
                                      const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2)),
                                    ]
                                  ]))))))
      ]);
}
