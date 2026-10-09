import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Reveal a room only after its selected background and catalog images decode.
/// Keep children mounted so image requests and the shared cache are reused.
class QuestwellHearthImageGate extends StatefulWidget {
  const QuestwellHearthImageGate(
      {super.key, required this.images, required this.child});
  final List<ImageProvider> images;
  final Widget child;
  @override
  State<QuestwellHearthImageGate> createState() => _HearthImageGateState();
}

class _HearthImageGateState extends State<QuestwellHearthImageGate> {
  int _generation = 0;
  int _retryRevision = 0;
  Timer? _deadline;
  bool _ready = false;
  bool _failed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  @override
  void didUpdateWidget(covariant QuestwellHearthImageGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.images, widget.images)) _load();
  }

  void _load() {
    final generation = ++_generation;
    _deadline?.cancel();
    _deadline = Timer(const Duration(seconds: 25), () {
      if (mounted && generation == _generation) setState(() => _failed = true);
    });
    _ready = false;
    _failed = false;
    final loads = widget.images.map((provider) async {
      Object? failure;
      await precacheImage(provider, context, onError: (error, stack) {
        failure = error;
      });
      if (failure != null) throw failure!;
    });
    Future.wait(loads).then((_) {
      if (mounted && generation == _generation) {
        _deadline?.cancel();
        setState(() {
          _ready = true;
          _failed = false;
        });
      }
    }, onError: (Object error, StackTrace stack) {
      if (mounted && generation == _generation) {
        _deadline?.cancel();
        setState(() => _failed = true);
      }
    });
  }

  Future<void> _retry() async {
    final generation = _generation;
    await Future.wait(widget.images.map((image) => image.evict()));
    if (!mounted || generation != _generation) return;
    setState(() {
      _retryRevision++;
      _load();
    });
  }

  @override
  void dispose() {
    _deadline?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        ExcludeSemantics(
            excluding: !_ready,
            child: IgnorePointer(
                ignoring: !_ready,
                child: Opacity(
                    opacity: _ready ? 1 : 0,
                    child: KeyedSubtree(
                        key: ValueKey(_retryRevision), child: widget.child)))),
        if (!_ready)
          ColoredBox(
              color: const Color(0xFF1D3035),
              child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(
                    _failed
                        ? 'Some room artwork could not load.'
                        : 'Preparing your Hearth…',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFF2E6C7))),
                if (_failed)
                  TextButton(
                      onPressed: _retry, child: const Text('Retry artwork')),
              ]))),
      ]);
}
